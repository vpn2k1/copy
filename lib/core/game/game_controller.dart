import 'dart:math' as math;

import '../classroom_layout.dart';
import 'event_scheduler.dart';
import 'game_rules.dart';
import 'game_state.dart';
import 'game_status.dart';
import 'level_config.dart';
import 'level_event.dart';
import 'levels.dart';
import 'skill_config.dart';
import 'skill_controller.dart';
import 'skills.dart';
import 'teacher_fsm.dart';
import 'teacher_squad.dart';
import 'teacher_state.dart';

/// Trần nghi ngờ trong lúc hướng dẫn đầu màn 1 (không bị bắt oan khi tập).
const tutorialSuspicionCap = 50.0;

/// Thời gian cô đứng nhìn để hỏi bài, đủ trùm hết pha hỏi.
const questionLookSeconds = 8.0;

/// Chủ sở hữu duy nhất của [GameState]. Giao diện gửi lệnh (start, press,
/// release, selectSkill, answer, phản ứng sự kiện, pause, resume, restart)
/// và gọi [tick] mỗi khung hình; mọi luật chơi nằm ở đây, không phụ thuộc
/// Flutter hay Flame. Nút "cóp" ([PlayerAction.cheat]) dùng kỹ năng đang chọn.
class GameController {
  GameController({
    required int seed,
    this.level = levelOne,
    this.catalog = allSkills,
    this.playerX = ClassroomLayout.playerSeatX,
  }) {
    _reset(seed);
  }

  final LevelConfig level;

  /// Bảng kỹ năng để tra theo `level.skillIds` (test có thể thay).
  final List<SkillConfig> catalog;

  /// Vị trí người chơi trên trục x thế giới, dùng cho phát hiện.
  final double playerX;

  late TeacherSquad _squad;
  late SkillController _skills;
  late EventScheduler _events;
  late GameState _state;

  GameState get state => _state;

  /// Bắt đầu ván (chỉ từ trạng thái ready).
  void start() {
    if (_state.status != GameStatus.ready) return;
    _state = _state.copyWith(status: GameStatus.running);
  }

  /// Tạm dừng: thả mọi nút, hủy kỹ năng đang thi triển (hoàn hồi chiêu),
  /// đóng băng mô phỏng.
  void pause() {
    if (!_state.isRunning) return;
    _skills.cancel(keepCooldown: false);
    _state = _state
        .copyWith(status: GameStatus.paused, skills: _skills.snapshot)
        .withHeldAction(null);
  }

  /// Chạy tiếp sau khi người chơi chủ động bấm tiếp tục.
  void resume() {
    if (_state.status != GameStatus.paused) return;
    _state = _state.copyWith(status: GameStatus.running);
  }

  /// Chơi lại từ đầu với [seed] mới (mặc định giữ seed cũ) và chạy ngay.
  void restart({int? seed}) {
    _reset(seed ?? _state.seed);
    start();
  }

  /// Chọn kỹ năng cho nút cóp.
  void selectSkill(String id) {
    if (_state.status.isFinished) return;
    _skills.select(id);
    _publish();
  }

  /// Chọn đáp án cho câu đố của kỹ năng đang thi triển.
  void answer(int index) {
    if (!_state.isRunning) return;
    _skills.answer(index);
    _publish();
  }

  /// Trả lời câu hỏi "Làm được mấy câu rồi?" của cô.
  void acknowledgeQuestion() {
    if (!_state.isRunning) return;
    _applyEventTick(_events.acknowledge());
    _publish();
  }

  /// Nhặt tờ giấy bị gió thổi rơi.
  void pickUpPaper() {
    if (!_state.isRunning) return;
    _events.pickUpPaper();
    _publish();
  }

  /// Gợi ý lệch mã đề: [isSelfWrite] tự làm lấy nửa số điểm một cách an
  /// toàn; ngược lại hỏi lại bạn (kỹ năng được dùng lại ngay).
  void resolveHint({required bool isSelfWrite}) {
    if (!_state.isRunning) return;
    final hint = _events.takeHint();
    if (hint == null) return;
    if (isSelfWrite) {
      _state = _state.copyWith(
        progress: GameRules.clamp(_state.progress + hint.amount / 2),
      );
    } else {
      _skills.refund(hint.skillId);
    }
    _publish();
    _resolveEnd();
  }

  /// Nhấn giữ một hành động. Hành động nhấn sau thay hành động trước; viết
  /// bài hoặc giả vờ sẽ dừng kỹ năng đang dùng.
  void press(PlayerAction action) {
    if (!_state.isRunning) return;
    if (action == PlayerAction.cheat) {
      _skills.press(isWatching: _isAnyWatching());
    } else {
      _skills.cancel(keepCooldown: true);
    }
    _state = _state.copyWith(skills: _skills.snapshot).withHeldAction(action);
  }

  /// Thả một hành động. Bỏ qua nếu đang giữ hành động khác.
  void release(PlayerAction action) {
    if (_state.heldAction != action) return;
    if (action == PlayerAction.cheat) _skills.release();
    _state = _state.copyWith(skills: _skills.snapshot).withHeldAction(null);
  }

  /// Tiến mô phỏng [dt] giây (bị giới hạn bởi `GameTuning.maxStep`).
  GameState tick(double dt) {
    if (!_state.isRunning) return _state;
    final step = dt.clamp(0.0, GameTuning.maxStep).toDouble();
    if (step == 0) return _state;
    final before = _state;
    final cheatingBefore = before.isSeenCheating;
    var teachers = _squad.update(
      before.teachers,
      step,
      suspicion: before.suspicion,
      sawCheating: [for (final seen in before.seenBy) seen && cheatingBefore],
    );
    final remaining = math.max(0.0, before.remainingSeconds - step);
    final event = _events.update(
      step,
      remainingSeconds: remaining,
      isUsingPaper: paperSkillIds.contains(_skills.activeSkillId),
      isSettled: _squad.isSettled(teachers),
    );
    teachers = _teachersAfter(event.request, teachers);
    final seenBy = _squad.seeing(teachers, playerX: playerX);
    final observers = seenBy.where((seen) => seen).length;
    final skill = _skills.tick(step, isSeen: observers > 0);
    var gain =
        GameRules.baseGain(before.heldAction) * step +
        skill.progressRate * step;
    final source = skill.sourceId;
    if (source == null ||
        !_events.interceptAllyGain(source, skill.instantGain)) {
      gain += skill.instantGain;
    }
    var suspicion =
        before.suspicion +
        (GameRules.suspicionRate(level, before.heldAction, skill, observers) +
                event.suspicionRate) *
            step +
        skill.extraRisk +
        event.suspicionBump +
        GameRules.inspectBumps(before.teachers, teachers);
    final tutorialLeft = math.max(0.0, before.tutorialRemaining - step);
    if (tutorialLeft > 0) suspicion = math.min(suspicion, tutorialSuspicionCap);
    _state = before.copyWith(
      remainingSeconds: remaining,
      progress: GameRules.clamp(before.progress + gain),
      suspicion: GameRules.clamp(suspicion),
      teachers: teachers,
      seenBy: seenBy,
      skills: _skills.snapshot,
      event: _events.snapshot,
      tutorialRemaining: tutorialLeft,
      isSeenCheating: observers > 0 && skill.isCheating,
    );
    _resolveEnd();
    return _state;
  }

  void _reset(int seed) {
    _squad = TeacherSquad(
      seed: seed,
      teacherSpeed: level.teacherSpeed,
      count: level.teacherCount,
      watchWarningSeconds: level.watchWarningSeconds,
    );
    _skills = SkillController(
      random: math.Random(seed ^ 0x5EED),
      available: [for (final id in level.skillIds) _lookup(id)],
    );
    _events = EventScheduler(level.specialEventId);
    final teachers = _squad.start();
    _state = GameState(
      levelId: level.id,
      seed: seed,
      status: GameStatus.ready,
      progress: 0,
      suspicion: 0,
      remainingSeconds: level.durationSeconds.toDouble(),
      teachers: teachers,
      seenBy: [for (final _ in teachers) false],
      skills: _skills.snapshot,
      event: _events.snapshot,
      tutorialRemaining: level.tutorialSeconds,
    );
  }

  SkillConfig _lookup(String id) {
    return catalog.firstWhere(
      (skill) => skill.id == id,
      orElse: () => skillById(id),
    );
  }

  bool _isAnyWatching() =>
      _state.teachers.any((teacher) => teacher.isWatchingClass);

  void _publish() {
    _state = _state.copyWith(skills: _skills.snapshot, event: _events.snapshot);
  }

  void _applyEventTick(EventTick tick) {
    final teachers = _teachersAfter(tick.request, _state.teachers);
    _state = _state.copyWith(
      teachers: teachers,
      suspicion: GameRules.clamp(_state.suspicion + tick.suspicionBump),
    );
  }

  List<TeacherState> _teachersAfter(
    EventRequest request,
    List<TeacherState> teachers,
  ) {
    switch (request) {
      case EventRequest.lookAtPlayer:
        return _squad.command(
          teachers,
          0,
          TeacherMode.lookLeft,
          dwell: questionLookSeconds,
        );
      case EventRequest.releaseTeacher:
        return _squad.command(teachers, 0, TeacherMode.idle);
      case EventRequest.dropPaper:
        _skills.cancel(keepCooldown: true);
        return teachers;
      case EventRequest.swapLanes:
        return _squad.swapLanes(teachers);
      case EventRequest.bossPace:
        _squad.pace = TeacherPace.boss;
        return teachers;
      case EventRequest.none:
        return teachers;
    }
  }

  /// Thứ tự ưu tiên tại biên tick: bị bắt > hết giờ > hoàn thành.
  void _resolveEnd() {
    final status = _endStatus();
    if (status == null) return;
    var teachers = _state.teachers;
    if (status == GameStatus.lostCaught) {
      teachers = _squad.catchPlayer(teachers);
    }
    _skills.cancel(keepCooldown: false);
    _state = _state
        .copyWith(status: status, teachers: teachers, skills: _skills.snapshot)
        .withHeldAction(null);
  }

  GameStatus? _endStatus() => GameRules.endStatus(
    suspicion: _state.suspicion,
    remainingSeconds: _state.remainingSeconds,
    progress: _state.progress,
  );
}

import 'package:dung_de_thay_thay/core/animation/teacher_rig.dart';
import 'package:dung_de_thay_thay/core/game/game_controller.dart';
import 'package:dung_de_thay_thay/core/game/game_state.dart';
import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/core/game/level_config.dart';
import 'package:dung_de_thay_thay/core/game/levels.dart';
import 'package:dung_de_thay_thay/core/game/scene_pose.dart';

/// Chiến thuật của người chơi giả lập: chọn hành động theo trạng thái thấy
/// được trên màn hình.
typedef Strategy = PlayerAction? Function(GameState state);

/// Chạy một ván từ đầu tới khi kết thúc với bước [dt] cố định.
GameState playOut(
  int seed,
  Strategy strategy, {
  double dt = 1 / 60,
  LevelConfig level = levelOne,
}) {
  final controller = GameController(seed: seed, level: level)..start();
  PlayerAction? held;
  while (!controller.state.status.isFinished) {
    final next = strategy(controller.state);
    if (next != held) {
      if (held != null) controller.release(held);
      if (next != null) controller.press(next);
      held = next;
    }
    controller.tick(dt);
  }
  return controller.state;
}

PlayerAction? doNothing(GameState state) => null;

PlayerAction? alwaysWrite(GameState state) => PlayerAction.write;

PlayerAction? alwaysCheat(GameState state) => PlayerAction.cheat;

/// Người chơi cẩn thận: chỉ nhìn biểu tượng trên đầu cô (không đọc AI), phản
/// ứng trễ [reaction] giây. Có biểu tượng thì viết bài (hoặc giả vờ khi nghi
/// ngờ cao), không có thì cóp; kỹ năng đang hồi chiêu thì viết bài chờ.
Strategy carefulPlayer({double reaction = 0.3}) {
  var cueSince = double.negativeInfinity;
  var lastCue = TeacherCue.none;
  var clock = 0.0;
  return (state) {
    clock += 1 / 60;
    final cue = teacherCueFor(state.teacher);
    final isAlert = cue != TeacherCue.none;
    if (isAlert && lastCue == TeacherCue.none) cueSince = clock;
    lastCue = cue;
    final reacted = isAlert && clock - cueSince >= reaction;
    final skills = state.skills;
    final canCheat = skills.isHolding || skills.isReady(skills.selectedId);
    if (!reacted && canCheat) return PlayerAction.cheat;
    if (!reacted) return PlayerAction.write;
    if (state.suspicion > 30) return PlayerAction.hide;
    return PlayerAction.write;
  };
}

/// Người chơi khéo: như [carefulPlayer] nhưng chọn kỹ năng giữ mạnh nhất
/// đang sẵn sàng, phản ứng với sự kiện (trả lời cô, nhặt giấy, tự làm khi
/// gợi ý lệch mã đề) và giả vờ khi nghi ngờ cao.
GameState playSmart(
  GameController controller, {
  double reaction = 0.3,
  double dt = 1 / 60,
}) {
  const holdPriority = ['cheat_sheet', 'ruler', 'peek'];
  controller.start();
  var clock = 0.0;
  var cueSince = double.negativeInfinity;
  var wasAlert = false;
  PlayerAction? held;
  void hold(PlayerAction? next) {
    if (next == held) return;
    if (held != null) controller.release(held!);
    if (next != null) controller.press(next);
    held = next;
  }

  while (!controller.state.status.isFinished) {
    clock += dt;
    final state = controller.state;
    final event = state.event;
    if (event.isAskingPlayer) controller.acknowledgeQuestion();
    if (event.isPaperDropped) controller.pickUpPaper();
    if (event.pendingHint != null) controller.resolveHint(isSelfWrite: true);
    final isAlert = state.teachers.any(
      (teacher) => teacherCueFor(teacher) != TeacherCue.none,
    );
    if (isAlert && !wasAlert) cueSince = clock;
    wasAlert = isAlert;
    final reacted = isAlert && clock - cueSince >= reaction;
    final skills = controller.state.skills;
    if (reacted) {
      if (state.suspicion > 30) {
        hold(PlayerAction.hide);
      } else {
        hold(PlayerAction.write);
      }
    } else if (skills.isHolding) {
      hold(PlayerAction.cheat);
    } else {
      final ready = holdPriority.where(
        (id) => skills.availableIds.contains(id) && skills.isReady(id),
      );
      if (ready.isEmpty) {
        hold(PlayerAction.write);
      } else {
        if (held == PlayerAction.cheat) hold(null);
        controller.selectSkill(ready.first);
        hold(PlayerAction.cheat);
      }
    }
    controller.tick(dt);
  }
  return controller.state;
}

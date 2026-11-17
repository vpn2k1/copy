import 'game_status.dart';
import 'level_event.dart';
import 'skill_runtime.dart';
import 'teacher_state.dart';

/// Ảnh chụp bất biến của ván thi sau mỗi tick. Giao diện chỉ đọc, không sửa.
class GameState {
  const GameState({
    required this.levelId,
    required this.seed,
    required this.status,
    required this.progress,
    required this.suspicion,
    required this.remainingSeconds,
    required this.teachers,
    required this.skills,
    this.seenBy = const [],
    this.event = EventSnapshot.none,
    this.tutorialRemaining = 0,
    this.heldAction,
    this.isSeenCheating = false,
  });

  final int levelId;
  final int seed;
  final GameStatus status;

  /// Tiến độ bài thi 0..100.
  final double progress;

  /// Độ nghi ngờ 0..100.
  final double suspicion;
  final double remainingSeconds;

  /// Các cô trong lớp (1 hoặc 2). Cô đầu tiên là cô chính.
  final List<TeacherState> teachers;

  /// Cô thứ i đang nhìn thấy người chơi.
  final List<bool> seenBy;
  final SkillSnapshot skills;
  final EventSnapshot event;

  /// Giây hướng dẫn còn lại (màn 1); 0 khi hết hướng dẫn.
  final double tutorialRemaining;

  /// Hành động đang giữ, null khi không giữ nút nào.
  final PlayerAction? heldAction;

  /// Có cô đang nhìn thấy người chơi cóp.
  final bool isSeenCheating;

  TeacherState get teacher => teachers.first;

  /// Có ít nhất một cô đang nhìn về phía người chơi.
  bool get isPlayerSeen => seenBy.contains(true);

  bool get isRunning => status == GameStatus.running;

  GameState copyWith({
    GameStatus? status,
    double? progress,
    double? suspicion,
    double? remainingSeconds,
    List<TeacherState>? teachers,
    List<bool>? seenBy,
    SkillSnapshot? skills,
    EventSnapshot? event,
    double? tutorialRemaining,
    bool? isSeenCheating,
  }) {
    return GameState(
      levelId: levelId,
      seed: seed,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      suspicion: suspicion ?? this.suspicion,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      teachers: teachers ?? this.teachers,
      seenBy: seenBy ?? this.seenBy,
      skills: skills ?? this.skills,
      event: event ?? this.event,
      tutorialRemaining: tutorialRemaining ?? this.tutorialRemaining,
      heldAction: heldAction,
      isSeenCheating: isSeenCheating ?? this.isSeenCheating,
    );
  }

  /// Bản sao với hành động đang giữ mới (kể cả null).
  GameState withHeldAction(PlayerAction? action) {
    return GameState(
      levelId: levelId,
      seed: seed,
      status: status,
      progress: progress,
      suspicion: suspicion,
      remainingSeconds: remainingSeconds,
      teachers: teachers,
      seenBy: seenBy,
      skills: skills,
      event: event,
      tutorialRemaining: tutorialRemaining,
      heldAction: action,
      isSeenCheating: isSeenCheating,
    );
  }
}

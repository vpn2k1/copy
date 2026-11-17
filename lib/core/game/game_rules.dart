import 'game_status.dart';
import 'level_config.dart';
import 'skill_runtime.dart';
import 'teacher_state.dart';

/// Các công thức luật chơi mỗi tick (03_GAMEPLAY_SYSTEMS), tách khỏi
/// `GameController` để dễ đọc và test.
abstract final class GameRules {
  /// Tiến độ mỗi giây từ hành động cơ bản (chỉ viết bài mới có tiến độ).
  static double baseGain(PlayerAction? held) {
    if (held == PlayerAction.write) return GameTuning.writeRate;
    return 0;
  }

  /// Nghi ngờ thay đổi mỗi giây. Mỗi cô đang nhìn thấy cóp đều làm nghi ngờ
  /// tăng (hai cô thì gấp đôi).
  static double suspicionRate(
    LevelConfig level,
    PlayerAction? held,
    SkillTick skill,
    int observers,
  ) {
    final isSeen = observers > 0;
    if (skill.isCheating) {
      if (isSeen) {
        return level.suspicionPerSecond * skill.riskMultiplier * observers;
      }
      return GameTuning.cheatUnseenRisk;
    }
    if (skill.recoverRate > 0) return -skill.recoverRate;
    if (held == PlayerAction.hide) {
      if (isSeen) return -GameTuning.hideRecoverSeen;
      return -GameTuning.hideRecoverUnseen;
    }
    return -GameTuning.idleDecay;
  }

  /// Mỗi cô vừa tới soi bàn cộng nghi ngờ một lần.
  static double inspectBumps(
    List<TeacherState> before,
    List<TeacherState> after,
  ) {
    var bump = 0.0;
    for (var i = 0; i < after.length; i++) {
      final started =
          before[i].mode != TeacherMode.inspect &&
          after[i].mode == TeacherMode.inspect;
      if (started) bump += GameTuning.inspectRisk;
    }
    return bump;
  }

  static double clamp(double value) =>
      value.clamp(0.0, GameTuning.maxValue).toDouble();

  /// Thứ tự ưu tiên tại biên tick: bị bắt > hết giờ > hoàn thành.
  static GameStatus? endStatus({
    required double suspicion,
    required double remainingSeconds,
    required double progress,
  }) {
    if (suspicion >= GameTuning.maxValue) return GameStatus.lostCaught;
    if (remainingSeconds <= 0) return GameStatus.lostTime;
    if (progress >= GameTuning.maxValue) return GameStatus.won;
    return null;
  }
}

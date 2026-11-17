/// Kết quả một lần dùng kỹ năng, để giao diện hiện phản hồi trung thực.
enum SkillOutcome {
  /// Thành công, [SkillFeedback.amount] là % tiến độ hoặc điểm nghi ngờ giảm.
  success,

  /// Thất bại hài hước (bạn che bài, giấy bay…), không được cộng.
  failure,

  /// Còn hồi chiêu, [SkillFeedback.amount] là số giây còn lại.
  notReady,

  /// Kỹ năng chưa mở ở màn này.
  locked,

  /// Đang thi triển kỹ năng khác.
  busy,
}

class SkillFeedback {
  const SkillFeedback({
    required this.skillId,
    required this.outcome,
    required this.serial,
    this.amount = 0,
  });

  final String skillId;
  final SkillOutcome outcome;
  final double amount;

  /// Tăng dần mỗi lần có phản hồi mới, để giao diện biết khi nào hiện lại.
  final int serial;
}

/// Câu đố của kỹ năng chọn đáp án. Với `calculator`: [operands] là hai số
/// cộng và [options] là ba kết quả. Với `signal`: [operands] chứa số ngón tay
/// bạn giơ, [options] là 0, 1, 2 ứng với đáp án A, B, C.
class SkillChoice {
  const SkillChoice({
    required this.operands,
    required this.options,
    required this.correctIndex,
  });

  final List<int> operands;
  final List<int> options;
  final int correctIndex;
}

/// Kỹ năng đang thi triển (không áp dụng cho kỹ năng giữ).
class ActiveSkill {
  const ActiveSkill({
    required this.skillId,
    required this.elapsed,
    required this.castSeconds,
    this.choice,
    this.isPressed = false,
  });

  final String skillId;
  final double elapsed;
  final double castSeconds;
  final SkillChoice? choice;

  /// Ngón tay còn giữ nút (kỹ năng thả đúng nhịp).
  final bool isPressed;

  double get progress {
    if (castSeconds <= 0) return 1;
    return (elapsed / castSeconds).clamp(0.0, 1.0).toDouble();
  }
}

/// Ảnh chụp bất biến phần kỹ năng của ván thi.
class SkillSnapshot {
  const SkillSnapshot({
    required this.selectedId,
    required this.availableIds,
    required this.cooldowns,
    this.isHolding = false,
    this.active,
    this.feedback,
  });

  final String selectedId;
  final List<String> availableIds;

  /// Giây hồi chiêu còn lại theo id (chỉ chứa kỹ năng đang hồi).
  final Map<String, double> cooldowns;

  /// Đang giữ một kỹ năng loại giữ.
  final bool isHolding;
  final ActiveSkill? active;
  final SkillFeedback? feedback;

  double cooldownOf(String id) => cooldowns[id] ?? 0;
  bool isReady(String id) => cooldownOf(id) <= 0;
}

/// Tác động của kỹ năng trong một tick, để bộ luật cộng vào tiến độ và
/// nghi ngờ.
class SkillTick {
  const SkillTick({
    this.progressRate = 0,
    this.instantGain = 0,
    this.recoverRate = 0,
    this.riskMultiplier = 0,
    this.extraRisk = 0,
    this.sourceId,
  });

  static const none = SkillTick();

  /// % tiến độ mỗi giây (kỹ năng giữ).
  final double progressRate;

  /// % tiến độ cộng một lần ở tick này.
  final double instantGain;

  /// Điểm nghi ngờ giảm mỗi giây.
  final double recoverRate;

  /// > 0 khi người chơi đang làm việc mờ ám (chịu rủi ro theo hệ số này).
  final double riskMultiplier;

  /// Nghi ngờ cộng một lần (thất bại ngay trước mắt cô).
  final double extraRisk;

  /// Kỹ năng sinh ra [instantGain] (để sự kiện có thể chặn gợi ý của bạn).
  final String? sourceId;

  bool get isCheating => riskMultiplier > 0;
}

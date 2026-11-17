/// Hiệu ứng của kỹ năng (07_DATA_CONTRACTS). Không trộn tiến độ theo giây và
/// tiến độ một lần: mỗi kỹ năng đúng một loại.
enum SkillEffectKind {
  /// Giữ nút: [SkillConfig.value] là % tiến độ mỗi giây.
  holdProgress,

  /// Thi triển xong: cộng [SkillConfig.value] % một lần.
  instantProgress,

  /// Thi triển xong: cộng một trong [SkillConfig.randomOutcomes].
  randomProgress,

  /// Giảm tổng [SkillConfig.value] điểm nghi ngờ trong lúc thi triển.
  recoverSuspicion,

  /// Câu đố ngắn: chọn đúng thì cộng [SkillConfig.value] %.
  minigame,
}

/// Cách người chơi kích hoạt kỹ năng.
enum SkillTrigger {
  /// Giữ để dùng, thả để dừng (hồi chiêu tính từ lúc thả).
  hold,

  /// Bấm một lần, thi triển trong [SkillConfig.castSeconds].
  tap,

  /// Giữ rồi thả đúng lúc trong cửa sổ [SkillConfig.timingWindow].
  timedRelease,

  /// Bấm rồi chọn một trong ba đáp án trước khi hết [SkillConfig.castSeconds].
  choice,
}

/// Điều kiện thành công thêm của kỹ năng thi triển.
enum SkillCondition {
  none,

  /// Thành công theo xác suất [SkillConfig.successChance].
  chance,

  /// Bạn chỉ giúp khi cô không nhìn lớp lúc bấm.
  teacherNotWatching,

  /// Diễn chỉ hiệu quả trọn vẹn khi cô đang nhìn (diễn cho cô xem).
  teacherWatching,
}

/// Cấu hình một kỹ năng. Tên và câu thoại hiển thị nằm ở `Strings`, tra theo
/// [id]. Rủi ro luôn không âm: kỹ năng hồi phục dùng [SkillEffectKind]
/// `recoverSuspicion`, không dùng hệ số âm.
class SkillConfig {
  const SkillConfig({
    required this.id,
    required this.effectKind,
    required this.trigger,
    required this.value,
    required this.riskMultiplier,
    required this.cooldownSeconds,
    required this.unlockLevel,
    this.castSeconds = 0,
    this.condition = SkillCondition.none,
    this.successChance = 1,
    this.randomOutcomes = const [],
    this.timingWindow = const (0, 0),
  });

  final String id;
  final SkillEffectKind effectKind;
  final SkillTrigger trigger;
  final double value;
  final double riskMultiplier;
  final double cooldownSeconds;
  final int unlockLevel;
  final double castSeconds;
  final SkillCondition condition;
  final double successChance;
  final List<double> randomOutcomes;

  /// (bắt đầu, kết thúc) tính bằng giây sau khi nhấn, cho `timedRelease`.
  final (double, double) timingWindow;

  bool get isRecovery => effectKind == SkillEffectKind.recoverSuspicion;
  bool get isHold => trigger == SkillTrigger.hold;
}

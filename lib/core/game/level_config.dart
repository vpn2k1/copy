/// Cấu hình một màn chơi (xem 05_LEVELS). Tên màn hiển thị nằm ở `Strings`.
class LevelConfig {
  const LevelConfig({
    required this.id,
    required this.durationSeconds,
    required this.teacherCount,
    required this.teacherSpeed,
    required this.suspicionPerSecond,
    required this.skillIds,
    required this.specialEventId,
    this.tutorialSeconds = 0,
    this.watchWarningSeconds = 1.0,
  });

  final int id;
  final int durationSeconds;
  final int teacherCount;

  /// Hệ số tốc độ đi tuần của giáo viên (chỉ ảnh hưởng tốc độ bước đi).
  final double teacherSpeed;

  /// Nghi ngờ tăng mỗi giây khi bị nhìn thấy đang cóp, trước hệ số rủi ro.
  final double suspicionPerSecond;

  /// Kỹ năng dùng được ở màn này, theo thứ tự hiện trên thanh kỹ năng.
  final List<String> skillIds;

  /// Sự kiện đặc trưng của màn (xem `level_event.dart`).
  final String specialEventId;

  /// Số giây đầu ván có gợi ý hướng dẫn và nghi ngờ bị chặn trần (màn 1).
  final double tutorialSeconds;

  /// Thời gian báo trước ("…") trước khi cô nhìn lớp. Màn dễ trên 1 giây
  /// (tính cả lúc quay người), màn khó ngắn dần nhưng không bao giờ bằng 0.
  final double watchWarningSeconds;
}

/// Hằng số luật chơi dùng chung mọi màn (03_GAMEPLAY_SYSTEMS).
abstract final class GameTuning {
  /// Bước thời gian tối đa mỗi tick, tránh nhảy lớn sau khi app vào nền.
  static const double maxStep = 0.05;

  static const double maxValue = 100;

  /// Viết bài thật: tiến độ mỗi giây, an toàn.
  static const double writeRate = 0.5;

  /// Cóp khi giáo viên không nhìn vẫn có chút rủi ro (bạn bên cạnh, tiếng động).
  static const double cheatUnseenRisk = 1.5;

  /// Giảm nghi ngờ khi giả vờ: không bị nhìn / đang bị nhìn.
  static const double hideRecoverUnseen = 10;
  static const double hideRecoverSeen = 4;

  /// Giảm nghi ngờ tự nhiên khi viết bài hoặc không làm gì.
  static const double idleDecay = 3;

  /// Cộng nghi ngờ một lần mỗi khi giáo viên tới soi tận bàn.
  static const double inspectRisk = 8;
}

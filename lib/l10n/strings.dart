/// Mọi câu chữ hiển thị cho người dùng đi qua lớp này (xem rules/localization.md).
/// Thêm câu mới: thêm một `static const` có tên lowerCamelCase, không viết chuỗi trong widget.
abstract final class Strings {
  static const appTitle = 'Nhất Quỷ Nhì Ma';
  static const splashTitle = 'VPN Games';
  static const menuTitle = 'NHẤT QUỶ NHÌ MA';
  static const menuSubtitle = 'Đại Chiến Phòng Thi';
  static const playButton = 'VÀO LỚP';
  static const settingsButton = 'CÀI ĐẶT';
  static const settingsTitle = 'Cài đặt';
  static const muteLabel = 'Tắt tiếng';
  static const musicVolumeLabel = 'Âm nền lớp học';
  static const sfxVolumeLabel = 'Hiệu ứng âm thanh';
  static const settingsSavedNote =
      'Cài đặt và tiến trình được lưu trên máy, chơi offline.';
  static const backToMenu = 'Về menu';
  static const boardSlogan = 'TIÊN HỌC LỄ, HẬU HỌC VĂN';
  static const boardExamTitle = 'KIỂM TRA 15 PHÚT';
  static const boardSubject = 'Môn: Toán – Đề số 01';
  static const cameraGuideLabel = 'CAMERA: bàn bên TRÁI, tầm mắt học sinh';
  static const pausedTitle = 'TẠM DỪNG';
  static const resumeButton = 'TIẾP TỤC';
  static const timeStat = 'THỜI GIAN';
  static const progressMeter = 'TIẾN ĐỘ';
  static const suspicionMeter = 'NGHI NGỜ';
  static const teacherSeeing = '👀 CÔ ĐANG NHÌN';
  static const teacherAway = '✅ AN TOÀN';
  static const suspicionDanger = '🚨 SẮP BỊ BẮT!';
  static const writeButton = 'VIẾT BÀI';
  static const hideButton = 'GIẢ VỜ';
  static const cheatButton = 'CÓP BÀI 📝';
  static const pauseButton = 'Tạm dừng';
  static const holdHint = 'Nhấn giữ để dùng, thả ra để dừng';
  static const wonResult = 'HOÀN THÀNH BÀI! 🎉';
  static const caughtResult = 'BỊ CÔ PHÁT HIỆN! 🚨';
  static const timeoutResult = 'HẾT GIỜ KIỂM TRA! ⏰';
  static const replay = 'CHƠI LẠI';

  static String secondsLeft(int value) => '${value}s';

  static String percent(int value) => '$value%';

  static String debugTeacher(String mode) => 'AI: $mode';

  static const skillsTitle = 'KỸ NĂNG';
  static const skillLocked = 'Kỹ năng này chưa mở ở màn này';
  static const skillBusy = 'Đang dùng kỹ năng khác';
  static const signalOptions = ['A', 'B', 'C'];

  static String skillName(String id) => switch (id) {
    'peek' => 'Liếc bài bạn',
    'pretend' => 'Diễn sâu',
    'cheat_sheet' => 'Phao giấy',
    'pencil_case' => 'Hộp bút bí ẩn',
    'pass_note' => 'Chuyền giấy',
    'ask_friend' => 'Đồng đội cứu viện',
    'eraser' => 'Tẩy tiên tri',
    'hide_note' => 'Giấu phao',
    'ruler' => 'Thước thần',
    'calculator' => 'Máy tính thần kỳ',
    'signal' => 'Tín hiệu mật',
    'oscar' => 'Oscar học đường',
    _ => id,
  };

  /// Thất bại hài hước của từng kỹ năng (04_SKILL_CATALOG).
  static String skillFailure(String id) => switch (id) {
    'peek' => 'Bạn lấy tay che bài!',
    'pretend' => 'Cô vẫn chưa tin lắm…',
    'cheat_sheet' => 'Phao tuột khỏi tay!',
    'pencil_case' => 'Mở nhầm ngăn hộp bút!',
    'pass_note' => 'Mẩu giấy bay mất!',
    'ask_friend' => 'Bạn lắc đầu từ chối!',
    'eraser' => 'Tẩy ra đáp án sai!',
    'hide_note' => 'Giấu chưa kỹ…',
    'ruler' => 'Thước rơi cái cạch!',
    'calculator' => 'Máy tính kêu bíp lỗi!',
    'signal' => 'Đọc nhầm tín hiệu!',
    'oscar' => 'Diễn lố quá rồi!',
    _ => '',
  };

  static String skillProgress(int percent) => '+$percent% bài làm';

  static String skillRecovered(int points) => '−$points nghi ngờ';

  static String skillNotReady(int seconds) => 'Chờ thêm ${seconds}s';

  static String skillUnlockAt(int level) => 'Mở ở màn $level';

  static String calculatorPrompt(int a, int b) => '$a + $b = ?';

  static String signalPrompt(int fingers) => 'Bạn giơ $fingers ngón. Chọn?';

  static const levelSelectTitle = 'CHỌN MÀN';
  static const nextLevel = 'MÀN TIẾP';
  static const lockedLevel = 'Thắng màn trước để mở';

  static String levelTitle(int id) => switch (id) {
    1 => 'Bài Kiểm Tra Bất Ổn',
    2 => 'Sát Thủ Môn Toán',
    3 => 'Đồng Đội Phản Chủ',
    4 => 'Song Sát Giám Thị',
    5 => 'Huyền Thoại Mắt Thần',
    _ => 'Màn thử kỹ năng',
  };

  static String levelLabel(int id) => 'Màn $id';

  static String starsLabel(int stars) => '${'★' * stars}${'☆' * (3 - stars)}';

  static const tutorialHintSafe =
      'Cô đang viết bảng: giữ nút kỹ năng để liếc bài!';
  static const tutorialHintCue =
      'Thấy dấu … hoặc mắt vàng thì thả ra, giữ VIẾT BÀI!';

  /// Báo trước của từng sự kiện.
  static String eventWarning(String id) => switch (id) {
    'teacher_question' => 'Cô đang đi về phía bạn…',
    'fan_wind' => 'Quạt trần rung lắc! Cẩn thận giấy!',
    'wrong_exam_code' => 'Bạn bên cạnh hình như khác mã đề…',
    'teacher_swap' => 'Hai giám thị chuẩn bị đổi chỗ!',
    'final_boss_mode' => 'GIÁM THỊ HUYỀN THOẠI TĂNG TỐC!',
    _ => '',
  };

  /// Dòng trạng thái khi sự kiện đang diễn ra.
  static String eventActive(String id) => switch (id) {
    'teacher_question' => 'Cô hỏi: "Làm được mấy câu rồi?"',
    'fan_wind' => 'Gió quạt thổi mạnh!',
    'wrong_exam_code' => 'Lệch mã đề: gợi ý của bạn có thể sai!',
    'teacher_swap' => 'Giám thị đang đổi chỗ…',
    'final_boss_mode' => 'Chế độ mắt thần!',
    _ => '',
  };

  static const answerTeacher = 'Dạ, em đang làm ạ!';
  static const paperDropped = 'Giấy rơi xuống sàn!';
  static const pickUpPaper = 'Nhặt giấy';
  static const hintMismatch = 'Gợi ý lệch mã đề!';
  static const hintRetry = 'Hỏi lại';
  static const hintSelfWrite = 'Tự làm';
}

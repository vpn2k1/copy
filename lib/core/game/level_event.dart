/// Pha của sự kiện đặc trưng: chưa tới, đang báo trước, đang diễn ra, xong.
enum EventPhase { pending, warning, active, done }

/// Cấu hình một sự kiện (05_LEVELS). [startAt] là giây kể từ đầu ván; riêng
/// `final_boss_mode` kích hoạt theo [startWhenRemaining] giây còn lại.
class EventConfig {
  const EventConfig({
    required this.id,
    required this.warningSeconds,
    required this.activeSeconds,
    this.startAt = 0,
    this.startWhenRemaining,
  });

  final String id;
  final double startAt;
  final double? startWhenRemaining;
  final double warningSeconds;

  /// Thời lượng pha diễn ra; với sự kiện kéo tới hết ván là vô hạn.
  final double activeSeconds;
}

/// Năm sự kiện, mỗi màn một sự kiện.
const allEvents = <EventConfig>[
  EventConfig(
    id: 'teacher_question',
    startAt: 25,
    warningSeconds: 1.5,
    activeSeconds: 5,
  ),
  EventConfig(
    id: 'fan_wind',
    startAt: 30,
    warningSeconds: 1.5,
    activeSeconds: 5,
  ),
  EventConfig(
    id: 'wrong_exam_code',
    startAt: 20,
    warningSeconds: 2,
    activeSeconds: 20,
  ),
  EventConfig(
    id: 'teacher_swap',
    startAt: 30,
    warningSeconds: 2,
    activeSeconds: 10,
  ),
  EventConfig(
    id: 'final_boss_mode',
    startWhenRemaining: 20,
    warningSeconds: 1.5,
    activeSeconds: double.infinity,
  ),
];

EventConfig? eventById(String id) {
  for (final event in allEvents) {
    if (event.id == id) return event;
  }
  return null;
}

/// Kỹ năng dùng giấy, dễ bị gió quạt thổi bay.
const paperSkillIds = {'cheat_sheet', 'pass_note'};

/// Kỹ năng nhờ bạn, bị ảnh hưởng khi bạn làm khác mã đề.
const allySkillIds = {'ask_friend', 'pass_note', 'signal'};

/// Gợi ý của bạn bị lệch mã đề, chờ người chơi quyết định.
class PendingHint {
  const PendingHint({required this.skillId, required this.amount});

  final String skillId;

  /// % tiến độ gợi ý mang lại nếu đúng mã đề.
  final double amount;
}

/// Ảnh chụp bất biến của sự kiện để giao diện hiện báo trước và nút phản ứng.
class EventSnapshot {
  const EventSnapshot({
    required this.id,
    required this.phase,
    this.phaseRemaining = 0,
    this.isPaperDropped = false,
    this.pendingHint,
  });

  static const none = EventSnapshot(id: 'none', phase: EventPhase.done);

  final String id;
  final EventPhase phase;

  /// Giây còn lại của pha hiện tại (vô hạn với boss).
  final double phaseRemaining;

  /// Gió đã thổi bay giấy xuống sàn, chờ nhặt.
  final bool isPaperDropped;
  final PendingHint? pendingHint;

  bool get isWarning => phase == EventPhase.warning;
  bool get isActive => phase == EventPhase.active;
  bool get isWindy => id == 'fan_wind' && isActive;
  bool get isBossMode => id == 'final_boss_mode' && isActive;

  /// Cô đang hỏi và chờ người chơi trả lời.
  bool get isAskingPlayer => id == 'teacher_question' && isActive;
}

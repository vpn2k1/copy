import 'dart:math' as math;

import 'level_event.dart';

/// Nghi ngờ thay đổi khi trả lời câu hỏi của cô / làm ngơ.
const questionAnsweredRelief = 10.0;
const questionIgnoredRisk = 10.0;

/// Nghi ngờ mỗi giây khi giấy còn nằm trên sàn (gấp đôi mức tự giảm khi
/// viết bài, để giấy rơi thật sự có hậu quả nếu không nhặt).
const droppedPaperRisk = 6.0;

/// Đổi chỗ xong sớm nhất sau chừng này giây (để kịp thấy hai cô đi).
const minSwapSeconds = 1.0;

/// Yêu cầu của sự kiện gửi cho bộ luật trong một tick.
enum EventRequest {
  none,

  /// Cô 1 quay sang nhìn người chơi để hỏi.
  lookAtPlayer,

  /// Cô thôi hỏi, quay về bình thường.
  releaseTeacher,

  /// Gió thổi bay giấy: hủy kỹ năng giấy đang dùng.
  dropPaper,

  /// Hai cô đổi lối.
  swapLanes,

  /// Bật nhịp boss cho mọi cô.
  bossPace,
}

class EventTick {
  const EventTick({
    this.request = EventRequest.none,
    this.suspicionBump = 0,
    this.suspicionRate = 0,
  });

  static const none = EventTick();

  final EventRequest request;

  /// Nghi ngờ cộng (hoặc trừ, nếu âm) một lần.
  final double suspicionBump;

  /// Nghi ngờ cộng mỗi giây.
  final double suspicionRate;
}

/// Lập lịch và giải quyết sự kiện đặc trưng của một màn. Mỗi sự kiện có
/// báo trước, pha diễn ra và kết thúc; chỉ chạy một lần mỗi ván.
class EventScheduler {
  EventScheduler(String eventId) : _config = eventById(eventId);

  final EventConfig? _config;
  EventPhase _phase = EventPhase.pending;
  double _elapsed = 0;
  double _phaseTime = 0;
  bool _isPaperDropped = false;
  bool _isAnswered = false;
  bool _isSettled = false;
  PendingHint? _hint;

  EventSnapshot get snapshot {
    final config = _config;
    if (config == null) return EventSnapshot.none;
    return EventSnapshot(
      id: config.id,
      phase: _phase,
      phaseRemaining: _phaseRemaining(config),
      isPaperDropped: _isPaperDropped,
      pendingHint: _hint,
    );
  }

  /// Tiến [dt] giây. [remainingSeconds]: thời gian ván còn lại.
  /// [isUsingPaper]: người chơi đang dùng kỹ năng giấy.
  /// [isSettled]: (đổi chỗ) hai cô đã tới lối mới.
  EventTick update(
    double dt, {
    required double remainingSeconds,
    bool isUsingPaper = false,
    bool isSettled = false,
  }) {
    final config = _config;
    if (config == null) return EventTick.none;
    _elapsed += dt;
    _phaseTime += dt;
    _isSettled = isSettled;
    final rate = _paperRate();
    switch (_phase) {
      case EventPhase.pending:
        if (!_isDue(config, remainingSeconds)) {
          return EventTick(suspicionRate: rate);
        }
        _enter(EventPhase.warning);
        return _onWarning(config);
      case EventPhase.warning:
        if (_phaseTime < config.warningSeconds) {
          return EventTick(suspicionRate: rate);
        }
        _enter(EventPhase.active);
        return _onActive(config);
      case EventPhase.active:
        return _whileActive(config, isUsingPaper);
      case EventPhase.done:
        return EventTick(suspicionRate: rate);
    }
  }

  /// Người chơi trả lời câu hỏi của cô.
  EventTick acknowledge() {
    if (!snapshot.isAskingPlayer || _isAnswered) return EventTick.none;
    _isAnswered = true;
    _enter(EventPhase.done);
    return const EventTick(
      request: EventRequest.releaseTeacher,
      suspicionBump: -questionAnsweredRelief,
    );
  }

  /// Nhặt giấy rơi lên.
  void pickUpPaper() {
    _isPaperDropped = false;
  }

  /// Sự kiện lệch mã đề đang chặn gợi ý của bạn: giữ lại [amount] % chờ
  /// người chơi quyết định. Trả về true nếu đã chặn.
  bool interceptAllyGain(String skillId, double amount) {
    final config = _config;
    if (config == null || config.id != 'wrong_exam_code') return false;
    if (_phase != EventPhase.active || !allySkillIds.contains(skillId)) {
      return false;
    }
    _hint = PendingHint(skillId: skillId, amount: amount);
    return true;
  }

  /// Bỏ gợi ý lệch mã đề và trả nó cho nơi gọi xử lý (hỏi lại / tự làm).
  PendingHint? takeHint() {
    final hint = _hint;
    _hint = null;
    return hint;
  }

  bool _isDue(EventConfig config, double remainingSeconds) {
    final byRemaining = config.startWhenRemaining;
    if (byRemaining != null) return remainingSeconds <= byRemaining;
    return _elapsed >= config.startAt;
  }

  EventTick _onWarning(EventConfig config) {
    if (config.id == 'teacher_question') {
      return const EventTick(request: EventRequest.lookAtPlayer);
    }
    return EventTick.none;
  }

  EventTick _onActive(EventConfig config) {
    return switch (config.id) {
      'teacher_swap' => const EventTick(request: EventRequest.swapLanes),
      'final_boss_mode' => const EventTick(request: EventRequest.bossPace),
      _ => EventTick.none,
    };
  }

  EventTick _whileActive(EventConfig config, bool isUsingPaper) {
    final isOver = _phaseTime >= config.activeSeconds;
    switch (config.id) {
      case 'teacher_question':
        if (!isOver) return EventTick.none;
        _enter(EventPhase.done);
        return const EventTick(
          request: EventRequest.releaseTeacher,
          suspicionBump: questionIgnoredRisk,
        );
      case 'fan_wind':
        if (isOver) _enter(EventPhase.done);
        if (!isOver && isUsingPaper && !_isPaperDropped) {
          _isPaperDropped = true;
          return const EventTick(request: EventRequest.dropPaper);
        }
        return EventTick(suspicionRate: _paperRate());
      case 'teacher_swap':
        if (isOver || (_isSettled && _phaseTime >= minSwapSeconds)) {
          _enter(EventPhase.done);
        }
        return EventTick.none;
      default:
        if (isOver) _enter(EventPhase.done);
        return EventTick.none;
    }
  }

  double _paperRate() {
    if (_isPaperDropped) return droppedPaperRisk;
    return 0;
  }

  void _enter(EventPhase phase) {
    _phase = phase;
    _phaseTime = 0;
  }

  double _phaseRemaining(EventConfig config) {
    final length = switch (_phase) {
      EventPhase.warning => config.warningSeconds,
      EventPhase.active => config.activeSeconds,
      _ => 0.0,
    };
    return math.max(0.0, length - _phaseTime);
  }
}

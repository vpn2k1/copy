/// Bộ đếm tư thế: tư thế hiện tại và số giây đã ở trong tư thế đó.
/// Tư thế kết thúc (ví dụ bị bắt) khóa animator: mọi lệnh đổi tư thế sau đó
/// bị bỏ qua cho tới khi [reset], để chuyển động của tư thế cũ dừng hẳn.
class PoseAnimator<P extends Enum> {
  PoseAnimator(P initial, {Set<P>? terminalPoses})
    : _pose = initial,
      _terminalPoses = terminalPoses ?? <P>{};

  final Set<P> _terminalPoses;
  P _pose;
  double _elapsed = 0;

  P get pose => _pose;

  /// Số giây đã ở trong tư thế hiện tại.
  double get elapsed => _elapsed;

  bool get isLocked => _terminalPoses.contains(_pose);

  /// Đổi tư thế. Trả về false nếu đang khóa hoặc đã ở đúng tư thế đó
  /// (giữ nguyên nhịp đang chạy).
  bool change(P next) {
    if (isLocked || next == _pose) return false;
    _pose = next;
    _elapsed = 0;
    return true;
  }

  /// Tiến thời gian. Bỏ qua `dt` không dương.
  void update(double dt) {
    if (dt <= 0) return;
    _elapsed += dt;
  }

  /// Đặt lại tư thế, kể cả khi đang khóa (chơi lại ván mới).
  void reset(P pose) {
    _pose = pose;
    _elapsed = 0;
  }
}

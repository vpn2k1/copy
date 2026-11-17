/// Chế độ của giáo viên (07_DATA_CONTRACTS).
enum TeacherMode {
  idle,
  patrol,
  lookLeft,
  lookRight,
  lookAway,
  suspicious,
  approach,
  inspect,
  caught,
}

/// Các chế độ giáo viên đang quan sát lớp theo hướng mặt.
const watchingModes = {
  TeacherMode.lookLeft,
  TeacherMode.suspicious,
  TeacherMode.approach,
  TeacherMode.inspect,
  TeacherMode.caught,
};

/// Ảnh chụp bất biến của giáo viên trên lối đi trước bảng (tọa độ thế giới).
/// Khi đang quay người, [facesLeft] vẫn là hướng cũ cho tới lúc quay xong.
class TeacherState {
  const TeacherState({
    required this.mode,
    required this.x,
    required this.facesLeft,
    this.modeRemaining = 0,
    this.turnRemaining = 0,
    this.warningRemaining = 0,
    this.targetX,
  });

  final TeacherMode mode;
  final double x;
  final bool facesLeft;

  /// Thời gian còn lại của chế độ có hạn giờ (giây).
  final double modeRemaining;

  /// Còn bao lâu nữa quay người xong (giây).
  final double turnRemaining;

  /// Còn bao lâu nữa hết báo trước, sau đó mới thật sự nhìn lớp.
  final double warningRemaining;

  /// Đích đến khi đi tuần hoặc tiến lại gần.
  final double? targetX;

  bool get isTurning => turnRemaining > 0;
  bool get isWarning => warningRemaining > 0;

  /// Đang thật sự quan sát lớp: đúng chế độ, đã quay xong, hết báo trước.
  bool get isWatchingClass =>
      watchingModes.contains(mode) && !isTurning && !isWarning;

  TeacherState copyWith({
    TeacherMode? mode,
    double? x,
    bool? facesLeft,
    double? modeRemaining,
    double? turnRemaining,
    double? warningRemaining,
    double? targetX,
  }) {
    return TeacherState(
      mode: mode ?? this.mode,
      x: x ?? this.x,
      facesLeft: facesLeft ?? this.facesLeft,
      modeRemaining: modeRemaining ?? this.modeRemaining,
      turnRemaining: turnRemaining ?? this.turnRemaining,
      warningRemaining: warningRemaining ?? this.warningRemaining,
      targetX: targetX ?? this.targetX,
    );
  }
}

/// Phát hiện theo góc nhìn ngang: giáo viên thấy người chơi khi đang quan
/// sát lớp và mặt hướng về phía người chơi trên trục x. Cảnh không có vật
/// che giữa giáo viên và nhân vật chính (nhân vật ở tiền cảnh), nên không
/// mô hình hóa che khuất.
bool canSeePlayer(TeacherState teacher, {required double playerX}) {
  if (!teacher.isWatchingClass) return false;
  final playerIsLeft = playerX < teacher.x;
  return teacher.facesLeft == playerIsLeft;
}

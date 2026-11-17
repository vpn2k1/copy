import 'pose_animator.dart';
import 'teacher_rig.dart';

/// Hoạt ảnh giáo viên: tư thế, thời gian và hướng mặt.
/// Tự chạy: `lookLeft`/`lookRight` đặt luôn hướng mặt; `turn` xong thì đổi
/// hướng và về `idle`. Khi được AI điều khiển qua [follow], hướng mặt, tiến
/// trình quay và biểu tượng lấy từ AI để hình luôn khớp bộ phát hiện.
class TeacherAnimator {
  final PoseAnimator<TeacherPose> _poses = PoseAnimator(
    TeacherPose.idle,
    terminalPoses: terminalTeacherPoses,
  );
  bool _facesLeft = true;
  bool _isFollowing = false;
  double _turnProgress = 0;
  TeacherCue? _cue;

  TeacherPose get pose => _poses.pose;
  bool get facesLeft => _facesLeft;
  bool get isLocked => _poses.isLocked;

  TeacherRig get rig {
    var rig = teacherRigFor(_poses.pose, _poses.elapsed, facesLeft: _facesLeft);
    if (!_isFollowing) return rig;
    if (pose == TeacherPose.turn) {
      rig = rig.copyWith(
        scaleX: teacherTurnScale(_turnProgress, facesLeft: _facesLeft),
      );
    }
    return rig.copyWith(cue: _cue);
  }

  bool change(TeacherPose next) {
    if (!_poses.change(next)) return false;
    _applyFacing(next);
    return true;
  }

  /// Theo trạng thái AI: [facesLeft] là hướng hiện tại (hướng cũ khi đang
  /// quay), [turnProgress] 0..1 khi tư thế là `turn`.
  void follow(
    TeacherPose next, {
    required bool facesLeft,
    required TeacherCue cue,
    double turnProgress = 0,
  }) {
    _isFollowing = true;
    _poses.change(next);
    _facesLeft = facesLeft;
    _turnProgress = turnProgress;
    _cue = cue;
  }

  void update(double dt) {
    _poses.update(dt);
    if (_isFollowing || pose != TeacherPose.turn) return;
    if (_poses.elapsed < teacherTurnSeconds) return;
    _facesLeft = !_facesLeft;
    _poses.change(TeacherPose.idle);
  }

  void reset(TeacherPose pose, {bool facesLeft = true}) {
    _poses.reset(pose);
    _facesLeft = facesLeft;
    _isFollowing = false;
    _cue = null;
    _applyFacing(pose);
  }

  void _applyFacing(TeacherPose pose) {
    if (pose == TeacherPose.lookLeft) _facesLeft = true;
    if (pose == TeacherPose.lookRight) _facesLeft = false;
  }
}

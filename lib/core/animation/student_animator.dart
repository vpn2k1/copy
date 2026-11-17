import 'pose_animator.dart';
import 'student_rig.dart';

/// Hoạt ảnh của một học sinh: tư thế, thời gian và mức nghi ngờ đang thấy.
class StudentAnimator {
  StudentAnimator(StudentPose initial, {this.phase = 0})
    : _poses = PoseAnimator(initial, terminalPoses: terminalStudentPoses);

  final PoseAnimator<StudentPose> _poses;

  /// Lệch nhịp so với các học sinh khác (giây).
  final double phase;

  double _suspicion = 0;

  StudentPose get pose => _poses.pose;
  bool get isLocked => _poses.isLocked;
  double get suspicion => _suspicion;

  /// Mức nghi ngờ 0..1 để nhân vật phản ứng (đổ mồ hôi, run).
  set suspicion(double value) {
    _suspicion = value.clamp(0.0, 1.0).toDouble();
  }

  StudentRig get rig => studentRigFor(
    _poses.pose,
    _poses.elapsed,
    phase: phase,
    suspicion: _suspicion,
  );

  bool change(StudentPose next) => _poses.change(next);

  void update(double dt) => _poses.update(dt);

  void reset(StudentPose pose) {
    _poses.reset(pose);
    _suspicion = 0;
  }
}

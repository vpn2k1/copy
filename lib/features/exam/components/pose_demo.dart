import 'package:flame/components.dart';

import '../../../core/animation/student_rig.dart';
import '../../../core/animation/teacher_rig.dart';
import 'seated_student.dart';
import 'teacher_figure.dart';

/// Chỉ để review hoạt ảnh: lần lượt cho nhân vật chính và giáo viên qua mọi
/// tư thế, mỗi tư thế [stepSeconds] giây. Bật bằng `--dart-define=POSE_DEMO=true`.
/// Không thay đổi luật chơi.
class PoseDemo extends Component {
  PoseDemo({
    required this.player,
    required this.teacher,
    this.stepSeconds = 2.5,
  });

  final SeatedStudent player;
  final TeacherFigure teacher;
  final double stepSeconds;

  double _clock = 0;
  int _step = 0;

  @override
  void onMount() {
    super.onMount();
    _apply();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_clock < stepSeconds) return;
    _clock = 0;
    _step++;
    _apply();
  }

  void _apply() {
    const studentPoses = StudentPose.values;
    const teacherPoses = TeacherPose.values;
    player.animator.reset(studentPoses[_step % studentPoses.length]);
    teacher.animator.reset(teacherPoses[_step % teacherPoses.length]);
  }
}

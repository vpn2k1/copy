import 'package:dung_de_thay_thay/core/animation/teacher_animator.dart';
import 'package:dung_de_thay_thay/core/animation/teacher_rig.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nhìn trái/phải đặt hướng mặt và hiện biểu tượng quan sát', () {
    final animator = TeacherAnimator()..change(TeacherPose.lookRight);
    expect(animator.facesLeft, isFalse);
    expect(animator.rig.cue, TeacherCue.watching);
    animator.change(TeacherPose.lookLeft);
    expect(animator.facesLeft, isTrue);
    expect(animator.rig.facesLeft, isTrue);
  });

  test('quay người: giữa chừng dẹt, xong thì đổi hướng và đứng yên', () {
    final animator = TeacherAnimator()..change(TeacherPose.turn);
    animator.update(teacherTurnSeconds / 2);
    expect(animator.rig.scaleX.abs(), lessThan(0.05));
    animator.update(teacherTurnSeconds);
    expect(animator.pose, TeacherPose.idle);
    expect(animator.facesLeft, isFalse);
  });

  test('biểu tượng: nghi ngờ khi soi, báo động khi bắt', () {
    expect(
      teacherRigFor(TeacherPose.inspect, 0, facesLeft: true).cue,
      TeacherCue.suspicious,
    );
    expect(
      teacherRigFor(TeacherPose.caught, 0, facesLeft: true).cue,
      TeacherCue.alarm,
    );
    expect(
      teacherRigFor(TeacherPose.walk, 0, facesLeft: true).cue,
      TeacherCue.none,
    );
  });

  test('bắt được thì khóa, không quay lại đi tuần', () {
    final animator = TeacherAnimator()..change(TeacherPose.caught);
    expect(animator.change(TeacherPose.walk), isFalse);
    expect(animator.pose, TeacherPose.caught);
    expect(animator.rig.isPointing, isTrue);
  });

  test('bước đi phụ thuộc thời gian, không phụ thuộc số khung hình', () {
    final coarse = TeacherAnimator()..change(TeacherPose.walk);
    final fine = TeacherAnimator()..change(TeacherPose.walk);
    coarse.update(0.6);
    for (var i = 0; i < 60; i++) {
      fine.update(0.01);
    }
    expect(fine.rig.nearStep, closeTo(coarse.rig.nearStep, 1e-6));
    expect(fine.rig.bodyY, closeTo(coarse.rig.bodyY, 1e-6));
  });

  test('mỗi tư thế giáo viên nhìn khác nhau', () {
    final signatures = {
      for (final pose in TeacherPose.values)
        _signature(teacherRigFor(pose, 0.3, facesLeft: true)),
    };
    expect(signatures, hasLength(TeacherPose.values.length));
  });
}

String _signature(TeacherRig rig) => [
  rig.scaleX.toStringAsFixed(3),
  rig.bodyY.toStringAsFixed(3),
  rig.nearStep.toStringAsFixed(3),
  rig.lean,
  rig.headTilt,
  rig.pupilX,
  rig.isSquinting,
  rig.isAngry,
  rig.isMouthOpen,
  rig.isPointing,
  rig.cue,
].join('|');

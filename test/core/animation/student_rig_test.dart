import 'dart:math' as math;

import 'package:dung_de_thay_thay/core/animation/rig_point.dart';
import 'package:dung_de_thay_thay/core/animation/student_animator.dart';
import 'package:dung_de_thay_thay/core/animation/student_rig.dart';
import 'package:flutter_test/flutter_test.dart';

/// Thời điểm không rơi vào lúc chớp mắt.
const awake = 0.5;

/// Tâm và bán kính mặt trong hệ gốc của hình (xem StudentHead).
const faceCenter = RigPoint(22, -462);
const faceRadius = 66.0;
const handRadius = 17.0;

double distance(RigPoint a, RigPoint b) =>
    math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));

void main() {
  test('7 tư thế cho ra 7 rig khác nhau', () {
    final rigs = {
      for (final pose in StudentPose.values) studentRigFor(pose, awake),
    };
    expect(rigs, hasLength(StudentPose.values.length));
  });

  test('mỗi tư thế đổi mắt, miệng hoặc mày so với ngồi yên', () {
    final idle = studentRigFor(StudentPose.idle, awake);
    for (final pose in StudentPose.values.skip(1)) {
      final rig = studentRigFor(pose, awake);
      final faceChanged =
          rig.pupil != idle.pupil ||
          rig.eyes != idle.eyes ||
          rig.mouth != idle.mouth ||
          rig.browLift != idle.browLift;
      expect(faceChanged, isTrue, reason: pose.name);
    }
  });

  test('tay không che mặt ở mọi tư thế', () {
    for (final pose in StudentPose.values) {
      for (final t in [0.0, 0.3, 1.1, 2.7]) {
        final rig = studentRigFor(pose, t);
        final face = faceCenter + rig.body + rig.head;
        for (final hand in [rig.nearHand, rig.farHand]) {
          expect(
            distance(hand, face),
            greaterThan(faceRadius + handRadius),
            reason: '${pose.name} t=$t',
          );
        }
      }
    }
  });

  test('bị bắt là khung hình đứng yên, không chớp mắt', () {
    final early = studentRigFor(StudentPose.caught, 0.05);
    final late = studentRigFor(StudentPose.caught, 5);
    expect(early, late);
    expect(early.eyeOpen, 1);
  });

  test('chớp mắt theo chu kỳ và lệch nhịp theo phase', () {
    expect(studentRigFor(StudentPose.idle, 0.05).eyeOpen, lessThan(0.3));
    expect(studentRigFor(StudentPose.idle, 1).eyeOpen, 1);
    expect(
      studentRigFor(StudentPose.idle, 0.05, phase: 1).eyeOpen,
      1,
      reason: 'học sinh lệch nhịp không chớp cùng lúc',
    );
  });

  test('nghi ngờ cao làm đổ mồ hôi, trừ khi đã ăn mừng', () {
    final calm = studentRigFor(StudentPose.writing, awake, suspicion: 0.3);
    final tense = studentRigFor(StudentPose.writing, awake, suspicion: 0.8);
    final won = studentRigFor(StudentPose.celebrating, awake, suspicion: 0.9);
    expect(calm.hasSweat, isFalse);
    expect(tense.hasSweat, isTrue);
    expect(won.hasSweat, isFalse);
  });

  test('animator khóa khi bị bắt, chuyển động cũ dừng', () {
    final animator = StudentAnimator(StudentPose.writing)..update(0.4);
    expect(animator.change(StudentPose.caught), isTrue);
    expect(animator.change(StudentPose.writing), isFalse);
    expect(animator.pose, StudentPose.caught);
    final frozen = animator.rig;
    animator.update(3);
    expect(animator.rig, frozen);
  });

  test('animator giới hạn nghi ngờ trong 0..1 và reset xóa nghi ngờ', () {
    final animator = StudentAnimator(StudentPose.idle)..suspicion = 3;
    expect(animator.suspicion, 1);
    animator.reset(StudentPose.idle);
    expect(animator.suspicion, 0);
  });
}

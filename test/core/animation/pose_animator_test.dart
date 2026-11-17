import 'package:dung_de_thay_thay/core/animation/pose_animator.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Pose { a, b, end }

void main() {
  PoseAnimator<_Pose> make() =>
      PoseAnimator(_Pose.a, terminalPoses: {_Pose.end});

  test('đổi tư thế đặt lại đồng hồ, cùng tư thế thì giữ nhịp', () {
    final animator = make()..update(1.2);
    expect(animator.change(_Pose.a), isFalse);
    expect(animator.elapsed, 1.2);
    expect(animator.change(_Pose.b), isTrue);
    expect(animator.elapsed, 0);
  });

  test('tư thế kết thúc khóa mọi lệnh đổi cho tới khi reset', () {
    final animator = make()..change(_Pose.end);
    expect(animator.isLocked, isTrue);
    expect(animator.change(_Pose.a), isFalse);
    expect(animator.pose, _Pose.end);
    animator.reset(_Pose.a);
    expect(animator.pose, _Pose.a);
    expect(animator.isLocked, isFalse);
  });

  test('dt không dương không làm lùi thời gian', () {
    final animator = make()
      ..update(0.5)
      ..update(-1)
      ..update(0);
    expect(animator.elapsed, 0.5);
  });
}

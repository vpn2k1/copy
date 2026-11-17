import 'dart:math' as math;

import 'package:dung_de_thay_thay/core/animation/limb_solver.dart';
import 'package:dung_de_thay_thay/core/animation/rig_point.dart';
import 'package:flutter_test/flutter_test.dart';

double length(RigPoint a, RigPoint b) =>
    math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));

void main() {
  const shoulder = RigPoint(-4, -366);
  const hand = RigPoint(182, -232);

  test('khuỷu tay giữ đúng chiều dài hai đoạn tay', () {
    final elbow = solveElbow(shoulder, hand);
    expect(length(shoulder, elbow), closeTo(125, 0.01));
    expect(length(elbow, hand), closeTo(125, 0.01));
  });

  test('bend đổi phía gập khuỷu', () {
    final down = solveElbow(shoulder, hand);
    final up = solveElbow(shoulder, hand, bend: -1);
    expect(down.y, greaterThan(up.y));
  });

  test('ngoài tầm với thì duỗi thẳng về phía tay', () {
    const far = RigPoint(400, -366);
    final elbow = solveElbow(shoulder, far);
    expect(elbow.y, closeTo(shoulder.y, 0.5));
    expect(elbow.x, closeTo(shoulder.x + 125, 0.5));
  });
}

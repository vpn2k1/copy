import 'package:dung_de_thay_thay/core/world_layout.dart';
import 'package:dung_de_thay_thay/features/exam/components/classroom_background.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nền lớp phủ đúng thế giới logic và nằm dưới cùng', () {
    final background = ClassroomBackground();
    expect(background.size.x, WorldLayout.width);
    expect(background.size.y, WorldLayout.height);
    expect(background.priority, lessThan(0));
  });
}

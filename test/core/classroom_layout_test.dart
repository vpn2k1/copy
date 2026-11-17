import 'package:dung_de_thay_thay/core/classroom_layout.dart';
import 'package:dung_de_thay_thay/core/world_layout.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kiểm tra hợp đồng camera trong plan 01_VISUAL_CAMERA bằng số liệu bố cục.
void main() {
  const height = WorldLayout.height;
  final top = ClassroomLayout.playableTop;
  final bottom = ClassroomLayout.playableBottom;

  test('nhân vật chính cao 45–60% khung cảnh', () {
    const player = ClassroomLayout.player;
    final fraction = ClassroomLayout.seatedFigureHeight * player.scale / height;
    expect(fraction, inInclusiveRange(0.45, 0.60));
  });

  test('giáo viên cao 12–20% khung cảnh', () {
    const teacher = ClassroomLayout.teacher;
    final fraction =
        ClassroomLayout.standingFigureHeight * teacher.scale / height;
    expect(fraction, inInclusiveRange(0.12, 0.20));
  });

  test('lớp có ít nhất 3 bạn học ngoài nhân vật chính', () {
    expect(ClassroomLayout.classmates.length, greaterThanOrEqualTo(3));
  });

  test('bàn trong dãy nối sát nhau, mỗi bàn hai bạn', () {
    for (final row in ClassroomLayout.rows) {
      final seats = row.nearSeats;
      for (var i = 1; i < seats.length; i++) {
        final gap = seats[i].x - seats[i - 1].x;
        expect(gap, closeTo(ClassroomLayout.deskPitch * row.scale, 0.001));
      }
    }
    final pairs = ClassroomLayout.rows.fold(0, (n, r) => n + r.deskCount);
    expect(ClassroomLayout.classmates.length, pairs * 2 + 1);
  });

  test('nhân vật chính có bạn cùng bàn ngồi sát bên', () {
    const player = ClassroomLayout.player;
    final mate = ClassroomLayout.playerDeskmate;
    final halfDesk = ClassroomLayout.deskPitch * player.scale / 2;
    expect(mate.x - player.x, inExclusiveRange(0, halfDesk));
    expect(mate.y, lessThan(player.y));
  });

  test('không đầu học sinh nào che mặt giáo viên', () {
    const t = ClassroomLayout.teacher;
    final faceX = t.x + ClassroomLayout.teacherFaceX * t.scale;
    final faceY = t.y + ClassroomLayout.teacherFaceY * t.scale;
    final faceR = ClassroomLayout.teacherFaceRadius * t.scale;
    for (final mate in ClassroomLayout.classmates) {
      final headX = mate.x + ClassroomLayout.seatedHeadX * mate.scale;
      final headY = mate.y + ClassroomLayout.seatedHeadY * mate.scale;
      final headR = ClassroomLayout.seatedHeadRadius * mate.scale;
      final dx = headX - faceX;
      final dy = headY - faceY;
      final minDistance = headR + faceR;
      expect(dx * dx + dy * dy, greaterThan(minDistance * minDistance));
    }
  });

  test('mặt, tay nhân vật chính và giáo viên nằm ngoài vùng HUD', () {
    expect(ClassroomLayout.playerHeadTop, inInclusiveRange(top, bottom));
    expect(ClassroomLayout.playerHandY, inInclusiveRange(top, bottom));
    expect(ClassroomLayout.teacherHeadTop, inInclusiveRange(top, bottom));
    expect(ClassroomLayout.teacher.y, inInclusiveRange(top, bottom));
  });

  test('giáo viên ở xa hơn mọi học sinh (vẽ phía sau)', () {
    for (final mate in ClassroomLayout.classmates) {
      expect(mate.y, greaterThan(ClassroomLayout.teacher.y));
      expect(mate.y, lessThan(ClassroomLayout.player.y));
    }
  });
}

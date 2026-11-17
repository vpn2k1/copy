import 'package:dung_de_thay_thay/core/animation/student_rig.dart';
import 'package:dung_de_thay_thay/core/animation/teacher_rig.dart';
import 'package:dung_de_thay_thay/features/exam/components/seated_student.dart';
import 'package:dung_de_thay_thay/features/exam/components/exam_images.dart';
import 'package:dung_de_thay_thay/features/exam/components/teacher_figure.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bảng tư thế để review phase 02. Hàng trên: 7 tư thế học sinh theo thứ tự
/// `StudentPose.values`. Hàng dưới: 7 tư thế giáo viên theo `TeacherPose.values`.
/// Sinh lại: `flutter test --update-goldens test/features/exam/pose_sheet_golden_test.dart`.
class PoseSheetGame extends FlameGame {
  PoseSheetGame()
    : super(
        camera: CameraComponent.withFixedResolution(width: 1600, height: 900),
      );

  static const double _column = 225;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await preloadExamImages();
    camera.viewfinder.anchor = Anchor.topLeft;
    for (final (i, pose) in StudentPose.values.indexed) {
      final student = SeatedStudent(
        seat: Vector2(70 + i * _column, 420),
        figureScale: 0.36,
        hasScarf: true,
        pose: pose,
      );
      await world.add(student);
    }
    for (final (i, pose) in TeacherPose.values.indexed) {
      final teacher = TeacherFigure(
        feet: Vector2(120 + i * _column, 870),
        figureScale: 0.6,
        cueScale: 1,
      );
      teacher.animator.reset(pose);
      await world.add(teacher);
    }
  }

  @override
  Color backgroundColor() => const Color(0xFFF3E2B3);
}

void main() {
  testWidgets('bảng tư thế học sinh và giáo viên', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(preloadExamImages);
    final game = PoseSheetGame();
    await tester.pumpWidget(RepaintBoundary(child: GameWidget(game: game)));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/pose_sheet.png'),
    );
  });
}

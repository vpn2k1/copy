import 'package:dung_de_thay_thay/features/exam/exam_game.dart';
import 'package:dung_de_thay_thay/features/exam/components/exam_images.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ảnh chụp cảnh lớp để review bố cục camera. Font trong test là Ahem nên chữ
/// hiện thành khối; ảnh thật trên thiết bị ghi trong PROGRESS.md.
/// Sinh lại: `flutter test --update-goldens test/features/exam/classroom_golden_test.dart`.
Future<void> pumpScene(WidgetTester tester, Size logicalSize) async {
  tester.view.physicalSize = logicalSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.runAsync(preloadExamImages);
  final game = ExamGame(showCameraGuides: true);
  await tester.pumpWidget(RepaintBoundary(child: GameWidget(game: game)));
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('cảnh lớp 1600x900', (tester) async {
    await pumpScene(tester, const Size(1600, 900));
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/classroom_1600x900.png'),
    );
  });

  testWidgets('cảnh lớp trên điện thoại 20:9', (tester) async {
    await pumpScene(tester, const Size(800, 360));
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/classroom_phone_20x9.png'),
    );
  });
}

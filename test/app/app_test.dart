import 'package:dung_de_thay_thay/app/app.dart';
import 'package:dung_de_thay_thay/app/app_scope.dart';
import 'package:dung_de_thay_thay/app/game_audio.dart';
import 'package:dung_de_thay_thay/core/save/save_repository.dart';
import 'package:dung_de_thay_thay/features/exam/exam_screen.dart';
import 'package:dung_de_thay_thay/features/levels/level_select_screen.dart';
import 'package:dung_de_thay_thay/features/menu/menu_screen.dart';
import 'package:dung_de_thay_thay/features/settings/settings_screen.dart';
import 'package:dung_de_thay_thay/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Màn thi có vòng lặp game chạy liên tục nên không dùng pumpAndSettle.
Future<void> pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Mở app với kho lưu trong bộ nhớ và không âm thanh, chờ đọc dữ liệu xong.
Future<void> pumpApp(WidgetTester tester, {SaveStore? store}) async {
  await tester.pumpWidget(
    App(store: store ?? MemorySaveStore(), audio: const SilentAudio()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('app mở vào menu có tên game và hai nút', (tester) async {
    await pumpApp(tester);
    expect(find.byType(MenuScreen), findsOneWidget);
    expect(find.text(Strings.menuTitle), findsOneWidget);
    expect(find.byKey(const Key('menu.play')), findsOneWidget);
    expect(find.byKey(const Key('menu.settings')), findsOneWidget);
  });

  testWidgets('VÀO LỚP mở chọn màn, màn 1 mở được, màn 2 đang khóa', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('menu.play')));
    await tester.pumpAndSettle();
    expect(find.byType(LevelSelectScreen), findsOneWidget);
    for (var id = 1; id <= 5; id++) {
      expect(find.byKey(Key('level.$id')), findsOneWidget);
    }
    expect(find.byIcon(Icons.lock), findsNWidgets(4));

    await tester.tap(find.byKey(const Key('level.2')));
    await tester.pumpAndSettle();
    expect(find.byType(ExamScreen), findsNothing, reason: 'màn 2 còn khóa');

    await tester.tap(find.byKey(const Key('level.1')));
    await pumpFrames(tester);
    expect(find.byType(ExamScreen), findsOneWidget);
    final exam = tester.widget<ExamScreen>(find.byType(ExamScreen));
    expect(exam.level!.id, 1);

    await tester.tap(find.byKey(const Key('exam.back')));
    await pumpFrames(tester);
    expect(find.byType(ExamScreen), findsNothing);
    expect(find.byType(LevelSelectScreen), findsOneWidget);
  });

  testWidgets('thắng màn 1 thì chọn màn hiện sao và mở màn 2', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('menu.play')));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(LevelSelectScreen));
    AppScope.of(context).record(1, isWon: true, stars: 2);
    await tester.pumpAndSettle();
    expect(find.text(Strings.starsLabel(2)), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsNWidgets(3));
    await tester.tap(find.byKey(const Key('level.2')));
    await pumpFrames(tester);
    final exam = tester.widget<ExamScreen>(find.byType(ExamScreen));
    expect(exam.level!.id, 2);
  });

  testWidgets('CÀI ĐẶT mở màn cài đặt và quay lại được', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('menu.settings')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(MenuScreen), findsOneWidget);
  });

  testWidgets('chọn màn vừa khổ điện thoại ngang 932x430, không tràn', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(932, 430);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('menu.play')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (var id = 1; id <= 5; id++) {
      final rect = tester.getRect(find.byKey(Key('level.$id')));
      expect(rect.bottom, lessThanOrEqualTo(430), reason: 'màn $id');
    }
  });
}

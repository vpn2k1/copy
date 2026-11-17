import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/core/game/levels.dart';
import 'package:dung_de_thay_thay/features/exam/exam_game.dart';
import 'package:dung_de_thay_thay/features/exam/components/exam_images.dart';
import 'package:dung_de_thay_thay/features/exam/exam_screen.dart';
import 'package:dung_de_thay_thay/features/exam/widgets/skill_bar.dart';
import 'package:dung_de_thay_thay/l10n/strings.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ExamGame gameIn(WidgetTester tester) {
  final widget = tester.widget<GameWidget<ExamGame>>(
    find.byType(GameWidget<ExamGame>),
  );
  return widget.game!;
}

/// Điện thoại ngang cỡ iPhone Pro Max (932x430 điểm).
void usePhoneLandscape(WidgetTester tester) {
  tester.view.physicalSize = const Size(932, 430);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> pumpFor(WidgetTester tester, double seconds) async {
  for (var t = 0.0; t < seconds; t += 0.05) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await preloadExamImages();
  });
  testWidgets('màn 1 chỉ có Liếc bài và Diễn sâu; chạm để chọn', (
    tester,
  ) async {
    usePhoneLandscape(tester);
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    expect(find.byKey(const Key('skill.peek')), findsOneWidget);
    expect(find.byKey(const Key('skill.pretend')), findsOneWidget);
    expect(find.byKey(const Key('skill.ruler')), findsNothing);
    await tester.tap(find.byKey(const Key('skill.pretend')));
    await tester.pump();
    final controller = gameIn(tester).controller;
    expect(controller.state.skills.selectedId, 'pretend');
    expect(
      find.descendant(
        of: find.byKey(const Key('action.cheat')),
        matching: find.text(Strings.skillName('pretend')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('máy tính thần kỳ: câu đố hiện ra, chọn đúng được +11%', (
    tester,
  ) async {
    usePhoneLandscape(tester);
    await tester.pumpWidget(
      const MaterialApp(home: ExamScreen(seed: 3, level: skillSandboxLevel)),
    );
    await tester.pump();
    final controller = gameIn(tester).controller;
    final calculator = find.byKey(const Key('skill.calculator'));
    await tester.dragUntilVisible(
      calculator,
      find.byType(SkillBar),
      const Offset(-120, 0),
    );
    await tester.ensureVisible(calculator);
    await tester.pump();
    await tester.tap(calculator);
    await tester.pump();
    await tester.tap(find.byKey(const Key('action.cheat')));
    await tester.pump();
    final choice = controller.state.skills.active!.choice!;
    final a = choice.operands[0];
    final b = choice.operands[1];
    expect(find.text(Strings.calculatorPrompt(a, b)), findsOneWidget);
    await tester.tap(find.byKey(Key('skill.choice.${choice.correctIndex}')));
    await pumpFor(tester, 1);
    expect(controller.state.skills.active, isNull);
    expect(controller.state.progress, closeTo(11, 0.01));
    expect(find.text(Strings.skillProgress(11)), findsOneWidget);
  });

  testWidgets('bấm kỹ năng đang hồi chiêu thì báo thời gian chờ', (
    tester,
  ) async {
    usePhoneLandscape(tester);
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final cheat = find.byKey(const Key('action.cheat'));
    await tester.tap(cheat);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(cheat);
    await tester.pump();
    expect(find.text(Strings.skillNotReady(2)), findsOneWidget);
  });

  testWidgets('tạm dừng liệt kê đủ 12 kỹ năng, nút tiếp tục bấm được', (
    tester,
  ) async {
    usePhoneLandscape(tester);
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pause')));
    await tester.pump();
    expect(find.byIcon(Icons.lock), findsNWidgets(10));
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('pause.resume')));
    await tester.pump();
    final controller = gameIn(tester).controller;
    expect(controller.state.status, GameStatus.running);
  });
}

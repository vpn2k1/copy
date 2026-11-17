import 'package:dung_de_thay_thay/app/app.dart';
import 'package:dung_de_thay_thay/app/game_audio.dart';
import 'package:dung_de_thay_thay/core/game/game_controller.dart';
import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/core/game/levels.dart';
import 'package:dung_de_thay_thay/core/save/save_repository.dart';
import 'package:dung_de_thay_thay/features/exam/exam_game.dart';
import 'package:dung_de_thay_thay/features/exam/components/exam_images.dart';
import 'package:dung_de_thay_thay/features/exam/exam_screen.dart';
import 'package:dung_de_thay_thay/features/exam/widgets/exam_hud.dart';
import 'package:dung_de_thay_thay/features/exam/widgets/result_panel.dart';
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

void usePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(932, 430);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> pumpSeconds(WidgetTester tester, double seconds) async {
  for (var t = 0.0; t < seconds; t += 0.05) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await preloadExamImages();
  });
  testWidgets('kéo ngón tay ra ngoài nút rồi mới nhấc: vẫn thả, không kẹt', (
    tester,
  ) async {
    usePhone(tester);
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final controller = gameIn(tester).controller;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('action.write'))),
    );
    await tester.pump();
    expect(controller.state.heldAction, PlayerAction.write);
    await gesture.moveTo(const Offset(466, 200));
    await pumpSeconds(tester, 0.3);
    await gesture.up();
    await tester.pump();
    expect(controller.state.heldAction, isNull);
  });

  testWidgets('hủy chạm (cuộc gọi đến…) cũng thả nút', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final controller = gameIn(tester).controller;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('action.cheat'))),
    );
    await tester.pump();
    expect(controller.state.skills.isHolding, isTrue);
    await gesture.cancel();
    await tester.pump();
    expect(controller.state.skills.isHolding, isFalse);
    expect(controller.state.heldAction, isNull);
  });

  testWidgets('chơi lại 10 lần liên tiếp: mỗi lần là ván mới, không lỗi', (
    tester,
  ) async {
    usePhone(tester);
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final game = gameIn(tester);
    final controller = game.controller;
    final seeds = <int>{};
    for (var round = 0; round < 10; round++) {
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('action.cheat'))),
      );
      for (var i = 0; i < 1200 && !controller.state.status.isFinished; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await gesture.up();
      expect(controller.state.status.isFinished, isTrue, reason: 'ván $round');
      await tester.pump();
      await tester.tap(find.byKey(const Key('result.retry')));
      await tester.pump();
      expect(controller.state.status, GameStatus.running);
      expect(controller.state.progress, 0);
      expect(game.teachers.first.animator.isLocked, isFalse);
      seeds.add(controller.state.seed);
    }
    expect(seeds, hasLength(10));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'hành trình đủ: menu → chọn màn → vào lớp → dừng → tiếp → kết quả',
    (tester) async {
      usePhone(tester);
      await tester.pumpWidget(
        App(store: MemorySaveStore(), audio: const SilentAudio()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu.play')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('level.1')));
      await pumpSeconds(tester, 1);
      await tester.tap(find.byKey(const Key('pause')));
      await tester.pump();
      expect(find.text(Strings.pausedTitle), findsOneWidget);
      await tester.tap(find.byKey(const Key('pause.resume')));
      await tester.pump();
      final controller = gameIn(tester).controller;
      for (var i = 0; i < 2400 && !controller.state.status.isFinished; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(controller.state.status, GameStatus.lostTime);
      expect(find.text(Strings.timeoutResult), findsOneWidget);
      expect(find.byKey(const Key('result.retry')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('HUD báo đỏ SẮP BỊ BẮT khi nghi ngờ từ 70', (tester) async {
    final state = GameController(seed: 1).state;
    Future<void> show(double suspicion) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExamHud(state: state.copyWith(suspicion: suspicion)),
        ),
      ),
    );
    await show(69);
    expect(find.text(Strings.suspicionDanger), findsNothing);
    await show(70);
    expect(find.text(Strings.suspicionDanger), findsOneWidget);
  });

  testWidgets('golden: HUD lúc nguy hiểm', (tester) async {
    tester.view.physicalSize = const Size(640, 80);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = GameController(
      seed: 1,
      level: levelOne,
    ).state.copyWith(suspicion: 85, progress: 60);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF2F5D45),
          body: RepaintBoundary(child: ExamHud(state: state)),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('goldens/hud_danger.png'),
    );
  });

  testWidgets('golden: màn kết quả thắng 3 sao', (tester) async {
    tester.view.physicalSize = const Size(640, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            child: ResultPanel(
              status: GameStatus.won,
              stars: 3,
              onRetry: () {},
              onExit: () {},
              onNext: () {},
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('goldens/result_won.png'),
    );
  });
}

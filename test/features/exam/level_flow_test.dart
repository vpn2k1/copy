import 'package:dung_de_thay_thay/app/app_scope.dart';
import 'package:dung_de_thay_thay/app/game_audio.dart';
import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/core/game/level_event.dart';
import 'package:dung_de_thay_thay/core/game/levels.dart';
import 'package:dung_de_thay_thay/features/exam/exam_game.dart';
import 'package:dung_de_thay_thay/features/exam/components/exam_images.dart';
import 'package:dung_de_thay_thay/features/exam/exam_screen.dart';
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

Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() done, {
  int maxFrames = 3000,
}) async {
  for (var i = 0; i < maxFrames && !done(); i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Widget host(ProfileNotifier progress, Widget child) => AppScope(
  notifier: progress,
  audio: const SilentAudio(),
  child: MaterialApp(home: child),
);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await preloadExamImages();
  });
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(932, 430);
    binding.platformDispatcher.views.first.devicePixelRatio = 1;
  });
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('màn 1: hướng dẫn, cô hỏi bài và trả lời qua nút', (
    tester,
  ) async {
    final progress = ProfileNotifier();
    await tester.pumpWidget(
      host(progress, ExamScreen(seed: 1, level: levelOne)),
    );
    await tester.pump();
    expect(find.byKey(const Key('tutorial.hint')), findsOneWidget);
    final controller = gameIn(tester).controller;
    await pumpUntil(tester, () => controller.state.event.isWarning);
    expect(find.text(Strings.eventWarning('teacher_question')), findsOneWidget);
    await pumpUntil(tester, () => controller.state.event.isAskingPlayer);
    await tester.tap(find.byKey(const Key('event.ack')));
    await tester.pump();
    expect(controller.state.event.phase, EventPhase.done);
    expect(find.byKey(const Key('event.ack')), findsNothing);
  });

  testWidgets('màn 4 có hai cô, cô thứ hai áo dài xanh', (tester) async {
    await tester.pumpWidget(
      host(ProfileNotifier(), ExamScreen(seed: 1, level: levelById(4))),
    );
    await tester.pump();
    final game = gameIn(tester);
    expect(game.teachers, hasLength(2));
    expect(game.teachers[1].aoDai, isNot(game.teachers[0].aoDai));
  });

  testWidgets('hết ván thì ghi tiến trình đúng một lần; thua không mở màn', (
    tester,
  ) async {
    final progress = ProfileNotifier();
    var changes = 0;
    progress.addListener(() => changes++);
    await tester.pumpWidget(
      host(progress, ExamScreen(seed: 1, level: levelOne)),
    );
    await tester.pump();
    final controller = gameIn(tester).controller;
    await pumpUntil(tester, () => controller.state.status.isFinished);
    expect(controller.state.status, GameStatus.lostTime);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(progress.book.unlockedLevel, 1);
    expect(changes, 0, reason: 'thua 0 sao, tiến trình không đổi');
    expect(find.byKey(const Key('result.next')), findsNothing);
    expect(find.byKey(const Key('result.retry')), findsOneWidget);
  });
}

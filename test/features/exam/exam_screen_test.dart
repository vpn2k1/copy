import 'package:dung_de_thay_thay/core/classroom_layout.dart';
import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/features/exam/components/seated_student.dart';
import 'package:dung_de_thay_thay/features/exam/components/exam_images.dart';
import 'package:dung_de_thay_thay/features/exam/components/teacher_figure.dart';
import 'package:dung_de_thay_thay/features/exam/exam_game.dart';
import 'package:dung_de_thay_thay/features/exam/exam_screen.dart';
import 'package:dung_de_thay_thay/l10n/strings.dart';
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ExamGame gameIn(WidgetTester tester) {
  final widget = tester.widget<GameWidget<ExamGame>>(
    find.byType(GameWidget<ExamGame>),
  );
  return widget.game!;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await preloadExamImages();
  });
  testWidgets('camera cố định 1600x900', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final viewport = gameIn(tester).camera.viewport;
    expect(viewport, isA<FixedResolutionViewport>());
    final resolution = (viewport as FixedResolutionViewport).resolution;
    expect(resolution.x, 1600);
    expect(resolution.y, 900);
  });

  testWidgets('cảnh có giáo viên, nhân vật chính và các bạn, xếp lớp đúng', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final game = gameIn(tester);
    final students = game.world.children.whereType<SeatedStudent>().toList();
    expect(game.world.children.whereType<TeacherFigure>(), hasLength(1));
    expect(students, hasLength(ClassroomLayout.classmates.length + 1));
    expect(game.teacher.priority, lessThan(game.player.priority));
    for (final mate in students.where((s) => s != game.player)) {
      expect(mate.priority, lessThan(game.player.priority));
    }
  });

  testWidgets('app mất focus thì dừng, chỉ chạy lại khi bấm TIẾP TỤC', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final game = gameIn(tester);
    expect(game.paused, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(game.paused, isTrue);
    expect(find.text(Strings.pausedTitle), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(game.paused, isTrue, reason: 'không tự chạy lại khi quay về app');

    await tester.tap(find.byKey(const Key('pause.resume')));
    await tester.pump();
    expect(game.paused, isFalse);
    expect(find.text(Strings.pausedTitle), findsNothing);
  });

  testWidgets('giữ nút cóp thì đang cóp, thả ra thì dừng', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final controller = gameIn(tester).controller;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('action.cheat'))),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(controller.state.heldAction, PlayerAction.cheat);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(controller.state.progress, greaterThan(1.5));
    await gesture.up();
    await tester.pump();
    expect(controller.state.heldAction, isNull);
  });

  testWidgets('giữ trên bài mình, nhân vật và bàn bạn để hành động', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final controller = gameIn(tester).controller;
    final scene = tester.getRect(find.byType(GameWidget<ExamGame>));
    final scale = (scene.width / 1600).clamp(0.0, scene.height / 900);
    final left = scene.left + (scene.width - 1600 * scale) / 2;
    final top = scene.top + (scene.height - 900 * scale) / 2;

    final writing = await tester.startGesture(
      Offset(left + 550 * scale, top + 545 * scale),
    );
    await tester.pump();
    expect(controller.state.heldAction, PlayerAction.write);
    await writing.up();
    await tester.pump();
    expect(controller.state.heldAction, isNull);

    final cheating = await tester.startGesture(
      Offset(left + 750 * scale, top + 465 * scale),
    );
    await tester.pump();
    expect(controller.state.heldAction, PlayerAction.cheat);
    await cheating.up();
    await tester.pump();
    expect(controller.state.heldAction, isNull);

    final hiding = await tester.startGesture(
      Offset(left + 580 * scale, top + 400 * scale),
    );
    await tester.pump();
    expect(controller.state.heldAction, PlayerAction.hide);
    await hiding.up();
    await tester.pump();
    expect(controller.state.heldAction, isNull);
  });

  testWidgets('vòng chơi qua giao diện: giữ cóp tới khi bị bắt rồi chơi lại', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final controller = gameIn(tester).controller;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('action.cheat'))),
    );
    for (var i = 0; i < 2000; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (controller.state.status.isFinished) break;
    }
    expect(controller.state.status, GameStatus.lostCaught);
    expect(find.text(Strings.caughtResult), findsOneWidget);
    await gesture.up();
    await tester.pump();

    await tester.tap(find.byKey(const Key('result.retry')));
    await tester.pump();
    expect(controller.state.status, GameStatus.running);
    expect(controller.state.progress, 0);
    expect(controller.state.suspicion, 0);
    expect(find.text(Strings.caughtResult), findsNothing);
  });

  testWidgets('nút tạm dừng đóng băng ván, thả nút đang giữ', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    final controller = gameIn(tester).controller;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('action.write'))),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const Key('pause')));
    await tester.pump();
    expect(controller.state.status, GameStatus.paused);
    expect(controller.state.heldAction, isNull);
    final time = controller.state.remainingSeconds;
    await tester.pump(const Duration(seconds: 1));
    expect(controller.state.remainingSeconds, time);
    await gesture.up();
  });

  testWidgets('HUD có đủ các khóa test', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExamScreen(seed: 3)));
    await tester.pump();
    for (final key in [
      'hud.progress',
      'hud.suspicion',
      'hud.timer',
      'action.cheat',
      'action.write',
      'action.hide',
      'pause',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
  });
}

import 'package:dung_de_thay_thay/core/game/game_controller.dart';
import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/core/game/level_config.dart';
import 'package:dung_de_thay_thay/core/game/skill_config.dart';
import 'package:dung_de_thay_thay/core/game/teacher_fsm.dart';
import 'package:dung_de_thay_thay/core/game/teacher_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'play_script.dart';

const seeds = [1, 2, 3, 7, 42, 99, 123, 2024];

/// Chạy tới khi điều kiện đúng hoặc hết [limit] giây giả lập.
void runUntil(
  GameController controller,
  bool Function() done, {
  double limit = 200,
}) {
  var time = 0.0;
  while (!done() && time < limit) {
    controller.tick(0.02);
    time += 0.02;
  }
}

void main() {
  group('ba kết thúc', () {
    test('không làm gì thì hết giờ', () {
      for (final seed in seeds) {
        expect(playOut(seed, doNothing).status, GameStatus.lostTime);
      }
    });

    test('chỉ viết bài thì an toàn nhưng không kịp (45%)', () {
      for (final seed in seeds) {
        final end = playOut(seed, alwaysWrite);
        expect(end.status, GameStatus.lostTime);
        expect(end.progress, closeTo(45, 0.5));
        expect(end.suspicion, 0);
      }
    });

    test('giữ nút cóp suốt thì bị bắt', () {
      for (final seed in seeds) {
        expect(playOut(seed, alwaysCheat).status, GameStatus.lostCaught);
      }
    });

    test('nhìn biểu tượng của cô và phản ứng 0,3 s thì thắng', () {
      for (final seed in seeds) {
        final end = playOut(seed, carefulPlayer());
        expect(end.status, GameStatus.won, reason: 'seed $seed');
        expect(end.progress, 100);
      }
    });

    test('kết thúc thì thả nút, không nhận lệnh nữa', () {
      final controller = GameController(seed: 1)..start();
      controller.press(PlayerAction.cheat);
      runUntil(controller, () => controller.state.status.isFinished);
      expect(controller.state.status, GameStatus.lostCaught);
      expect(controller.state.heldAction, isNull);
      expect(controller.state.teacher.mode, TeacherMode.caught);
      controller.press(PlayerAction.write);
      final frozen = controller.state;
      controller.tick(0.05);
      expect(controller.state, same(frozen));
    });
  });

  test('ưu tiên tại cùng một tick: bị bắt > hết giờ > thắng', () {
    const quick = LevelConfig(
      id: 9,
      durationSeconds: 1,
      teacherCount: 1,
      teacherSpeed: 1,
      suspicionPerSecond: 20,
      skillIds: ['peek'],
      specialEventId: 'none',
    );
    const instant = SkillConfig(
      id: 'peek',
      effectKind: SkillEffectKind.holdProgress,
      trigger: SkillTrigger.hold,
      value: 200,
      riskMultiplier: 1,
      cooldownSeconds: 0,
      unlockLevel: 1,
    );
    final controller =
        GameController(seed: 1, level: quick, catalog: const [instant])
          ..start()
          ..press(PlayerAction.cheat);
    runUntil(controller, () => controller.state.status.isFinished);
    expect(controller.state.status, GameStatus.won);

    final late = GameController(seed: 1, level: quick)..start();
    runUntil(late, () => late.state.status.isFinished);
    expect(late.state.status, GameStatus.lostTime);
  });

  test('tạm dừng đóng băng mọi giá trị, thả nút đang giữ', () {
    final controller = GameController(seed: 5)..start();
    controller.press(PlayerAction.write);
    runUntil(controller, () => controller.state.remainingSeconds < 80);
    controller.pause();
    final paused = controller.state;
    expect(paused.heldAction, isNull);
    for (var i = 0; i < 100; i++) {
      controller.tick(0.05);
    }
    expect(controller.state, same(paused));
    controller.press(PlayerAction.cheat);
    expect(controller.state.heldAction, isNull);
    controller.resume();
    expect(controller.state.status, GameStatus.running);
  });

  test('nhả nút cũ sau khi đã nhấn nút mới không hủy nút mới', () {
    final controller = GameController(seed: 1)..start();
    controller.press(PlayerAction.write);
    controller.press(PlayerAction.cheat);
    controller.release(PlayerAction.write);
    expect(controller.state.heldAction, PlayerAction.cheat);
    controller.release(PlayerAction.cheat);
    expect(controller.state.heldAction, isNull);
  });

  test('dt lớn bị giới hạn, dt âm/0 bỏ qua', () {
    final controller = GameController(seed: 1)..start();
    controller.tick(5);
    expect(controller.state.remainingSeconds, 90 - GameTuning.maxStep);
    controller.tick(-1);
    controller.tick(0);
    expect(controller.state.remainingSeconds, 90 - GameTuning.maxStep);
  });

  test('cùng seed, cùng input: kết quả giống hệt; khác tốc độ khung hình '
      'vẫn cùng kết cục', () {
    final a = playOut(42, carefulPlayer());
    final b = playOut(42, carefulPlayer());
    expect(a.remainingSeconds, b.remainingSeconds);
    expect(a.suspicion, b.suspicion);
    final slow = playOut(42, alwaysWrite, dt: 1 / 30);
    final fast = playOut(42, alwaysWrite, dt: 1 / 120);
    expect(slow.progress, closeTo(fast.progress, 0.1));
    expect(slow.status, fast.status);
  });

  test('bị nhìn thấy khi cóp thì nghi ngờ tăng nhanh, giả vờ thì giảm', () {
    final controller = GameController(seed: 3)..start();
    runUntil(controller, () => controller.state.teacher.isWatchingClass);
    expect(controller.state.isPlayerSeen, isTrue);
    controller.press(PlayerAction.cheat);
    controller.tick(0.05);
    final risen = controller.state.suspicion;
    expect(risen, closeTo(20 * 0.65 * 0.05, 1e-9));
    expect(controller.state.isSeenCheating, isTrue);
    controller.press(PlayerAction.hide);
    controller.tick(0.05);
    expect(controller.state.suspicion, lessThan(risen));
  });

  test('cô tới soi bàn: cộng nghi ngờ đúng một lần mỗi lần soi', () {
    // Màn 1 bỏ sự kiện và hướng dẫn để chỉ đo cú cộng của lần soi.
    const quiet = LevelConfig(
      id: 1,
      durationSeconds: 90,
      teacherCount: 1,
      teacherSpeed: 0.6,
      suspicionPerSecond: 20,
      skillIds: ['peek', 'pretend'],
      specialEventId: 'none',
    );
    final controller = GameController(seed: 11, level: quiet)..start();
    var inspections = 0;
    var jumps = 0;
    var previous = controller.state.teacher.mode;
    while (!controller.state.status.isFinished && inspections < 2) {
      final state = controller.state;
      // Cố tình bị bắt gặp tới 80 rồi chỉ viết bài: cô nghi ngờ rồi tới soi.
      if (state.isPlayerSeen && state.suspicion < 80) {
        controller.press(PlayerAction.cheat);
      } else {
        controller.press(PlayerAction.write);
      }
      final before = state.suspicion;
      controller.tick(0.02);
      final mode = controller.state.teacher.mode;
      if (mode == TeacherMode.inspect && previous != TeacherMode.inspect) {
        inspections++;
      }
      if (controller.state.suspicion - before > GameTuning.inspectRisk / 2) {
        jumps++;
      }
      previous = mode;
    }
    expect(inspections, greaterThan(0));
    expect(jumps, inspections);
    expect(TeacherTuning.approachAt, lessThan(GameTuning.maxValue));
  });
}

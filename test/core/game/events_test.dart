import 'package:dung_de_thay_thay/core/game/event_scheduler.dart';
import 'package:dung_de_thay_thay/core/game/game_controller.dart';
import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/core/game/level_event.dart';
import 'package:dung_de_thay_thay/core/game/levels.dart';
import 'package:dung_de_thay_thay/core/game/teacher_squad.dart';
import 'package:dung_de_thay_thay/core/game/teacher_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Chạy ván, gọi [each] mỗi tick, dừng khi [until] đúng hoặc hết [limit] giây.
void run(
  GameController controller, {
  required bool Function() until,
  void Function()? each,
  double limit = 120,
}) {
  for (var t = 0.0; t < limit && !until(); t += 0.02) {
    each?.call();
    controller.tick(0.02);
  }
}

GameController startLevel(int id, {int seed = 1}) =>
    GameController(seed: seed, level: levelById(id))..start();

void main() {
  test('mọi sự kiện đều báo trước rồi mới diễn ra, rồi kết thúc', () {
    for (final level in allLevels) {
      final controller = startLevel(level.id);
      final phases = <EventPhase>[];
      run(
        controller,
        until: () => controller.state.status.isFinished,
        each: () {
          final event = controller.state.event;
          if (phases.isEmpty || phases.last != event.phase) {
            phases.add(event.phase);
          }
          if (event.isAskingPlayer) controller.acknowledgeQuestion();
          if (event.isPaperDropped) controller.pickUpPaper();
          controller.press(PlayerAction.write);
        },
      );
      final where = level.specialEventId;
      expect(phases.indexOf(EventPhase.warning), greaterThan(0), reason: where);
      expect(
        phases.indexOf(EventPhase.active),
        phases.indexOf(EventPhase.warning) + 1,
        reason: where,
      );
      if (where != 'final_boss_mode') {
        expect(phases.last, EventPhase.done, reason: where);
      }
    }
  });

  group('cô hỏi bài (màn 1)', () {
    test('cô quay sang nhìn, trả lời thì bớt nghi ngờ và cô thôi hỏi', () {
      final controller = startLevel(1);
      run(controller, until: () => controller.state.event.isAskingPlayer);
      expect(controller.state.remainingSeconds, closeTo(90 - 26.5, 0.1));
      run(controller, until: () => controller.state.teacher.isWatchingClass);
      expect(controller.state.event.isAskingPlayer, isTrue);
      expect(controller.state.isPlayerSeen, isTrue);
      final before = controller.state.suspicion;
      controller.acknowledgeQuestion();
      expect(controller.state.event.phase, EventPhase.done);
      expect(controller.state.suspicion, lessThanOrEqualTo(before));
      expect(controller.state.teacher.mode, isNot(TeacherMode.lookLeft));
    });

    test('làm ngơ thì bị cộng nghi ngờ đúng một lần, không thua ngay', () {
      final controller = startLevel(1);
      run(controller, until: () => controller.state.event.isAskingPlayer);
      final before = controller.state.suspicion;
      run(
        controller,
        until: () => controller.state.event.phase == EventPhase.done,
      );
      final after = controller.state.suspicion;
      expect(after, greaterThan(before));
      expect(after - before, lessThanOrEqualTo(questionIgnoredRisk));
      expect(controller.state.status, GameStatus.running);
    });

    test('10 giây đầu là hướng dẫn: cóp liều cũng không bị bắt', () {
      final controller = startLevel(1)..press(PlayerAction.cheat);
      run(controller, until: () => controller.state.tutorialRemaining <= 0);
      expect(controller.state.status, GameStatus.running);
      expect(
        controller.state.suspicion,
        lessThanOrEqualTo(tutorialSuspicionCap),
      );
    });
  });

  group('quạt gió (màn 2)', () {
    test('dùng phao lúc gió thổi thì giấy rơi, nhặt lên thì hết bị nghi', () {
      final controller = startLevel(2);
      run(controller, until: () => controller.state.event.isWindy);
      controller.selectSkill('cheat_sheet');
      controller.press(PlayerAction.cheat);
      controller.tick(0.02);
      final event = controller.state.event;
      expect(event.isPaperDropped, isTrue);
      expect(controller.state.skills.isHolding, isFalse);
      controller.release(PlayerAction.cheat);
      final before = controller.state.suspicion;
      for (var i = 0; i < 50; i++) {
        controller.tick(0.02);
      }
      expect(controller.state.suspicion, greaterThan(before));
      controller.pickUpPaper();
      expect(controller.state.event.isPaperDropped, isFalse);
      expect(controller.state.status, GameStatus.running);
    });

    test('không dùng giấy lúc gió thì không sao', () {
      final controller = startLevel(2);
      run(
        controller,
        until: () => controller.state.event.phase == EventPhase.done,
        each: () => controller.press(PlayerAction.write),
      );
      expect(controller.state.event.isPaperDropped, isFalse);
    });
  });

  group('lệch mã đề (màn 3)', () {
    GameController duringEvent() {
      final controller = startLevel(3, seed: 2);
      run(controller, until: () => controller.state.event.isActive);
      return controller;
    }

    void askFriendWhenSafe(GameController controller) {
      controller.selectSkill('ask_friend');
      run(controller, until: () => !controller.state.teacher.isWatchingClass);
      controller.press(PlayerAction.cheat);
      controller.release(PlayerAction.cheat);
      run(
        controller,
        until: () =>
            !controller.state.skills.isHolding &&
            controller.state.skills.active == null,
      );
    }

    test('gợi ý của bạn bị giữ lại, không âm thầm cộng hay trừ tiến độ', () {
      final controller = duringEvent();
      final before = controller.state.progress;
      askFriendWhenSafe(controller);
      final hint = controller.state.event.pendingHint;
      if (hint == null) {
        markTestSkipped('cô thấy lúc bạn đưa gợi ý ở seed này');
        return;
      }
      expect(hint.skillId, 'ask_friend');
      expect(controller.state.progress, closeTo(before, 0.5));
      controller.resolveHint(isSelfWrite: true);
      expect(controller.state.progress, closeTo(before + hint.amount / 2, 0.5));
      expect(controller.state.event.pendingHint, isNull);
    });

    test('hỏi lại thì được dùng lại kỹ năng ngay', () {
      final controller = duringEvent();
      askFriendWhenSafe(controller);
      if (controller.state.event.pendingHint == null) {
        markTestSkipped('cô thấy lúc bạn đưa gợi ý ở seed này');
        return;
      }
      expect(controller.state.skills.isReady('ask_friend'), isFalse);
      controller.resolveHint(isSelfWrite: false);
      expect(controller.state.skills.isReady('ask_friend'), isTrue);
    });

    test('kỹ năng không nhờ bạn thì không bị chặn', () {
      final scheduler = EventScheduler('wrong_exam_code');
      while (!scheduler.snapshot.isActive) {
        scheduler.update(0.1, remainingSeconds: 60);
      }
      expect(scheduler.interceptAllyGain('pencil_case', 8), isFalse);
      expect(scheduler.interceptAllyGain('signal', 10), isTrue);
    });
  });

  group('đổi giám thị (màn 4)', () {
    test('hai cô chú ý độc lập, mỗi cô một nửa lối', () {
      final controller = startLevel(4);
      expect(controller.state.teachers, hasLength(2));
      var differentModes = 0;
      run(
        controller,
        until: () => controller.state.event.phase == EventPhase.warning,
        each: () {
          final [a, b] = controller.state.teachers;
          if (a.mode != b.mode) differentModes++;
          expect(a.x, lessThanOrEqualTo(leftHalfLane.maxX + 1));
          expect(b.x, greaterThanOrEqualTo(rightHalfLane.minX - 1));
        },
      );
      expect(differentModes, greaterThan(100));
    });

    test('sau báo trước hai cô đổi chỗ cho nhau', () {
      final controller = startLevel(4);
      run(controller, until: () => controller.state.event.isActive);
      run(
        controller,
        until: () => controller.state.event.phase == EventPhase.done,
      );
      final [a, b] = controller.state.teachers;
      expect(a.x, greaterThanOrEqualTo(rightHalfLane.minX - 1));
      expect(b.x, lessThanOrEqualTo(leftHalfLane.maxX + 1));
    });

    test('hai cô cùng thấy thì nghi ngờ tăng gấp đôi', () {
      final controller = startLevel(4, seed: 3)..press(PlayerAction.cheat);
      var sawDouble = false;
      run(
        controller,
        until: () => sawDouble || controller.state.status.isFinished,
        each: () {
          final before = controller.state;
          final seenByBoth = !before.seenBy.contains(false);
          if (!seenByBoth || !before.skills.isHolding) return;
          controller.tick(0.02);
          final after = controller.state;
          if (!after.seenBy.every((seen) => seen)) return;
          final rate = (after.suspicion - before.suspicion) / 0.02;
          expect(rate, closeTo(38 * 0.65 * 2, 0.5));
          sawDouble = true;
        },
      );
      expect(sawDouble, isTrue);
    });
  });

  group('boss cuối (màn 5)', () {
    test('20 giây cuối bật chế độ boss, vẫn báo trước, vẫn có lúc an toàn', () {
      final controller = startLevel(5);
      run(
        controller,
        until: () => controller.state.event.isBossMode,
        each: () => controller.press(PlayerAction.write),
      );
      expect(controller.state.remainingSeconds, closeTo(20 - 1.5, 0.1));
      var safeTicks = 0;
      var watchStarts = 0;
      var warnedStarts = 0;
      var wasWatching = false;
      var wasWarning = false;
      run(
        controller,
        until: () => controller.state.status.isFinished,
        each: () {
          final teacher = controller.state.teacher;
          if (!teacher.isWatchingClass) safeTicks++;
          if (teacher.isWatchingClass && !wasWatching) {
            watchStarts++;
            if (wasWarning) warnedStarts++;
          }
          wasWatching = teacher.isWatchingClass;
          wasWarning = teacher.isWarning;
        },
      );
      expect(safeTicks, greaterThan(100), reason: 'vẫn có lúc an toàn');
      expect(warnedStarts, watchStarts, reason: 'mọi lần nhìn đều báo trước');
    });
  });
}

import 'dart:math' as math;

import 'package:dung_de_thay_thay/core/game/levels.dart';
import 'package:dung_de_thay_thay/core/game/skill_config.dart';
import 'package:dung_de_thay_thay/core/game/skill_controller.dart';
import 'package:dung_de_thay_thay/core/game/skill_runtime.dart';
import 'package:dung_de_thay_thay/core/game/skills.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hàng bảng: id, trigger, loại hiệu ứng, hồi chiêu, mở ở màn.
const catalogTable = <(String, SkillTrigger, SkillEffectKind, double, int)>[
  ('peek', SkillTrigger.hold, SkillEffectKind.holdProgress, 2, 1),
  ('pretend', SkillTrigger.tap, SkillEffectKind.recoverSuspicion, 5, 1),
  ('cheat_sheet', SkillTrigger.hold, SkillEffectKind.holdProgress, 7, 2),
  ('pencil_case', SkillTrigger.tap, SkillEffectKind.instantProgress, 12, 2),
  (
    'pass_note',
    SkillTrigger.timedRelease,
    SkillEffectKind.instantProgress,
    15,
    3,
  ),
  ('ask_friend', SkillTrigger.tap, SkillEffectKind.instantProgress, 10, 3),
  ('eraser', SkillTrigger.tap, SkillEffectKind.randomProgress, 13, 4),
  ('hide_note', SkillTrigger.tap, SkillEffectKind.recoverSuspicion, 6, 4),
  ('ruler', SkillTrigger.hold, SkillEffectKind.holdProgress, 8, 5),
  ('calculator', SkillTrigger.choice, SkillEffectKind.minigame, 14, 5),
  ('signal', SkillTrigger.choice, SkillEffectKind.minigame, 11, 5),
  ('oscar', SkillTrigger.tap, SkillEffectKind.recoverSuspicion, 16, 5),
];

SkillController controllerFor(String id, {int seed = 1}) =>
    SkillController(random: math.Random(seed), available: [skillById(id)]);

/// Dùng kỹ năng theo đúng cách kích hoạt, khi cô không nhìn, rồi chạy tới
/// khi xong. Trả về tổng tác động cộng dồn.
({double progress, double recovered, bool wasCheating}) useWell(
  SkillController skills, {
  bool isWatching = false,
}) {
  final skill = skills.selected;
  var progress = 0.0;
  var recovered = 0.0;
  var wasCheating = false;
  skills.press(isWatching: isWatching);
  final choice = skills.snapshot.active?.choice;
  if (choice != null) skills.answer(choice.correctIndex);
  var time = 0.0;
  while (time < 6) {
    if (skill.trigger == SkillTrigger.timedRelease && time >= 1.1) {
      skills.release();
    }
    final tick = skills.tick(0.02, isSeen: isWatching);
    progress += tick.progressRate * 0.02 + tick.instantGain;
    recovered += tick.recoverRate * 0.02;
    wasCheating = wasCheating || tick.isCheating;
    time += 0.02;
    if (skill.isHold && time >= 2) skills.release();
    if (!skills.isBusy && time > 0.1) break;
  }
  return (progress: progress, recovered: recovered, wasCheating: wasCheating);
}

void main() {
  test('đúng 12 kỹ năng, id không trùng, khớp bảng catalog', () {
    expect(allSkills, hasLength(12));
    expect(allSkills.map((s) => s.id).toSet(), hasLength(12));
    for (final (id, trigger, kind, cooldown, unlock) in catalogTable) {
      final skill = skillById(id);
      expect(skill.trigger, trigger, reason: id);
      expect(skill.effectKind, kind, reason: id);
      expect(skill.cooldownSeconds, cooldown, reason: id);
      expect(skill.unlockLevel, unlock, reason: id);
    }
  });

  test('số liệu hợp lệ: rủi ro không âm, hồi phục chỉ qua loại riêng', () {
    for (final skill in allSkills) {
      expect(skill.riskMultiplier, greaterThanOrEqualTo(0), reason: skill.id);
      expect(skill.value, greaterThan(0), reason: skill.id);
      expect(skill.cooldownSeconds, greaterThan(0), reason: skill.id);
      if (skill.isRecovery) expect(skill.riskMultiplier, 0, reason: skill.id);
      if (!skill.isRecovery) {
        expect(skill.riskMultiplier, greaterThan(0), reason: skill.id);
      }
      if (!skill.isHold) {
        expect(skill.castSeconds, greaterThan(0), reason: skill.id);
      }
      expect(skill.value, lessThanOrEqualTo(30), reason: skill.id);
    }
  });

  test('mỗi kỹ năng đều có tác dụng thật khi dùng đúng cách', () {
    for (final skill in allSkills) {
      final isWatching = skill.condition == SkillCondition.teacherWatching;
      final controller = controllerFor(skill.id, seed: 4);
      var best = 0.0;
      for (var attempt = 0; attempt < 12; attempt++) {
        final result = useWell(controller, isWatching: isWatching);
        best = math.max(best, result.progress + result.recovered);
        controller.tick(30, isSeen: false);
      }
      expect(best, greaterThan(0), reason: skill.id);
    }
  });

  test('kỹ năng tiến độ chịu rủi ro, kỹ năng hồi phục thì không', () {
    for (final skill in allSkills) {
      final result = useWell(controllerFor(skill.id));
      expect(result.wasCheating, !skill.isRecovery, reason: skill.id);
    }
  });

  test(
    'dùng xong thì hồi chiêu; bấm sớm báo còn bao lâu, không có tác dụng',
    () {
      for (final skill in allSkills) {
        final controller = controllerFor(skill.id);
        useWell(controller);
        final snapshot = controller.snapshot;
        expect(snapshot.isReady(skill.id), isFalse, reason: skill.id);
        controller.press(isWatching: false);
        expect(controller.isBusy, isFalse, reason: skill.id);
        final feedback = controller.snapshot.feedback!;
        expect(feedback.outcome, SkillOutcome.notReady, reason: skill.id);
        expect(feedback.amount, greaterThan(0), reason: skill.id);
        controller.tick(skill.cooldownSeconds + 0.1, isSeen: false);
        expect(controller.snapshot.isReady(skill.id), isTrue, reason: skill.id);
      }
    },
  );

  test('kỹ năng không có ở màn này thì báo khóa', () {
    final controller = SkillController(
      random: math.Random(1),
      available: [for (final id in levelOne.skillIds) skillById(id)],
    );
    controller.select('ruler');
    expect(controller.selected.id, 'peek');
    expect(controller.snapshot.feedback!.outcome, SkillOutcome.locked);
    controller.select('pretend');
    expect(controller.selected.id, 'pretend');
  });

  test('giữ kỹ năng khi cô nhìn: không có tiến độ, báo thất bại một lần', () {
    final controller = controllerFor('peek')..press(isWatching: true);
    var progress = 0.0;
    var failures = 0;
    var lastSerial = 0;
    for (var i = 0; i < 50; i++) {
      final tick = controller.tick(0.02, isSeen: true);
      progress += tick.progressRate;
      expect(tick.isCheating, isTrue);
      final feedback = controller.snapshot.feedback;
      if (feedback != null && feedback.serial != lastSerial) {
        failures++;
        lastSerial = feedback.serial;
      }
    }
    expect(progress, 0);
    expect(failures, 1);
  });

  test('thi triển bị cô thấy lúc xong thì thất bại và bị nghi thêm', () {
    final controller = controllerFor('pencil_case')..press(isWatching: false);
    SkillTick last = SkillTick.none;
    while (controller.isBusy) {
      last = controller.tick(0.02, isSeen: true);
    }
    expect(last.instantGain, 0);
    expect(last.extraRisk, failInSightRisk);
    expect(controller.snapshot.feedback!.outcome, SkillOutcome.failure);
  });

  test('đồng đội từ chối khi bấm lúc cô đang nhìn', () {
    final result = useWell(controllerFor('ask_friend'), isWatching: true);
    expect(result.progress, 0);
    final calm = useWell(controllerFor('ask_friend'));
    expect(calm.progress, 7);
  });

  test(
    'chuyền giấy: thả trong cửa sổ thì được, thả sớm hay giữ quá thì bay',
    () {
      for (final (releaseAt, expected) in [
        (1.1, 12.0),
        (0.4, 0.0),
        (9.0, 0.0),
      ]) {
        final controller = controllerFor('pass_note')..press(isWatching: false);
        var gain = 0.0;
        for (var t = 0.0; controller.isBusy && t < 5; t += 0.02) {
          if (t >= releaseAt) controller.release();
          gain += controller.tick(0.02, isSeen: false).instantGain;
        }
        expect(gain, expected, reason: 'thả lúc $releaseAt');
      }
    },
  );

  test('câu đố: sai thì báo lỗi không kẹt, hết giờ thì thất bại', () {
    final wrong = controllerFor('calculator')..press(isWatching: false);
    final choice = wrong.snapshot.active!.choice!;
    expect(choice.options.toSet(), hasLength(3));
    expect(
      choice.options[choice.correctIndex],
      choice.operands[0] + choice.operands[1],
    );
    wrong.answer((choice.correctIndex + 1) % 3);
    var wrongGain = 0.0;
    var waited = 0.0;
    while (wrong.isBusy && waited < 2) {
      wrongGain += wrong.tick(0.02, isSeen: false).instantGain;
      waited += 0.02;
    }
    expect(wrongGain, 0);
    expect(wrong.isBusy, isFalse, reason: 'không bị kẹt trong câu đố');
    expect(waited, closeTo(minChoiceSeconds, 0.05));
    expect(wrong.snapshot.feedback!.outcome, SkillOutcome.failure);

    final slow = controllerFor('signal')..press(isWatching: false);
    var gain = 0.0;
    for (var t = 0.0; slow.isBusy && t < 5; t += 0.02) {
      gain += slow.tick(0.02, isSeen: false).instantGain;
    }
    expect(gain, 0);
    expect(slow.snapshot.feedback!.outcome, SkillOutcome.failure);
  });

  test('tẩy tiên tri ra 0, 5 hoặc 10 theo seed, lặp lại được', () {
    List<double> rolls(int seed) {
      final controller = controllerFor('eraser', seed: seed);
      return [
        for (var i = 0; i < 20; i++) ...[
          useWell(controller).progress,
          if (controller.tick(20, isSeen: false).isCheating) -1,
        ],
      ];
    }

    final first = rolls(9);
    expect(first.toSet().difference({0.0, 5.0, 10.0}), isEmpty);
    expect(first.toSet().length, greaterThan(1));
    expect(rolls(9), first);
  });

  test('Oscar: diễn khi cô nhìn hồi đủ, diễn khi không ai xem thì lố', () {
    final watched = useWell(controllerFor('oscar'), isWatching: true);
    final unseen = useWell(controllerFor('oscar'));
    expect(watched.recovered, greaterThan(unseen.recovered * 2));
  });

  test('hủy khi tạm dừng hoàn hồi chiêu, khi đổi hành động thì không', () {
    final paused = controllerFor('pencil_case')..press(isWatching: false);
    paused.cancel(keepCooldown: false);
    expect(paused.snapshot.isReady('pencil_case'), isTrue);
    expect(paused.isBusy, isFalse);
    final switched = controllerFor('pencil_case')..press(isWatching: false);
    switched.cancel(keepCooldown: true);
    expect(switched.snapshot.isReady('pencil_case'), isFalse);
  });
}

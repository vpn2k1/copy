import 'dart:math' as math;

import 'skill_config.dart';
import 'skill_runtime.dart';

/// Câu đố ngắn cho kỹ năng chọn đáp án, sinh từ [random] có seed.
/// `signal`: bạn giơ 1–3 ngón, đáp án A/B/C tương ứng. `calculator`: phép
/// cộng hai số, ba đáp án khác nhau. Kỹ năng không phải loại chọn → null.
SkillChoice? puzzleFor(SkillConfig skill, math.Random random) {
  if (skill.trigger != SkillTrigger.choice) return null;
  if (skill.id == 'signal') {
    final fingers = 1 + random.nextInt(3);
    return SkillChoice(
      operands: [fingers],
      options: const [0, 1, 2],
      correctIndex: fingers - 1,
    );
  }
  final a = 12 + random.nextInt(38);
  final b = 11 + random.nextInt(29);
  final answer = a + b;
  final options = <int>{answer};
  while (options.length < 3) {
    final offset = 1 + random.nextInt(9);
    options.add(answer + offset * _randomSign(random));
  }
  final shuffled = options.toList()..shuffle(random);
  return SkillChoice(
    operands: [a, b],
    options: shuffled,
    correctIndex: shuffled.indexOf(answer),
  );
}

int _randomSign(math.Random random) {
  if (random.nextBool()) return 1;
  return -1;
}

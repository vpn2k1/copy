import 'package:flutter/material.dart';

import '../../../core/game/skill_runtime.dart';
import '../../../core/game/skills.dart';
import '../../../l10n/strings.dart';

/// Bảng nhỏ phía trên nút cóp khi đang thi triển: thanh tiến trình (có vùng
/// xanh cho kỹ năng thả đúng nhịp) và câu đố ba đáp án nếu có.
class SkillCastPanel extends StatelessWidget {
  const SkillCastPanel({
    super.key,
    required this.active,
    required this.onAnswer,
  });

  final ActiveSkill active;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    final choice = active.choice;
    return Container(
      key: const Key('skill.cast'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Strings.skillName(active.skillId),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(height: 4),
          _progressBar(),
          if (choice != null) ...[
            const SizedBox(height: 6),
            Text(
              _prompt(choice),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            _options(choice),
          ],
        ],
      ),
    );
  }

  Widget _progressBar() {
    final skill = skillById(active.skillId);
    final (from, to) = skill.timingWindow;
    final hasWindow = to > from;
    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            Container(color: Colors.white12),
            if (hasWindow)
              Positioned(
                left: box.maxWidth * from / active.castSeconds,
                width: box.maxWidth * (to - from) / active.castSeconds,
                top: 0,
                bottom: 0,
                child: Container(color: Colors.green.withValues(alpha: 0.6)),
              ),
            FractionallySizedBox(
              widthFactor: active.progress,
              child: Container(color: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }

  String _prompt(SkillChoice choice) {
    if (active.skillId == 'signal') {
      return Strings.signalPrompt(choice.operands.first);
    }
    return Strings.calculatorPrompt(choice.operands[0], choice.operands[1]);
  }

  Widget _options(SkillChoice choice) {
    return Row(
      children: [
        for (var i = 0; i < choice.options.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: FilledButton(
              key: Key('skill.choice.$i'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 34),
              ),
              onPressed: () => onAnswer(i),
              child: Text(_optionLabel(choice, i)),
            ),
          ),
        ],
      ],
    );
  }

  String _optionLabel(SkillChoice choice, int index) {
    if (active.skillId == 'signal') {
      return Strings.signalOptions[choice.options[index]];
    }
    return '${choice.options[index]}';
  }
}

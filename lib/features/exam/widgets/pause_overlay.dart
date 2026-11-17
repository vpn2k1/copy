import 'package:flutter/material.dart';

import '../../../core/game/skills.dart';
import '../../../l10n/strings.dart';

/// Lớp phủ khi game tạm dừng. Chỉ chạy tiếp khi người chơi bấm TIẾP TỤC.
/// Nút tiếp tục đặt ngay dưới tiêu đề để luôn bấm được trên màn thấp.
/// Kèm danh sách đủ 12 kỹ năng: có ở màn này hay mở ở màn nào.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.availableSkillIds,
    required this.onResume,
    required this.onExit,
  });

  final List<String> availableSkillIds;
  final VoidCallback onResume;
  final VoidCallback onExit;

  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(_gap),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Strings.pausedTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: _gap / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          key: const Key('pause.resume'),
                          onPressed: onResume,
                          child: const Text(Strings.resumeButton),
                        ),
                        const SizedBox(width: _gap / 2),
                        TextButton(
                          onPressed: onExit,
                          child: const Text(Strings.backToMenu),
                        ),
                      ],
                    ),
                    const SizedBox(height: _gap),
                    _skillList(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _skillList(BuildContext context) {
    return Column(
      key: const Key('pause.skills'),
      children: [
        Text(
          Strings.skillsTitle,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [for (final skill in allSkills) _chip(skill.id)],
        ),
      ],
    );
  }

  Widget _chip(String id) {
    final isAvailable = availableSkillIds.contains(id);
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(_icon(isAvailable), size: 16),
      label: Text(
        _label(id, isAvailable),
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  IconData _icon(bool isAvailable) {
    if (isAvailable) return Icons.check_circle;
    return Icons.lock;
  }

  String _label(String id, bool isAvailable) {
    final name = Strings.skillName(id);
    if (isAvailable) return name;
    return '$name · ${Strings.skillUnlockAt(skillById(id).unlockLevel)}';
  }
}

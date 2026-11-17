import 'package:flutter/material.dart';

import '../../../core/game/skill_runtime.dart';
import '../../../l10n/strings.dart';

/// Thanh chọn kỹ năng của màn: chạm để chọn kỹ năng cho nút cóp. Kỹ năng
/// đang hồi chiêu hiện số giây còn lại.
class SkillBar extends StatelessWidget {
  const SkillBar({super.key, required this.skills, required this.onSelect});

  final SkillSnapshot skills;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: skills.availableIds.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) => _chip(skills.availableIds[index]),
      ),
    );
  }

  Widget _chip(String id) {
    final isSelected = id == skills.selectedId;
    return GestureDetector(
      key: Key('skill.$id'),
      onTap: () => onSelect(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _fill(isSelected),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border(isSelected), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Strings.skillName(id),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (!skills.isReady(id))
              Text(
                Strings.secondsLeft(skills.cooldownOf(id).ceil()),
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  Color _fill(bool isSelected) {
    if (isSelected) return const Color(0xCCE65100);
    return Colors.black54;
  }

  Color _border(bool isSelected) {
    if (isSelected) return Colors.white;
    return Colors.white24;
  }
}

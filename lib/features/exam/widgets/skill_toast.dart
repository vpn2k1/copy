import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/game/skill_runtime.dart';
import '../../../core/game/skills.dart';
import '../../../l10n/strings.dart';

/// Dòng phản hồi ngắn sau mỗi lần dùng kỹ năng: được bao nhiêu, thất bại hài
/// hước, còn hồi chiêu hay chưa mở. Hiện 1,6 giây mỗi khi có phản hồi mới.
class SkillToast extends StatefulWidget {
  const SkillToast({super.key, required this.feedback});

  final SkillFeedback? feedback;

  @override
  State<SkillToast> createState() => _SkillToastState();
}

class _SkillToastState extends State<SkillToast> {
  static const _visibleFor = Duration(milliseconds: 1600);

  Timer? hideTimer;
  bool isVisible = false;

  @override
  void didUpdateWidget(SkillToast old) {
    super.didUpdateWidget(old);
    final serial = widget.feedback?.serial;
    if (serial == null || serial == old.feedback?.serial) return;
    hideTimer?.cancel();
    isVisible = true;
    hideTimer = Timer(_visibleFor, () {
      if (mounted) setState(() => isVisible = false);
    });
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedback = widget.feedback;
    if (feedback == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _opacity(),
        duration: const Duration(milliseconds: 150),
        child: Container(
          key: const Key('skill.toast'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _color(feedback.outcome),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _message(feedback),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  double _opacity() {
    if (isVisible) return 1;
    return 0;
  }

  Color _color(SkillOutcome outcome) {
    return switch (outcome) {
      SkillOutcome.success => const Color(0xE62E7D32),
      SkillOutcome.failure => const Color(0xE6C62828),
      _ => const Color(0xE6424242),
    };
  }

  String _message(SkillFeedback feedback) {
    final amount = feedback.amount.round();
    return switch (feedback.outcome) {
      SkillOutcome.success => _successText(feedback.skillId, amount),
      SkillOutcome.failure => Strings.skillFailure(feedback.skillId),
      SkillOutcome.notReady => Strings.skillNotReady(feedback.amount.ceil()),
      SkillOutcome.locked => Strings.skillLocked,
      SkillOutcome.busy => Strings.skillBusy,
    };
  }

  String _successText(String id, int amount) {
    if (skillById(id).isRecovery) return Strings.skillRecovered(amount);
    return Strings.skillProgress(amount);
  }
}

import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../core/game/scene_pose.dart';
import '../../../core/animation/teacher_rig.dart';
import '../../../l10n/strings.dart';

/// Dải báo sự kiện dưới HUD: hướng dẫn đầu màn 1, báo trước và trạng thái
/// sự kiện, kèm nút phản ứng (trả lời cô, nhặt giấy, xử lý gợi ý lệch mã đề).
class EventBanner extends StatelessWidget {
  const EventBanner({
    super.key,
    required this.state,
    required this.onAcknowledge,
    required this.onPickUp,
    required this.onResolveHint,
  });

  final GameState state;
  final VoidCallback onAcknowledge;
  final VoidCallback onPickUp;
  final void Function({required bool isSelfWrite}) onResolveHint;

  @override
  Widget build(BuildContext context) {
    final rows = _rows();
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows) ...[row, const SizedBox(height: 4)],
      ],
    );
  }

  List<Widget> _rows() {
    final event = state.event;
    return [
      if (state.tutorialRemaining > 0)
        _pill(_tutorialHint(), const Color(0xE61565C0), key: 'tutorial.hint'),
      if (event.isWarning)
        _pill(
          Strings.eventWarning(event.id),
          const Color(0xE6EF6C00),
          key: 'event.warning',
        ),
      if (event.isActive)
        _pill(
          Strings.eventActive(event.id),
          const Color(0xE6C62828),
          key: 'event.active',
        ),
      if (event.isAskingPlayer)
        _action('event.ack', Strings.answerTeacher, onAcknowledge),
      if (event.isPaperDropped)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pill(Strings.paperDropped, const Color(0xE6C62828)),
            const SizedBox(width: 6),
            _action('event.pickup', Strings.pickUpPaper, onPickUp),
          ],
        ),
      if (event.pendingHint != null) _hintRow(),
    ];
  }

  String _tutorialHint() {
    final cue = teacherCueFor(state.teacher);
    if (cue == TeacherCue.none) return Strings.tutorialHintSafe;
    return Strings.tutorialHintCue;
  }

  Widget _hintRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pill(Strings.hintMismatch, const Color(0xE66A1B9A)),
        const SizedBox(width: 6),
        _action(
          'event.hint.retry',
          Strings.hintRetry,
          () => onResolveHint(isSelfWrite: false),
        ),
        const SizedBox(width: 6),
        _action(
          'event.hint.self',
          Strings.hintSelfWrite,
          () => onResolveHint(isSelfWrite: true),
        ),
      ],
    );
  }

  Widget _pill(String text, Color color, {String? key}) {
    return Container(
      key: _keyOf(key),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _action(String key, String label, VoidCallback onPressed) {
    return FilledButton(
      key: Key(key),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 36),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Key? _keyOf(String? key) {
    if (key == null) return null;
    return Key(key);
  }
}

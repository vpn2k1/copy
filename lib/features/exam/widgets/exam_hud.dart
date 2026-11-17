import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../l10n/strings.dart';
import 'meter_bar.dart';
import 'stat_tile.dart';

/// Dải HUD phía trên: thời gian, hai thanh đo, trạng thái giáo viên.
class ExamHud extends StatelessWidget {
  const ExamHud({super.key, required this.state, this.isDebug = false});

  final GameState state;

  /// Nghi ngờ từ mức này trở lên thì HUD báo đỏ "SẮP BỊ BẮT!".
  static const double dangerSuspicion = 70;

  /// Hiện thêm chế độ AI giáo viên (bật bằng `--dart-define=DEBUG_HUD=true`).
  final bool isDebug;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _background(),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            StatTile(
              key: const Key('hud.timer'),
              name: Strings.timeStat,
              value: Strings.secondsLeft(state.remainingSeconds.ceil()),
            ),
            const SizedBox(width: 12),
            Expanded(child: _meters()),
            const SizedBox(width: 12),
            _visibility(),
          ],
        ),
      ),
    );
  }

  Widget _meters() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MeterBar(
          key: const Key('hud.progress'),
          label: Strings.progressMeter,
          value: state.progress,
          color: Colors.lightGreenAccent,
        ),
        const SizedBox(height: 4),
        MeterBar(
          key: const Key('hud.suspicion'),
          label: Strings.suspicionMeter,
          value: state.suspicion,
          color: Colors.redAccent,
        ),
      ],
    );
  }

  Widget _visibility() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _visibilityLabel(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: _visibilityColor(),
          ),
        ),
        if (isDebug)
          Text(
            Strings.debugTeacher(state.teacher.mode.name),
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
      ],
    );
  }

  String _visibilityLabel() {
    if (state.suspicion >= dangerSuspicion) return Strings.suspicionDanger;
    if (state.isPlayerSeen) return Strings.teacherSeeing;
    return Strings.teacherAway;
  }

  Color _visibilityColor() {
    if (state.suspicion >= dangerSuspicion) return Colors.white;
    if (state.isPlayerSeen) return Colors.orangeAccent;
    return Colors.lightGreenAccent;
  }

  /// Nền HUD chuyển đỏ khi sắp bị bắt (kèm chữ, không chỉ dựa vào màu).
  Color _background() {
    if (state.suspicion >= dangerSuspicion) return const Color(0xB3B71C1C);
    return Colors.black54;
  }
}

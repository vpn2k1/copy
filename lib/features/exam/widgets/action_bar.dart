import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../core/game/game_status.dart';
import '../../../l10n/strings.dart';
import 'hold_action_button.dart';
import 'skill_bar.dart';
import 'skill_cast_panel.dart';

/// Hàng nút phía dưới: tay trái viết bài / giả vờ, giữa là thanh kỹ năng,
/// tay phải là nút dùng kỹ năng đang chọn (kèm bảng thi triển phía trên).
class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.state,
    required this.onPress,
    required this.onRelease,
    required this.onSelectSkill,
    required this.onAnswer,
  });

  final GameState state;
  final ValueChanged<PlayerAction> onPress;
  final ValueChanged<PlayerAction> onRelease;
  final ValueChanged<String> onSelectSkill;
  final ValueChanged<int> onAnswer;

  static const double _gap = 8;
  static const double _sideWidth = 112;
  static const double _skillWidth = 170;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _button(
          PlayerAction.write,
          Strings.writeButton,
          const Color(0xFF2E7D32),
          'action.write',
          _sideWidth,
        ),
        const SizedBox(width: _gap),
        _button(
          PlayerAction.hide,
          Strings.hideButton,
          const Color(0xFF6A1B9A),
          'action.hide',
          _sideWidth,
        ),
        const SizedBox(width: _gap),
        Expanded(
          child: SkillBar(skills: state.skills, onSelect: onSelectSkill),
        ),
        const SizedBox(width: _gap),
        SizedBox(
          width: _skillWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._castPanel(),
              _button(
                PlayerAction.cheat,
                _skillLabel(),
                const Color(0xFFE65100),
                'action.cheat',
                _skillWidth,
                height: 64,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _castPanel() {
    final active = state.skills.active;
    if (active == null) return const [];
    return [
      SkillCastPanel(active: active, onAnswer: onAnswer),
      const SizedBox(height: 6),
    ];
  }

  String _skillLabel() {
    final skills = state.skills;
    final name = Strings.skillName(skills.selectedId);
    if (skills.isReady(skills.selectedId)) return name;
    final left = Strings.secondsLeft(
      skills.cooldownOf(skills.selectedId).ceil(),
    );
    return '$name · $left';
  }

  Widget _button(
    PlayerAction action,
    String label,
    Color color,
    String key,
    double width, {
    double height = 56,
  }) {
    return SizedBox(
      width: width,
      child: HoldActionButton(
        key: Key(key),
        label: label,
        color: color,
        height: height,
        isActive: state.heldAction == action,
        isEnabled: state.isRunning,
        onPress: () => onPress(action),
        onRelease: () => onRelease(action),
      ),
    );
  }
}

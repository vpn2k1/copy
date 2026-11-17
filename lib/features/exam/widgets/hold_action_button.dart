import 'package:flutter/material.dart';

import '../../../l10n/strings.dart';

/// Nút nhấn giữ: chạm xuống gọi [onPress], nhấc tay hoặc bị hủy (kéo ra
/// ngoài hệ thống, cuộc gọi đến) gọi [onRelease]. Mỗi lần nhấn luôn có đúng
/// một lần thả.
class HoldActionButton extends StatefulWidget {
  const HoldActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.isActive,
    required this.isEnabled,
    required this.onPress,
    required this.onRelease,
    this.height = 56,
  });

  final String label;
  final Color color;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onPress;
  final VoidCallback onRelease;
  final double height;

  @override
  State<HoldActionButton> createState() => _HoldActionButtonState();
}

class _HoldActionButtonState extends State<HoldActionButton> {
  bool isDown = false;

  void _down() {
    if (!widget.isEnabled) return;
    isDown = true;
    widget.onPress();
  }

  void _up() {
    if (!isDown) return;
    isDown = false;
    widget.onRelease();
  }

  @override
  void dispose() {
    _up();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.isEnabled,
      toggled: widget.isActive,
      label: widget.label,
      hint: Strings.holdHint,
      excludeSemantics: true,
      child: _listener(),
    );
  }

  Widget _listener() {
    return Listener(
      onPointerDown: (_) => _down(),
      onPointerUp: (_) => _up(),
      onPointerCancel: (_) => _up(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        height: widget.height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _fill(),
          borderRadius: BorderRadius.circular(widget.height / 2),
          border: Border.all(color: Colors.white, width: _borderWidth()),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Color _fill() {
    if (!widget.isEnabled) return widget.color.withValues(alpha: 0.35);
    if (widget.isActive) return widget.color;
    return widget.color.withValues(alpha: 0.8);
  }

  double _borderWidth() {
    if (widget.isActive) return 3;
    return 1;
  }
}

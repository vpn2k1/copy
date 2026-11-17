import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'cartoon_paint.dart';

/// Tờ phao bị gió quạt thổi rơi xuống sàn cạnh bàn nhân vật chính. Chỉ hiện
/// khi sự kiện báo giấy đang nằm trên sàn.
class DroppedPaper extends PositionComponent {
  DroppedPaper() : super(position: Vector2(640, 800), priority: 900);

  bool isVisible = false;

  final CartoonPaint _pen = CartoonPaint(outlineWidth: 3);
  double _clock = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;
    canvas.save();
    canvas.rotate(-0.25 + math.sin(_clock * 6) * 0.04);
    _pen.box(
      canvas,
      const Rect.fromLTWH(-46, -30, 92, 60),
      const Color(0xFFFFFFFF),
    );
    for (var i = 0; i < 3; i++) {
      final y = -14.0 + i * 12;
      _pen.line(
        canvas,
        Offset(-32, y),
        Offset(32, y),
        3,
        color: const Color(0xFF90A4AE),
      );
    }
    canvas.restore();
  }
}

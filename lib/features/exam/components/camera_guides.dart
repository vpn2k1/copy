import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

import '../../../core/classroom_layout.dart';
import '../../../core/world_layout.dart';
import '../../../l10n/strings.dart';

/// Chú thích camera chỉ bật khi debug: vùng dành cho HUD và dải giữa nơi
/// đặt vật quan trọng. Bật bằng `--dart-define=CAMERA_GUIDES=true`.
class CameraGuides extends PositionComponent {
  CameraGuides() : super(priority: 3000);

  final Paint _hudBand = Paint()..color = const Color(0x33E53935);
  final Paint _frame = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..color = const Color(0xCC1E88E5);
  final TextPaint _label = TextPaint(
    style: const TextStyle(
      color: Color(0xFF0D47A1),
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
  );

  @override
  void render(Canvas canvas) {
    const width = WorldLayout.width;
    final top = ClassroomLayout.playableTop;
    final bottom = ClassroomLayout.playableBottom;
    canvas.drawRect(Rect.fromLTRB(0, 0, width, top), _hudBand);
    canvas.drawRect(
      Rect.fromLTRB(0, bottom, width, WorldLayout.height),
      _hudBand,
    );
    canvas.drawRect(Rect.fromLTRB(4, top, width - 4, bottom), _frame);
    _label.render(canvas, Strings.cameraGuideLabel, Vector2(20, top + 12));
  }
}

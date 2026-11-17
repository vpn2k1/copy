import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show FontWeight, TextStyle;

import '../../../core/world_layout.dart';
import '../../../l10n/strings.dart';

/// Nền lớp học 2D tĩnh, vẽ từ ảnh đã tải một lần.
class ClassroomBackground extends PositionComponent {
  ClassroomBackground()
    : super(
        size: Vector2(WorldLayout.width, WorldLayout.height),
        priority: -1000,
      );

  ui.Image? _image;
  final ui.Paint _paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
  final TextPaint _title = TextPaint(
    style: const TextStyle(
      color: ui.Color(0xFFF5F5F0),
      fontSize: 44,
      fontWeight: FontWeight.bold,
    ),
  );
  final TextPaint _subject = TextPaint(
    style: const TextStyle(color: ui.Color(0xFFF5F5F0), fontSize: 28),
  );

  @override
  void onLoad() {
    _image = Flame.images.fromCache('classroom.png');
  }

  @override
  void render(ui.Canvas canvas) {
    final image = _image;
    if (image == null) return;
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, width, height),
      _paint,
    );
    _title.render(
      canvas,
      Strings.boardExamTitle,
      Vector2(1010, 250),
      anchor: Anchor.center,
    );
    _subject.render(
      canvas,
      Strings.boardSubject,
      Vector2(1010, 315),
      anchor: Anchor.center,
    );
  }
}

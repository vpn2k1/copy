import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../../core/animation/student_animator.dart';
import '../../../core/animation/student_rig.dart';

enum HairStyle { short, ponytail }

/// Học sinh 2D ngồi ở bàn, đổi ảnh theo tư thế của bộ hoạt ảnh hiện có.
class SeatedStudent extends PositionComponent {
  SeatedStudent({
    required Vector2 seat,
    required double figureScale,
    this.hairStyle = HairStyle.short,
    this.hasScarf = false,
    StudentPose pose = StudentPose.idle,
    double phase = 0,
  }) : animator = StudentAnimator(pose, phase: phase),
       super(
         position: seat,
         scale: Vector2.all(figureScale),
         priority: seat.y.toInt(),
       );

  final HairStyle hairStyle;
  final bool hasScarf;
  final StudentAnimator animator;
  final ui.Paint _paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
  late final ui.Image _writing;
  late final ui.Image _idle;
  late final ui.Image _nervous;
  late final ui.Image _girl;
  late final ui.Image _cheating;
  late final ui.Image _caught;
  late final ui.Image _celebrating;

  StudentPose get pose => animator.pose;

  bool setPose(StudentPose next) => animator.change(next);

  @override
  void onLoad() {
    _writing = Flame.images.fromCache('student_writing.png');
    _idle = Flame.images.fromCache('student_idle.png');
    _nervous = Flame.images.fromCache('student_nervous.png');
    _girl = Flame.images.fromCache('student_girl.png');
    _cheating = Flame.images.fromCache('student_cheating.png');
    _caught = Flame.images.fromCache('student_caught.png');
    _celebrating = Flame.images.fromCache('student_celebrating.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    animator.update(dt);
  }

  @override
  void render(ui.Canvas canvas) {
    final image = _imageForPose();
    final rig = animator.rig;
    canvas.save();
    canvas.translate(rig.body.x * 0.3, rig.body.y * 0.3);
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      const ui.Rect.fromLTWH(-112, -560, 550, 560),
      _paint,
    );
    canvas.restore();
  }

  ui.Image _imageForPose() {
    if (pose == StudentPose.caught) return _caught;
    if (pose == StudentPose.celebrating) return _celebrating;
    if (pose == StudentPose.cheating) return _cheating;
    if (pose == StudentPose.hiding) return _idle;
    if (hairStyle == HairStyle.ponytail) return _girl;
    if (pose == StudentPose.idle) return _idle;
    if (pose == StudentPose.nervous) return _nervous;
    return _writing;
  }
}

import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../../core/animation/teacher_animator.dart';
import '../../../core/animation/teacher_rig.dart';
import 'cartoon_paint.dart';
import 'teacher_cue.dart';

/// Giáo viên 2D. Cảnh báo hướng nhìn vẫn nằm trên đầu nhân vật.
class TeacherFigure extends PositionComponent {
  TeacherFigure({
    required Vector2 feet,
    required double figureScale,
    this.cueScale = 2,
    this.aoDai = purpleAoDai,
    this.aoDaiLight = const ui.Color(0xFFA472C4),
    this.watchingCueColor = TeacherCuePainter.defaultWatchingColor,
  }) : super(
         position: feet,
         scale: Vector2.all(figureScale),
         priority: feet.y.toInt(),
       );

  final TeacherAnimator animator = TeacherAnimator();
  static const ui.Color purpleAoDai = ui.Color(0xFF7B3FA0);
  static const ui.Color blueAoDai = ui.Color(0xFF1565C0);
  static const ui.Color blueAoDaiLight = ui.Color(0xFF64B5F6);
  static const ui.Color blueCue = ui.Color(0xFF81D4FA);
  final ui.Color aoDai;
  final ui.Color aoDaiLight;
  final ui.Color watchingCueColor;
  final double cueScale;
  final ui.Paint _paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
  late final TeacherCuePainter _cue = TeacherCuePainter(
    CartoonPaint(outlineWidth: 6),
    watchingColor: watchingCueColor,
  );
  late final ui.Image _standing;
  late final ui.Image _pointing;

  TeacherPose get pose => animator.pose;

  bool setPose(TeacherPose next) => animator.change(next);

  @override
  void onLoad() {
    var name = 'teacher_purple.png';
    if (aoDai == blueAoDai) name = 'teacher_blue.png';
    _standing = Flame.images.fromCache(name);
    _pointing = Flame.images.fromCache('teacher_pointing.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    animator.update(dt);
  }

  @override
  void render(ui.Canvas canvas) {
    final rig = animator.rig;
    var image = _standing;
    if (rig.isPointing && aoDai != blueAoDai) image = _pointing;
    canvas.save();
    canvas.scale(rig.scaleX, 1);
    canvas.translate(rig.lean, rig.bodyY);
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      const ui.Rect.fromLTWH(-170, -540, 340, 540),
      _paint,
    );
    canvas.restore();
    final radius = TeacherCuePainter.radius * cueScale;
    canvas.save();
    canvas.translate(0, -520 - radius - 16);
    canvas.scale(cueScale);
    var lookSign = 1.0;
    if (rig.facesLeft) lookSign = -1;
    _cue.paint(canvas, ui.Offset.zero, rig.cue, lookSign);
    canvas.restore();
  }
}

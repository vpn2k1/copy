import 'dart:ui';

import '../../../core/animation/teacher_rig.dart';
import 'cartoon_paint.dart';

/// Biểu tượng chú ý trên đầu giáo viên, để người chơi biết cô đang nhìn đâu
/// trong chưa đầy một giây: mắt vàng kèm mũi tên chỉ hướng khi đang quan sát,
/// dấu hỏi cam khi nghi ngờ, dấu chấm than đỏ khi bắt được. Trước khi quay
/// sang nhìn lớp có bóng "…" màu kem để người chơi kịp phản ứng.
class TeacherCuePainter {
  TeacherCuePainter(this._pen, {this.watchingColor = defaultWatchingColor});

  final CartoonPaint _pen;

  static const Color defaultWatchingColor = Color(0xFFFFD54F);

  /// Màu biểu tượng "đang nhìn", khác nhau giữa hai cô.
  final Color watchingColor;

  static const double radius = 64;
  static const Color _suspicious = Color(0xFFFF9800);
  static const Color _alarm = Color(0xFFE53935);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _warning = Color(0xFFFFF59D);

  /// Vẽ tại [center]. [lookSign] âm là nhìn sang trái màn hình.
  void paint(Canvas canvas, Offset center, TeacherCue cue, double lookSign) {
    switch (cue) {
      case TeacherCue.none:
        return;
      case TeacherCue.warning:
        _pen.circle(canvas, center, radius * 0.8, _warning);
        _drawDots(canvas, center);
      case TeacherCue.watching:
        _drawPointer(canvas, center, lookSign);
        _pen.circle(canvas, center, radius, watchingColor);
        _drawEye(canvas, center, lookSign);
      case TeacherCue.suspicious:
        _pen.circle(canvas, center, radius, _suspicious);
        _drawQuestion(canvas, center);
      case TeacherCue.alarm:
        _pen.circle(canvas, center, radius, _alarm);
        _drawExclamation(canvas, center);
    }
  }

  void _drawDots(Canvas canvas, Offset center) {
    for (var i = -1; i <= 1; i++) {
      final dot = center.translate(i * radius * 0.32, 0);
      _pen.spot(canvas, dot, radius * 0.11, CartoonPaint.ink);
    }
  }

  void _drawPointer(Canvas canvas, Offset center, double lookSign) {
    final tip = center.dx + lookSign * radius * 1.7;
    final base = center.dx + lookSign * radius * 0.6;
    final pointer = Path()
      ..moveTo(tip, center.dy)
      ..lineTo(base, center.dy - radius * 0.55)
      ..lineTo(base, center.dy + radius * 0.55)
      ..close();
    _pen.shape(canvas, pointer, watchingColor);
  }

  void _drawEye(Canvas canvas, Offset center, double lookSign) {
    final eye = Rect.fromCenter(
      center: center,
      width: radius * 1.3,
      height: radius * 0.75,
    );
    _pen.oval(canvas, eye, _white);
    final pupil = center.translate(lookSign * radius * 0.25, 0);
    _pen.spot(canvas, pupil, radius * 0.24, CartoonPaint.ink);
  }

  void _drawQuestion(Canvas canvas, Offset center) {
    final r = radius;
    final hook = Path()
      ..moveTo(center.dx - r * 0.32, center.dy - r * 0.28)
      ..quadraticBezierTo(
        center.dx - r * 0.3,
        center.dy - r * 0.68,
        center.dx,
        center.dy - r * 0.66,
      )
      ..quadraticBezierTo(
        center.dx + r * 0.42,
        center.dy - r * 0.6,
        center.dx + r * 0.3,
        center.dy - r * 0.22,
      )
      ..quadraticBezierTo(
        center.dx + r * 0.2,
        center.dy - r * 0.02,
        center.dx,
        center.dy + r * 0.12,
      );
    _pen.curve(canvas, hook, r * 0.18, color: _white);
    _pen.spot(canvas, center.translate(0, r * 0.48), r * 0.12, _white);
  }

  void _drawExclamation(Canvas canvas, Offset center) {
    final r = radius;
    _pen.line(
      canvas,
      center.translate(0, -r * 0.62),
      center.translate(0, r * 0.12),
      r * 0.22,
      color: _white,
    );
    _pen.spot(canvas, center.translate(0, r * 0.48), r * 0.13, _white);
  }
}

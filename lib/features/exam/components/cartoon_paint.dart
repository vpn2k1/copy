import 'dart:ui';

/// Bút vẽ hoạt hình: tô màu kèm viền đậm. Dùng chung cho nhân vật và đồ vật
/// để toàn cảnh có cùng nét vẽ.
class CartoonPaint {
  CartoonPaint({this.outlineWidth = 5});

  static const Color ink = Color(0xFF2A211C);

  final double outlineWidth;
  final Paint _fill = Paint();
  late final Paint _outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = outlineWidth
    ..strokeJoin = StrokeJoin.round
    ..color = ink;
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  void shape(Canvas canvas, Path path, Color color) {
    _fill.color = color;
    canvas.drawPath(path, _fill);
    canvas.drawPath(path, _outline);
  }

  void box(Canvas canvas, Rect rect, Color color, {double radius = 0}) {
    final rounded = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    shape(canvas, Path()..addRRect(rounded), color);
  }

  void circle(Canvas canvas, Offset center, double radius, Color color) {
    oval(canvas, Rect.fromCircle(center: center, radius: radius), color);
  }

  void oval(Canvas canvas, Rect rect, Color color) {
    shape(canvas, Path()..addOval(rect), color);
  }

  /// Tay, chân, chân bàn: nét dày có viền.
  void limb(Canvas canvas, Offset from, Offset to, double width, Color color) {
    _stroke
      ..color = ink
      ..strokeWidth = width + outlineWidth * 2;
    canvas.drawLine(from, to, _stroke);
    _stroke
      ..color = color
      ..strokeWidth = width;
    canvas.drawLine(from, to, _stroke);
  }

  /// Mảng màu không viền: má hồng, bóng đổ.
  void spot(Canvas canvas, Offset center, double radius, Color color) {
    _fill.color = color;
    canvas.drawCircle(center, radius, _fill);
  }

  /// Đường cong mảnh không viền: miệng, nếp áo.
  void curve(Canvas canvas, Path path, double width, {Color color = ink}) {
    _stroke
      ..color = color
      ..strokeWidth = width;
    canvas.drawPath(path, _stroke);
  }

  /// Nét mảnh không viền: lông mày, miệng, dòng chữ trên giấy.
  void line(
    Canvas canvas,
    Offset from,
    Offset to,
    double width, {
    Color color = ink,
  }) {
    _stroke
      ..color = color
      ..strokeWidth = width;
    canvas.drawLine(from, to, _stroke);
  }
}

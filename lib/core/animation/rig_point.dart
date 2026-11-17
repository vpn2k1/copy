/// Một điểm trong hệ tọa độ gốc của nhân vật (scale = 1, y âm là hướng lên).
class RigPoint {
  const RigPoint(this.x, this.y);

  static const zero = RigPoint(0, 0);

  final double x;
  final double y;

  RigPoint operator +(RigPoint other) => RigPoint(x + other.x, y + other.y);

  @override
  bool operator ==(Object other) =>
      other is RigPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'RigPoint($x, $y)';
}

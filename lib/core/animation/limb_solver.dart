import 'dart:math' as math;

import 'rig_point.dart';

/// Tìm khuỷu tay cho cánh tay hai đoạn [upper], [lower] nối [shoulder] tới
/// [hand]. [bend] = 1 gập về phía pháp tuyến quay +90° của hướng vai → tay
/// (trong tọa độ y hướng xuống là gập xuống dưới), -1 gập về phía ngược lại.
/// Khi tay ở xa quá tầm với, cánh tay duỗi thẳng về phía [hand].
RigPoint solveElbow(
  RigPoint shoulder,
  RigPoint hand, {
  double upper = 125,
  double lower = 125,
  double bend = 1,
}) {
  final dx = hand.x - shoulder.x;
  final dy = hand.y - shoulder.y;
  final distance = math.sqrt(dx * dx + dy * dy);
  if (distance < 1e-6) return RigPoint(shoulder.x, shoulder.y + upper);
  final reach = math.min(distance, upper + lower - 1e-6);
  final along = (upper * upper - lower * lower + reach * reach) / (2 * reach);
  final height = math.sqrt(math.max(0.0, upper * upper - along * along));
  final ux = dx / distance;
  final uy = dy / distance;
  return RigPoint(
    shoulder.x + ux * along - uy * height * bend,
    shoulder.y + uy * along + ux * height * bend,
  );
}

import 'package:flutter/services.dart';

/// Game chỉ chơi màn hình ngang, cho phép xoay cả hai chiều.
const landscapeOrientations = [
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
];

/// Khóa hướng màn hình ngang. Gọi một lần trước `runApp`.
Future<void> lockLandscape() {
  return SystemChrome.setPreferredOrientations(landscapeOrientations);
}

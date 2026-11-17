import 'package:flutter/material.dart';

/// Màu thương hiệu theo lớp học: bảng xanh, tường vàng kem, phấn trắng.
/// Mọi màn hình dùng các hằng số này, không viết mã màu rải rác.
const Color brandPrimary = Color(0xFF2F5D45);
const Color chalkboard = Color(0xFF2F5D45);
const Color chalkboardFrame = Color(0xFF7A5230);
const Color classroomWall = Color(0xFFF3E2B3);
const Color chalk = Color(0xFFF5F5F0);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: brandPrimary,
    scaffoldBackgroundColor: classroomWall,
    appBarTheme: const AppBarTheme(backgroundColor: classroomWall),
  );
}

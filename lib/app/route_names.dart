/// Tên route. Feature điều hướng qua các tên này, không import feature khác.
abstract final class RouteNames {
  static const menu = '/';
  static const levels = '/levels';

  /// Màn thi; tham số route là id màn (int, 1..5).
  static const exam = '/exam';
  static const settings = '/settings';
}

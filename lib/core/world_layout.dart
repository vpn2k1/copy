/// Kích thước thế giới logic của cảnh lớp học (xem plan 01_VISUAL_CAMERA).
/// Mọi vị trí trong game tính theo hệ tọa độ này, không theo pixel màn hình.
/// Màn hình khác tỉ lệ được letterbox, không cắt mất phần nào.
abstract final class WorldLayout {
  static const double width = 1600;
  static const double height = 900;

  /// Tỉ lệ chiều cao phần tường; phần dưới là sàn.
  static const double wallFraction = 0.68;
}

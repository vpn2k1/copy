import 'world_layout.dart';

/// Điểm neo của một nhân vật trong thế giới logic: chân ghế (học sinh) hoặc
/// bàn chân (giáo viên), và tỉ lệ vẽ so với kích thước gốc.
class FigurePlacement {
  const FigurePlacement({
    required this.x,
    required this.y,
    required this.scale,
  });

  final double x;
  final double y;
  final double scale;
}

/// Một dãy bàn đôi nhìn nghiêng, các bàn nối sát nhau từ cuối lớp lên đầu lớp.
class DeskRow {
  const DeskRow({
    required this.firstX,
    required this.y,
    required this.scale,
    required this.deskCount,
  });

  final double firstX;
  final double y;
  final double scale;
  final int deskCount;

  /// Chỗ ngồi phía gần camera của từng bàn trong dãy.
  List<FigurePlacement> get nearSeats => [
    for (var i = 0; i < deskCount; i++)
      FigurePlacement(
        x: firstX + i * ClassroomLayout.deskPitch * scale,
        y: y,
        scale: scale,
      ),
  ];
}

/// Bố cục cảnh lớp nhìn từ bàn kề bên TRÁI nhân vật chính, tầm mắt học sinh
/// ngồi (plan 01_VISUAL_CAMERA). Mọi số liệu theo thế giới 1600x900.
abstract final class ClassroomLayout {
  /// Phần trên và dưới dành cho HUD; vật quan trọng nằm ở dải giữa.
  static const double hudTopFraction = 0.12;
  static const double hudBottomFraction = 0.16;

  /// Mép dưới tường sau, nơi bắt đầu sàn.
  static const double wallBottom = 440;

  /// Kích thước gốc (scale = 1) đo từ điểm neo lên đỉnh tóc.
  static const double seatedFigureHeight = 555;
  static const double standingFigureHeight = 520;

  /// Độ cao của tay đặt trên bàn so với chân ghế (scale = 1).
  static const double seatedHandHeight = 236;

  /// Nhân vật chính ngồi gần camera, quay 3/4 về phía bảng.
  static const double playerSeatX = 430;
  static const player = FigurePlacement(x: playerSeatX, y: 820, scale: 0.95);

  /// Giáo viên đứng trước bảng, trên lối tuần tra.
  /// Đặt ở khoảng trống giữa các đầu học sinh dãy xa để không bị che.
  static const teacher = FigurePlacement(x: 1215, y: 470, scale: 0.31);

  /// Khoảng cách hai bàn liên tiếp (scale = 1): lưng ghế bàn sau sát mép
  /// bàn trước, như lớp học thật.
  static const double deskPitch = 540;

  /// Bạn cùng bàn ngồi sát phía xa camera: lùi lên, lệch nhẹ, nhỏ hơn chút.
  static const double deskmateLift = 90;
  static const double deskmateShift = 115;
  static const double deskmateShrink = 0.92;

  /// Hai dãy bàn đôi: dãy xa (nhỏ) và dãy giữa.
  static const rows = [
    DeskRow(firstX: 760, y: 560, scale: 0.32, deskCount: 4),
    DeskRow(firstX: 840, y: 665, scale: 0.42, deskCount: 3),
  ];

  /// Bạn cùng bàn của nhân vật chính, ngồi sát bên phía xa camera.
  static final FigurePlacement playerDeskmate = deskmateOf(player);

  /// Mọi bạn cùng lớp: bạn cùng bàn của nhân vật chính rồi từng bàn đôi.
  static final List<FigurePlacement> classmates = [
    playerDeskmate,
    for (final row in rows)
      for (final seat in row.nearSeats) ...[deskmateOf(seat), seat],
  ];

  static FigurePlacement deskmateOf(FigurePlacement seat) {
    return FigurePlacement(
      x: seat.x + deskmateShift * seat.scale,
      y: seat.y - deskmateLift * seat.scale,
      scale: seat.scale * deskmateShrink,
    );
  }

  /// Tâm và bán kính khối đầu (tóc) học sinh ngồi, scale = 1.
  static const double seatedHeadX = 4;
  static const double seatedHeadY = -478;
  static const double seatedHeadRadius = 76;

  /// Tâm và bán kính mặt giáo viên, scale = 1.
  static const double teacherFaceX = -6;
  static const double teacherFaceY = -446;
  static const double teacherFaceRadius = 50;

  static double get playableTop => WorldLayout.height * hudTopFraction;

  static double get playableBottom =>
      WorldLayout.height * (1 - hudBottomFraction);

  /// Đỉnh đầu nhân vật chính (tọa độ y thế giới).
  static double get playerHeadTop =>
      player.y - seatedFigureHeight * player.scale;

  /// Độ cao tay nhân vật chính trên bàn (tọa độ y thế giới).
  static double get playerHandY => player.y - seatedHandHeight * player.scale;

  /// Đỉnh đầu giáo viên (tọa độ y thế giới).
  static double get teacherHeadTop =>
      teacher.y - standingFigureHeight * teacher.scale;
}

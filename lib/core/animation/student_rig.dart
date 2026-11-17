import 'dart:math' as math;

import 'rig_point.dart';

/// Tư thế của một học sinh ngồi tại bàn.
enum StudentPose {
  idle,
  writing,
  cheating,
  nervous,
  hiding,
  caught,
  celebrating,
}

/// Dáng mắt: mở thường, trợn to, cười híp.
enum EyeShape { open, wide, happy }

/// Dáng miệng.
enum MouthShape { smile, flat, sly, wavy, round, grin }

/// Tư thế kết thúc: khóa animator, không còn chớp mắt hay run vì nghi ngờ.
const terminalStudentPoses = {StudentPose.caught, StudentPose.celebrating};

/// Ngưỡng nghi ngờ (0..1) bắt đầu đổ mồ hôi và run.
const studentSweatThreshold = 0.6;

const _blinkPeriod = 3.4;
const _blinkLength = 0.13;

/// Vị trí các khớp của học sinh tại một thời điểm, theo tọa độ gốc của hình.
/// Phần vẽ chỉ đọc giá trị này, không tự tính chuyển động.
class StudentRig {
  const StudentRig({
    this.body = RigPoint.zero,
    this.head = RigPoint.zero,
    this.headTilt = 0,
    this.pupil = RigPoint.zero,
    this.eyeOpen = 1,
    this.eyes = EyeShape.open,
    this.browLift = 0,
    this.mouth = MouthShape.smile,
    this.nearHand = restNearHand,
    this.farHand = restFarHand,
    this.nearBend = 1,
    this.farBend = 1,
    this.hasSweat = false,
  });

  /// Tay đặt trên bàn khi ngồi yên.
  static const restNearHand = RigPoint(182, -232);
  static const restFarHand = RigPoint(232, -236);

  /// Vai trái (gần camera) và vai phải, trước khi cộng [body].
  static const nearShoulder = RigPoint(-4, -366);
  static const farShoulder = RigPoint(40, -372);

  /// Dịch thân (nghiêng, nhún, run).
  final RigPoint body;

  /// Dịch thêm của đầu so với thân.
  final RigPoint head;

  /// Góc nghiêng đầu (radian), dương là cúi về phía trước.
  final double headTilt;

  /// Hướng nhìn của con ngươi, mỗi trục trong khoảng -1..1.
  final RigPoint pupil;

  /// Độ mở mắt 0..1 (chớp mắt).
  final double eyeOpen;
  final EyeShape eyes;

  /// Nhướng mày (dương là nhướng lên, âm là cau).
  final double browLift;
  final MouthShape mouth;

  /// Vị trí bàn tay (tọa độ hình, không cộng [body]).
  final RigPoint nearHand;
  final RigPoint farHand;

  /// Hướng gập khuỷu tay, xem `solveElbow`.
  final double nearBend;
  final double farBend;
  final bool hasSweat;

  StudentRig copyWith({RigPoint? body, double? eyeOpen, bool? hasSweat}) {
    return StudentRig(
      body: body ?? this.body,
      head: head,
      headTilt: headTilt,
      pupil: pupil,
      eyeOpen: eyeOpen ?? this.eyeOpen,
      eyes: eyes,
      browLift: browLift,
      mouth: mouth,
      nearHand: nearHand,
      farHand: farHand,
      nearBend: nearBend,
      farBend: farBend,
      hasSweat: hasSweat ?? this.hasSweat,
    );
  }

  List<Object> get _fields => [
    body,
    head,
    headTilt,
    pupil,
    eyeOpen,
    eyes,
    browLift,
    mouth,
    nearHand,
    farHand,
    nearBend,
    farBend,
    hasSweat,
  ];

  @override
  bool operator ==(Object other) {
    if (other is! StudentRig) return false;
    for (var i = 0; i < _fields.length; i++) {
      if (_fields[i] != other._fields[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_fields);
}

/// Rig của [pose] sau [t] giây. [phase] lệch nhịp giữa các học sinh để cả lớp
/// không chớp mắt cùng lúc. [suspicion] (0..1) chỉ ảnh hưởng tư thế thường.
StudentRig studentRigFor(
  StudentPose pose,
  double t, {
  double phase = 0,
  double suspicion = 0,
}) {
  final clock = t + phase;
  final base = _basePose(pose, clock);
  if (terminalStudentPoses.contains(pose)) return base;
  return _withReactions(base, clock, suspicion);
}

StudentRig _basePose(StudentPose pose, double t) {
  return switch (pose) {
    StudentPose.idle => StudentRig(
      body: RigPoint(0, math.sin(t * 2 * math.pi / 3) * 3),
      pupil: const RigPoint(0.3, 0.1),
    ),
    StudentPose.writing => StudentRig(
      head: const RigPoint(4, 8),
      headTilt: 0.16,
      pupil: const RigPoint(0.5, 1),
      mouth: MouthShape.flat,
      nearHand: RigPoint(182 + math.sin(t * 9) * 12, -232),
    ),
    StudentPose.cheating => const StudentRig(
      body: RigPoint(14, 0),
      head: RigPoint(20, -4),
      headTilt: -0.05,
      pupil: RigPoint(1, -0.2),
      browLift: -4,
      mouth: MouthShape.sly,
      nearHand: RigPoint(196, -232),
    ),
    StudentPose.nervous => StudentRig(
      body: RigPoint(math.sin(t * 38) * 2.5, 0),
      pupil: RigPoint(math.sin(t * 6), 0),
      eyes: EyeShape.wide,
      browLift: 8,
      mouth: MouthShape.wavy,
      hasSweat: true,
    ),
    StudentPose.hiding => const StudentRig(
      body: RigPoint(-4, 18),
      head: RigPoint(0, 10),
      headTilt: 0.06,
      pupil: RigPoint(0.2, -1),
      mouth: MouthShape.round,
      nearHand: RigPoint(226, -238),
      farHand: RigPoint(262, -242),
    ),
    StudentPose.caught => const StudentRig(
      head: RigPoint(-4, -12),
      headTilt: -0.08,
      eyes: EyeShape.wide,
      browLift: 14,
      mouth: MouthShape.round,
      nearHand: RigPoint(-96, -468),
      farHand: RigPoint(128, -500),
      nearBend: -1,
      hasSweat: true,
    ),
    StudentPose.celebrating => _celebrating(t),
  };
}

StudentRig _celebrating(double t) {
  final bounce = -math.sin(t * 7).abs() * 12;
  return StudentRig(
    body: RigPoint(0, bounce),
    eyes: EyeShape.happy,
    browLift: 6,
    mouth: MouthShape.grin,
    nearHand: RigPoint(-44, -610 + bounce),
    farHand: RigPoint(108, -612 + bounce),
    nearBend: -1,
  );
}

StudentRig _withReactions(StudentRig rig, double t, double suspicion) {
  var result = rig;
  if (t % _blinkPeriod < _blinkLength) result = result.copyWith(eyeOpen: 0.1);
  if (suspicion < studentSweatThreshold) return result;
  final shake = math.sin(t * 38) * (suspicion - studentSweatThreshold) * 8;
  return result.copyWith(
    body: RigPoint(rig.body.x + shake, rig.body.y),
    hasSweat: true,
  );
}

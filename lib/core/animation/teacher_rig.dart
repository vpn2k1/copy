import 'dart:math' as math;

/// Tư thế của giáo viên.
enum TeacherPose { idle, walk, turn, lookLeft, lookRight, inspect, caught }

/// Biểu tượng chú ý trên đầu giáo viên.
/// `warning` báo trước giáo viên sắp quay sang nhìn lớp.
enum TeacherCue { none, warning, watching, suspicious, alarm }

/// Tư thế kết thúc của giáo viên (đã bắt được).
const terminalTeacherPoses = {TeacherPose.caught};

/// Thời gian quay người sang hướng ngược lại (giây).
const teacherTurnSeconds = 0.4;

/// Vị trí các phần của giáo viên tại một thời điểm. Hình gốc vẽ quay mặt
/// sang trái (về phía học sinh); [scaleX] = -1 là lật sang phải.
class TeacherRig {
  const TeacherRig({
    this.scaleX = 1,
    this.bodyY = 0,
    this.lean = 0,
    this.nearStep = 0,
    this.farStep = 0,
    this.headTilt = 0,
    this.pupilX = -0.4,
    this.isSquinting = false,
    this.isAngry = false,
    this.isMouthOpen = false,
    this.isPointing = false,
    this.cue = TeacherCue.none,
  });

  /// 1 = nhìn trái, -1 = nhìn phải, giá trị giữa khi đang quay người.
  final double scaleX;

  /// Nhún người khi đi hoặc thở (âm là lên).
  final double bodyY;

  /// Nghiêng thân và đầu về phía trước (theo hướng mặt).
  final double lean;

  /// Độ lệch bàn chân khi bước.
  final double nearStep;
  final double farStep;

  /// Góc cúi đầu (radian).
  final double headTilt;

  /// Hướng con ngươi theo hướng mặt: -1 là nhìn thẳng về phía trước mặt.
  final double pupilX;
  final bool isSquinting;
  final bool isAngry;
  final bool isMouthOpen;
  final bool isPointing;
  final TeacherCue cue;

  /// Giáo viên đang quay mặt về bên trái màn hình (phía nhân vật chính).
  bool get facesLeft => scaleX > 0;

  /// Bản sao với biểu tượng và (nếu có) độ lật ngang khác.
  TeacherRig copyWith({TeacherCue? cue, double? scaleX}) {
    return TeacherRig(
      scaleX: scaleX ?? this.scaleX,
      bodyY: bodyY,
      lean: lean,
      nearStep: nearStep,
      farStep: farStep,
      headTilt: headTilt,
      pupilX: pupilX,
      isSquinting: isSquinting,
      isAngry: isAngry,
      isMouthOpen: isMouthOpen,
      isPointing: isPointing,
      cue: cue ?? this.cue,
    );
  }
}

/// Độ lật ngang khi quay người được [progress] (0..1), bắt đầu từ hướng
/// [facesLeft].
double teacherTurnScale(double progress, {required bool facesLeft}) {
  return _facingScale(facesLeft) * math.cos(math.pi * progress);
}

/// Rig của [pose] sau [t] giây, khi giáo viên đang quay mặt theo [facesLeft].
TeacherRig teacherRigFor(
  TeacherPose pose,
  double t, {
  required bool facesLeft,
}) {
  final facing = _facingScale(facesLeft);
  return switch (pose) {
    TeacherPose.idle => TeacherRig(scaleX: facing, bodyY: math.sin(t * 2) * 2),
    TeacherPose.walk => _walk(facing, t),
    TeacherPose.turn => TeacherRig(
      scaleX:
          facing * math.cos(math.pi * math.min(1.0, t / teacherTurnSeconds)),
    ),
    TeacherPose.lookLeft => const TeacherRig(
      pupilX: -1,
      cue: TeacherCue.watching,
    ),
    TeacherPose.lookRight => const TeacherRig(
      scaleX: -1,
      pupilX: -1,
      cue: TeacherCue.watching,
    ),
    TeacherPose.inspect => TeacherRig(
      scaleX: facing,
      lean: -12,
      headTilt: -0.12,
      pupilX: -1,
      isSquinting: true,
      cue: TeacherCue.suspicious,
    ),
    TeacherPose.caught => TeacherRig(
      scaleX: facing,
      pupilX: -1,
      isAngry: true,
      isMouthOpen: true,
      isPointing: true,
      cue: TeacherCue.alarm,
    ),
  };
}

double _facingScale(bool facesLeft) {
  if (facesLeft) return 1;
  return -1;
}

TeacherRig _walk(double facing, double t) {
  final swing = math.sin(t * 8);
  return TeacherRig(
    scaleX: facing,
    bodyY: -math.sin(t * 8).abs() * 6,
    nearStep: swing * 22,
    farStep: -swing * 22,
  );
}

import 'dart:math' as math;

import '../animation/teacher_rig.dart';
import 'teacher_state.dart';

/// Tham số AI giáo viên, gom một chỗ để chỉnh độ khó.
abstract final class TeacherTuning {
  /// Lối đi trước bảng (tọa độ x thế giới) và điểm xuất phát.
  static const double laneMinX = 760;
  static const double laneMaxX = 1450;
  static const double startX = 1215;

  /// Tốc độ đi gốc, nhân với `LevelConfig.teacherSpeed`.
  static const double baseWalkSpeed = 200;

  /// Báo trước (cue vàng "…") trước khi quay sang nhìn lớp.
  static const double watchWarningSeconds = 1.0;

  /// Lần quay lưng viết bảng đầu ván: người chơi có lúc an toàn để bắt đầu.
  static const double openingLookAwaySeconds = 4;

  /// Ngưỡng nghi ngờ để dừng lại nhìn kỹ và để tiến lại soi bàn.
  static const double suspiciousAt = 40;
  static const double approachAt = 70;

  static const double suspiciousSeconds = 1.5;
  static const double inspectSeconds = 2.0;
  static const double minPatrolDistance = 150;
}

/// Đoạn lối đi một giáo viên được phép đi (tọa độ x thế giới).
class TeacherLane {
  const TeacherLane({
    required this.minX,
    required this.maxX,
    required this.startX,
  });

  /// Cả lối trước bảng, cho màn một giáo viên.
  static const full = TeacherLane(
    minX: TeacherTuning.laneMinX,
    maxX: TeacherTuning.laneMaxX,
    startX: TeacherTuning.startX,
  );

  final double minX;
  final double maxX;
  final double startX;

  double get centerX => (minX + maxX) / 2;
}

/// Nhịp quan sát; chế độ boss rút ngắn thời gian đứng, giảm lúc quay lưng.
class TeacherPace {
  const TeacherPace({
    this.dwellScale = 1,
    this.warningSeconds = TeacherTuning.watchWarningSeconds,
    this.speedScale = 1,
    this.lookAwayShare = 0.20,
  });

  static const normal = TeacherPace();

  /// Nhịp thường với thời gian báo trước của màn.
  const TeacherPace.level(double warningSeconds)
    : this(warningSeconds: warningSeconds);

  /// Boss 20 giây cuối: nhanh hơn nhưng vẫn báo trước và vẫn có lúc an toàn.
  static const boss = TeacherPace(
    dwellScale: 0.6,
    warningSeconds: 0.45,
    speedScale: 1.3,
    lookAwayShare: 0.12,
  );

  final double dwellScale;
  final double warningSeconds;
  final double speedScale;

  /// Xác suất quay lưng viết bảng khi chọn việc tiếp theo.
  final double lookAwayShare;
}

/// Máy trạng thái của giáo viên. Mọi lựa chọn ngẫu nhiên lấy từ [random]
/// được truyền vào (có seed), nên cùng seed và cùng chuỗi input cho cùng kết
/// quả. Không phụ thuộc số khung hình: chỉ dùng `dt`.
class TeacherFsm {
  TeacherFsm({
    required this.random,
    required this.teacherSpeed,
    this.lane = TeacherLane.full,
  });

  final math.Random random;
  final double teacherSpeed;

  /// Lối đi hiện tại; sự kiện đổi chỗ thay lối của hai cô.
  TeacherLane lane;
  TeacherPace pace = TeacherPace.normal;

  double get walkSpeed =>
      TeacherTuning.baseWalkSpeed * teacherSpeed * pace.speedScale;

  TeacherState start() {
    return TeacherState(
      mode: TeacherMode.lookAway,
      x: lane.startX,
      facesLeft: false,
      modeRemaining: TeacherTuning.openingLookAwaySeconds,
    );
  }

  /// Sự kiện ra lệnh chuyển chế độ (có quay người và báo trước như thường).
  /// [dwell] ghi đè thời gian đứng ở chế độ đó.
  TeacherState command(TeacherState state, TeacherMode mode, {double? dwell}) {
    if (state.mode == TeacherMode.caught) return state;
    final next = _enter(state, mode);
    if (dwell == null) return next;
    return next.copyWith(modeRemaining: dwell);
  }

  /// Sự kiện ra lệnh đi tới [x] (không quan sát lớp khi đi).
  TeacherState walkTo(TeacherState state, double x) {
    if (state.mode == TeacherMode.caught) return state;
    return _enter(state.copyWith(targetX: x), TeacherMode.patrol);
  }

  /// Tiến [dt] giây. [suspicion] 0..100; [sawCheating] là giáo viên vừa nhìn
  /// thấy người chơi đang cóp ở tick trước.
  TeacherState update(
    TeacherState state,
    double dt, {
    required double suspicion,
    required bool sawCheating,
  }) {
    if (state.mode == TeacherMode.caught || dt <= 0) return state;
    if (state.isTurning) return _turn(state, dt);
    if (state.isWarning) {
      final left = math.max(0.0, state.warningRemaining - dt);
      return state.copyWith(warningRemaining: left);
    }
    if (_shouldGetSuspicious(state, suspicion, sawCheating)) {
      return _enter(state, TeacherMode.suspicious);
    }
    return switch (state.mode) {
      TeacherMode.patrol || TeacherMode.approach => _walk(state, dt),
      _ => _dwell(state, dt, suspicion),
    };
  }

  /// Giáo viên bắt được: đứng yên, quay về phía người chơi.
  TeacherState catchPlayer(TeacherState state) {
    return TeacherState(mode: TeacherMode.caught, x: state.x, facesLeft: true);
  }

  bool _shouldGetSuspicious(
    TeacherState state,
    double suspicion,
    bool sawCheating,
  ) {
    return sawCheating &&
        state.mode == TeacherMode.lookLeft &&
        suspicion >= TeacherTuning.suspiciousAt;
  }

  TeacherState _turn(TeacherState state, double dt) {
    final left = state.turnRemaining - dt;
    if (left > 0) return state.copyWith(turnRemaining: left);
    return state.copyWith(turnRemaining: 0, facesLeft: !state.facesLeft);
  }

  TeacherState _walk(TeacherState state, double dt) {
    final target = state.targetX ?? state.x;
    final distance = target - state.x;
    final step = walkSpeed * dt;
    if (distance.abs() > step) {
      return state.copyWith(x: state.x + distance.sign * step);
    }
    final arrived = state.copyWith(x: target);
    if (state.mode == TeacherMode.approach) {
      return _enter(arrived, TeacherMode.inspect);
    }
    return _enter(arrived, TeacherMode.idle);
  }

  TeacherState _dwell(TeacherState state, double dt, double suspicion) {
    final left = state.modeRemaining - dt;
    if (left > 0) return state.copyWith(modeRemaining: left);
    return _enter(state, _nextAfter(state.mode, suspicion));
  }

  TeacherMode _nextAfter(TeacherMode mode, double suspicion) {
    return switch (mode) {
      TeacherMode.idle => _pickFromIdle(),
      TeacherMode.lookAway => TeacherMode.lookLeft,
      TeacherMode.suspicious => _afterSuspicious(suspicion),
      _ => TeacherMode.idle,
    };
  }

  TeacherMode _afterSuspicious(double suspicion) {
    if (suspicion >= TeacherTuning.approachAt) return TeacherMode.approach;
    return TeacherMode.idle;
  }

  TeacherMode _pickFromIdle() {
    final roll = random.nextDouble();
    final rest = 1 - pace.lookAwayShare;
    if (roll < rest * 0.44) return TeacherMode.patrol;
    if (roll < rest * 0.81) return TeacherMode.lookLeft;
    if (roll < rest) return TeacherMode.lookRight;
    return TeacherMode.lookAway;
  }

  TeacherState _enter(TeacherState state, TeacherMode mode) {
    final targetX = _targetFor(state, mode);
    final facesLeft = _facingFor(state, mode, targetX);
    var next = TeacherState(
      mode: mode,
      x: state.x,
      facesLeft: state.facesLeft,
      modeRemaining: _dwellFor(mode),
      targetX: targetX,
    );
    if (facesLeft != state.facesLeft) {
      next = next.copyWith(turnRemaining: teacherTurnSeconds);
    }
    if (mode == TeacherMode.lookLeft) {
      next = next.copyWith(warningRemaining: pace.warningSeconds);
    }
    return next;
  }

  double? _targetFor(TeacherState state, TeacherMode mode) {
    if (mode == TeacherMode.approach) return lane.minX;
    if (mode != TeacherMode.patrol) return null;
    final forced = state.targetX;
    if (forced != null) return forced;
    final span = lane.maxX - lane.minX;
    final minDistance = math.min(TeacherTuning.minPatrolDistance, span / 2);
    for (var attempt = 0; attempt < 4; attempt++) {
      final x = lane.minX + random.nextDouble() * span;
      if ((x - state.x).abs() >= minDistance) return x;
    }
    if (state.x > lane.centerX) return lane.minX;
    return lane.maxX;
  }

  bool _facingFor(TeacherState state, TeacherMode mode, double? targetX) {
    return switch (mode) {
      TeacherMode.lookLeft ||
      TeacherMode.suspicious ||
      TeacherMode.approach ||
      TeacherMode.inspect ||
      TeacherMode.caught => true,
      TeacherMode.lookRight || TeacherMode.lookAway => false,
      TeacherMode.patrol => (targetX ?? state.x) < state.x,
      TeacherMode.idle => state.facesLeft,
    };
  }

  double _dwellFor(TeacherMode mode) {
    return switch (mode) {
      TeacherMode.idle => _between(0.8, 1.6),
      TeacherMode.lookLeft => _between(1.5, 3.0),
      TeacherMode.lookRight => _between(1.2, 2.2),
      TeacherMode.lookAway => _between(3.0, 6.0),
      TeacherMode.suspicious => TeacherTuning.suspiciousSeconds,
      TeacherMode.inspect => TeacherTuning.inspectSeconds,
      _ => 0,
    };
  }

  double _between(double min, double max) =>
      (min + random.nextDouble() * (max - min)) * pace.dwellScale;
}

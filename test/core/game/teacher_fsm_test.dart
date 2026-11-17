import 'dart:math' as math;

import 'package:dung_de_thay_thay/core/animation/teacher_rig.dart';
import 'package:dung_de_thay_thay/core/classroom_layout.dart';
import 'package:dung_de_thay_thay/core/game/teacher_fsm.dart';
import 'package:dung_de_thay_thay/core/game/teacher_state.dart';
import 'package:flutter_test/flutter_test.dart';

const playerX = ClassroomLayout.playerSeatX;

TeacherFsm fsm(int seed) =>
    TeacherFsm(random: math.Random(seed), teacherSpeed: 0.6);

/// Ghi lại chuỗi trạng thái của giáo viên trong [seconds] giây yên ổn.
List<TeacherState> trace(int seed, {double seconds = 60, double dt = 0.02}) {
  final machine = fsm(seed);
  var state = machine.start();
  final states = [state];
  for (var t = 0.0; t < seconds; t += dt) {
    state = machine.update(state, dt, suspicion: 0, sawCheating: false);
    states.add(state);
  }
  return states;
}

void main() {
  test('đầu ván cô quay lưng viết bảng, không nhìn lớp', () {
    final start = fsm(1).start();
    expect(start.mode, TeacherMode.lookAway);
    expect(start.facesLeft, isFalse);
    expect(canSeePlayer(start, playerX: playerX), isFalse);
  });

  test('từ lúc quay lưng tới lúc thật sự nhìn lớp có hơn 1 giây báo trước', () {
    for (final seed in [1, 2, 3, 4, 5]) {
      final states = trace(seed);
      for (var i = 1; i < states.length; i++) {
        final was = states[i - 1];
        final now = states[i];
        if (was.mode != TeacherMode.lookAway) continue;
        if (now.mode == TeacherMode.lookAway) continue;
        expect(now.mode, TeacherMode.lookLeft);
        expect(now.isWatchingClass, isFalse);
        final lead = now.turnRemaining + now.warningRemaining;
        expect(lead, greaterThan(1.0), reason: 'seed $seed');
      }
    }
  });

  test(
    'mọi lần bắt đầu nhìn lớp đều có báo trước, không phát hiện tức thì',
    () {
      for (final seed in [1, 2, 3, 4, 5, 6]) {
        final states = trace(seed);
        for (var i = 1; i < states.length; i++) {
          final startsWatching =
              states[i].isWatchingClass && !states[i - 1].isWatchingClass;
          if (!startsWatching) continue;
          expect(states[i - 1].isWarning, isTrue, reason: 'seed $seed i=$i');
        }
      }
    },
  );

  test('đang quay người hay đang báo trước thì không thấy ai', () {
    for (final state in trace(8)) {
      if (state.isTurning || state.isWarning) {
        expect(canSeePlayer(state, playerX: playerX), isFalse);
      }
    }
  });

  test('chỉ thấy người chơi khi mặt hướng về bên trái (phía người chơi)', () {
    const watching = TeacherState(
      mode: TeacherMode.lookLeft,
      x: 1200,
      facesLeft: true,
    );
    expect(canSeePlayer(watching, playerX: playerX), isTrue);
    final away = watching.copyWith(facesLeft: false);
    expect(canSeePlayer(away, playerX: playerX), isFalse);
    final lookRight = watching.copyWith(mode: TeacherMode.lookRight);
    expect(
      canSeePlayer(lookRight, playerX: playerX),
      isFalse,
      reason: 'nhìn dãy bên phải không tính là quan sát người chơi',
    );
    const right = TeacherState(
      mode: TeacherMode.lookRight,
      x: 1200,
      facesLeft: false,
    );
    expect(canSeePlayer(right, playerX: playerX), isFalse);
  });

  test('quay người kéo dài đúng thời gian hoạt ảnh quay', () {
    final states = trace(3);
    final turnStart = states.indexWhere((s) => s.isTurning);
    expect(turnStart, greaterThan(0));
    expect(states[turnStart].turnRemaining, closeTo(teacherTurnSeconds, 0.03));
  });

  test('cùng seed cho cùng chuỗi trạng thái, khác seed cho chuỗi khác', () {
    String signature(List<TeacherState> s) =>
        s.map((t) => '${t.mode.index}:${t.x.round()}').join(',');
    expect(signature(trace(77)), signature(trace(77)));
    expect(signature(trace(77)), isNot(signature(trace(78))));
  });

  test('cô luôn ở trên lối đi trước bảng', () {
    for (final seed in [1, 2, 3]) {
      for (final state in trace(seed, seconds: 120)) {
        expect(
          state.x,
          inInclusiveRange(TeacherTuning.laneMinX, TeacherTuning.laneMaxX),
        );
      }
    }
  });

  test('thấy cóp khi nghi ngờ cao: nhìn kỹ, rồi tiến lại, rồi soi bàn', () {
    final machine = fsm(1);
    var state = const TeacherState(
      mode: TeacherMode.lookLeft,
      x: 1200,
      facesLeft: true,
      modeRemaining: 2,
    );
    state = machine.update(state, 0.02, suspicion: 50, sawCheating: true);
    expect(state.mode, TeacherMode.suspicious);
    while (state.mode == TeacherMode.suspicious) {
      state = machine.update(state, 0.02, suspicion: 80, sawCheating: false);
    }
    expect(state.mode, TeacherMode.approach);
    expect(state.isWatchingClass, isTrue);
    while (state.mode == TeacherMode.approach) {
      state = machine.update(state, 0.02, suspicion: 80, sawCheating: false);
    }
    expect(state.mode, TeacherMode.inspect);
    expect(state.x, TeacherTuning.laneMinX);
  });

  test('nghi ngờ thấp thì nhìn kỹ xong quay về bình thường', () {
    final machine = fsm(1);
    var state = const TeacherState(
      mode: TeacherMode.suspicious,
      x: 1200,
      facesLeft: true,
      modeRemaining: 0.01,
    );
    state = machine.update(state, 0.02, suspicion: 30, sawCheating: false);
    expect(state.mode, TeacherMode.idle);
  });

  test('bước đi nhanh theo hệ số tốc độ màn, không theo khung hình', () {
    final slow = TeacherFsm(random: math.Random(1), teacherSpeed: 0.6);
    final fast = TeacherFsm(random: math.Random(1), teacherSpeed: 1.2);
    expect(fast.walkSpeed, closeTo(slow.walkSpeed * 2, 1e-9));
  });
}

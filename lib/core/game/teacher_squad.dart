import 'dart:math' as math;

import 'teacher_fsm.dart';
import 'teacher_state.dart';

/// Lối đi khi có hai cô: mỗi cô một nửa lối trước bảng.
const leftHalfLane = TeacherLane(minX: 760, maxX: 1080, startX: 900);
const rightHalfLane = TeacherLane(minX: 1130, maxX: 1450, startX: 1330);

/// Nhóm giáo viên của một ván (1 hoặc 2 cô). Mỗi cô có AI và hạt ngẫu nhiên
/// riêng nên chú ý độc lập; người chơi bị thấy nếu ít nhất một cô thấy.
class TeacherSquad {
  TeacherSquad({
    required int seed,
    required double teacherSpeed,
    required int count,
    double watchWarningSeconds = 1.0,
  }) : _fsms = [
         for (var i = 0; i < count; i++)
           TeacherFsm(
             random: math.Random(seed + i * 7919),
             teacherSpeed: teacherSpeed,
             lane: _laneFor(i, count),
           )..pace = TeacherPace.level(watchWarningSeconds),
       ];

  final List<TeacherFsm> _fsms;

  int get count => _fsms.length;

  List<TeacherState> start() => [for (final fsm in _fsms) fsm.start()];

  List<TeacherState> update(
    List<TeacherState> teachers,
    double dt, {
    required double suspicion,
    required List<bool> sawCheating,
  }) {
    return [
      for (var i = 0; i < _fsms.length; i++)
        _fsms[i].update(
          teachers[i],
          dt,
          suspicion: suspicion,
          sawCheating: sawCheating[i],
        ),
    ];
  }

  /// Cô thứ [index] thấy người chơi.
  List<bool> seeing(List<TeacherState> teachers, {required double playerX}) {
    return [
      for (final teacher in teachers) canSeePlayer(teacher, playerX: playerX),
    ];
  }

  /// Đổi nhịp quan sát của mọi cô (chế độ boss).
  set pace(TeacherPace pace) {
    for (final fsm in _fsms) {
      fsm.pace = pace;
    }
  }

  /// Ra lệnh cho cô thứ [index] chuyển chế độ.
  List<TeacherState> command(
    List<TeacherState> teachers,
    int index,
    TeacherMode mode, {
    double? dwell,
  }) {
    final next = List.of(teachers);
    next[index] = _fsms[index].command(teachers[index], mode, dwell: dwell);
    return next;
  }

  /// Hai cô đổi lối cho nhau và đi tới giữa lối mới.
  List<TeacherState> swapLanes(List<TeacherState> teachers) {
    if (_fsms.length < 2) return teachers;
    final first = _fsms[0].lane;
    _fsms[0].lane = _fsms[1].lane;
    _fsms[1].lane = first;
    return [
      for (var i = 0; i < _fsms.length; i++)
        _fsms[i].walkTo(teachers[i], _fsms[i].lane.centerX),
    ];
  }

  /// Mọi cô đã tới lối của mình (sau khi đổi chỗ).
  bool isSettled(List<TeacherState> teachers) {
    for (var i = 0; i < _fsms.length; i++) {
      final lane = _fsms[i].lane;
      final x = teachers[i].x;
      if (x < lane.minX - 1 || x > lane.maxX + 1) return false;
      if (teachers[i].mode == TeacherMode.patrol) return false;
    }
    return true;
  }

  /// Bắt được: cô gần người chơi nhất chỉ tay, các cô khác nhìn sang.
  List<TeacherState> catchPlayer(List<TeacherState> teachers) {
    return [
      for (var i = 0; i < _fsms.length; i++) _fsms[i].catchPlayer(teachers[i]),
    ];
  }

  static TeacherLane _laneFor(int index, int count) {
    if (count < 2) return TeacherLane.full;
    if (index == 0) return leftHalfLane;
    return rightHalfLane;
  }
}

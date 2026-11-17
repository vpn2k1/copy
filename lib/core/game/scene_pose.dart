import '../animation/student_rig.dart';
import '../animation/teacher_rig.dart';
import 'game_state.dart';
import 'game_status.dart';
import 'skills.dart';
import 'teacher_state.dart';

/// Ngưỡng nghi ngờ để nhân vật chính lộ vẻ lo lắng khi bị nhìn.
const nervousSuspicion = 60.0;

/// Tư thế nhân vật chính ứng với trạng thái ván thi.
StudentPose playerPoseFor(GameState state) {
  switch (state.status) {
    case GameStatus.won:
      return StudentPose.celebrating;
    case GameStatus.lostCaught:
      return StudentPose.caught;
    case GameStatus.lostTime:
      return StudentPose.nervous;
    case GameStatus.ready:
    case GameStatus.running:
    case GameStatus.paused:
      return _activePose(state);
  }
}

StudentPose _activePose(GameState state) {
  final active = state.skills.active;
  if (active != null) return _castPose(active.skillId);
  if (state.skills.isHolding) return StudentPose.cheating;
  return switch (state.heldAction) {
    PlayerAction.hide => StudentPose.hiding,
    PlayerAction.write => StudentPose.writing,
    PlayerAction.cheat || null => _restingPose(state),
  };
}

/// Tư thế khi thi triển: kỹ năng hồi phục thì giấu bài / diễn, còn lại cóp.
StudentPose _castPose(String skillId) {
  if (skillId == 'oscar') return StudentPose.nervous;
  if (skillById(skillId).isRecovery) return StudentPose.hiding;
  return StudentPose.cheating;
}

StudentPose _restingPose(GameState state) {
  if (state.isPlayerSeen && state.suspicion >= nervousSuspicion) {
    return StudentPose.nervous;
  }
  return StudentPose.idle;
}

/// Tư thế giáo viên ứng với chế độ AI. Khi đang quay người, hình cũng quay.
TeacherPose teacherPoseFor(TeacherState teacher) {
  if (teacher.mode == TeacherMode.caught) return TeacherPose.caught;
  if (teacher.isTurning) return TeacherPose.turn;
  return switch (teacher.mode) {
    TeacherMode.patrol || TeacherMode.approach => TeacherPose.walk,
    TeacherMode.lookLeft => TeacherPose.lookLeft,
    TeacherMode.lookRight => TeacherPose.lookRight,
    TeacherMode.suspicious || TeacherMode.inspect => TeacherPose.inspect,
    TeacherMode.idle ||
    TeacherMode.lookAway ||
    TeacherMode.caught => TeacherPose.idle,
  };
}

/// Biểu tượng trên đầu giáo viên, khớp đúng với việc bộ phát hiện có thấy
/// người chơi hay không: chỉ hiện mắt/"?"/"!" khi đang thật sự quan sát.
TeacherCue teacherCueFor(TeacherState teacher) {
  if (teacher.mode == TeacherMode.caught) return TeacherCue.alarm;
  if (teacher.isWarning) return TeacherCue.warning;
  if (teacher.isTurning) return TeacherCue.none;
  return switch (teacher.mode) {
    TeacherMode.lookLeft || TeacherMode.lookRight => TeacherCue.watching,
    TeacherMode.suspicious ||
    TeacherMode.approach ||
    TeacherMode.inspect => TeacherCue.suspicious,
    _ => TeacherCue.none,
  };
}

/// Tiến trình quay người 0..1 theo đồng hồ của AI.
double teacherTurnProgress(TeacherState teacher) {
  if (!teacher.isTurning) return 0;
  final done = 1 - teacher.turnRemaining / teacherTurnSeconds;
  return done.clamp(0.0, 1.0).toDouble();
}

import '../animation/teacher_rig.dart';
import 'game_state.dart';
import 'game_status.dart';
import 'level_event.dart';
import 'scene_pose.dart';
import 'skill_runtime.dart';
import 'teacher_state.dart';

/// Hiệu ứng âm thanh của ván thi. Tên file nằm ở lớp phát âm thanh.
enum SoundCue {
  warning,
  alert,
  footstep,
  pencil,
  fail,
  click,
  paper,
  bell,
  win,
  lose,
}

/// Các hiệu ứng cần phát khi trạng thái đổi từ [before] sang [after]. Chỉ
/// phát ở lúc chuyển (cạnh lên), không phát lặp mỗi khung hình.
List<SoundCue> soundCuesBetween(GameState before, GameState after) {
  return [
    if (_startsWarning(before, after)) SoundCue.warning,
    if (!before.isPlayerSeen && after.isPlayerSeen) SoundCue.alert,
    if (_startsWalking(before, after)) SoundCue.footstep,
    ..._skillCues(before.skills.feedback, after.skills.feedback),
    if (!before.event.isPaperDropped && after.event.isPaperDropped)
      SoundCue.paper,
    if (before.event.phase == EventPhase.pending &&
        after.event.phase == EventPhase.warning)
      SoundCue.bell,
    ..._endCues(before.status, after.status),
  ];
}

bool _startsWarning(GameState before, GameState after) {
  for (
    var i = 0;
    i < after.teachers.length && i < before.teachers.length;
    i++
  ) {
    final was = teacherCueFor(before.teachers[i]) == TeacherCue.warning;
    final now = teacherCueFor(after.teachers[i]) == TeacherCue.warning;
    if (now && !was) return true;
  }
  return false;
}

bool _startsWalking(GameState before, GameState after) {
  const walking = {TeacherMode.patrol, TeacherMode.approach};
  for (
    var i = 0;
    i < after.teachers.length && i < before.teachers.length;
    i++
  ) {
    final was = walking.contains(before.teachers[i].mode);
    final now = walking.contains(after.teachers[i].mode);
    if (now && !was) return true;
  }
  return false;
}

List<SoundCue> _skillCues(SkillFeedback? before, SkillFeedback? after) {
  if (after == null || after.serial == before?.serial) return const [];
  return [
    switch (after.outcome) {
      SkillOutcome.success => SoundCue.pencil,
      SkillOutcome.failure => SoundCue.fail,
      _ => SoundCue.click,
    },
  ];
}

List<SoundCue> _endCues(GameStatus before, GameStatus after) {
  if (before.isFinished || !after.isFinished) return const [];
  if (after == GameStatus.won) return const [SoundCue.win];
  return const [SoundCue.lose];
}

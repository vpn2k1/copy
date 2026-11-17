import 'package:dung_de_thay_thay/core/animation/student_rig.dart';
import 'package:dung_de_thay_thay/core/animation/teacher_animator.dart';
import 'package:dung_de_thay_thay/core/animation/teacher_rig.dart';
import 'package:dung_de_thay_thay/core/game/game_controller.dart';
import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/core/game/scene_pose.dart';
import 'package:dung_de_thay_thay/core/game/teacher_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'play_script.dart';

void main() {
  test('hình giáo viên luôn khớp bộ phát hiện suốt một ván', () {
    for (final seed in [1, 4, 9]) {
      final controller = GameController(seed: seed)..start();
      final animator = TeacherAnimator();
      final strategy = carefulPlayer();
      while (!controller.state.status.isFinished) {
        final action = strategy(controller.state);
        if (action != null) controller.press(action);
        final state = controller.tick(1 / 60);
        final teacher = state.teacher;
        animator.follow(
          teacherPoseFor(teacher),
          facesLeft: teacher.facesLeft,
          cue: teacherCueFor(teacher),
          turnProgress: teacherTurnProgress(teacher),
        );
        animator.update(1 / 60);
        final rig = animator.rig;
        if (state.isPlayerSeen) {
          expect(rig.facesLeft, isTrue, reason: 'thấy thì mặt phải hướng trái');
          expect(rig.cue, isNot(TeacherCue.none));
          expect(rig.cue, isNot(TeacherCue.warning));
        }
        if (rig.cue == TeacherCue.warning || teacher.isTurning) {
          expect(state.isPlayerSeen, isFalse);
        }
      }
    }
  });

  test('quay người: hình dẹt giữa chừng và kết thúc đúng hướng mới', () {
    const start = TeacherState(
      mode: TeacherMode.lookLeft,
      x: 1200,
      facesLeft: false,
      turnRemaining: teacherTurnSeconds / 2,
    );
    expect(teacherPoseFor(start), TeacherPose.turn);
    expect(teacherTurnProgress(start), closeTo(0.5, 1e-9));
    final animator = TeacherAnimator()
      ..follow(
        TeacherPose.turn,
        facesLeft: false,
        cue: TeacherCue.none,
        turnProgress: 0.5,
      );
    expect(animator.rig.scaleX.abs(), lessThan(1e-9));
    animator.update(5);
    expect(animator.pose, TeacherPose.turn, reason: 'AI quyết định khi xong');
  });

  test('tư thế nhân vật chính theo hành động và kết cục', () {
    final controller = GameController(seed: 1)..start();
    expect(playerPoseFor(controller.state), StudentPose.idle);
    controller.press(PlayerAction.cheat);
    expect(playerPoseFor(controller.state), StudentPose.cheating);
    controller.press(PlayerAction.hide);
    expect(playerPoseFor(controller.state), StudentPose.hiding);
    controller.press(PlayerAction.write);
    expect(playerPoseFor(controller.state), StudentPose.writing);
    expect(
      playerPoseFor(controller.state.copyWith(status: GameStatus.won)),
      StudentPose.celebrating,
    );
    expect(
      playerPoseFor(controller.state.copyWith(status: GameStatus.lostCaught)),
      StudentPose.caught,
    );
  });

  test('bắt được thì cô chỉ tay với dấu chấm than', () {
    const caught = TeacherState(
      mode: TeacherMode.caught,
      x: 900,
      facesLeft: true,
    );
    expect(teacherPoseFor(caught), TeacherPose.caught);
    expect(teacherCueFor(caught), TeacherCue.alarm);
  });
}

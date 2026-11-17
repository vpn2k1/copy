import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../../core/animation/student_rig.dart';
import '../../core/animation/teacher_rig.dart';
import '../../core/game/game_controller.dart';
import '../../core/game/game_state.dart';
import '../../core/game/scene_pose.dart';
import '../../core/classroom_layout.dart';
import '../../core/world_layout.dart';
import 'components/camera_guides.dart';
import 'components/classroom_background.dart';
import 'components/dropped_paper.dart';
import 'components/exam_images.dart';
import 'components/pose_demo.dart';
import 'components/seated_student.dart';
import 'components/teacher_figure.dart';

/// Game Flame của màn thi. Camera cố định độ phân giải logic 1600x900 và
/// letterbox theo tỉ lệ màn hình, không cắt mất phần cảnh nào.
/// Cảnh dựng theo góc nhìn từ bàn bên trái nhân vật chính.
/// Mỗi khung hình: tick [controller], đồng bộ hình theo trạng thái, rồi báo
/// [onStateChanged] cho HUD. Hình chỉ đọc trạng thái, không đổi luật chơi.
class ExamGame extends FlameGame {
  ExamGame({
    GameController? controller,
    this.onStateChanged,
    this.showCameraGuides = false,
    this.showPoseDemo = false,
  }) : controller = controller ?? GameController(seed: 1),
       super(
         camera: CameraComponent.withFixedResolution(
           width: WorldLayout.width,
           height: WorldLayout.height,
         ),
       );

  final GameController controller;
  final void Function(GameState state)? onStateChanged;

  /// Vẽ chú thích vùng HUD và camera (chỉ dùng khi review bố cục).
  final bool showCameraGuides;

  /// Lần lượt chạy mọi tư thế của nhân vật chính và giáo viên (chỉ review).
  final bool showPoseDemo;

  /// Màu viền letterbox ngoài vùng 16:9.
  static const Color letterboxColor = Color(0xFF162034);

  /// Lệch nhịp (giây) giữa các bạn để cả lớp không viết, chớp mắt đồng loạt.
  static const double _classmatePhaseStep = 0.37;

  late final SeatedStudent player;
  late final List<TeacherFigure> teachers;
  late final List<SeatedStudent> classmates;
  final DroppedPaper droppedPaper = DroppedPaper();

  /// Cô chính (cô đầu tiên).
  TeacherFigure get teacher => teachers.first;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await preloadExamImages();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    player = _seatedAt(ClassroomLayout.player, HairStyle.short, hasScarf: true);
    teachers = [
      for (var i = 0; i < controller.level.teacherCount; i++) _teacherAt(i),
    ];
    classmates = [
      for (final (i, mate) in ClassroomLayout.classmates.indexed)
        _seatedAt(
          mate,
          _hairFor(i),
          pose: StudentPose.writing,
          phase: (i + 1) * _classmatePhaseStep,
        ),
    ];
    await world.addAll([
      ClassroomBackground(),
      ...teachers,
      ...classmates,
      player,
      droppedPaper,
      if (showCameraGuides) CameraGuides(),
      if (showPoseDemo) PoseDemo(player: player, teacher: teacher),
    ]);
    _syncViews(controller.state);
  }

  @override
  void update(double dt) {
    if (!showPoseDemo && isLoaded) {
      final state = controller.tick(dt);
      _syncViews(state);
      onStateChanged?.call(state);
    }
    super.update(dt);
  }

  /// Đặt lại hoạt ảnh khi chơi lại (gỡ khóa tư thế bị bắt / ăn mừng).
  void resetViews() {
    player.animator.reset(StudentPose.idle);
    for (final figure in teachers) {
      figure.animator.reset(TeacherPose.idle);
    }
    _syncViews(controller.state);
  }

  TeacherFigure _teacherAt(int index) {
    final feet = Vector2(ClassroomLayout.teacher.x, ClassroomLayout.teacher.y);
    if (index == 0) {
      return TeacherFigure(
        feet: feet,
        figureScale: ClassroomLayout.teacher.scale,
      );
    }
    return TeacherFigure(
      feet: feet,
      figureScale: ClassroomLayout.teacher.scale,
      aoDai: TeacherFigure.blueAoDai,
      aoDaiLight: TeacherFigure.blueAoDaiLight,
      watchingCueColor: TeacherFigure.blueCue,
    );
  }

  void _syncViews(GameState state) {
    if (showPoseDemo) return;
    for (final (i, mode) in state.teachers.indexed) {
      final figure = teachers[i];
      figure.position.x = mode.x;
      figure.animator.follow(
        teacherPoseFor(mode),
        facesLeft: mode.facesLeft,
        cue: teacherCueFor(mode),
        turnProgress: teacherTurnProgress(mode),
      );
    }
    droppedPaper.isVisible = state.event.isPaperDropped;
    player.animator.change(playerPoseFor(state));
    player.animator.suspicion = state.suspicion / 100;
  }

  /// Trộn tóc ngắn / tóc buộc theo chỉ số để lớp không đồng loạt một kiểu.
  HairStyle _hairFor(int index) {
    return HairStyle.values[(index * 5 ~/ 3) % HairStyle.values.length];
  }

  SeatedStudent _seatedAt(
    FigurePlacement place,
    HairStyle hair, {
    bool hasScarf = false,
    StudentPose pose = StudentPose.idle,
    double phase = 0,
  }) {
    return SeatedStudent(
      seat: Vector2(place.x, place.y),
      figureScale: place.scale,
      hairStyle: hair,
      hasScarf: hasScarf,
      pose: pose,
      phase: phase,
    );
  }

  @override
  Color backgroundColor() => letterboxColor;
}

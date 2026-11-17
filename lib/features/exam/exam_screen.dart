import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/game_audio.dart';
import '../../app/route_names.dart';
import '../../core/game/game_controller.dart';
import '../../core/game/game_state.dart';
import '../../core/game/game_status.dart';
import '../../core/game/level_config.dart';
import '../../core/game/levels.dart';
import '../../core/game/stars.dart';
import '../../core/world_layout.dart';
import '../../l10n/strings.dart';
import 'exam_game.dart';
import 'state/exam_session.dart';
import 'widgets/action_bar.dart';
import 'widgets/event_banner.dart';
import 'widgets/exam_hud.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/result_panel.dart';
import 'widgets/skill_toast.dart';

/// Màn thi: khung Flame toàn màn hình, HUD phía trên, nút giữ phía dưới.
/// Khi app mất focus hoặc vào nền, ván dừng (thả mọi nút) và chỉ chạy lại khi
/// người chơi bấm tiếp tục.
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key, this.seed, this.level});

  /// Seed cố định cho test; mặc định lấy theo thời gian.
  final int? seed;

  /// Màn chơi; mặc định màn 1 (hoặc màn thử kỹ năng khi bật SKILL_SANDBOX).
  final LevelConfig? level;

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  late final ExamSession session = ExamSession(
    controller: GameController(
      seed: widget.seed ?? DateTime.now().millisecondsSinceEpoch,
      level: _level(),
    ),
    onFinished: _record,
  );
  late final ExamGame game = ExamGame(
    controller: session.controller,
    onStateChanged: session.onTick,
    showCameraGuides: const bool.fromEnvironment('CAMERA_GUIDES'),
    showPoseDemo: const bool.fromEnvironment('POSE_DEMO'),
  );
  bool hasStartedAudio = false;
  final Map<int, PlayerAction> _scenePointers = {};

  static const bool _isDebugHud = bool.fromEnvironment('DEBUG_HUD');
  static const bool _isSkillSandbox = bool.fromEnvironment('SKILL_SANDBOX');

  GameController get controller => session.controller;

  LevelConfig _level() {
    final level = widget.level;
    if (level != null) return level;
    if (_isSkillSandbox) return skillSandboxLevel;
    return levelOne;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hasStartedAudio) return;
    hasStartedAudio = true;
    session.audio = AppScope.maybeRead(context)?.audio ?? const SilentAudio();
    session.audio.startAmbient();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    session.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    _pause();
  }

  void _pause() {
    if (!controller.state.isRunning) return;
    _scenePointers.clear();
    session.run((c) => c.pause());
    game.pauseEngine();
    session.audio.stopAmbient();
  }

  void _resume() {
    session.run((c) => c.resume());
    game.resumeEngine();
    session.audio.startAmbient();
  }

  void _record(GameState state) {
    AppScope.maybeRead(context)?.notifier?.record(
      state.levelId,
      isWon: state.status == GameStatus.won,
      stars: starsOf(state),
    );
  }

  void _retry() {
    _scenePointers.clear();
    session.restart();
    game.resetViews();
  }

  void _pressScene(PointerDownEvent event, Size size) {
    if (!controller.state.isRunning) return;
    final action = _sceneActionAt(event.localPosition, size);
    if (action == null) return;
    _scenePointers[event.pointer] = action;
    session.run((c) => c.press(action));
  }

  void _releaseScene(int pointer) {
    final action = _scenePointers.remove(pointer);
    if (action == null) return;
    session.run((c) => c.release(action));
  }

  PlayerAction? _sceneActionAt(Offset point, Size size) {
    final scale = (size.width / WorldLayout.width).clamp(
      0.0,
      size.height / WorldLayout.height,
    );
    if (scale <= 0) return null;
    final left = (size.width - WorldLayout.width * scale) / 2;
    final top = (size.height - WorldLayout.height * scale) / 2;
    final x = (point.dx - left) / scale;
    final y = (point.dy - top) / scale;
    if (x >= 410 && x <= 685 && y >= 505 && y <= 590) {
      return PlayerAction.write;
    }
    if (x >= 680 && x <= 815 && y >= 425 && y <= 510) {
      return PlayerAction.cheat;
    }
    if (x >= 510 && x <= 675 && y >= 335 && y <= 500) {
      return PlayerAction.hide;
    }
    return null;
  }

  void _exit() => Navigator.of(context).pop();

  /// Nút màn tiếp: chỉ khi thắng một màn thật chưa phải màn cuối.
  VoidCallback? _nextLevel(GameState state) {
    final id = state.levelId;
    if (state.status != GameStatus.won || id < 1 || id >= lastLevelId) {
      return null;
    }
    return () => Navigator.of(
      context,
    ).pushReplacementNamed(RouteNames.exam, arguments: id + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExamGame.letterboxColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                return Listener(
                  onPointerDown: (event) => _pressScene(event, size),
                  onPointerUp: (event) => _releaseScene(event.pointer),
                  onPointerCancel: (event) => _releaseScene(event.pointer),
                  child: GameWidget(game: game),
                );
              },
            ),
          ),
          ValueListenableBuilder<GameState>(
            valueListenable: session.state,
            builder: (context, state, _) => _overlay(state),
          ),
        ],
      ),
    );
  }

  Widget _overlay(GameState state) {
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _topBar(state),
                const SizedBox(height: 6),
                EventBanner(
                  state: state,
                  onAcknowledge: () =>
                      session.run((c) => c.acknowledgeQuestion()),
                  onPickUp: () => session.run((c) => c.pickUpPaper()),
                  onResolveHint: ({required isSelfWrite}) => session.run(
                    (c) => c.resolveHint(isSelfWrite: isSelfWrite),
                  ),
                ),
                const Spacer(),
                SkillToast(feedback: state.skills.feedback),
                const SizedBox(height: 8),
                ActionBar(
                  state: state,
                  onPress: (action) => session.run((c) => c.press(action)),
                  onRelease: (action) => session.run((c) => c.release(action)),
                  onSelectSkill: (id) => session.run((c) => c.selectSkill(id)),
                  onAnswer: (index) => session.run((c) => c.answer(index)),
                ),
              ],
            ),
          ),
        ),
        if (state.status == GameStatus.paused)
          PauseOverlay(
            availableSkillIds: state.skills.availableIds,
            onResume: _resume,
            onExit: _exit,
          ),
        if (state.status.isFinished)
          ResultPanel(
            status: state.status,
            stars: starsOf(state),
            onNext: _nextLevel(state),
            onRetry: _retry,
            onExit: _exit,
          ),
      ],
    );
  }

  Widget _topBar(GameState state) {
    return Row(
      children: [
        IconButton.filledTonal(
          key: const Key('exam.back'),
          tooltip: Strings.backToMenu,
          onPressed: _exit,
          icon: const Icon(Icons.arrow_back),
        ),
        IconButton.filledTonal(
          key: const Key('pause'),
          tooltip: Strings.pauseButton,
          onPressed: _pause,
          icon: const Icon(Icons.pause),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ExamHud(state: state, isDebug: _isDebugHud),
          ),
        ),
      ],
    );
  }
}

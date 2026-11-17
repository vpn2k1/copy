import 'package:flutter/foundation.dart';

import '../../../app/game_audio.dart';
import '../../../core/game/game_controller.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/game_status.dart';
import '../../../core/game/sound_cues.dart';

/// Phiên chơi của màn thi: giữ [controller], phát trạng thái cho giao diện,
/// phát âm thanh khi có chuyển biến và báo kết quả đúng một lần mỗi ván.
class ExamSession {
  ExamSession({required this.controller, this.onFinished})
    : state = ValueNotifier(controller.state),
      _lastHeard = controller.state;

  final GameController controller;
  final ValueNotifier<GameState> state;

  /// Gọi một lần khi ván kết thúc (ghi tiến trình).
  final void Function(GameState state)? onFinished;

  GameAudio audio = const SilentAudio();
  GameState _lastHeard;
  bool _hasReportedEnd = false;

  /// Gửi một lệnh cho [controller] rồi cập nhật giao diện.
  void run(void Function(GameController controller) command) {
    command(controller);
    state.value = controller.state;
  }

  /// Gọi mỗi khung hình sau khi game tick.
  void onTick(GameState next) {
    state.value = next;
    for (final cue in soundCuesBetween(_lastHeard, next)) {
      audio.play(cue);
    }
    _lastHeard = next;
    if (!next.status.isFinished || _hasReportedEnd) return;
    _hasReportedEnd = true;
    onFinished?.call(next);
  }

  /// Chơi lại với seed mới.
  void restart() {
    _hasReportedEnd = false;
    controller.restart(seed: controller.state.seed + 1);
    _lastHeard = controller.state;
    state.value = controller.state;
  }

  void dispose() {
    audio.stopAmbient();
    state.dispose();
  }
}

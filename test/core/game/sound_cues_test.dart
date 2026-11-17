import 'package:dung_de_thay_thay/core/game/game_controller.dart';
import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/core/game/levels.dart';
import 'package:dung_de_thay_thay/core/game/sound_cues.dart';
import 'package:flutter_test/flutter_test.dart';

import 'play_script.dart';

/// Chạy cả ván chỉ viết bài (sống tới hết giờ), gom mọi hiệu ứng phát ra.
List<SoundCue> heardDuring(GameController controller) {
  final heard = <SoundCue>[];
  controller.start();
  var last = controller.state;
  controller.press(PlayerAction.write);
  for (var t = 0.0; t < 200 && !last.status.isFinished; t += 1 / 60) {
    controller.tick(1 / 60);
    heard.addAll(soundCuesBetween(last, controller.state));
    last = controller.state;
  }
  return heard;
}

void main() {
  test(
    'một ván có báo trước, báo động, bước chân, chuông sự kiện, kết thúc',
    () {
      final heard = heardDuring(GameController(seed: 1, level: levelOne));
      expect(heard, contains(SoundCue.warning));
      expect(heard, contains(SoundCue.alert));
      expect(heard, contains(SoundCue.footstep));
      expect(heard, contains(SoundCue.bell));
      expect(heard.where((cue) => cue == SoundCue.lose), hasLength(1));
    },
  );

  test('không phát lặp khi trạng thái không đổi', () {
    final controller = GameController(seed: 1)..start();
    final state = controller.state;
    expect(soundCuesBetween(state, state), isEmpty);
  });

  test('thắng phát đúng một tiếng thắng', () {
    final controller = GameController(seed: 2, level: levelOne);
    final before = controller.state;
    final end = playSmart(controller);
    expect(end.status, GameStatus.won);
    expect(soundCuesBetween(before, end), contains(SoundCue.win));
    expect(soundCuesBetween(end, end), isEmpty);
  });

  test('kỹ năng: thành công tiếng bút, bấm khi hồi chiêu tiếng tách', () {
    final controller = GameController(seed: 1)..start();
    controller.selectSkill('pretend');
    var last = controller.state;
    controller.press(PlayerAction.cheat);
    final heard = <SoundCue>[];
    for (var i = 0; i < 120; i++) {
      controller.tick(1 / 60);
      heard.addAll(soundCuesBetween(last, controller.state));
      last = controller.state;
    }
    controller.release(PlayerAction.cheat);
    controller.press(PlayerAction.cheat);
    heard.addAll(soundCuesBetween(last, controller.state));
    expect(heard, contains(SoundCue.pencil));
    expect(heard.last, SoundCue.click);
  });
}

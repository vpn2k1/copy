import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '../core/game/sound_cues.dart';
import '../core/save/save_data.dart';

/// Phát âm thanh của game. Lỗi nền tảng hay thiếu file không được làm hỏng
/// game: mọi lỗi bị nuốt và chuyển sang im lặng.
abstract interface class GameAudio {
  void apply(AudioSettings settings);

  void play(SoundCue cue);

  void startAmbient();

  void stopAmbient();
}

/// Không phát gì (test, hoặc khi nền tảng không có âm thanh).
class SilentAudio implements GameAudio {
  const SilentAudio();

  @override
  void apply(AudioSettings settings) {}

  @override
  void play(SoundCue cue) {}

  @override
  void startAmbient() {}

  @override
  void stopAmbient() {}
}

/// Phát bằng flame_audio từ `assets/audio/` (xem README trong thư mục đó).
class FlameGameAudio implements GameAudio {
  static const _ambientFile = 'ambient_classroom.wav';

  AudioSettings _settings = const AudioSettings();
  bool _isAmbientWanted = false;

  /// File đã lỗi (thiếu, không giải mã được): bỏ qua từ đó về sau.
  final Set<String> _failed = {};

  static String fileFor(SoundCue cue) => '${cue.name}.wav';

  @override
  void apply(AudioSettings settings) {
    _settings = settings;
    _guard(_ambientFile, () async {
      if (!_isAmbientWanted) return;
      if (_settings.isMuted || _settings.musicVolume <= 0) {
        await FlameAudio.bgm.stop();
        return;
      }
      if (!FlameAudio.bgm.isPlaying) {
        await FlameAudio.bgm.play(_ambientFile, volume: _settings.musicVolume);
        return;
      }
      await FlameAudio.bgm.audioPlayer.setVolume(_settings.musicVolume);
    });
  }

  @override
  void play(SoundCue cue) {
    if (_settings.isMuted || _settings.sfxVolume <= 0) return;
    final file = fileFor(cue);
    _guard(file, () => FlameAudio.play(file, volume: _settings.sfxVolume));
  }

  @override
  void startAmbient() {
    _isAmbientWanted = true;
    apply(_settings);
  }

  @override
  void stopAmbient() {
    _isAmbientWanted = false;
    _guard(_ambientFile, FlameAudio.bgm.stop);
  }

  void _guard(String file, Future<void> Function() action) {
    if (_failed.contains(file)) return;
    void fail(Object error) {
      _failed.add(file);
      debugPrint('Tắt âm thanh $file do lỗi: $error');
    }

    try {
      action().catchError(fail);
    } on Object catch (error) {
      fail(error);
    }
  }
}

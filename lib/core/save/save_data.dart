import 'dart:convert';

import '../game/levels.dart';
import '../game/progress_book.dart';

/// Phiên bản định dạng lưu hiện tại (07_DATA_CONTRACTS, "Save JSON version 1").
const currentSaveVersion = 1;

/// Tùy chọn âm thanh.
class AudioSettings {
  const AudioSettings({
    this.musicVolume = 0.5,
    this.sfxVolume = 0.8,
    this.isMuted = false,
  });

  /// 0..1, âm nền lớp học.
  final double musicVolume;

  /// 0..1, hiệu ứng (bước chân, báo động, giấy…).
  final double sfxVolume;
  final bool isMuted;

  AudioSettings copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? isMuted,
  }) {
    return AudioSettings(
      musicVolume: _volume(musicVolume ?? this.musicVolume),
      sfxVolume: _volume(sfxVolume ?? this.sfxVolume),
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AudioSettings &&
      other.musicVolume == musicVolume &&
      other.sfxVolume == sfxVolume &&
      other.isMuted == isMuted;

  @override
  int get hashCode => Object.hash(musicVolume, sfxVolume, isMuted);
}

/// Dữ liệu lưu của người chơi: tiến trình và cài đặt. Đọc dễ dãi (thiếu
/// hoặc hỏng thì dùng mặc định, ngoài phạm vi thì kẹp lại), ghi đúng
/// định dạng phiên bản 1.
class SaveData {
  const SaveData({
    this.progress = const ProgressBook(),
    this.settings = const AudioSettings(),
    this.version = currentSaveVersion,
  });

  final ProgressBook progress;
  final AudioSettings settings;

  /// Phiên bản đọc được từ máy. Lớn hơn [currentSaveVersion] nghĩa là dữ
  /// liệu do bản app mới hơn ghi; bản này không được ghi đè lên.
  final int version;

  bool get isFromNewerVersion => version > currentSaveVersion;

  SaveData copyWith({ProgressBook? progress, AudioSettings? settings}) {
    return SaveData(
      progress: progress ?? this.progress,
      settings: settings ?? this.settings,
      version: version,
    );
  }

  Map<String, Object> toJson() => {
    'version': currentSaveVersion,
    'unlockedLevel': progress.unlockedLevel,
    'bestStars': {
      for (var id = 1; id <= lastLevelId; id++) '$id': progress.starsOf(id),
    },
    'settings': {
      'musicVolume': settings.musicVolume,
      'sfxVolume': settings.sfxVolume,
      'muted': settings.isMuted,
    },
  };

  String encode() => jsonEncode(toJson());

  /// Đọc từ chuỗi JSON. Ném [FormatException] nếu không phải JSON object
  /// (nơi gọi quyết định giữ bản hỏng lại hay không).
  static SaveData decode(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map<String, Object?>) {
      throw const FormatException('Dữ liệu lưu không phải JSON object');
    }
    return fromJson(json);
  }

  static SaveData fromJson(Map<String, Object?> json) {
    final unlocked = _int(json['unlockedLevel'], 1).clamp(1, lastLevelId);
    final stars = <int, int>{};
    final rawStars = json['bestStars'];
    if (rawStars is Map) {
      for (var id = 1; id <= lastLevelId; id++) {
        final value = _int(rawStars['$id'], 0).clamp(0, 3);
        if (value > 0) stars[id] = value;
      }
    }
    final rawSettings = json['settings'];
    var settings = const AudioSettings();
    if (rawSettings is Map) {
      settings = AudioSettings(
        musicVolume: _volume(_double(rawSettings['musicVolume'], 0.5)),
        sfxVolume: _volume(_double(rawSettings['sfxVolume'], 0.8)),
        isMuted: rawSettings['muted'] == true,
      );
    }
    return SaveData(
      progress: ProgressBook(
        unlockedLevel: unlocked,
        bestStars: Map.unmodifiable(stars),
      ),
      settings: settings,
      version: _int(json['version'], currentSaveVersion),
    );
  }
}

int _int(Object? value, int fallback) {
  if (value is int) return value;
  if (value is double && value.isFinite) return value.round();
  return fallback;
}

double _double(Object? value, double fallback) {
  if (value is num && value.isFinite) return value.toDouble();
  return fallback;
}

double _volume(double value) => value.clamp(0.0, 1.0).toDouble();

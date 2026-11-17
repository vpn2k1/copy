import 'dart:convert';

import 'package:dung_de_thay_thay/core/game/progress_book.dart';
import 'package:dung_de_thay_thay/core/save/save_data.dart';
import 'package:dung_de_thay_thay/core/save/save_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ghi đúng định dạng JSON phiên bản 1 của contract', () {
    const data = SaveData(
      progress: ProgressBook(unlockedLevel: 3, bestStars: {1: 3, 2: 1}),
      settings: AudioSettings(musicVolume: 0.25, sfxVolume: 1, isMuted: true),
    );
    expect(jsonDecode(data.encode()), {
      'version': 1,
      'unlockedLevel': 3,
      'bestStars': {'1': 3, '2': 1, '3': 0, '4': 0, '5': 0},
      'settings': {'musicVolume': 0.25, 'sfxVolume': 1.0, 'muted': true},
    });
  });

  test('ghi rồi đọc lại giữ nguyên', () {
    const data = SaveData(
      progress: ProgressBook(unlockedLevel: 5, bestStars: {4: 2}),
      settings: AudioSettings(musicVolume: 0.1),
    );
    final back = SaveData.decode(data.encode());
    expect(back.progress.unlockedLevel, 5);
    expect(back.progress.starsOf(4), 2);
    expect(back.settings, data.settings);
  });

  test(
    'thiếu trường hoặc sai kiểu thì dùng mặc định, ngoài phạm vi thì kẹp',
    () {
      final data = SaveData.fromJson({
        'unlockedLevel': 99,
        'bestStars': {'1': 7, '2': -1, '3': 'x'},
        'settings': {'musicVolume': 4, 'sfxVolume': 'loud'},
      });
      expect(data.progress.unlockedLevel, 5);
      expect(data.progress.starsOf(1), 3);
      expect(data.progress.starsOf(2), 0);
      expect(data.progress.starsOf(3), 0);
      expect(data.settings.musicVolume, 1);
      expect(data.settings.sfxVolume, 0.8);
      expect(SaveData.fromJson({}).progress.unlockedLevel, 1);
      expect(SaveData.fromJson({'unlockedLevel': 0}).progress.unlockedLevel, 1);
    },
  );

  group('kho lưu', () {
    test('chưa có dữ liệu thì bắt đầu từ màn 1', () async {
      final repo = SaveRepository(MemorySaveStore());
      final data = await repo.load();
      expect(data.progress.unlockedLevel, 1);
    });

    test(
      'dữ liệu hỏng: sao lưu bản hỏng, không xóa âm thầm, dùng mặc định',
      () async {
        final store = MemorySaveStore({SaveRepository.saveKey: '{oops'});
        final repo = SaveRepository(store);
        final data = await repo.load();
        expect(data.progress.unlockedLevel, 1);
        expect(repo.hasRecoveredFromCorruption, isTrue);
        expect(store.values[SaveRepository.corruptBackupKey], '{oops');
        expect(await repo.save(data), isTrue);
      },
    );

    test('JSON không phải object cũng coi là hỏng', () async {
      final store = MemorySaveStore({SaveRepository.saveKey: '[1,2]'});
      final repo = SaveRepository(store);
      await repo.load();
      expect(repo.hasRecoveredFromCorruption, isTrue);
    });

    test('dữ liệu từ bản mới hơn: đọc phần hiểu được, không ghi đè', () async {
      final newer = jsonEncode({'version': 2, 'unlockedLevel': 4, 'extra': 1});
      final store = MemorySaveStore({SaveRepository.saveKey: newer});
      final repo = SaveRepository(store);
      final data = await repo.load();
      expect(data.isFromNewerVersion, isTrue);
      expect(data.progress.unlockedLevel, 4);
      expect(await repo.save(data), isFalse);
      expect(store.values[SaveRepository.saveKey], newer);
    });
  });
}

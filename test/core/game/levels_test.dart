import 'package:dung_de_thay_thay/core/game/game_controller.dart';
import 'package:dung_de_thay_thay/core/game/game_status.dart';
import 'package:dung_de_thay_thay/core/game/level_event.dart';
import 'package:dung_de_thay_thay/core/game/levels.dart';
import 'package:dung_de_thay_thay/core/game/progress_book.dart';
import 'package:dung_de_thay_thay/core/game/skills.dart';
import 'package:dung_de_thay_thay/core/game/stars.dart';
import 'package:flutter_test/flutter_test.dart';

import 'play_script.dart';

void main() {
  group('dữ liệu màn', () {
    test('đúng 5 màn id 1..5 theo bảng 05_LEVELS', () {
      expect([for (final level in allLevels) level.id], [1, 2, 3, 4, 5]);
      const table = [
        (90, 1, 0.6, 20.0, 'teacher_question'),
        (80, 1, 0.9, 27.0, 'fan_wind'),
        (75, 1, 1.0, 32.0, 'wrong_exam_code'),
        (70, 2, 1.2, 38.0, 'teacher_swap'),
        (65, 1, 1.5, 45.0, 'final_boss_mode'),
      ];
      for (final (i, row) in table.indexed) {
        final level = allLevels[i];
        expect(level.durationSeconds, row.$1);
        expect(level.teacherCount, row.$2);
        expect(level.teacherSpeed, row.$3);
        expect(level.suspicionPerSecond, row.$4);
        expect(level.specialEventId, row.$5);
      }
    });

    test('kỹ năng hợp lệ, cộng dồn, khớp màn mở khóa; đủ 12 ở màn 5', () {
      var previous = <String>{};
      for (final level in allLevels) {
        final ids = level.skillIds.toSet();
        expect(ids, isNotEmpty);
        expect(ids.containsAll(previous), isTrue, reason: 'màn ${level.id}');
        for (final id in ids) {
          expect(skillById(id).unlockLevel, lessThanOrEqualTo(level.id));
        }
        previous = ids;
      }
      expect(previous, hasLength(12));
    });

    test('mỗi màn một sự kiện khác nhau và có cấu hình', () {
      final events = {for (final level in allLevels) level.specialEventId};
      expect(events, hasLength(5));
      for (final id in events) {
        expect(eventById(id), isNotNull, reason: id);
      }
    });

    test(
      'độ khó tăng dần: nhanh hơn, nghi ngờ nhanh hơn, báo trước ngắn hơn',
      () {
        for (var i = 1; i < allLevels.length; i++) {
          final easier = allLevels[i - 1];
          final harder = allLevels[i];
          expect(harder.teacherSpeed, greaterThan(easier.teacherSpeed));
          expect(
            harder.suspicionPerSecond,
            greaterThan(easier.suspicionPerSecond),
          );
          expect(
            harder.watchWarningSeconds,
            lessThan(easier.watchWarningSeconds),
          );
          expect(harder.watchWarningSeconds, greaterThan(0));
        }
        expect(allLevels.first.watchWarningSeconds, greaterThanOrEqualTo(1));
      },
    );
  });

  group('cân bằng (người chơi giả lập)', () {
    test(
      'mọi màn: không làm gì, chỉ viết bài thì hết giờ; cóp liều thì bị bắt',
      () {
        for (final level in allLevels) {
          for (final seed in [1, 2, 3]) {
            final idle = playOut(seed, doNothing, level: level);
            final writer = playOut(seed, alwaysWrite, level: level);
            final reckless = playOut(seed, alwaysCheat, level: level);
            final where = 'màn ${level.id} seed $seed';
            expect(idle.status, GameStatus.lostTime, reason: where);
            expect(writer.status, GameStatus.lostTime, reason: where);
            expect(reckless.status, GameStatus.lostCaught, reason: where);
          }
        }
      },
    );

    test('người chơi khéo (phản ứng 0,3 s) thắng được mọi màn', () {
      for (final level in allLevels) {
        var wins = 0;
        for (var seed = 1; seed <= 10; seed++) {
          final end = playSmart(GameController(seed: seed, level: level));
          if (end.status == GameStatus.won) wins++;
        }
        expect(wins, greaterThanOrEqualTo(8), reason: 'màn ${level.id}');
      }
    });

    test('phản ứng chậm (1,3 s): màn sau kết thúc với nghi ngờ cao hơn', () {
      double averageSuspicion(int levelId) {
        var total = 0.0;
        for (var seed = 1; seed <= 10; seed++) {
          final controller = GameController(
            seed: seed,
            level: levelById(levelId),
          );
          total += playSmart(controller, reaction: 1.3).suspicion;
        }
        return total / 10;
      }

      expect(averageSuspicion(5), greaterThan(averageSuspicion(1) + 30));
      expect(averageSuspicion(4), greaterThan(averageSuspicion(2)));
    });

    test('cùng seed, cùng cách chơi: kết quả lặp lại ở mọi màn', () {
      for (final level in allLevels) {
        final a = playSmart(GameController(seed: 9, level: level));
        final b = playSmart(GameController(seed: 9, level: level));
        expect(a.remainingSeconds, b.remainingSeconds);
        expect(a.suspicion, b.suspicion);
      }
    });
  });

  group('sao', () {
    test('ranh giới 0/1/2/3 sao', () {
      int stars(bool won, double s, double t) =>
          starsFor(isWon: won, suspicion: s, remainingSeconds: t);
      expect(stars(false, 0, 60), 0);
      expect(stars(true, 41, 60), 1);
      expect(stars(true, 40, 0), 2);
      expect(stars(true, 21, 60), 2);
      expect(stars(true, 20, 29.9), 2);
      expect(stars(true, 20, 30), 3);
      expect(stars(true, 0, 90), 3);
    });
  });

  group('tiến trình', () {
    test('thắng mở màn kế, thua giữ nguyên, sao không giảm, tối đa màn 5', () {
      var book = const ProgressBook();
      expect(book.isUnlocked(1), isTrue);
      expect(book.isUnlocked(2), isFalse);
      book = book.record(1, isWon: false, stars: 0);
      expect(book.unlockedLevel, 1);
      book = book.record(1, isWon: true, stars: 2);
      expect(book.unlockedLevel, 2);
      expect(book.starsOf(1), 2);
      book = book.record(1, isWon: true, stars: 1);
      expect(book.starsOf(1), 2, reason: 'sao tốt nhất không giảm');
      book = book.record(1, isWon: false, stars: 0);
      expect(book.unlockedLevel, 2, reason: 'thua không khóa lại');
      for (var id = 2; id <= 5; id++) {
        book = book.record(id, isWon: true, stars: 3);
      }
      expect(book.unlockedLevel, 5);
      expect(book.record(9, isWon: true, stars: 3), same(book));
    });
  });
}

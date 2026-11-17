import 'levels.dart';

/// Tiến trình người chơi: màn đã mở và số sao tốt nhất từng màn.
/// Bất biến; [record] trả về bản mới. Phase 06 lưu bản này xuống máy.
class ProgressBook {
  const ProgressBook({this.unlockedLevel = 1, this.bestStars = const {}});

  /// Màn cao nhất đã mở (1..5).
  final int unlockedLevel;

  /// Sao tốt nhất theo id màn (0..3).
  final Map<int, int> bestStars;

  bool isUnlocked(int levelId) => levelId <= unlockedLevel;

  int starsOf(int levelId) => bestStars[levelId] ?? 0;

  /// Ghi kết quả một ván. Thắng màn N mở màn N+1 (tối đa 5). Sao chỉ tăng,
  /// không bao giờ giảm; thua không làm mất gì.
  ProgressBook record(int levelId, {required bool isWon, required int stars}) {
    if (levelId < 1 || levelId > lastLevelId) return this;
    var unlocked = unlockedLevel;
    if (isWon && levelId + 1 > unlocked) unlocked = levelId + 1;
    if (unlocked > lastLevelId) unlocked = lastLevelId;
    final isBetter = stars > starsOf(levelId);
    if (unlocked == unlockedLevel && !isBetter) return this;
    final best = Map<int, int>.of(bestStars);
    if (isBetter) best[levelId] = stars;
    return ProgressBook(
      unlockedLevel: unlocked,
      bestStars: Map.unmodifiable(best),
    );
  }
}

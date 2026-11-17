import 'game_state.dart';
import 'game_status.dart';

/// Sao của một ván (05_LEVELS): thắng 1 sao; +1 nếu nghi ngờ cuối ≤ 40;
/// +1 nếu nghi ngờ ≤ 20 và còn ≥ 30 giây. Thua 0 sao.
int starsFor({
  required bool isWon,
  required double suspicion,
  required double remainingSeconds,
}) {
  if (!isWon) return 0;
  var stars = 1;
  if (suspicion <= 40) stars++;
  if (suspicion <= 20 && remainingSeconds >= 30) stars++;
  return stars;
}

int starsOf(GameState state) => starsFor(
  isWon: state.status == GameStatus.won,
  suspicion: state.suspicion,
  remainingSeconds: state.remainingSeconds,
);

/// Trạng thái một ván thi.
enum GameStatus { ready, running, paused, won, lostCaught, lostTime }

extension GameStatusX on GameStatus {
  /// Ván đã kết thúc (thắng hoặc thua), không nhận lệnh chơi nữa.
  bool get isFinished =>
      this == GameStatus.won ||
      this == GameStatus.lostCaught ||
      this == GameStatus.lostTime;
}

/// Hành động người chơi đang giữ.
enum PlayerAction { write, cheat, hide }

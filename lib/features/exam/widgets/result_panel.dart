import 'package:flutter/material.dart';

import '../../../core/game/game_status.dart';
import '../../../l10n/strings.dart';

/// Lớp phủ kết quả ván thi: thông báo, sao, màn tiếp (khi thắng), chơi lại,
/// về menu.
class ResultPanel extends StatelessWidget {
  const ResultPanel({
    super.key,
    required this.status,
    required this.stars,
    required this.onRetry,
    required this.onExit,
    this.onNext,
  });

  final GameStatus status;
  final int stars;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  /// Null khi thua hoặc đã là màn cuối.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final next = onNext;
    return Center(
      child: Card(
        color: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _resultText(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (status == GameStatus.won)
                Text(
                  Strings.starsLabel(stars),
                  key: const Key('result.stars'),
                  style: const TextStyle(fontSize: 32, color: Colors.amber),
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (next != null)
                    FilledButton.icon(
                      key: const Key('result.next'),
                      onPressed: next,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text(Strings.nextLevel),
                    ),
                  FilledButton.tonalIcon(
                    key: const Key('result.retry'),
                    onPressed: onRetry,
                    icon: const Icon(Icons.replay),
                    label: const Text(Strings.replay),
                  ),
                  TextButton(
                    onPressed: onExit,
                    child: const Text(Strings.backToMenu),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resultText() {
    return switch (status) {
      GameStatus.won => Strings.wonResult,
      GameStatus.lostCaught => Strings.caughtResult,
      GameStatus.lostTime => Strings.timeoutResult,
      _ => '',
    };
  }
}

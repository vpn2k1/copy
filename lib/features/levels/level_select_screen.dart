import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/route_names.dart';
import '../../core/game/levels.dart';
import '../../l10n/strings.dart';

/// Chọn màn: 5 màn với khóa và sao tốt nhất. Màn chưa mở không bấm được.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final book = AppScope.of(context).book;
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.levelSelectTitle)),
      body: SafeArea(
        child: GridView.extent(
          padding: const EdgeInsets.all(_gap),
          maxCrossAxisExtent: 220,
          mainAxisSpacing: _gap,
          crossAxisSpacing: _gap,
          childAspectRatio: 1.4,
          children: [
            for (final level in allLevels)
              _LevelCard(
                levelId: level.id,
                isUnlocked: book.isUnlocked(level.id),
                stars: book.starsOf(level.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.levelId,
    required this.isUnlocked,
    required this.stars,
  });

  final int levelId;
  final bool isUnlocked;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      key: Key('level.$levelId'),
      child: InkWell(
        onTap: _onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Strings.levelLabel(levelId), style: textTheme.titleMedium),
                Text(
                  Strings.levelTitle(levelId),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                ..._status(textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _status(TextTheme textTheme) {
    if (!isUnlocked) {
      return [
        const Icon(Icons.lock),
        Text(Strings.lockedLevel, style: textTheme.labelSmall),
      ];
    }
    return [
      Text(
        Strings.starsLabel(stars),
        style: const TextStyle(fontSize: 20, color: Colors.amber),
      ),
    ];
  }

  VoidCallback? _onTap(BuildContext context) {
    if (!isUnlocked) return null;
    return () =>
        Navigator.of(context).pushNamed(RouteNames.exam, arguments: levelId);
  }
}

import 'package:flutter/material.dart';

import '../../app/route_names.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';

/// Menu gốc kiểu bảng phấn: tên game, VÀO LỚP (mở chọn màn) và CÀI ĐẶT.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const double _maxContentWidth = 460;
  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_gap),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: chalkboard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: chalkboardFrame, width: 10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_gap * 1.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        Strings.menuTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineLarge?.copyWith(
                          color: chalk,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        Strings.menuSubtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(color: chalk),
                      ),
                      const SizedBox(height: _gap * 1.5),
                      FilledButton(
                        key: const Key('menu.play'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: () =>
                            Navigator.of(context).pushNamed(RouteNames.levels),
                        child: const Text(Strings.playButton),
                      ),
                      const SizedBox(height: _gap),
                      OutlinedButton(
                        key: const Key('menu.settings'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: chalk,
                          side: const BorderSide(color: chalk),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(RouteNames.settings),
                        child: const Text(Strings.settingsButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/game/levels.dart';
import '../core/save/save_data.dart';
import '../core/save/save_repository.dart';
import '../features/exam/exam_screen.dart';
import '../features/levels/level_select_screen.dart';
import '../features/menu/menu_screen.dart';
import '../features/settings/settings_screen.dart';
import '../l10n/strings.dart';
import 'app_scope.dart';
import 'splash_screen.dart';
import 'game_audio.dart';
import 'route_names.dart';
import 'shared_prefs_store.dart';
import 'theme.dart';

/// Gốc của ứng dụng: đọc hồ sơ đã lưu, cung cấp hồ sơ và âm thanh, theme,
/// bảng route. Màn hình đầu tiên là menu.
class App extends StatefulWidget {
  const App({super.key, this.store, this.audio});

  /// Kho lưu; mặc định shared_preferences. Test truyền kho trong bộ nhớ.
  final SaveStore? store;

  /// Âm thanh; mặc định flame_audio. Test truyền [SilentAudio].
  final GameAudio? audio;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SaveRepository repository = SaveRepository(
    widget.store ?? SharedPrefsSaveStore(),
  );
  late final GameAudio audio = widget.audio ?? FlameGameAudio();
  ProfileNotifier? profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final splashDelay = Future<void>.delayed(const Duration(milliseconds: 900));
    var data = const SaveData();
    try {
      data = await repository.load();
    } on Object catch (error) {
      debugPrint('Không đọc được dữ liệu lưu, dùng mặc định: $error');
    }
    await splashDelay;
    if (!mounted) return;
    final loaded = ProfileNotifier(data: data, repository: repository)
      ..addListener(_applyAudio);
    setState(() => profile = loaded);
    _applyAudio();
  }

  void _applyAudio() {
    final settings = profile?.settings;
    if (settings != null) audio.apply(settings);
  }

  @override
  void dispose() {
    profile?.dispose();
    audio.stopAmbient();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loaded = profile;
    if (loaded == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
      );
    }
    return AppScope(
      notifier: loaded,
      audio: audio,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: Strings.appTitle,
        theme: buildAppTheme(),
        initialRoute: RouteNames.menu,
        onGenerateRoute: _route,
      ),
    );
  }

  Route<void> _route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => _page(settings),
    );
  }

  Widget _page(RouteSettings settings) {
    return switch (settings.name) {
      RouteNames.levels => const LevelSelectScreen(),
      RouteNames.exam => _exam(settings.arguments),
      RouteNames.settings => const SettingsScreen(),
      _ => const MenuScreen(),
    };
  }

  /// Màn thi theo id màn; không có tham số thì để màn thi tự chọn mặc định.
  Widget _exam(Object? argument) {
    if (argument is int) return ExamScreen(level: levelById(argument));
    return const ExamScreen();
  }
}

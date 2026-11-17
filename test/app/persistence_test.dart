import 'dart:convert';

import 'package:dung_de_thay_thay/app/app.dart';
import 'package:dung_de_thay_thay/app/app_scope.dart';
import 'package:dung_de_thay_thay/app/game_audio.dart';
import 'package:dung_de_thay_thay/core/game/sound_cues.dart';
import 'package:dung_de_thay_thay/core/save/save_data.dart';
import 'package:dung_de_thay_thay/core/save/save_repository.dart';
import 'package:dung_de_thay_thay/features/levels/level_select_screen.dart';
import 'package:dung_de_thay_thay/features/exam/components/exam_images.dart';
import 'package:dung_de_thay_thay/features/menu/menu_screen.dart';
import 'package:dung_de_thay_thay/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ghi lại mọi lệnh âm thanh để kiểm tra.
class RecordingAudio implements GameAudio {
  final List<AudioSettings> applied = [];
  final List<SoundCue> played = [];
  int ambientStarts = 0;

  @override
  void apply(AudioSettings settings) => applied.add(settings);

  @override
  void play(SoundCue cue) => played.add(cue);

  @override
  void startAmbient() => ambientStarts++;

  @override
  void stopAmbient() {}
}

Future<ProfileNotifier> pumpApp(
  WidgetTester tester,
  SaveStore store, {
  GameAudio audio = const SilentAudio(),
}) async {
  await tester.pumpWidget(App(store: store, audio: audio));
  await tester.pumpAndSettle();
  return AppScope.of(tester.element(find.byType(MenuScreen)));
}

/// Tháo app (như tắt app) rồi mở lại với cùng kho.
Future<ProfileNotifier> restart(WidgetTester tester, SaveStore store) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();
  return pumpApp(tester, store);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await preloadExamImages();
  });

  testWidgets('splash hiện VPN Games trước menu', (tester) async {
    await tester.pumpWidget(
      App(store: MemorySaveStore(), audio: const SilentAudio()),
    );
    expect(find.text(Strings.splashTitle), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(MenuScreen), findsOneWidget);
  });
  testWidgets('thắng màn 1 rồi tắt app: mở lại vẫn còn màn 2 và sao', (
    tester,
  ) async {
    final store = MemorySaveStore();
    var profile = await pumpApp(tester, store);
    profile.record(1, isWon: true, stars: 3);
    await profile.flushed;
    profile = await restart(tester, store);
    expect(profile.book.unlockedLevel, 2);
    expect(profile.book.starsOf(1), 3);
    await tester.tap(find.byKey(const Key('menu.play')));
    await tester.pumpAndSettle();
    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsNWidgets(3));
  });

  testWidgets('chơi lại kém hơn không làm giảm sao đã lưu', (tester) async {
    final store = MemorySaveStore();
    var profile = await pumpApp(tester, store);
    profile.record(1, isWon: true, stars: 3);
    profile.record(1, isWon: true, stars: 1);
    profile.record(1, isWon: false, stars: 0);
    await profile.flushed;
    profile = await restart(tester, store);
    expect(profile.book.starsOf(1), 3);
  });

  testWidgets('chỉ ghi khi có thay đổi thật', (tester) async {
    final store = MemorySaveStore();
    final profile = await pumpApp(tester, store);
    profile.record(1, isWon: false, stars: 0);
    await profile.flushed;
    expect(store.values.containsKey(SaveRepository.saveKey), isFalse);
  });

  testWidgets('cài đặt: tắt tiếng được lưu và áp dụng cho âm thanh', (
    tester,
  ) async {
    final store = MemorySaveStore();
    final audio = RecordingAudio();
    await pumpApp(tester, store, audio: audio);
    await tester.tap(find.byKey(const Key('menu.settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.mute')));
    await tester.pumpAndSettle();
    expect(audio.applied.last.isMuted, isTrue);
    final profile = await restart(tester, store);
    await profile.flushed;
    expect(profile.settings.isMuted, isTrue);
    final saved = jsonDecode(store.values[SaveRepository.saveKey]!);
    expect((saved as Map)['settings'], containsPair('muted', true));
  });

  testWidgets('kéo thanh âm lượng chỉ lưu khi thả tay', (tester) async {
    final store = MemorySaveStore();
    await pumpApp(tester, store);
    await tester.tap(find.byKey(const Key('menu.settings')));
    await tester.pumpAndSettle();
    final slider = find.byKey(const Key('settings.music'));
    final gesture = await tester.startGesture(tester.getCenter(slider));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();
    expect(store.values.containsKey(SaveRepository.saveKey), isFalse);
    await gesture.up();
    await tester.pumpAndSettle();
    final saved = SaveData.decode(store.values[SaveRepository.saveKey]!);
    expect(saved.settings.musicVolume, greaterThan(0.5));
  });

  testWidgets('dữ liệu hỏng lúc mở app: vẫn vào menu, bản hỏng được giữ lại', (
    tester,
  ) async {
    final store = MemorySaveStore({SaveRepository.saveKey: 'not json'});
    final profile = await pumpApp(tester, store);
    expect(find.byType(MenuScreen), findsOneWidget);
    expect(profile.book.unlockedLevel, 1);
    expect(store.values[SaveRepository.corruptBackupKey], 'not json');
  });

  testWidgets('menu và cài đặt vừa điện thoại ngang 932x430', (tester) async {
    tester.view.physicalSize = const Size(932, 430);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, MemorySaveStore());
    expect(tester.takeException(), isNull);
    for (final key in ['menu.play', 'menu.settings']) {
      final rect = tester.getRect(find.byKey(Key(key)));
      expect(rect.bottom, lessThanOrEqualTo(430), reason: key);
    }
    await tester.tap(find.byKey(const Key('menu.settings')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('settings.mute')), findsOneWidget);
  });

  testWidgets('vào màn thi: bật âm nền và phát hiệu ứng theo diễn biến', (
    tester,
  ) async {
    final audio = RecordingAudio();
    await pumpApp(tester, MemorySaveStore(), audio: audio);
    await tester.tap(find.byKey(const Key('menu.play')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('level.1')));
    for (var i = 0; i < 200; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(audio.ambientStarts, greaterThanOrEqualTo(1));
    expect(audio.played, contains(SoundCue.warning));
  });
}

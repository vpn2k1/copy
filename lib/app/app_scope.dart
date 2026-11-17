import 'package:flutter/widgets.dart';

import '../core/game/progress_book.dart';
import '../core/save/save_data.dart';
import '../core/save/save_repository.dart';
import 'game_audio.dart';

/// Hồ sơ người chơi của cả app: tiến trình và cài đặt âm thanh. Mỗi lần đổi
/// thì báo giao diện và ghi xuống máy (chỉ khi có thay đổi thật, không ghi
/// mỗi khung hình). Các lần ghi được xếp hàng, không chồng lên nhau.
class ProfileNotifier extends ChangeNotifier {
  ProfileNotifier({SaveData? data, this.repository})
    : _data = data ?? const SaveData();

  final SaveRepository? repository;
  SaveData _data;
  Future<void> _writes = Future.value();

  SaveData get data => _data;
  ProgressBook get book => _data.progress;
  AudioSettings get settings => _data.settings;

  /// Hoàn tất khi mọi lần ghi đã xếp hàng xong (dùng trong test).
  Future<void> get flushed => _writes;

  /// Ghi kết quả một ván: thắng mở màn kế, sao tốt nhất không giảm.
  void record(int levelId, {required bool isWon, required int stars}) {
    final next = book.record(levelId, isWon: isWon, stars: stars);
    if (identical(next, book)) return;
    _update(_data.copyWith(progress: next));
  }

  void updateSettings(AudioSettings settings) {
    if (settings == _data.settings) return;
    _update(_data.copyWith(settings: settings));
  }

  void _update(SaveData next) {
    _data = next;
    notifyListeners();
    final repo = repository;
    if (repo == null) return;
    _writes = _writes.then((_) => repo.save(next)).catchError((Object _) {
      return false;
    });
  }
}

/// Cung cấp [ProfileNotifier] và [GameAudio] cho cây widget.
class AppScope extends InheritedNotifier<ProfileNotifier> {
  const AppScope({
    super.key,
    required ProfileNotifier super.notifier,
    required this.audio,
    required super.child,
  });

  final GameAudio audio;

  static ProfileNotifier of(BuildContext context) {
    final notifier = context
        .dependOnInheritedWidgetOfExactType<AppScope>()
        ?.notifier;
    if (notifier == null) throw FlutterError('Thiếu AppScope phía trên');
    return notifier;
  }

  /// Không đăng ký rebuild; null khi không có scope (test màn đơn lẻ).
  static AppScope? maybeRead(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AppScope>();
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return oldWidget.audio != audio || super.updateShouldNotify(oldWidget);
  }
}

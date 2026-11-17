import 'package:shared_preferences/shared_preferences.dart';

import '../core/save/save_repository.dart';

/// Lưu chuỗi bằng shared_preferences (offline, trên máy).
class SharedPrefsSaveStore implements SaveStore {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  @override
  Future<String?> read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);
}

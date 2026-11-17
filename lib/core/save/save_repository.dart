import 'save_data.dart';

/// Kho chuỗi theo khóa (bản thật dùng shared_preferences, test dùng bộ nhớ).
abstract interface class SaveStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}

/// Kho trong bộ nhớ cho test và khi nền tảng không lưu được.
class MemorySaveStore implements SaveStore {
  MemorySaveStore([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

/// Đọc / ghi [SaveData]. Dữ liệu hỏng không bị xóa âm thầm: chuỗi gốc được
/// chép sang [corruptBackupKey] trước khi dùng mặc định. Dữ liệu từ bản app
/// mới hơn được đọc phần hiểu được nhưng không bị ghi đè.
class SaveRepository {
  SaveRepository(this.store);

  static const saveKey = 'nqnm.save';
  static const corruptBackupKey = 'nqnm.save.corrupt';

  final SaveStore store;
  bool _isWriteBlocked = false;

  /// Lần đọc gần nhất gặp dữ liệu hỏng và đã sao lưu bản hỏng.
  bool hasRecoveredFromCorruption = false;

  Future<SaveData> load() async {
    hasRecoveredFromCorruption = false;
    final raw = await store.read(saveKey);
    if (raw == null) return const SaveData();
    try {
      final data = SaveData.decode(raw);
      _isWriteBlocked = data.isFromNewerVersion;
      return data;
    } on FormatException {
      await store.write(corruptBackupKey, raw);
      hasRecoveredFromCorruption = true;
      return const SaveData();
    }
  }

  /// Ghi [data]. Trả về false khi bị chặn vì dữ liệu trên máy mới hơn.
  Future<bool> save(SaveData data) async {
    if (_isWriteBlocked) return false;
    await store.write(saveKey, data.encode());
    return true;
  }
}

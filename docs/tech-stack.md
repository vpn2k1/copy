# Tech stack và thư viện (mẫu)

Mẫu gốc chỉ có Flutter thuần. Dự án này thêm `flame`. Khi cần thêm gói khác, xem danh sách gợi ý bên dưới và [rules/dependencies.md](../rules/dependencies.md).

## 1. Nền tảng

| Hạng mục | Công nghệ |
| --- | --- |
| Framework | Flutter (Dart `^3.12.2`, chỉnh theo dự án) |
| Nền tảng đích | Android, iOS (chỉnh theo dự án) |

## 2. Thư viện đang dùng

| Gói | Phiên bản | Dùng để |
| --- | --- | --- |
| `flame` | `^1.33.0` | Vòng lặp game và vẽ Canvas cho màn thi |
| `flame_audio` | `^2.12.2` | Phát âm nền và hiệu ứng (`lib/app/game_audio.dart`); lỗi hay thiếu file thì im lặng |
| `shared_preferences` | `^2.5.6` | Lưu tiến trình và cài đặt offline (JSON phiên bản 1, `lib/app/shared_prefs_store.dart`) |
| `flutter_lints` (dev) | `^6.0.0` | Bộ lint chuẩn |

## 3. Lệnh cài đặt trên máy mới

```bash
flutter pub get
```

Sinh mã (nếu dự án dùng gen-l10n hoặc build_runner):

```bash
flutter gen-l10n
```

## 4. Thư viện nên cân nhắc thêm

Chỉ thêm khi có nhu cầu tương ứng.

| Nhu cầu | Thư viện gợi ý | Ghi chú |
| --- | --- | --- |
| Quản lý state, DI | `flutter_riverpod` | `Notifier`/`AsyncNotifier` cho state màn hình |
| Điều hướng khai báo | `go_router` | Deep link, redirect |
| Co giãn kích thước | `flutter_screenutil` | Thay cho hằng số pixel cứng |
| Lưu cài đặt nhỏ | `shared_preferences` | Ngôn ngữ, âm thanh |
| Dữ liệu có cấu trúc | `drift` hoặc `hive_ce` | Khi dữ liệu lớn hoặc cần truy vấn |
| Model bất biến | `freezed`, `json_serializable` | Cần `build_runner` (dev) |
| Gọi HTTP | `dio` hoặc `http` | `dio` khi cần interceptor, retry |
| Test mock | `mocktail` (dev) | Mock repository, Riverpod |
| Ghi log | `logger` | Thay cho `print` |

Lệnh thêm nhóm dev: `flutter pub add dev:mocktail dev:build_runner`.

## 5. Gói chỉ dùng khi build

Gói như `flutter_launcher_icons`, `flutter_native_splash` đặt trong `dev_dependencies`, không đặt trong `dependencies`.

## 6. Lưu ý

- Dùng `flutter pub add`, không sửa `pubspec.yaml` bằng tay.
- Commit cả `pubspec.lock`.
- Chạy `flutter pub outdated` định kỳ.
- Đọc changelog khi nâng major.

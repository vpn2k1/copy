# Bàn giao — Nhất Quỷ Nhì Ma: Đại Chiến Phòng Thi

Game stealth-comedy 2D, lớp học Việt Nam, Flutter + Flame, chơi offline, màn hình ngang.
Tiến độ và bằng chứng từng phase: [`nhat_quy_nhi_ma_claude_plan/docs/PROGRESS.md`](../nhat_quy_nhi_ma_claude_plan/docs/PROGRESS.md).

## Môi trường đã dùng

| Thành phần | Phiên bản |
|---|---|
| Flutter | 3.44.8 (stable), Dart `^3.12.2` |
| Xcode | 26.6 (iOS Simulator iPhone 16 Pro Max) |
| Android SDK | 36.0.0, JDK 21 (kèm Android Studio) |
| `flame` | 1.38.2 |
| `flame_audio` | 2.12.2 (kéo theo `audioplayers` 6.8.1) |
| `shared_preferences` | 2.5.6 |
| `flutter_lints` (dev) | 6.0.0 |

Phiên bản chính xác nằm trong `pubspec.lock` (đã commit).

## Lệnh

```bash
flutter pub get
```

```bash
dart format --output=none --set-exit-if-changed lib test
```

```bash
flutter analyze
```

```bash
flutter test
```

Chạy trên máy/emulator đang kết nối:

```bash
flutter run
```

Build APK debug (file ra ở `build/app/outputs/flutter-apk/app-debug.apk`, hoặc trong thư mục `build-dir` nếu máy cấu hình `flutter config --build-dir`):

```bash
flutter build apk --debug
```

Cài APK lên điện thoại Android đã bật USB debugging:

```bash
flutter install --debug
```

Hoặc dùng adb (trong `Android/sdk/platform-tools`):

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Cờ review (chỉ dùng khi kiểm tra, không dùng khi phát hành)

| Cờ | Tác dụng |
|---|---|
| `--dart-define=SKILL_SANDBOX=true` | Màn thử có đủ 12 kỹ năng, 180 giây |
| `--dart-define=DEBUG_HUD=true` | HUD hiện chế độ AI của cô |
| `--dart-define=CAMERA_GUIDES=true` | Vẽ khung vùng HUD và dải giữa của camera |
| `--dart-define=POSE_DEMO=true` | Lần lượt mọi tư thế nhân vật chính và cô |

## Bản phát hành (release) Android

Chưa ký. Để build bản release cần tạo keystore riêng (không đưa vào repo):

1. Tạo key: `keytool -genkey -v -keystore ~/nqnm-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias nqnm`.
2. Tạo `android/key.properties` (đã nằm ngoài git) với `storePassword`, `keyPassword`, `keyAlias`, `storeFile`.
3. Khai báo `signingConfigs.release` trong `android/app/build.gradle.kts` đọc file trên, rồi gán cho `buildTypes.release`.
4. Đổi `applicationId` khỏi `com.example.dung_de_thay_thay` trước khi lên store.
5. `flutter build appbundle --release`.

## Cấu trúc chính

- `lib/core/` — Dart thuần, test được không cần giao diện:
  - `core/game/`: luật chơi, AI giáo viên, kỹ năng, sự kiện, màn, sao.
  - `core/save/`: dữ liệu lưu JSON phiên bản 1.
  - `core/animation/`: rig tư thế.
- `lib/features/exam/` — màn thi (Flame vẽ cảnh, Flutter vẽ HUD và nút).
- `lib/features/levels`, `menu`, `settings` — các màn còn lại.
- `lib/app/` — gốc app, route, hồ sơ người chơi, âm thanh, kho lưu.
- `assets/audio/` — 11 file âm thanh tự tổng hợp (`tool/generate_sfx.py`), có README ghi nguồn gốc.

## Giới hạn đã biết

- Nhân vật và cảnh là hình vector vẽ bằng code (placeholder theo 06_ASSET_PIPELINE), chưa có sprite PNG.
- Cân bằng mới tune bằng người chơi giả lập. Với người chơi phản ứng nhanh, màn 5 dễ hơn màn 4 và thường thắng trước khi chế độ boss bật.
- Chưa có sự kiện phụ ngẫu nhiên; mỗi màn mới có 1 sự kiện cố định. Boss chưa có chiêu giả quay lưng.
- Chưa đo FPS hay bộ nhớ trên điện thoại thật. Chỉ mới đo thời gian ghi khung hình trên máy dev (xem PROGRESS).
- Âm thanh mới kiểm bằng log (không lỗi) và test; chưa nghe đánh giá bằng tai.
- Tạm dừng giữa lúc đang thi triển kỹ năng thì được hoàn hồi chiêu (cố ý, để không phạt người chơi khi bị gián đoạn), nên có thể bị lợi dụng nhẹ.

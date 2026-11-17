# Đừng Để Thầy Thấy! — Flutter + Flame

Game 2D top-down một màn chơi, không cần asset ảnh. Cấu trúc và quy ước theo mẫu `flutter_base` (xem [AGENTS.md](AGENTS.md), [docs/architecture.md](docs/architecture.md)).

## Yêu cầu
- Flutter SDK, Dart `^3.12.2`
- Android Studio / VS Code hoặc trình duyệt Chrome

## Chạy
1. `flutter pub get`
2. `flutter run` (hoặc `flutter run -d chrome`)

## Kiểm tra
```bash
dart format lib test
flutter analyze
flutter test
```

## Luật chơi
- Giữ nút **GIỮ ĐỂ CÓP** để tăng tiến độ bài thi.
- Khi giáo viên nhìn đúng về phía học sinh, thanh nghi ngờ tăng rất nhanh nếu đang cóp.
- Thả nút để giảm nghi ngờ.
- Tiến độ 100%: thắng. Nghi ngờ 100%: thua. Hết 75 giây: thua.
- Nhấn CHƠI LẠI để đặt lại ván.

## Cấu trúc
- `lib/core/exam_config.dart`: toàn bộ hằng số độ khó.
- `lib/core/exam_state.dart`, `teacher_patrol.dart`: luật ván thi và đi tuần, Dart thuần.
- `lib/features/exam/`: màn hình, vòng lặp Flame và cách vẽ lớp học.
- `lib/l10n/strings.dart`: mọi câu chữ hiển thị.

## Tùy chỉnh nhanh
Sửa trong `lib/core/exam_config.dart`:
- `maxTime`: thời lượng.
- `progressPerSecond`: tốc độ cóp.
- `suspicionWhenSeen`: tốc độ tăng nghi ngờ khi bị nhìn.
- `teacherSpeed`: tốc độ đi tuần.

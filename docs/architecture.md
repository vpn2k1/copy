# Kiến trúc

Chi tiết quy tắc nằm trong [rules/structure.md](../rules/structure.md). Tài liệu này giải thích lý do và luồng chạy.

## Luồng khởi động

```
main.dart  →  runApp(App)  →  app/app.dart (MaterialApp, theme)  →  features/exam/exam_screen.dart  →  GameWidget(ExamGame)
```

`main.dart` không chứa logic. `App` là nơi gắn theme, bản địa hóa và điều hướng khi dự án có nhiều màn hình.

## Vì sao tách `core/`

`core/` chứa quy tắc nghiệp vụ dưới dạng Dart thuần (ví dụ `calculateScore`). Lợi ích:

- Test được bằng `flutter test` mà không cần dựng giao diện.
- Có thể chuyển sang Dart CLI hoặc server nếu cần.
- Giao diện đổi thường xuyên hơn logic, tách ra giảm rủi ro khi đổi giao diện.

Kiểm tra tự động: `test/rules/architecture_test.dart`.

## Vì sao màn hình là thư mục

Một màn hình thường có nhiều phần: header, danh sách, nút, popup. Đặt phần con vào `widgets/` giữ `*_screen.dart` ngắn, dễ đọc, và mỗi file dưới 300 dòng ([file-size](../rules/file-size.md)).

## Khi nào thêm `state/`

Thêm thư mục `state/` trong feature khi có trạng thái cần chia sẻ hoặc gọi dữ liệu bất đồng bộ. Mẫu Riverpod nằm trong [tech-stack](tech-stack.md). Với dự án nhỏ, `StatefulWidget` đủ dùng.

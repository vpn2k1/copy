# AGENTS.md – Hướng dẫn cho AI agent trong dự án Flutter

Đây là bộ hướng dẫn chung cho mọi dự án Flutter theo mẫu này. Chỗ nào dự án cụ thể khác, ghi đè trong `CLAUDE.md` hoặc file riêng của dự án, và nói rõ trong báo cáo.

## Trước khi sửa code

1. Đọc [rules/](rules/) để nắm quy ước bắt buộc. Các file được nạp qua `CLAUDE.md`.
2. Đọc [docs/architecture.md](docs/architecture.md) nếu thay đổi cấu trúc thư mục hoặc thêm tính năng.
3. Dùng skill trong `.claude/skills/` khi có việc tương ứng: `new-feature`, `add-dependency`, `split-large-file`, `verify-flutter`.

## Quy tắc bắt buộc (tóm tắt)

- Không toán tử 3 ngôi trong `lib/` và `test/` ([no-ternary](rules/no-ternary.md)).
- Mỗi file dưới 300 dòng code ([file-size](rules/file-size.md)).
- Tên file `snake_case`, class `UpperCamelCase`, còn lại `lowerCamelCase` ([naming](rules/naming.md)).
- `core/` là Dart thuần; feature không import feature khác ([structure](rules/structure.md)).
- Câu chữ hiển thị qua `Strings` ([localization](rules/localization.md)).
- Thêm thư viện bằng `flutter pub add` và chỉ khi có nhu cầu ([dependencies](rules/dependencies.md)).

## Sau khi sửa

Chạy `dart format lib test`, `flutter analyze`, `flutter test`. Báo kết quả thật, kể cả khi lỗi ([workflow](rules/workflow.md)).

## Ranh giới

- Không commit hay push khi người dùng chưa yêu cầu.
- Không sửa file sinh tự động bằng tay.
- Không thêm tính năng ngoài yêu cầu.
- Không đưa khóa bí mật, `.env` hay thông tin tài khoản vào repo ([git](rules/git.md)).

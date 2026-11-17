# Changelog

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/).

## [Chưa phát hành]

### Hình ảnh 2D và thương hiệu
- Cảnh lớp và học sinh, giáo viên dùng ảnh 2D hoạt hình; tư thế chính đổi theo trạng thái game.
- Icon Android/iOS và splash screen dùng biểu tượng gamepad, hiện chữ “VPN Games”.
- Có thể giữ trực tiếp tờ bài của mình để viết, nhân vật để giả vờ, hoặc bàn bạn cùng lớp để dùng kỹ năng; thả tay để dừng. Tư thế GIẢ VỜ dùng ảnh ngồi bình thường.

### Phase 07 — Hoàn thiện
- HUD chuyển đỏ và báo "SẮP BỊ BẮT!" khi nghi ngờ từ 70.
- Tên app trên máy: "Nhất Quỷ Nhì Ma". Nút giữ có nhãn trợ năng cho trình đọc màn hình.
- Nền lớp học vẽ một lần rồi dùng lại, giảm việc vẽ mỗi khung hình.
- Tài liệu bàn giao `docs/HANDOFF.md`: lệnh chạy, build và cài Android, phiên bản thư viện, giới hạn đã biết.

### Phase 06 — Giao diện, âm thanh, lưu offline
- Tiến trình (màn đã mở, sao tốt nhất) và cài đặt được lưu trên máy, còn nguyên sau khi tắt app; dữ liệu hỏng không làm app lỗi.
- Âm nền lớp học và hiệu ứng: báo trước, cô nhìn thấy, bước chân, viết bài, thất bại, giấy rơi, chuông sự kiện, thắng/thua. Âm thanh tự tạo.
- Màn cài đặt: tắt tiếng, âm lượng âm nền và hiệu ứng. Menu kiểu bảng phấn, giao diện tông lớp học.

### Phase 05 — 5 màn và sự kiện
- VÀO LỚP mở màn chọn 5 màn: khóa, mở theo thứ tự, hiện sao tốt nhất; thắng mở màn kế, có nút MÀN TIẾP.
- Mỗi màn một sự kiện có báo trước: cô hỏi bài (màn 1, kèm 10 giây hướng dẫn), quạt thổi bay phao (màn 2), bạn khác mã đề (màn 3), hai giám thị đổi chỗ (màn 4, cô thứ hai áo dài xanh), giám thị tăng tốc 20 giây cuối (màn 5).
- Sao: thắng 1 sao, nghi ngờ cuối ≤ 40 thêm 1, ≤ 20 và còn ≥ 30 giây thêm 1.
- Màn sau khó dần: cô đi nhanh hơn, nghi ngờ tăng nhanh hơn, thời gian báo trước ngắn dần.

### Phase 04 — 12 kỹ năng
- Thanh kỹ năng: chọn kỹ năng cho nút cóp; giữ, bấm, thả đúng nhịp hoặc giải câu đố tùy kỹ năng; hồi chiêu hiện rõ.
- Mỗi kỹ năng có thất bại hài hước riêng khi bị cô nhìn thấy hoặc làm sai; thông báo kết quả ngay trên màn hình.
- Màn tạm dừng liệt kê đủ 12 kỹ năng và màn mở khóa.

### Phase 03 — Vòng chơi và AI giáo viên
- Chơi được trọn ván: giữ VIẾT BÀI / GIẢ VỜ / CÓP BÀI, thắng khi xong bài, thua khi bị bắt hoặc hết giờ, có nút chơi lại.
- Cô đi tuần, quay người, nhìn lớp; biểu tượng "…" báo trước khi cô sắp nhìn, mắt vàng khi đang nhìn, "?" khi nghi ngờ rồi tới soi bàn.
- HUD thời gian, tiến độ, nghi ngờ, trạng thái an toàn; nút tạm dừng.

### Phase 02 — Nhân vật và hoạt ảnh
- Học sinh có 7 tư thế (ngồi yên, viết bài, liếc bài, run, giấu, bị bắt, ăn mừng): biểu cảm, chớp mắt, đổ mồ hôi khi bị nghi ngờ.
- Cô giáo có 7 tư thế (đứng, đi, quay người, nhìn trái, nhìn phải, soi, bắt được) kèm biểu tượng hướng nhìn trên đầu.
- Trong lớp, các bạn ngồi viết bài lệch nhịp nhau.

### Phase 01 — Cảnh lớp học
- Màn thi hiển thị lớp học Việt Nam nhìn từ bàn bên trái: nhân vật chính thấy mặt và tay, cô giáo áo dài trước bảng, 5 bạn, bảng xanh, khẩu hiệu, cửa sổ, quạt trần quay.

### Phase 00 — Nhất Quỷ Nhì Ma
- App khóa màn hình ngang, mở vào menu (VÀO LỚP, CÀI ĐẶT).
- Màn thi mới dùng thế giới logic 1600x900, letterbox; tạm thời chỉ có nền lớp. Gameplay top-down cũ không còn hiển thị.
- Game tự dừng khi app mất focus, chỉ chạy lại khi bấm TIẾP TỤC.

### Thay đổi
- Cập nhật theo mẫu `flutter_base`: `AGENTS.md`, `CLAUDE.md`, `rules/`, `docs/`, `.claude/`, `test/rules/`, `analysis_options.yaml`.
- Tách mã thành `app/`, `core/`, `features/exam/`, `l10n/`. Logic ván thi (`core/`) là Dart thuần, không phụ thuộc Flame.
- Mọi câu chữ hiển thị chuyển vào `lib/l10n/strings.dart`.
- Bỏ toán tử 3 ngôi trong `lib/` và `test/`.
- Thêm `flutter_lints`, đặt SDK `^3.12.2`.

### Thêm
- Test logic (`test/core/`) và test màn hình thi (`test/features/exam/`).

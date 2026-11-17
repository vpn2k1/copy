# 00 — Product / Scope

## Elevator pitch
**Nhất Quỷ Nhì Ma — Đại Chiến Phòng Thi**: game stealth-comedy hoạt hình 2D trên Android, bối cảnh giờ kiểm tra tại trường phổ thông Việt Nam. Người chơi ngồi tại một bàn cố định, cân nhắc tự làm bài, kích hoạt các trò nghịch ngợm hư cấu, canh giáo viên quan sát, quản lý thời gian và nghi ngờ.

## Người chơi / phiên chơi
- Chơi offline, chạm/giữ nút, landscape, 2–4 phút mỗi ván; màn thắng/thua và chơi lại nhanh.
- Trò chơi lấy cảm hứng từ văn hóa học đường, không cổ vũ gian lận thật; hình phạt hài hước, không gây hại.

## MVP must-have
- Một cảnh lớp học Việt Nam có chiều sâu layer, góc nhìn ngang từ **bàn trái/phải**.
- Nhân vật chính hiện rõ mắt/mặt/tay, có ít nhất idle, writing, cheating, nervous, caught, celebrate.
- 1–2 giáo viên hoạt động theo state machine và quan sát nhân vật (có cảnh báo rõ ràng).
- 12 kỹ năng dựa trên data, 5 level với cấu hình độc lập và sự kiện đặc trưng.
- Tiến độ 0–100, nghi ngờ 0–100, đếm ngược, nút giữ để cóp, tự làm bài, ẩn/giả vờ, pause.
- Menu, chọn màn, khóa/mở màn, kết quả sao, âm lượng, save offline.
- Test đơn vị AI/luật thắng thua/skills; chạy Android landscape.

## Out-of-scope MVP
- Multiplayer, quảng cáo, IAP, cloud save, leaderboard, backend, toàn bộ 1001 chiêu, voice actor đầy đủ, real-time pathfinding phức tạp.

## Core game loop
Mở menu → chọn level → vào lớp → giáo viên tuần tra → người chơi chọn hành động → tăng điểm/rủi ro → sự kiện → thắng/thua → sao/tiến trình → chơi tiếp.

## Quy tắc chiến thắng
- Win khi `progress >= 100` **và** `remainingTime > 0` **và** `suspicion < 100`.
- Lose khi `suspicion >= 100` (caught) hoặc `remainingTime <= 0` trước khi hoàn thành.
- Nếu cùng frame chạm nhiều ngưỡng: giải quyết nghi ngờ trước, hết giờ thứ hai, thắng cuối cùng; cần test thứ tự nhất quán.
- 1 sao: thắng; +1 nếu nghi ngờ cuối màn <=40; +1 nếu <=20 và còn >=30 giây. Tối đa 3.

## UX goals / đo nghiệm thu
- Hình đầu tiên cho thấy đủ **nhân vật chính + giáo viên + ít nhất 3 học sinh phụ + bảng VN**.
- Người chơi nhận biết giáo viên đang quan sát trong <1 giây nhờ mặt/hướng nhìn/UI cảnh báo (không dùng tia laser như cơ chế duy nhất).
- Button giữ/thả hoạt động kể cả khi rê ngón tay ra ngoài; khi app mất focus tự ngừng giữ.
- Không có nút che mặt nhân vật chính hoặc giáo viên trên màn 16:9.

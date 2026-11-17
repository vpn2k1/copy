# NHẤT QUỶ NHÌ MA — Kế hoạch sản xuất game Flutter + Flame

**Trạng thái:** đặc tả và kế hoạch, chưa phải mã game hoàn chỉnh. **Mục tiêu:** MVP offline Android landscape, 5 level, 12 kỹ năng, đồ họa 2D hoạt hình lớp học Việt Nam. Tài liệu viết cho Claude Code thực hiện tuần tự.

## Bắt đầu
1. Đặt toàn bộ thư mục `docs/` và `CLAUDE.md` vào gốc repository Flutter. Mở terminal tại gốc repository.
2. Đọc `CLAUDE.md`, `docs/00_PRODUCT_SPEC.md`, `docs/01_VISUAL_CAMERA.md`, `docs/02_ARCHITECTURE.md`.
3. Yêu cầu Claude thực thi **một phase tại một thời điểm** theo `docs/10_EXECUTION_PROMPTS.md`, không nhảy giai đoạn. Claude cập nhật `docs/PROGRESS.md` sau mỗi phase.
4. Mọi điều kiện nghiệm thu ở `docs/09_QA_ACCEPTANCE.md` phải được đối chiếu trước khi đánh dấu xong.

## Lộ trình
| Phase | Tài liệu | Kết quả có thể kiểm thử |
|---|---|---|
| 00 | `docs/phases/00_BOOTSTRAP.md` | App khởi động, landscape, menu, test cơ bản |
| 01 | `docs/phases/01_SCENE_CAMERA.md` | Khung cảnh lớp VN với góc **từ bàn bên trái/phải** |
| 02 | `docs/phases/02_CHARACTERS_ANIMATION.md` | Học sinh / giáo viên / biểu cảm / chuyển động |
| 03 | `docs/phases/03_GAMEPLAY_TEACHER_AI.md` | Game loop, tầm nhìn, nghi ngờ, thắng thua |
| 04 | `docs/phases/04_SKILLS.md` | 12 kỹ năng có dữ liệu và tác dụng nhất quán |
| 05 | `docs/phases/05_LEVELS_EVENTS.md` | 5 màn + sự kiện đặc trưng + mở khóa |
| 06 | `docs/phases/06_UI_AUDIO_SAVE.md` | HUD, menu, pause, âm thanh, lưu tiến trình |
| 07 | `docs/phases/07_POLISH_RELEASE.md` | Test, tối ưu, build Android, tài liệu bàn giao |

## Quy tắc quan trọng
- **Không top-down, không POV phía sau lưng**: camera ngang hơi xiên từ **bàn kề bên trái hoặc bên phải**, tầm mắt học sinh; thấy mặt/người nhân vật chính và thầy/cô, nhìn được phần lớn lớp.
- Không coi hình concept là sprite có sẵn. Nếu không có asset, dùng placeholder **từng lớp (layer) có thể hoạt ảnh**, không dùng một tấm ảnh nền tĩnh để giả vờ có gameplay.
- Phiên bản MVP ưu tiên **một cảnh lớp học** dùng chung, 5 cấu hình level khác nhau.
- Gameplay hài hước hư cấu, không mô tả thủ thuật quay cóp đời thực một cách chi tiết.
- Không tuyên bố “chạy được” hoặc “đã test” nếu chưa thực sự chạy lệnh và ghi kết quả.

## Tài liệu nền
`00_PRODUCT_SPEC`, `01_VISUAL_CAMERA`, `02_ARCHITECTURE`, `03_GAMEPLAY_SYSTEMS`, `04_SKILL_CATALOG`, `05_LEVELS`, `06_ASSET_PIPELINE`, `07_DATA_CONTRACTS`, `08_TESTING_PLAN`, `09_QA_ACCEPTANCE`, `10_EXECUTION_PROMPTS`, `PROGRESS`.

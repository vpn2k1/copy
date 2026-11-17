# Implementation Tracker

**Current phase:** 07 — gần xong; còn chặn: build và chạy APK Android (đĩa không đủ). **Last update:** 2026-10-19.

| Phase | Status | Evidence |
|---|---|---|
| 00 Bootstrap | DONE (iOS Simulator); Android chưa xác nhận | boot + menu ↔ màn thi trên iPhone 16 Pro Max simulator: `docs/evidence/phase00_ios_menu.png`; APK debug chưa build được (hết đĩa) |
| 01 Scene / Camera | DONE (người dùng duyệt bản bàn đôi ngồi sát) | `docs/evidence/phase01_ios_classroom.png`, golden `test/features/exam/goldens/classroom_1600x900.png`, `classroom_phone_20x9.png` |
| 02 Characters / Animation | DONE (người dùng duyệt) | `docs/evidence/phase02_pose_sheet.png`, `docs/evidence/phase02_ios_classroom_animated.png`, golden `test/features/exam/goldens/pose_sheet.png` |
| 03 Game / Teacher AI | DONE (người dùng duyệt) | `docs/evidence/phase03_ios_seen_cheating.png`, `docs/evidence/phase03_ios_warning_cue.png`; 77/77 test |
| 04 Skills | DONE (người dùng duyệt) | `docs/evidence/phase04_ios_skill_bar.png`, `phase04_ios_pencil_case_success.png`, `phase04_ios_calculator_puzzle.png`; 95/95 test |
| 05 Levels / Events | DONE (người dùng duyệt) | `docs/evidence/phase05_ios_level_select.png`, `phase05_ios_tutorial_hint.png`, `phase05_ios_question_warning.png`, `phase05_ios_teacher_question.png`; 123/123 test |
| 06 UI / Audio / Save | DONE (người dùng duyệt) | `docs/evidence/phase06_ios_menu.png`, `phase06_ios_settings_persisted.png`; 142/142 test |
| 07 Polish / Release | PARTIAL — APK Android bị chặn vì đĩa | 149/149 test, `docs/HANDOFF.md`, goldens `hud_danger.png`, `result_won.png` |

## Work log template
```
### YYYY-MM-DD — Phase NN
- Changed files:
- Implemented behavior:
- Decisions and deviations:
- Tests executed (command -> real result):
- Visual evidence path:
- Bugs / blockers:
- Next phase:
```

### 2026-10-19 — Phase 00
- Changed files: `lib/main.dart`, `lib/app/app.dart`, `lib/app/orientation.dart` (mới), `lib/app/route_names.dart` (mới), `lib/core/world_layout.dart` (mới), `lib/features/menu/menu_screen.dart` (mới), `lib/features/settings/settings_screen.dart` (mới), `lib/features/exam/exam_game.dart`, `lib/features/exam/exam_screen.dart`, `lib/features/exam/classroom_background.dart` (mới), `lib/features/exam/widgets/pause_overlay.dart` (mới), `lib/l10n/strings.dart`, `android/app/src/main/AndroidManifest.xml` (`sensorLandscape`), test: `test/app/app_test.dart`, `test/app/orientation_test.dart`, `test/features/exam/exam_screen_test.dart`, `test/features/exam/classroom_background_test.dart`; xóa `test/widget_test.dart` (mẫu cũ gọi `MyApp` không tồn tại, vốn đang lỗi).
- Implemented behavior: khóa landscape (SystemChrome + manifest); menu VÀO LỚP / CÀI ĐẶT điều hướng thật; màn thi Flame 1600x900 letterbox, chỉ có lớp nền tường + sàn; app mất focus → dừng engine, hiện lớp TẠM DỪNG, chỉ chạy lại khi bấm TIẾP TỤC.
- Decisions and deviations: theo quy tắc repo (`rules/structure.md`) thay cho layout `game/` `ui/` của plan: `core/` (Dart thuần), `features/<tên>/`, route qua `app/route_names.dart` để feature không import nhau. Flame giữ `^1.33.0` (lock 1.38.2). Chưa thêm `shared_preferences`: `rules/dependencies.md` cấm thêm gói trước khi cần, sẽ thêm ở phase 06. Code top-down cũ (`core/exam_*`, `core/teacher_patrol.dart`, `features/exam/classroom_scene.dart`, `teacher_painter.dart`, `paint_helpers.dart`, `widgets/` cũ) giữ nguyên nhưng không còn được dùng, chờ phase 01/03 thay thế.
- Tests executed: `dart format lib test` → exit 0; `flutter analyze` → No issues found; `flutter test` → 23/23 passed. `flutter build apk --debug` → exit 1, sau đó máy báo ENOSPC (hết dung lượng đĩa), chưa đọc được log chi tiết.
- Visual evidence path: chưa có (chưa chạy trên thiết bị).
- Bugs / blockers: hết dung lượng đĩa; không có Android emulator/thiết bị. Có iOS Simulator iPhone 16 Pro Max đang boot, chưa thử.
- Next phase: hoàn tất xác nhận boot của phase 00, rồi phase 01 (Scene/Camera, có điểm dừng duyệt hình).

### 2026-10-19 — Phase 00 (bổ sung xác nhận)
- `flutter build apk --debug` lần 2: Gradle daemon chiếm ~4,5 GB tạm, đĩa đầy (ENOSPC), build dừng; đã kill daemon. Chưa có APK.
- `flutter build ios --simulator --debug` → thành công (44,8 s). `xcrun simctl install/launch` → exit 0. App mở ngang, menu hiển thị đúng tiếng Việt, VÀO LỚP → màn thi, nút ← về menu: kiểm tra bằng tay trên simulator.

### 2026-10-19 — Phase 01
- Changed files: `lib/core/classroom_layout.dart` (mới), `lib/features/exam/components/` (mới: `cartoon_paint.dart`, `classroom_background.dart`, `ceiling_fan.dart`, `seated_student.dart`, `teacher_figure.dart`, `foreground_desk.dart`, `camera_guides.dart`), `lib/features/exam/exam_game.dart`, `lib/features/exam/exam_screen.dart`, `lib/l10n/strings.dart`; xóa `lib/features/exam/classroom_background.dart` (chuyển vào `components/`). Test: `test/core/classroom_layout_test.dart`, `test/features/exam/components/classroom_background_test.dart`, `test/features/exam/classroom_golden_test.dart` (+2 golden), `test/features/exam/exam_screen_test.dart`.
- Implemented behavior: camera cố định từ bàn bên TRÁI, tầm mắt học sinh ngồi. Lớp nền: tường kem, cửa sổ xanh, khẩu hiệu đỏ "TIÊN HỌC LỄ, HẬU HỌC VĂN", bảng xanh chữ phấn, đèn tuýp, 2 quạt trần quay, sàn, bàn giáo viên. Nhân vật chính ngồi gần camera quay 3/4 về phía bảng (thấy mặt + hai tay + bút + bài), cô giáo áo dài tím trước bảng, 5 bạn ở 2 dãy. Thứ tự vẽ theo `priority` = y chân. Mảnh bàn của camera ở góc dưới trái. Chú thích camera/vùng HUD bật bằng `--dart-define=CAMERA_GUIDES=true`.
- Đối chiếu số liệu (test tự động): nhân vật chính cao 58,6% khung (yêu cầu 45–60%), giáo viên 17,9% (12–20%), 5 bạn (3–7), mặt/tay chính và giáo viên nằm trong dải giữa 12%–84%.
- Visual rejection checklist (tự đánh giá trên ảnh simulator): không top-down ✓; không sau lưng/over-shoulder ✓; thấy mặt và tay học sinh chính ✓; giáo viên cùng khung ✓; vẫn thấy toàn lớp VN ✓; chưa có HUD nên chưa che ✓. Cần người dùng duyệt.
- Decisions and deviations: nhân vật vẽ bằng Canvas theo từng phần (ghế, chân, thân, bàn, tay, đầu) để phase 02 tách chuyển động; tạm thời đứng yên, chỉ quạt quay. Cô giáo đặt ở x=1160 để không bị đầu học sinh dãy xa che. Nhân vật chính cả bàn chiếm ~31% chiều ngang (spec ~20–30%), riêng người ~20%.
- Tests executed: `dart format lib test` → 0; `flutter analyze` → No issues found; `flutter test` → 31/31 passed (chạy lại sau khi dời cô giáo và sinh lại golden).
- Bugs / blockers: golden dùng font Ahem (chữ thành khối); chữ thật xem ở ảnh simulator. APK Android chưa build do đĩa.
- Next phase: 02 Characters / Animation — chỉ sau khi người dùng duyệt hình.

### 2026-10-19 — Phase 01 (chỉnh theo góp ý: ngồi gần nhau hơn)
- Góp ý người dùng: học sinh "ngồi gần nhau hơn, không tách biệt". Ảnh cũ lưu tại `docs/evidence/phase01_ios_classroom_v1_separated.png`.
- Thay đổi: `lib/core/classroom_layout.dart` thêm `DeskRow` và bàn đôi. Các bàn trong dãy nối sát (`deskPitch` = 540 đơn vị, lưng ghế bàn sau sát mép bàn trước). Mỗi bàn có hai bạn: bạn phía xa camera lùi lên 90 và lệch 115 đơn vị. Nhân vật chính có bạn cùng bàn ngồi sát (dùng cho kỹ năng `peek` sau này). Dãy xa 4 bàn, dãy giữa 3 bàn, tổng cộng 15 bạn. Cô giáo dời tới x=1215, vào khe giữa các đầu học sinh. `exam_game.dart` trộn kiểu tóc theo chỉ số.
- Lệch khỏi spec: `01_VISUAL_CAMERA` ghi "thấy 3–7 bạn"; nay có 15 bạn theo yêu cầu lớp đông, ngồi sát. Test đổi thành "ít nhất 3", thêm test bàn nối sát, test bạn cùng bàn và test không đầu học sinh nào che mặt giáo viên.
- Tests: `dart format` → 0; `flutter analyze` → No issues; `flutter test` → 34/34 passed; golden sinh lại.
- Visual evidence: `docs/evidence/phase01_ios_classroom.png` (iOS Simulator, bản mới).
- Trạng thái: chờ người dùng duyệt lại.

### 2026-10-19 — Phase 02
- Changed files: mới `lib/core/animation/` (`rig_point.dart`, `pose_animator.dart`, `limb_solver.dart`, `student_rig.dart`, `student_animator.dart`, `teacher_rig.dart`, `teacher_animator.dart`); mới `lib/features/exam/components/student_head.dart`, `teacher_cue.dart`, `pose_demo.dart`; sửa `seated_student.dart`, `teacher_figure.dart`, `exam_game.dart`, `exam_screen.dart`. Test mới: `test/core/animation/` (4 file), `test/features/exam/pose_sheet_golden_test.dart` (+golden `pose_sheet.png`).
- Implemented behavior: học sinh có 7 tư thế (idle, writing, cheating, nervous, hiding, caught, celebrating). Mỗi tư thế đổi mắt, miệng, mày, hướng nhìn, đầu và tay; khuỷu tay tính bằng IK hai đoạn. Có chớp mắt theo chu kỳ, lệch nhịp giữa các học sinh, nghi ngờ ≥ 0,6 thì đổ mồ hôi và run. Giáo viên có 7 tư thế (idle, walk, turn, lookLeft, lookRight, inspect, caught), lật ngang theo hướng mặt, quay người 0,4 s. Biểu tượng trên đầu: mắt vàng kèm mũi tên chỉ hướng nhìn, dấu "?" cam khi soi, dấu "!" đỏ khi bắt. Tư thế kết thúc (caught, celebrating) khóa animator nên chuyển động cũ dừng hẳn. Trong game, các bạn ngồi viết bài; nhân vật chính ngồi yên; xem lần lượt mọi tư thế bằng `--dart-define=POSE_DEMO=true`.
- Logic hoạt ảnh nằm trong `core/` (Dart thuần, tính theo thời gian, không theo số khung hình); component chỉ đọc rig để vẽ.
- Tests: `dart format lib test` → 0 file đổi; `flutter analyze` → No issues found; `flutter test` → 55/55 passed (gồm test tay không che mặt ở mọi tư thế, khóa khi bị bắt, chớp mắt lệch nhịp, bước đi độc lập với dt).
- Visual evidence: bảng tư thế `docs/evidence/phase02_pose_sheet.png` (golden, chữ Ahem không ảnh hưởng vì không có chữ); iOS Simulator `docs/evidence/phase02_ios_classroom_animated.png`, hai ảnh chụp cách 0,7 s khác nhau nên hoạt ảnh có chạy.
- Bugs / blockers: lần chạy test đầu bị dừng (exit 137) khi app thoát; chạy lại thì pass. APK Android vẫn chưa build.
- Chưa kiểm chứng: cảm giác chuyển động thực tế (chỉ có ảnh tĩnh), hiệu năng trên máy Android thấp.
- Next phase: 03 Game / Teacher AI — chỉ sau khi người dùng duyệt hình.

### 2026-10-19 — Phase 03
- Changed files: mới `lib/core/game/` (`game_status.dart`, `level_config.dart`, `teacher_state.dart`, `teacher_fsm.dart`, `game_state.dart`, `game_controller.dart`, `scene_pose.dart`); mới `lib/features/exam/widgets/` (`hold_action_button.dart`, `action_bar.dart`, `exam_hud.dart`); viết lại `exam_screen.dart`, `widgets/result_panel.dart`; sửa `exam_game.dart`, `components/teacher_figure.dart`, `components/teacher_cue.dart`, `core/animation/teacher_animator.dart`, `core/animation/teacher_rig.dart`, `core/classroom_layout.dart`, `l10n/strings.dart`. Test mới: `test/core/game/` (`game_controller_test.dart`, `teacher_fsm_test.dart`, `scene_pose_test.dart`, `play_script.dart`); thêm 4 test widget trong `test/features/exam/exam_screen_test.dart`.
- Đã gỡ bộ logic top-down cũ (nón nhìn hình học, spec đã loại): `core/exam_config|exam_result|exam_snapshot|exam_state|teacher_patrol.dart`, `features/exam/classroom_scene|teacher_painter|paint_helpers.dart`, `widgets/cheat_button|exam_header.dart` và 2 test của chúng. Thư mục dự án chưa nằm trong git nên bản sao được chuyển vào scratchpad của phiên này, không xóa thẳng.
- Implemented behavior:
  - `GameController` là nguồn sự thật duy nhất, Dart thuần, có các lệnh `start`/`press`/`release`/`pause`/`resume`/`restart`/`tick`. Mỗi tick, `dt` bị giới hạn 0,05 s.
  - Ba hành động giữ:
    - Viết bài: +0,5%/s, an toàn.
    - Cóp bài (peek): +2,2%/s. Bị nhìn thì nghi ngờ +20×0,65/s; không bị nhìn thì +1,5/s.
    - Giả vờ: nghi ngờ −10/s khi không bị nhìn, −4/s khi bị nhìn.
  - Không làm gì hoặc đang viết thì nghi ngờ −3/s. Thứ tự kết thúc: bị bắt > hết giờ > thắng. Khi kết thúc, nút tự thả và không nhận lệnh nữa.
  - `TeacherFsm` có seed, gồm 9 chế độ theo contract. Giáo viên đi trên lối x 760–1450 với tốc độ gốc 200 × hệ số màn. Quay người mất 0,4 s (bằng hoạt ảnh) và trong lúc quay không thấy ai.
  - Mọi lần chuyển sang nhìn lớp đều báo trước 1,0 s bằng biểu tượng "…". Từ lúc quay lưng viết bảng tới lúc nhìn lớp có tổng 1,4 s báo trước.
  - Thấy cóp khi nghi ngờ ≥ 40 thì cô nhìn kỹ 1,5 s; hết thời gian đó mà nghi ngờ ≥ 70 thì tiến lại bàn và soi 2 s. Lần soi cộng +8 nghi ngờ, đúng một lần mỗi lần soi.
- Phát hiện theo góc nhìn ngang (`canSeePlayer`): bị thấy khi cô ở chế độ quan sát (lookLeft, suspicious, approach, inspect), đã quay xong, đã hết báo trước, và mặt hướng về phía người chơi trên trục x. Không mô hình hóa che khuất vì nhân vật chính ở tiền cảnh, không có gì chắn giữa.
- Hình chỉ đọc trạng thái. `scene_pose.dart` chuyển trạng thái sang tư thế và biểu tượng. `TeacherAnimator.follow` lấy hướng mặt và tiến trình quay từ AI, nên hình luôn khớp bộ phát hiện (có test chạy cả ván và so từng khung).
- Biểu tượng trên đầu cô được phóng to ×2 độc lập với tỉ lệ thân để đọc được trên điện thoại.
- HUD có các khóa `hud.timer`, `hud.progress`, `hud.suspicion`, `action.write|hide|cheat`, `pause`, `result.retry`. Dòng debug chế độ AI bật bằng `--dart-define=DEBUG_HUD=true`. App vào nền thì tự tạm dừng và thả nút.
- Cân bằng màn 1, test với 8 seed:
  - Không làm gì → hết giờ.
  - Chỉ viết bài → hết giờ ở 45%.
  - Giữ cóp suốt → bị bắt.
  - Người chơi chỉ nhìn biểu tượng, phản ứng trễ 0,3 s → thắng.
- Decisions: viết bài cũng là nút giữ, không phải mặc định, để phân biệt "không làm gì" với "viết bài" như spec yêu cầu. Kỹ năng tạm cố định là peek; phase 04 thay bằng hệ kỹ năng. `lookRight` (nhìn dãy bên phải) không tính là quan sát người chơi.
- Tests: `dart format lib test` → 0 file đổi; `flutter analyze` → No issues found; `flutter test` → 77/77 passed. Lần chạy đầu có 1 test sai kỳ vọng (`lookRight`), đã sửa test; golden cảnh lớp được sinh lại vì đầu ván cô quay lưng viết bảng.
- Visual evidence (iOS Simulator, iPhone 16 Pro Max, `DEBUG_HUD=true`): `phase03_ios_warning_cue.png` (báo trước "…", HUD AN TOÀN, AI lookLeft đang báo trước), `phase03_ios_seen_cheating.png` (đang giữ cóp, cô nhìn trái có mắt vàng, HUD CÔ ĐANG NHÌN, thanh nghi ngờ tăng).
- Chưa kiểm chứng: cảm giác chơi thực tế qua nhiều ván trên máy (mới chạy kịch bản tự động và vài thao tác tay). APK Android vẫn chưa build. Hướng dẫn 10 giây đầu và câu hỏi của cô ở màn 1 thuộc phase 05.
- Next phase: 04 Skills — sau khi người dùng duyệt.

### 2026-10-19 — Phase 04
- Changed files: mới `lib/core/game/skill_config.dart`, `skills.dart`, `skill_runtime.dart`, `skill_controller.dart`; mới `lib/features/exam/widgets/skill_bar.dart`, `skill_cast_panel.dart`, `skill_toast.dart`; sửa `game_controller.dart` (bỏ `CheatProfile`, nút cóp dùng kỹ năng đang chọn), `game_state.dart` (thêm `skills`), `level_config.dart` (`skillIds`, màn thử `skillSandboxLevel`), `scene_pose.dart`, `action_bar.dart`, `pause_overlay.dart`, `exam_screen.dart`, `l10n/strings.dart`. Test mới: `test/core/game/skills_test.dart`, `test/features/exam/skill_ui_test.dart`; sửa `game_controller_test.dart`, `play_script.dart`.
- Dữ liệu: 12 kỹ năng đúng id, cách kích hoạt, hồi chiêu và màn mở khóa theo 04_SKILL_CATALOG.
  - Mỗi kỹ năng có đúng một loại hiệu ứng (`SkillEffectKind`) và một cách kích hoạt (`SkillTrigger`).
  - Rủi ro luôn ≥ 0. Các cột hồi phục âm của catalog được quy đổi: −0.18 → −18, −0.2 → −20, −0.30 → −30 điểm nghi ngờ, trải đều trong lúc thi triển.
  - Tên và câu thoại nằm trong `Strings`.
- Cơ chế (`SkillController`, có seed riêng nên không làm lệch chuỗi AI giáo viên):
  - Giữ (peek, cheat_sheet, ruler): có tiến độ theo giây khi cô không nhìn. Nếu cô đang nhìn thì không có tiến độ, vẫn chịu rủi ro, và hiện thất bại hài một lần (ví dụ "Bạn lấy tay che bài!"). Hồi chiêu tính từ lúc thả.
  - Thi triển (pencil_case 75% thành công, ask_friend, eraser): cast 1–1,2 s và chịu rủi ro trong lúc cast. ask_friend chỉ được khi bấm lúc cô không nhìn. eraser cho 0/5/10 theo seed. Nếu cô thấy đúng lúc xong thì thất bại và bị +5 nghi ngờ.
  - Thả đúng nhịp (pass_note): phải thả trong 0,9–1,4 s, có vùng xanh trên thanh. Thả sớm hoặc giữ quá thì "giấy bay mất".
  - Chọn đáp án:
    - calculator: phép cộng, 3 đáp án.
    - signal: bạn giơ n ngón thì chọn A/B/C.
    - Sai hoặc hết giờ thì thất bại nhưng không kẹt. Phải thao tác tối thiểu 0,6 s nên trả lời nhanh vẫn chịu rủi ro.
  - Hồi phục (pretend, hide_note): bị nhìn thì chỉ hồi 40%. Oscar diễn khi cô nhìn thì hồi đủ, không ai xem thì "diễn lố" (40%).
  - Tạm dừng hoặc hết ván thì hủy kỹ năng và hoàn hồi chiêu. Bấm viết bài hoặc giả vờ giữa chừng thì hủy và vẫn tính hồi chiêu. Bấm khi còn hồi chiêu thì báo "Chờ thêm Ns". Chọn kỹ năng không có ở màn thì báo khóa.
- Giao diện:
  - Thanh kỹ năng cuộn ngang ở giữa hàng nút dưới, chip hiện số giây hồi chiêu. Nút cóp mang tên kỹ năng đang chọn.
  - Khi đang thi triển có bảng nhỏ phía trên nút: thanh tiến trình, vùng nhịp, câu đố.
  - Dòng phản hồi 1,6 s: +% bài làm, −điểm nghi ngờ, thất bại hài, chờ, khóa.
  - Màn tạm dừng liệt kê đủ 12 kỹ năng, kèm dấu khóa và "Mở ở màn N". Nút TIẾP TỤC được đưa lên trên danh sách để luôn bấm được trên màn thấp.
- Tư thế: kỹ năng tiến độ dùng `cheating`, giấu/diễn sâu dùng `hiding`, Oscar dùng `nervous`.
- Màn 1 chỉ có peek và pretend. Muốn review đủ 12 kỹ năng trên máy thì build với `--dart-define=SKILL_SANDBOX=true` (màn thử id 0, không phải màn chơi). 5 màn thật thuộc phase 05.
- Tests: `dart format lib test` → 0 file đổi; `flutter analyze` → No issues found; `flutter test` → 95/95 passed.
  - Test bảng 12 hàng kiểm: id, kích hoạt, hiệu ứng, hồi chiêu, mở khóa; số liệu hợp lệ; mỗi kỹ năng có tác dụng thật; rủi ro đúng loại; hồi chiêu và báo chờ; khóa; thất bại khi bị nhìn; ask_friend; nhịp pass_note; câu đố sai hoặc hết giờ; eraser theo seed; Oscar; hủy khi tạm dừng.
  - Test widget kiểm: chọn chip, giải câu đố qua giao diện (+11%), báo hồi chiêu, danh sách 12 kỹ năng khi tạm dừng ở khổ 932×430.
  - Lỗi phát hiện và đã sửa trong lúc làm:
    - Trả lời câu đố ngay lập tức thì không chịu rủi ro → thêm thời gian tối thiểu 0,6 s.
    - Nút TIẾP TỤC bị đẩy ra ngoài màn hình → đưa lên trên danh sách.
- Visual evidence (iOS Simulator, `SKILL_SANDBOX=true`):
  - `phase04_ios_skill_bar.png`: thanh kỹ năng.
  - `phase04_ios_pencil_case_success.png`: "+8% bài làm", hồi chiêu 12s trên chip và nút.
  - `phase04_ios_calculator_puzzle.png`: "24 + 20 = ?" với 3 đáp án, nhân vật đang cóp. Chọn 44 thì kỹ năng có kết quả và vào hồi chiêu; thông báo đã tắt khi chụp vì độ trễ công cụ.
- Chưa kiểm chứng: cân bằng từng kỹ năng qua chơi thật (mới có số liệu khởi điểm và kịch bản tự động). Hiệu ứng hình riêng cho từng thất bại hài hiện mới là dòng chữ cộng tư thế chung. APK Android chưa build.
- Next phase: 05 Levels / Events — sau khi người dùng duyệt.

### 2026-10-19 — Phase 05
- Changed files: mới `lib/core/game/levels.dart`, `stars.dart`, `progress_book.dart`, `level_event.dart`, `event_scheduler.dart`, `teacher_squad.dart`; sửa `game_controller.dart` (nhiều cô, sự kiện, hướng dẫn), `game_state.dart` (`teachers`, `seenBy`, `event`, `tutorialRemaining`), `level_config.dart` (`specialEventId`, `tutorialSeconds`, `watchWarningSeconds`; dữ liệu màn chuyển sang `levels.dart`), `teacher_fsm.dart` (`TeacherLane`, `TeacherPace`, lệnh `command`/`walkTo`), `skill_controller.dart` (`activeSkillId`, `refund`), `skill_runtime.dart` (`sourceId`). App: mới `lib/app/progress_scope.dart`, `lib/features/levels/level_select_screen.dart`; sửa `app.dart` (route có tham số id màn), `route_names.dart`, `menu_screen.dart` (VÀO LỚP → chọn màn). Màn thi: mới `widgets/event_banner.dart`, `components/dropped_paper.dart`; sửa `exam_screen.dart` (ghi tiến trình đúng một lần, MÀN TIẾP), `widgets/result_panel.dart` (sao, MÀN TIẾP), `exam_game.dart` (nhiều cô, quạt gió, giấy rơi), `components/teacher_figure.dart` (áo dài xanh cho cô thứ hai), `teacher_cue.dart` (màu biểu tượng riêng), `ceiling_fan.dart` (tăng tốc khi gió), `l10n/strings.dart`. Test mới: `test/core/game/levels_test.dart`, `events_test.dart`, `test/features/exam/level_flow_test.dart`; sửa `test/app/app_test.dart`, `play_script.dart` (thêm `playSmart`), `game_controller_test.dart`.
- 5 màn đúng bảng 05_LEVELS:
  - Các cột thời gian, số cô, tốc độ, nghi ngờ/giây và kỹ năng cộng dồn khớp bảng; màn 5 có đủ 12 kỹ năng.
  - Một bộ luật dùng chung cho cả 5 màn, không chép code theo màn.
  - Thêm một nút chỉnh độ khó mỗi màn: thời gian báo trước giảm dần 1,0 → 0,9 → 0,8 → 0,7 → 0,6 s. Boss còn 0,45 s, luôn > 0.
- Sự kiện (mỗi màn một sự kiện, đều có báo trước → diễn ra → kết thúc, chỉ chạy một lần mỗi ván):
  - teacher_question (màn 1, giây 25): báo trước 1,5 s, rồi cô quay sang nhìn và hỏi "Làm được mấy câu rồi?". Có 5 s để trả lời: trả lời thì −10 nghi ngờ, làm ngơ thì +10 (một lần, không thua ngay). Màn 1 còn có 10 s hướng dẫn đầu ván: gợi ý đổi theo biểu tượng của cô, nghi ngờ bị chặn ở 50.
  - fan_wind (màn 2, giây 30): quạt quay nhanh ×4 trong 5 s. Dùng phao giấy hoặc chuyền giấy lúc gió thì giấy rơi (kỹ năng bị hủy). Giấy nằm trên sàn thì +6 nghi ngờ/s cho tới khi bấm "Nhặt giấy".
  - wrong_exam_code (màn 3, giây 20, kéo dài 20 s): thành công của kỹ năng nhờ bạn (ask_friend, pass_note, signal) bị giữ lại, không âm thầm cộng hay trừ. Người chơi chọn "Hỏi lại" (dùng lại kỹ năng ngay) hoặc "Tự làm" (+½ số % một cách an toàn).
  - teacher_swap (màn 4, giây 30): hai cô, mỗi cô một nửa lối, AI và seed riêng nên chú ý độc lập. Cô thứ hai mặc áo dài xanh, biểu tượng nhìn màu xanh nhạt. Sau 2 s báo trước, hai cô đổi lối cho nhau. Hai cô cùng thấy cóp thì nghi ngờ tăng gấp đôi.
  - final_boss_mode (màn 5, khi còn ≤ 20 s): báo trước 1,5 s rồi tăng nhịp: đứng ngắn ×0,6, đi nhanh ×1,3, ít quay lưng hơn, báo trước 0,45 s. Vẫn có lúc an toàn và mọi lần nhìn vẫn báo trước (có test).
- Sao theo spec (thắng 1; ≤ 40 thêm 1; ≤ 20 và còn ≥ 30 s thêm 1), có test ranh giới.
- Tiến trình (`ProgressBook`): thắng màn N mở màn N+1 (tối đa 5); sao chỉ tăng; thua không làm mất gì. Hiện chỉ lưu trong bộ nhớ khi app chạy; lưu xuống máy thuộc phase 06.
- Màn chọn màn: 5 thẻ, khóa và sao; màn khóa không bấm được. Bảng kết quả có sao, MÀN TIẾP (khi thắng, chưa phải màn cuối), CHƠI LẠI và Về menu.
- Cân bằng: người chơi giả lập (`playSmart`) chỉ nhìn biểu tượng hiển thị, chọn kỹ năng giữ mạnh nhất đang sẵn sàng và phản ứng với sự kiện. Kết quả 20 seed mỗi màn:

  | Phản ứng | Màn 1 | Màn 2 | Màn 3 | Màn 4 | Màn 5 |
  |---|---|---|---|---|---|
  | 0,3 s (thắng) | 20/20 | 20/20 | 20/20 | 18/20 | 20/20 |
  | 1,3 s (thắng) | 20/20 | 20/20 | 20/20 | 17/20 | 8/20 |

  - Phản ứng 1,3 s thì nghi ngờ cuối ván tăng rõ theo màn.
  - Ở mọi màn: không làm gì → hết giờ; chỉ viết bài → hết giờ; cóp liều → bị bắt.
  - Lưu ý: với người chơi nhanh, màn 5 vẫn dễ hơn màn 4 (kỹ năng màn 5 mạnh hơn) và thường thắng trước khi boss bật. Cần chơi thật để chỉnh tiếp.
- Tests: `dart format lib test` → 0 file đổi; `flutter analyze` → No issues found; `flutter test` → 123/123 passed.
  - Lỗi phát hiện và đã sửa trong lúc làm:
    - Giấy rơi +3/s bị mức tự giảm khi viết bài (−3/s) triệt tiêu → nâng lên +6/s.
    - Thẻ màn tràn 14 px ở màn thấp → co nội dung.
    - Thua vẫn báo "tiến trình đổi" → `record` trả về chính nó khi không có gì thay đổi.
- Visual evidence (iOS Simulator):
  - `phase05_ios_level_select.png`: màn 1 mở, 2–5 khóa.
  - `phase05_ios_tutorial_hint.png`: gợi ý hướng dẫn, không che mặt nhân vật.
  - `phase05_ios_question_warning.png`: báo trước "Cô đang đi về phía bạn…" kèm "…".
  - `phase05_ios_teacher_question.png`: câu hỏi của cô, nút "Dạ, em đang làm ạ!", mắt vàng, HUD CÔ ĐANG NHÌN.
  - Sự kiện màn 2–5 mới kiểm bằng test (core và widget), chưa chụp trên máy vì phải thắng các màn trước mới mở.
- Chưa làm theo spec: sự kiện ngẫu nhiên phụ có seed ("bounded seeded random flavor events"); mới có 1 sự kiện cố định mỗi màn. Boss chưa có chiêu giả quay lưng. Âm thanh báo hiệu thuộc phase 06.
- `game_controller.dart` 275 dòng code, `skill_controller.dart` 260 (giới hạn 300). Phase sau nên tách trước khi thêm.
- Next phase: 06 UI / Audio / Save — sau khi người dùng duyệt.

### 2026-10-19 — Phase 06
- Thư viện mới (thêm bằng `flutter pub add`, ghi trong `docs/tech-stack.md`):
  - `shared_preferences ^2.5.6`: lưu offline.
  - `flame_audio ^2.12.2`: âm thanh, cùng hệ với Flame.
- Changed files:
  - Mới, core: `lib/core/save/save_data.dart`, `save_repository.dart`, `lib/core/game/sound_cues.dart`.
  - Mới, app: `lib/app/app_scope.dart` (thay `progress_scope.dart`), `game_audio.dart`, `shared_prefs_store.dart`.
  - Mới, âm thanh: `assets/audio/*.wav` + `README.md` ghi nguồn gốc; `tool/generate_sfx.py`.
  - Sửa: `app.dart` (đọc hồ sơ khi mở, nhận store/audio để test), `theme.dart` (tông lớp học), `menu_screen.dart` (bảng phấn), `settings_screen.dart` (thật), `level_select_screen.dart`, `exam_screen.dart` (âm thanh, ghi kết quả qua hồ sơ), `l10n/strings.dart`, `pubspec.yaml` (thêm asset).
  - Test mới: `test/core/save/save_data_test.dart`, `test/core/game/sound_cues_test.dart`, `test/app/persistence_test.dart`; sửa `test/app/app_test.dart`, `test/features/exam/level_flow_test.dart`.
- Lưu offline:
  - Đúng JSON phiên bản 1 của 07_DATA_CONTRACTS (version, unlockedLevel, bestStars 1..5, settings musicVolume/sfxVolume/muted), dưới khóa `nqnm.save`.
  - Đọc dễ dãi: thiếu hoặc sai kiểu thì dùng mặc định; màn kẹp 1–5, sao 0–3, âm lượng 0–1.
  - JSON hỏng: chép nguyên văn sang `nqnm.save.corrupt` rồi mới dùng mặc định, không xóa âm thầm.
  - Dữ liệu từ bản app mới hơn (version > 1): đọc phần hiểu được và không ghi đè.
  - Chỉ ghi khi có thay đổi thật (hết ván có tiến bộ, đổi cài đặt, thả thanh trượt); không ghi mỗi khung hình. Các lần ghi được xếp hàng. Sao tốt nhất không bao giờ giảm.
- Âm thanh:
  - 11 file `.wav` tự tổng hợp bằng code (sine, nhiễu, đường bao), có ghi nguồn gốc, không dùng mẫu của ai.
  - Âm nền lớp học + quạt lặp suốt ván; dừng khi tạm dừng hoặc rời màn, bật lại khi tiếp tục.
  - Hiệu ứng chỉ phát lúc có chuyển biến (`soundCuesBetween`): báo trước, cô nhìn thấy, bước chân, kỹ năng thành công/thất bại/chưa sẵn sàng, giấy rơi, chuông sự kiện, thắng/thua.
  - Tôn trọng tắt tiếng và âm lượng. Lỗi phát hoặc thiếu file chỉ làm im đúng file đó, game không lỗi. Âm thanh chỉ bắt đầu sau khi người chơi bấm vào lớp.
- Giao diện:
  - Theme tông lớp học (bảng xanh, tường kem). Menu kiểu bảng phấn.
  - Cài đặt: tắt tiếng, âm nền, hiệu ứng. Thanh trượt cập nhật khi kéo, lưu khi thả.
  - Chọn màn, tạm dừng, kết quả (từ phase 04–05) đều bằng tiếng Việt. HUD giữ như phase 03–05: thời gian, tiến độ, nghi ngờ, trạng thái cô nhìn; hồi chiêu trên chip kỹ năng và nút. Không che mặt hay tay nhân vật (đã soát trên ảnh máy).
- Tests: `dart format lib test` → 0 file đổi; `flutter analyze` → No issues found; `flutter test` → 142/142 passed.
  - Lưu/tải: định dạng v1, khứ hồi, kẹp giá trị, dữ liệu hỏng, bản mới hơn.
  - App: thắng rồi tắt app mở lại vẫn còn màn 2 và sao; chơi kém hơn không giảm sao; không thay đổi thì không ghi; tắt tiếng được lưu và áp dụng; thanh trượt chỉ lưu khi thả; dữ liệu hỏng lúc mở app vẫn vào menu và giữ bản hỏng; menu và cài đặt vừa khổ 932×430.
  - Âm thanh: các hiệu ứng phát đúng lúc, không lặp, thắng/thua đúng một lần; vào màn thi thì âm nền bật và có hiệu ứng.
- Kiểm tra trên iOS Simulator:
  - `phase06_ios_menu.png`: menu bảng phấn.
  - `phase06_ios_settings_persisted.png`: bật Tắt tiếng, tắt hẳn app (tiến trình đổi 19872 → 20342), mở lại vẫn bật. Đã tắt lại sau khi kiểm tra.
  - Log khi vào màn thi không có lỗi "Tắt âm thanh". Chưa nghe bằng tai được vì simulator không xuất âm qua công cụ.
  - Lưu ý: hai lần chạm trên simulator rơi nhầm vào một app khác cài sẵn (màn chào của app đó); không thao tác gì thêm trong app ấy.
- Chưa làm hoặc chưa kiểm chứng:
  - Cảm nhận âm lượng và chất lượng âm thanh bằng tai.
  - Tiến trình thắng thật qua 5 màn trên máy (mới kiểm bằng test).
  - Android (APK chưa build từ phase 00 vì đĩa đầy; nay đĩa còn ~10 GB).
- File sắp chạm giới hạn 300 dòng: `game_controller.dart` 275, `skill_controller.dart` 260, `exam_screen.dart` 239. Nên tách ở phase 07.
- Next phase: 07 Polish / Release — sau khi người dùng duyệt.

### 2026-10-20 — Phase 07
- Môi trường: macOS, Flutter 3.44.8 stable, Xcode 26.6, Android SDK 36 + JDK 21, iOS Simulator iPhone 16 Pro Max, emulator Android `JobMatchingTest` (có sẵn, chưa dùng tới).
- Lệnh cổng (mã thoát thật, chạy 2026-10-20):
  - `flutter pub get` → 0
  - `dart format --output=none --set-exit-if-changed lib test` → 0
  - `flutter analyze` → 0 (No issues found)
  - `flutter test` → 0 (149/149 passed)
  - `flutter build apk --debug` → **dừng chủ động**. Script canh đĩa dừng build khi đĩa còn 0,9 GB, lúc Gradle đang ở `assembleDebug`. `~/.gradle` đã tăng 2,9 → 6,4 GB, và `build/` (Android) lên 1,7 GB. Đã xóa `build/` do lần build này tạo ra, đĩa về 2,6 GB. Không đụng bộ đệm Gradle dùng chung với dự án khác. **Chưa có APK, chưa chạy trên Android.**
- Changed files:
  - Tách cho file dưới 300 dòng, không đổi hành vi:
    - `game_controller.dart` 275 → 245 (công thức sang `lib/core/game/game_rules.dart`).
    - `skill_controller.dart` 260 → 232 (câu đố sang `skill_puzzles.dart`; thứ tự rút ngẫu nhiên giữ nguyên nên kết quả theo seed không đổi).
    - `exam_screen.dart` 239 → 199 (phiên chơi sang `lib/features/exam/state/exam_session.dart`).
  - Sửa: `components/classroom_background.dart` (cache Picture), `widgets/exam_hud.dart` (cảnh báo nguy hiểm), `widgets/hold_action_button.dart` (Semantics), `l10n/strings.dart`, `android/app/src/main/AndroidManifest.xml` và `ios/Runner/Info.plist` (tên app "Nhất Quỷ Nhì Ma").
  - Mới: `docs/HANDOFF.md`; `test/features/exam/qa_test.dart` (+2 golden).
- Hiệu năng (đo trên máy dev, chế độ test, trung bình 300 lần, màn 4 hai cô):
  - Ghi nền: 0,079 ms → 0,006 ms sau khi cache Picture.
  - Ghi cả khung: 0,64 ms.
  - `update` một khung: 0,03 ms.
  - Đây là thời gian CPU ghi lệnh vẽ, **không phải FPS trên máy thật**. FPS, bộ nhớ và raster GPU trên Android/iOS thật chưa đo.
- Hoàn thiện:
  - HUD từ nghi ngờ 70 trở lên: nền đỏ, chữ trắng "🚨 SẮP BỊ BẮT!" (có chữ, không chỉ dựa vào màu; golden ban đầu lộ chữ đỏ trên nền đỏ nên đã đổi chữ sang trắng).
  - Nút giữ có nhãn trợ năng (nút, bật/tắt, gợi ý "Nhấn giữ để dùng, thả ra để dừng").
  - Tên app tiếng Việt trên Android và iOS.
- Test QA mới:
  - Kéo ngón ra ngoài nút rồi nhấc vẫn thả; hủy chạm cũng thả.
  - Chơi lại 10 lần liên tiếp: mỗi lần là ván mới, seed khác, không lỗi, cô không bị khóa tư thế.
  - Hành trình đầy đủ trên khổ 932×430: menu → chọn màn → vào lớp → tạm dừng → tiếp → hết giờ → kết quả.
  - HUD nguy hiểm ở ngưỡng 69/70; golden HUD nguy hiểm và màn thắng 3 sao (font Ahem).
- Cân bằng (từ phase 05):
  - Người mới (phản ứng chậm 1,3 s) thắng màn 1 20/20; màn 5 chỉ 8/20 nên có rủi ro thật.
  - Lỗ hổng đã rà: trả lời câu đố tức thì (đã chặn ở phase 04); giữ nút kẹt (có test); kết thúc lặp (chỉ ghi một lần, có test).
  - Còn một điểm cố ý: tạm dừng giữa lúc thi triển thì được hoàn hồi chiêu (ghi trong HANDOFF).

#### Checklist nghiệm thu (09_QA_ACCEPTANCE)
- Gate A — hình ảnh:
  - [x] Góc từ bàn bên cạnh (ảnh phase 01–05, người dùng đã duyệt).
  - [x] Thấy mặt, tay nhân vật chính và cô cùng lúc.
  - [x] Lớp học VN (bảng xanh, khẩu hiệu, áo dài, đồng phục).
  - [x] HUD dùng được ở khổ ngang (test 932×430 + ảnh simulator).
- Gate B — cơ chế:
  - [x] Giữ/thả đổi trạng thái thật.
  - [x] Hướng đầu cô khớp bộ phát hiện (test so từng khung).
  - [x] Có tự làm bài an toàn.
  - [x] Tạm dừng dừng giờ, không kẹt nút.
  - [x] Thắng/thua một lần, sao đúng.
- Gate C — nội dung:
  - [x] 12 kỹ năng theo màn, không nút giả.
  - [x] 5 màn khác nhau.
  - [x] 5 sự kiện báo trước và kết thúc (test). Trên máy mới chụp được sự kiện màn 1.
  - [x] Chữ Việt có dấu, không lorem ipsum.
- Gate D — lưu và giao diện:
  - [x] Màn mở và sao giữ qua lần tắt app (test; simulator thử với cài đặt).
  - [x] Menu, tạm dừng, chơi lại, chọn màn, cài đặt nối đủ.
  - [x] Tắt tiếng và âm lượng được lưu; thiếu file âm thanh không lỗi.
- Gate E — chất lượng:
  - [x] format/analyze/test đều thoát 0.
  - [ ] **APK debug build và mở trên thiết bị/emulator: CHƯA.** Bị chặn vì dung lượng đĩa (xem trên). Việc cần làm: giải phóng khoảng ≥ 6 GB rồi chạy lại `flutter build apk --debug`, khởi động emulator, cài và chơi qua 5 màn.
  - [x] Giới hạn và ảnh bằng chứng có ghi (`docs/HANDOFF.md`, `docs/evidence/`).
  - [x] PROGRESS phản ánh đúng thực tế.
- Kết luận: **chưa thể tuyên bố MVP hoàn tất** vì Gate E còn mục APK/Android chưa kiểm chứng. Spec yêu cầu "chạy Android landscape".
- Next: sau khi có đủ chỗ trống trên đĩa thì build APK, chạy trên emulator Android qua 5 màn và chụp bằng chứng.

## Architecture decisions
- ADR-001: Fixed side-neighbor desk perspective; 1600x900 logical layout; no top-down camera.
- ADR-002: Pure deterministic core game logic separated from Flame rendering.

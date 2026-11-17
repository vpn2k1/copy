# 01 — Visual Direction and Camera Contract (CRITICAL)

## Camera chính xác
Camera như **một bạn học ngồi tại bàn ngay bên TRÁI hoặc bên PHẢI nhân vật chính**, nhìn ngang/xéo nhẹ sang bạn đó và phần trước lớp, ở độ cao mắt học sinh đang ngồi. 2D side / 2.5D staged perspective, **không phải camera di chuyển tự do 3D**. Thống nhất camera trái cho MVP, biến thể camera phải chỉ cần mirror/layout khi thích hợp.

### Sơ đồ topological (KHÔNG phải hướng camera từ trên xuống)
`[Bàn camera bên trái] → [Nhân vật chính tại bàn kế bên] → [Dãy bàn phía xa + giáo viên + bảng]`
- Nhân vật chính chiếm ~20–30% chiều ngang và ~45–60% chiều cao vùng cảnh; mặt/hai tay đủ to để đọc cử chỉ.
- Giáo viên chiếm ~12–20% chiều cao cảnh, không bị che hoàn toàn bởi bàn.
- Mặt giáo viên luôn nhìn thấy được khi đang tuần tra trong vùng chơi hữu hiệu.
- Lớp đủ rộng để thấy 3–7 bạn, bảng xanh, cửa sổ, quạt trần, bàn ghế; không zoom cận một chiếc bàn.
- Camera **không đặt ở sau vai/đằng sau lưng** học sinh chính. Ưu tiên góc 3/4 phía trước bên hông để nhìn thấy mặt và tay nhân vật, không chỉ thấy lưng.

## Layer / sorting
`background wall/window/board` → `far desks/students` → `teacher lane` → `player and player desk` → `foreground desk sliver` → `FX` → `Flutter HUD`. Các component có depth/z-index cố định hoặc sort theo chân nhân vật để tránh pop overlap. Giáo viên vẫn phải nhìn thấy khi đi ngang lớp.

## Vietnamese art bible
- Tường vàng kem, bảng xanh chữ phấn, bàn gỗ khung sắt, ghế gỗ, quạt trần, đèn tuýp, cửa sổ xanh.
- Đồng phục học sinh: áo trắng, quần sẫm/ váy sẫm, có thể dùng khăn quàng khi phù hợp bối cảnh tuổi.
- Khẩu hiệu trên bảng: `TIÊN HỌC LỄ, HẬU HỌC VĂN`; tiêu đề đề thi bằng tiếng Việt; giáo viên có thể mặc áo dài tím hoặc áo sơ mi.
- 2D cartoon với outline rõ, đổ bóng đơn giản, cảm xúc lố có chủ đích; không giả 3D/photoreal.

## Art / animation sheet
Player: idle 4f, write 4f, peek 4f, unfold 5f, hide 3f, nervous 3f, caught 5f, celebrate 5f. Teacher: walk 6f, idle 3f, look-left 3f, look-right 3f, approach 6f, inspect 4f, catch 5f. Timing đề xuất 8–12 FPS cho sprite, gameplay 60 FPS nếu thiết bị chịu được.

## Tỷ lệ/viewport
Logical world `1600x900`, letterbox contain; không crop mất giáo viên / bảng / nhân vật. Flutter HUD responsive theo safe-area; reserve top 12%, bottom 16%; gameplay object quan trọng nằm vùng middle 72%.

## Checklist phải bác bỏ khi review
- [ ] Camera từ trên xuống thấy nóc bàn (top-down).
- [ ] Camera ở phía sau lưng nhân vật chính hoặc góc over-shoulder.
- [ ] Không thấy mặt hoặc tay học sinh chính.
- [ ] Không thấy giáo viên cùng một frame khi bình thường.
- [ ] Phóng to đến mức không còn thấy lớp Việt Nam.
- [ ] HUD che mặt học sinh hoặc thầy/cô.

## Visual approval gate
Trước khi code sâu: render một frame nguyên cảnh ở 1600x900 và screenshot trên Android landscape, đánh dấu vị trí học sinh, giáo viên và camera. Cần user duyệt lại nếu thực hiện sai bất kỳ điều kiện không-negotiable nào.

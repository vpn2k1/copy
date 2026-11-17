# Âm thanh

Mọi file `.wav` ở đây được **tổng hợp bằng code** bởi `tool/generate_sfx.py`
(sóng sin, nhiễu, đường bao), không dùng mẫu âm thanh của ai. Bản quyền thuộc
dự án. Sinh lại:

```bash
python3 -I tool/generate_sfx.py assets/audio
```

| File | Dùng khi |
|---|---|
| `ambient_classroom.wav` | Âm nền lớp học + quạt trần, lặp suốt ván (âm lượng "nhạc nền") |
| `warning.wav` | Cô sắp quay sang nhìn lớp (biểu tượng "…") |
| `alert.wav` | Cô bắt đầu nhìn thấy người chơi |
| `footstep.wav` | Cô bắt đầu bước đi |
| `pencil.wav` | Kỹ năng thành công |
| `fail.wav` | Kỹ năng thất bại hài |
| `click.wav` | Bấm kỹ năng còn hồi chiêu / chưa mở |
| `paper.wav` | Giấy bị gió thổi rơi |
| `bell.wav` | Sự kiện đặc trưng bắt đầu báo trước |
| `win.wav` / `lose.wav` | Kết thúc ván |

Khi có file thật (`.ogg` theo 06_ASSET_PIPELINE), thay tên trong
`lib/app/game_audio.dart`. Thiếu file thì game vẫn chạy, chỉ im lặng.

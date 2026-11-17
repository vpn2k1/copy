"""Sinh hiệu ứng âm thanh gốc cho game bằng tổng hợp (sine, nhiễu, đường bao).

Không dùng mẫu âm thanh có sẵn nào, nên không vướng bản quyền. Chạy lại:
    python3 -I tool/generate_sfx.py assets/audio
"""
import math
import random
import struct
import sys
import wave

RATE = 22050
rng = random.Random(20261019)


def envelope(i, n, attack=0.01, release=0.2):
    t = i / RATE
    total = n / RATE
    a = min(1.0, t / attack) if attack > 0 else 1.0
    r = min(1.0, (total - t) / release) if release > 0 else 1.0
    return max(0.0, min(a, r))


def tone(freqs, seconds, volume=0.5, attack=0.01, release=0.15, wobble=0.0):
    n = int(seconds * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        f = freqs[min(len(freqs) - 1, int(t / seconds * len(freqs)))]
        f *= 1 + wobble * math.sin(2 * math.pi * 6 * t)
        s = math.sin(2 * math.pi * f * t) + 0.3 * math.sin(4 * math.pi * f * t)
        out.append(s * volume * envelope(i, n, attack, release) / 1.3)
    return out


def noise(seconds, volume=0.4, smooth=0.0, attack=0.005, release=0.1):
    n = int(seconds * RATE)
    out = []
    last = 0.0
    for i in range(n):
        x = rng.uniform(-1, 1)
        last = last * smooth + x * (1 - smooth)
        out.append(last * volume * envelope(i, n, attack, release))
    return out


def ambient(seconds=4.0):
    """Tiếng phòng học + quạt trần: nhiễu trầm và tiếng ù quạt, lặp liền."""
    n = int(seconds * RATE)
    out = []
    last = 0.0
    for i in range(n):
        t = i / RATE
        last = last * 0.985 + rng.uniform(-1, 1) * 0.015
        hum = 0.05 * math.sin(2 * math.pi * 55 * t)
        blade = 0.5 + 0.5 * math.sin(2 * math.pi * 2.5 * t)
        out.append((last * 2.5 * (0.7 + 0.3 * blade)) * 0.5 + hum)
    fade = int(0.05 * RATE)
    for i in range(fade):
        k = i / fade
        out[i] = out[i] * k + out[n - fade + i] * (1 - k)
    return out[: n - fade]


def concat(*parts):
    result = []
    for p in parts:
        result.extend(p)
    return result


def write(path, samples):
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = b''.join(
            struct.pack('<h', int(max(-1, min(1, s)) * 32000)) for s in samples
        )
        w.writeframes(frames)


def main(out_dir):
    sounds = {
        'ambient_classroom.wav': ambient(),
        'warning.wav': tone([660], 0.18, 0.35, release=0.1),
        'alert.wav': concat(tone([880], 0.12, 0.5), tone([1175], 0.2, 0.5)),
        'footstep.wav': noise(0.09, 0.5, smooth=0.6, release=0.07),
        'pencil.wav': concat(*(noise(0.05, 0.25, smooth=0.2) for _ in range(3))),
        'paper.wav': noise(0.45, 0.45, smooth=0.3, attack=0.05, release=0.3),
        'fail.wav': tone([392, 330, 262], 0.45, 0.45, wobble=0.03),
        'click.wav': tone([1200], 0.05, 0.3, release=0.04),
        'bell.wav': tone([1046], 0.9, 0.45, release=0.8, wobble=0.004),
        'win.wav': tone([523, 659, 784, 1046], 0.8, 0.5, release=0.25),
        'lose.wav': tone([392, 349, 311, 262], 1.0, 0.5, release=0.4, wobble=0.02),
    }
    for name, samples in sounds.items():
        write(f'{out_dir}/{name}', samples)
        print(name, len(samples) / RATE)


if __name__ == '__main__':
    main(sys.argv[1])

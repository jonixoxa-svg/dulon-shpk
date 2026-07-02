#!/usr/bin/env python3
"""Generates the placeholder sound effects in assets/audio/.

Pure-stdlib (wave + math), no dependencies. Run from the project root:

    python3 tool/generate_sounds.py

Replace the generated .wav files with real sound design whenever you like —
just keep the file names (tap.wav, orb.wav, death.wav, button.wav).
"""
import math
import os
import random
import struct
import wave

RATE = 22050  # 22 kHz mono keeps files tiny


def write_wav(path, samples):
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = b"".join(
            struct.pack("<h", max(-32767, min(32767, int(s * 32767))))
            for s in samples
        )
        w.writeframes(frames)
    print(f"wrote {path} ({os.path.getsize(path)} bytes)")


def env(i, n, attack=0.01, release=0.5):
    """Simple attack/release envelope, 0..1."""
    t = i / n
    a = min(1.0, t / attack) if attack > 0 else 1.0
    r = min(1.0, (1.0 - t) / release) if release > 0 else 1.0
    return a * r


def tone(freq_start, freq_end, dur, vol=0.6, attack=0.01, release=0.6):
    n = int(RATE * dur)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / n
        f = freq_start + (freq_end - freq_start) * t
        phase += 2 * math.pi * f / RATE
        out.append(vol * env(i, n, attack, release) * math.sin(phase))
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] if i < len(t) else 0.0 for t in tracks) for i in range(n)]


def main():
    out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
    os.makedirs(out_dir, exist_ok=True)

    # tap: quick rising blip
    write_wav(os.path.join(out_dir, "tap.wav"),
              tone(620, 940, 0.07, vol=0.5, release=0.8))

    # orb: bright two-note ding
    ding = mix(
        tone(880, 880, 0.10, vol=0.35, release=0.9),
        [0.0] * int(RATE * 0.05) + tone(1318, 1318, 0.12, vol=0.35, release=0.9),
    )
    write_wav(os.path.join(out_dir, "orb.wav"), ding)

    # death: falling tone + noise burst
    n = int(RATE * 0.35)
    rng = random.Random(7)
    noise = [0.45 * env(i, n, 0.005, 0.9) * (rng.random() * 2 - 1)
             for i in range(n)]
    fall = tone(420, 70, 0.35, vol=0.5, release=0.9)
    write_wav(os.path.join(out_dir, "death.wav"), mix(noise, fall))

    # button: soft low click
    write_wav(os.path.join(out_dir, "button.wav"),
              tone(300, 220, 0.06, vol=0.4, release=0.9))


if __name__ == "__main__":
    main()

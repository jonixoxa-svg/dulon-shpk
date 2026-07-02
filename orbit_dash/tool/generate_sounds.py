#!/usr/bin/env python3
"""Generates the placeholder sound effects in assets/audio/.

Pure-stdlib (wave + math), no dependencies. Run from the project root:

    python3 tool/generate_sounds.py

Replace the generated .wav files with real sound design whenever you like —
just keep the file names.
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


def silence(dur):
    return [0.0] * int(RATE * dur)


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] if i < len(t) else 0.0 for t in tracks) for i in range(n)]


def main():
    out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
    os.makedirs(out_dir, exist_ok=True)

    def out(name):
        return os.path.join(out_dir, name)

    # tap: quick rising blip
    write_wav(out("tap.wav"), tone(620, 940, 0.07, vol=0.5, release=0.8))

    # orb pickups: two-note dings, one per combo step, rising in pitch
    base_notes = [880, 988, 1109, 1245, 1397]  # A5 B5 C#6 D#6 F6-ish
    for i, f in enumerate(base_notes, start=1):
        ding = mix(
            tone(f, f, 0.10, vol=0.32, release=0.9),
            silence(0.05) + tone(f * 1.5, f * 1.5, 0.12, vol=0.32, release=0.9),
        )
        write_wav(out(f"orb{i}.wav"), ding)

    # near-miss: short airy whoosh (filtered-ish noise sweep)
    n = int(RATE * 0.16)
    rng = random.Random(3)
    prev = 0.0
    whoosh = []
    for i in range(n):
        raw = rng.random() * 2 - 1
        prev = prev * 0.82 + raw * 0.18  # crude low-pass
        whoosh.append(0.5 * env(i, n, 0.2, 0.6) * prev)
    write_wav(out("whoosh.wav"), whoosh)

    # power-up: bright upward arpeggio
    arp = mix(
        tone(660, 660, 0.09, vol=0.3, release=0.9),
        silence(0.06) + tone(880, 880, 0.09, vol=0.3, release=0.9),
        silence(0.12) + tone(1320, 1320, 0.14, vol=0.3, release=0.9),
    )
    write_wav(out("powerup.wav"), arp)

    # shield break: glassy crack + drop
    n = int(RATE * 0.22)
    rng = random.Random(11)
    crack = [0.5 * env(i, n, 0.002, 0.95) * (rng.random() * 2 - 1)
             for i in range(n)]
    write_wav(out("shield_break.wav"), mix(crack, tone(900, 200, 0.22, vol=0.35)))

    # sector up: two-note fanfare
    fanfare = mix(
        tone(523, 523, 0.12, vol=0.3, release=0.8),
        silence(0.10) + tone(784, 784, 0.20, vol=0.34, release=0.85),
    )
    write_wav(out("sector.wav"), fanfare)

    # level up: triumphant three-note rise
    lvl = mix(
        tone(523, 523, 0.12, vol=0.28, release=0.8),
        silence(0.10) + tone(659, 659, 0.12, vol=0.28, release=0.8),
        silence(0.20) + tone(1047, 1047, 0.28, vol=0.32, release=0.9),
    )
    write_wav(out("levelup.wav"), lvl)

    # death: falling tone + noise burst
    n = int(RATE * 0.35)
    rng = random.Random(7)
    noise = [0.45 * env(i, n, 0.005, 0.9) * (rng.random() * 2 - 1)
             for i in range(n)]
    write_wav(out("death.wav"), mix(noise, tone(420, 70, 0.35, vol=0.5, release=0.9)))

    # button: soft low click
    write_wav(out("button.wav"), tone(300, 220, 0.06, vol=0.4, release=0.9))


if __name__ == "__main__":
    main()

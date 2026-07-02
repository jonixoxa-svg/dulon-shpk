# ⭕ Orbit Maze

A one-finger neon maze game in a **single self-contained HTML file** —
no dependencies, no build step, no storage. Drag the glowing orb through
rotating rings, pulsing circles, orbiting hazards, gravity wells and
teleporters to the goal portal. 30 levels across 3 color chapters.

**Play it:** open `index.html` in any browser, or (once GitHub Pages is
enabled for this repo) at `https://<user>.github.io/<repo>/maze/`.

## Level progression

| Levels | New mechanic |
|---|---|
| 1–4 | Drag control, static walls, rotating rings |
| 5 | Pulsing circles |
| 10 | Orbiting hazards + chapter boss |
| 15 | Keys (portal locked until collected) |
| 20 | Gravity wells + chapter boss |
| 25 | Teleporters + time limits |
| 27 | Invisible walls (revealed by proximity) |
| 30 | Chasing hazard finale |

Stars: 3★ = no deaths and under par time · 2★ = ≤2 deaths and under
2.5× par · 1★ = finish.

## Tech notes

- Canvas 2D, `requestAnimationFrame` with delta-time; virtual 1000×1600
  portrait space scaled to any screen.
- Pointer Events (touch + mouse) with a drag offset so the finger never
  covers the orb.
- All sound synthesized with the Web Audio API (ambient hum, shatter,
  chimes, ticks); mute toggle on the menu.
- Progress (unlocks, stars, best times) is session-only by design — no
  localStorage.

## Shipping to Google Play

A single-file HTML game ships to the Play Store as a **Trusted Web
Activity** (host the file on HTTPS, wrap with
[Bubblewrap](https://github.com/GoogleChromeLabs/bubblewrap)) or inside a
WebView wrapper. If you'd rather have a native build with AdMob like
Orbit Dash, the game logic here ports 1:1 to the Flutter/Flame stack in
`../orbit_dash/`.

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

## Ascent Mode (endless vertical climb)

Second game mode on the main menu: drag the orb upward through an endless
procedural maze. Altitude is the score (with a session-best ghost line).

- **Zones** with distinct palettes, mechanics and ambience, crossfading at
  each boundary with an "ENTERING:" banner and musical sting:
  Neon City (0–200m, classic hazards + city glow) → Storm Layer (200–500m,
  wind gusts with streak warnings, rain, lightning that reveals invisible
  walls) → Stratosphere (500–900m, drifty controls, faster rings, auroras)
  → Orbit (900–1400m, gravity wells, floating debris, Earth below) →
  Deep Space (1400m+, black holes, comets, trail-revealed ghost walls).
- **Checkpoints** at growing intervals (100/250/450/700m…), 3 lives each
  shown as orbs; dying respawns at the last checkpoint, exhausting one
  falls you back to the previous.
- **Fair procedural generation**: screen-height chunks assembled from
  hand-designed per-zone patterns, every pattern keeps a passable route,
  hazards never spawn inside a checkpoint's protected band; difficulty
  rises in waves with calm shard-rich stretches between intense ones.
- **Star shards** along the route (riskier = more) feed the same Locker
  unlock currency (10 shards = 1 star); altitude milestones at
  500/1000/2000m grant one-time bonuses.
- **Run summary** with altitude, shards, best, and a vertical mini-map of
  the zones you climbed through.
- Camera: eased follow with velocity look-ahead and speed-based zoom;
  only entities within ~1.5 screens are simulated (60 FPS held at 2000m+).
- Dev keys with `#fly` in the URL: J = jump to next checkpoint,
  U = +400m, K = force death (for testing checkpoints).

## Engagement & retention systems

- **Trails** (7, unlocked by total stars): Comet, Fire, Electric, Rainbow,
  Stardust, Shadow, and Golden (requires 3-starring all 30 levels).
- **Skins** (6): Neon, Planet, Eyeball (looks at the goal), Heart, Disco,
  Black Hole — unlocked at 0/5/15/30/45/75 stars.
- **Locker screen** with live animated preview; the menu's demo orb also
  wears your equipped cosmetics.
- **Flow meter**: threading ring gaps fills it; at full flow the trail
  doubles and the screen edges glow. Full flow is sticky until death;
  finishing at full flow earns a sparkle banner.
- **Near-miss sparks** + whoosh for shaving past hazards (counted in stats).
- **Daily challenge**: date-seeded procedural level with crown + streak
  counter (session-only; see code comment for the TWA persistence hook).
- **Chapter celebrations** after levels 10/20 with animated palette reveal.
- **Stats screen**: deaths, near-misses, gaps threaded, fastest level,
  favorite trail, daily streak.
- Ambient life: 3-layer parallax starfield reacting to the orb, shooting
  stars, portal vortex with glyph ring, breathing ring glow, hazard
  warning particles, floating title letters.
- **Adaptive quality**: all particles pooled (hard cap); if frames exceed
  20 ms for 30 consecutive frames, particle budgets step down
  automatically and recover when performance allows.
- Dev/testing hook: open with `#dev` in the URL to unlock everything.

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

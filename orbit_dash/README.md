# 🪐 Orbit Dash

A one-tap hypercasual arcade game for Android, built with **Flutter** and
the **Flame** game engine, monetized with **Google AdMob**, and ready to
publish on Google Play.

**How it plays:** a neon ball orbits a center point. Tap anywhere to
reverse its direction. Dodge the pink arcs, grab the gold orbs (+5 points
each), survive as long as you can. One hit and it's game over. The game
gets faster the longer you last.

---

## Table of contents

1. [Run and test the game locally](#1-run-and-test-the-game-locally)
2. [Set up AdMob and add your real ad IDs](#2-set-up-admob-and-add-your-real-ad-ids)
3. [Host your privacy policy](#3-host-your-privacy-policy)
4. [Create your signing key](#4-create-your-signing-key)
5. [Build the release file for Google Play](#5-build-the-release-file-for-google-play)
6. [Create the Play Console listing](#6-create-the-play-console-listing)
7. [Screenshots & graphics you need](#7-screenshots--graphics-you-need)
8. [Data safety form — exactly what to declare](#8-data-safety-form--exactly-what-to-declare)
9. [Project structure](#9-project-structure)
10. [How the ads behave](#10-how-the-ads-behave)

---

## 1. Run and test the game locally

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install)
(3.24 or newer) and either an Android phone with USB debugging enabled or
an Android emulator.

```bash
cd orbit_dash
flutter pub get        # download dependencies
flutter run            # run on the connected device/emulator
```

That's it. The game works **fully offline** — with no internet you simply
see no ads. All ads currently use **Google's official test IDs**, so you
will see ads labeled "Test Ad". That is correct and safe; never click real
ads in your own app.

Useful checks:

```bash
flutter analyze        # static analysis — should report no issues
flutter test           # runs the included smoke tests
```

**What to test manually:** tap to reverse, die on purpose, watch the
"Continue" rewarded test ad, check that an interstitial appears after
every 3rd game over, toggle sound, kill the app and confirm the high
score survived.

---

## 2. Set up AdMob and add your real ad IDs

The app ships with Google's **test** ad IDs. You must replace them with
your own before releasing, otherwise you earn nothing.

**Step 1 — create the account.** Go to <https://admob.google.com>, sign in
with your Google account and complete the sign-up (country, payment info).

**Step 2 — add the app.** In AdMob: **Apps → Add app → Android**. Say
"No, it's not listed on Google Play yet" (you can link it after
publishing). Name it "Orbit Dash". You get an **App ID** that looks like
`ca-app-pub-1234567890123456~1234567890` (note the `~`).

**Step 3 — create three ad units.** In your new app: **Ad units → Add ad
unit**, and create one of each:

| Ad unit type | Suggested name | Used for |
|---|---|---|
| Banner | `orbit_banner` | bottom of menu + game-over screen |
| Interstitial | `orbit_interstitial` | after every 3rd game over |
| Rewarded | `orbit_rewarded` | continue-after-death + 2× score |

Each gives you an ID like `ca-app-pub-…/…` (note the `/`).

**Step 4 — paste the IDs into the code.** Only **two files** ever contain
ad IDs:

- `lib/config/ad_config.dart` — replace the three ad-unit IDs (each has a
  `TODO(you)` comment above it).
- `android/app/src/main/AndroidManifest.xml` — replace the **App ID** in
  the `com.google.android.gms.ads.APPLICATION_ID` meta-data tag.
  ⚠️ If this one is wrong or missing, the app **crashes on launch**.

**Step 5 — set up the GDPR consent message.** In AdMob go to **Privacy &
messaging → European regulations**, create a GDPR message and publish it
for this app. The app already contains the Google UMP consent code — with
no published message, users in Europe see no ads.

> New AdMob accounts and new ad units often serve nothing (or very little)
> for a few hours up to a couple of days. That's normal.

---

## 3. Host your privacy policy

Google Play **requires** a public privacy policy URL for any app that
shows ads.

1. Open `PRIVACY_POLICY.md` and fill in the two placeholders: your
   name/company and a contact email.
2. Host it anywhere public, for free. Easiest option — **GitHub Pages**:
   push this repo to GitHub, go to repo **Settings → Pages**, enable Pages
   for the main branch, and your policy will be reachable at
   `https://<your-username>.github.io/<repo>/orbit_dash/PRIVACY_POLICY`.
   (Alternatives: Google Sites, Notion public page, any static host.)
3. Paste that URL in **two places** in the Play Console:
   - **App content → Privacy policy**
   - and keep it in your store listing if asked.

---

## 4. Create your signing key

Android apps must be signed. You create one keystore file, once, and use
it for every update **forever** — so back it up.

**Step 1 — generate the keystore** (the `keytool` command comes with Java,
which the Flutter/Android toolchain already installed):

```bash
keytool -genkey -v -keystore ~/orbit-dash-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias orbitdash
```

It asks for a password and your name — remember the password!

**Step 2 — tell Gradle about it.** Create the file
`android/key.properties` (this exact path) with:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=orbitdash
storeFile=/home/you/orbit-dash-release.jks
```

That's all — `android/app/build.gradle.kts` already reads this file and
signs release builds with it automatically. If the file is missing, debug
signing is used so development still works.

**Security notes (important):**

- `key.properties` and `*.jks` are already in `.gitignore` — never commit
  them.
- **Back up the keystore file and passwords** (password manager + offline
  copy). If you lose it, you can never update the app again.
- In the Play Console, accept **Play App Signing** when offered (default) —
  Google then keeps the final signing key and your keystore becomes the
  "upload key", which can be reset if lost.

---

## 5. Build the release file for Google Play

Google Play wants an **.aab** (Android App Bundle), not an APK:

```bash
cd orbit_dash
flutter build appbundle --release
```

The file appears at:

```
build/app/outputs/bundle/release/app-release.aab
```

Upload that file in the Play Console. Release builds have code shrinking
enabled and the download size stays small (well under 30 MB).

For quick on-device testing of the release build you can also do
`flutter build apk --release` and install
`build/app/outputs/flutter-apk/app-release.apk` directly.

**Every new upload** to Play must have a higher build number: bump the
`+N` part of `version:` in `pubspec.yaml` (e.g. `1.0.0+1` → `1.0.1+2`).

---

## 6. Create the Play Console listing

1. Register at <https://play.google.com/console> (one-time $25 fee).
2. **Create app** → name "Orbit Dash", App, Free, English (or your default).
3. Work through the **App content** checklist:
   - **Privacy policy:** paste your hosted URL (section 3).
   - **Ads:** Yes, the app contains ads.
   - **Content rating questionnaire:** category *Game*. Answer **No** to
     everything (no violence, sexuality, gambling, drugs, user
     interaction, data sharing). Result: **Everyone / PEGI 3**. There is
     nothing in this game that rates higher.
   - **Target audience:** select **13+** (do NOT tick the younger age
     groups — targeting children triggers Google's Families policy, which
     restricts ads heavily and requires extra review).
   - **Data safety:** see [section 8](#8-data-safety-form--exactly-what-to-declare).
4. **Store listing** — copy-paste the ready-made texts below.
5. Create a **Production release** (or start with *Internal testing* —
   recommended: you get the app reviewed and installable within hours),
   upload `app-release.aab`, add release notes ("First release"), roll out.

### Ready-made store listing text (ASO-optimized)

**App name** (30 chars max):

```
Orbit Dash: One Tap Arcade
```

**Short description** (80 chars max):

```
One tap hypercasual reflex game. Dodge, orbit, survive. How long can you last?
```

**Full description** (paste as-is):

```
Orbit Dash is a one tap game that takes 2 seconds to learn and a lifetime
to master. The perfect hypercasual arcade experience: instant action,
short rounds, pure reflex gameplay.

HOW TO PLAY
🪐 Your ball orbits around the core
👆 Tap anywhere to reverse direction
💥 Dodge the neon arcs — one hit and it's over
⭐ Collect golden orbs for +5 bonus points
⏱️ Survive as long as you can — speed keeps increasing!

WHY YOU'LL LOVE IT
• One tap controls — play with one hand, anywhere
• Fast rounds — a perfect quick game on the bus, in a queue, in a break
• Endless arcade action — no levels, no waiting, just play
• A true reflex game — pure skill, no pay-to-win
• Beat your high score and challenge your friends
• Stunning minimal neon design, silky-smooth 60 FPS
• Tiny download, works offline
• Family friendly — rated for everyone

Orbit Dash is made for fans of hypercasual games, one tap games, reflex
tests and classic arcade challenges. Easy to learn, brutally hard to
master: the orbit gets faster, the obstacles get meaner, and "just one
more run" gets very real.

Can you beat 100 points? Download free and find out. 🚀
```

*(Keywords covered: one tap game, hypercasual, arcade, reflex game — in
the title, short description and repeatedly in natural sentences in the
full description, which is exactly what Play Store ASO rewards.)*

---

## 7. Screenshots & graphics you need

Google Play requires these assets for the listing:

| Asset | Spec | Notes |
|---|---|---|
| App icon | 512 × 512 px, PNG, ≤ 1 MB | Suggestion: neon cyan ball + pink arc on dark navy — match the game's palette |
| Feature graphic | 1024 × 500 px, PNG/JPG | Game title + a scene from the game; shown at the top of the listing |
| Phone screenshots | 2–8 images, min 320 px, max 3840 px, 16:9 or 9:16 | Just play the game and screenshot: menu, mid-run, near-miss, game over |

Tips:

- Take screenshots on a real phone (`Power + Volume-down`) or emulator.
  The dark neon style looks great without any editing.
- Good set of 4: ① gameplay with obstacles close to the ball, ② main
  menu with the logo, ③ "NEW BEST" game-over screen, ④ gameplay with
  several arcs at high speed. Add short captions ("ONE TAP", "DODGE",
  "BEAT YOUR BEST") with any free tool (Figma/Canva) if you want extra polish.
- The launcher icon currently used by the app is Flutter's default. Replace
  it before release: generate icons from your 512×512 art with the
  [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
  package (5-minute job — add the package, point it at your PNG, run it).

---

## 8. Data safety form — exactly what to declare

In Play Console → **App content → Data safety**, answer like this. This
matches what the AdMob SDK actually collects (the app itself collects
nothing — high scores stay on the device).

- **Does your app collect or share any of the required user data types?** → **Yes**
- **Is all of the user data collected by your app encrypted in transit?** → **Yes**
- **Do you provide a way for users to request that their data is deleted?** →
  Select the option indicating data deletion isn't user-requestable /
  point to Google's advertising controls (data is held by Google, not you;
  users can reset their Advertising ID any time).

Declare these data types, all with the same answers —
*Collected: Yes · Shared: No (collected by the ads SDK for your app) ·
Processed ephemerally: No · Required: Yes · Purpose: Advertising or
marketing*:

| Category | Data type |
|---|---|
| Device or other IDs | **Device or other IDs** (this is the Advertising ID) |
| App activity | **App interactions** (ad views/clicks) |
| App info and performance | **Diagnostics** |
| Location | **Approximate location** (AdMob derives coarse location from IP) |

That is the standard declaration set for "app with Google AdMob and
nothing else". Google publishes the authoritative list at
<https://support.google.com/admob/answer/10787303> — check it once before
submitting in case the SDK's disclosure has been updated.

Also in **App content → Ads**: declare **Yes, my app contains ads**.

---

## 9. Project structure

```
orbit_dash/
├── lib/
│   ├── main.dart                    # app entry, theme, orientation lock
│   ├── config/
│   │   ├── ad_config.dart           # ⭐ ALL AdMob IDs + ad policy knobs
│   │   └── game_config.dart         # every gameplay tuning value + palette
│   ├── game/
│   │   ├── orbit_dash_game.dart     # core loop: state, spawning, collisions,
│   │   │                            #   difficulty curve, screen shake, particles
│   │   └── components/              # ball, obstacle arcs, orbs, ring, core, bg
│   ├── services/
│   │   ├── ad_service.dart          # load/show/preload/retry for all ad types
│   │   ├── consent_service.dart     # Google UMP (GDPR) consent flow
│   │   ├── storage_service.dart     # high score & settings (shared_preferences)
│   │   └── audio_service.dart       # sound effects (flame_audio), never throws
│   └── ui/
│       ├── screens/                 # main menu, game screen
│       ├── overlays/                # ready / HUD / game-over overlays
│       └── widgets/                 # neon button, self-contained banner slot
├── assets/audio/                    # generated placeholder SFX (see tool/)
├── tool/generate_sounds.py          # regenerates the placeholder SFX
├── android/                         # manifest (AdMob App ID), signing config
├── PRIVACY_POLICY.md                # fill in 2 placeholders and host it
└── README.md                        # this file
```

Architecture rule of thumb: **game logic** (`game/`) never talks to ads or
storage directly except through the small **services** layer, and **UI**
(`ui/`) is plain Flutter that sits on top of the Flame game as overlays.

---

## 10. How the ads behave

Implemented to be both **policy-safe** and **retention-friendly**:

| Ad | Where | Rules |
|---|---|---|
| Banner | Main menu + game-over screen | **Never during gameplay.** Fixed-height slot, so the layout never jumps; collapses silently if it fails to load |
| Interstitial | After every **3rd** game over, when tapping Retry/Home | Preloaded in advance; frequency lives in `AdConfig.interstitialFrequency` |
| Rewarded #1 | "CONTINUE" on the game-over screen | Once per run, 5-second offer window, only shown if an ad is actually preloaded |
| Rewarded #2 | "2× SCORE" on the game-over screen | Once per game over; doubles the final score and updates the best score |

Reliability guarantees baked into `AdService`:

- The SDK initializes **after** the UMP consent flow, off the critical
  startup path — the menu appears instantly even with no network.
- Every ad call is wrapped in try/catch; failures are logged and skipped.
- Failed loads retry with exponential backoff (2s → 4s → 8s), then wait
  for the next natural reload.
- **Offline = zero ads, fully playable game.** No spinners, no blocking.

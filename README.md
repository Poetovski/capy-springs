# Capy Springs 🛁

A cozy idle clicker with a story, made in **Godot 4** with **GDScript**.
Capy the capybara sits in a frozen hot spring and warms the valley back to life with zen. Friends come back, the snow melts, and the story unfolds over three books and 24 chapters.

**▶ Play in the browser:** https://poetiha.itch.io/capy-springs

| Start | Night by the spring | Book Three | Upgrades | Achievements |
|---|---|---|---|---|
| ![Start](docs/screenshots/start.png) | ![Main](docs/screenshots/main.png) | ![Book Three](docs/screenshots/summer.png) | ![Upgrades](docs/screenshots/upgrades.png) | ![Awards](docs/screenshots/awards.png) |

## Features

- **Tap and idle economy:** 24 friends give passive income. Prices grow by ×1.15 per purchase, with buy ×1 / ×10 / MAX. Each kind of friend has a limited number of places in the spring, and the limit grows with every chapter.
- **Upgrades:** tiered upgrades for every friend, global "all friends" boosts and tap upgrades.
- **Story:** three books with 24 chapters. Every friend has their own lines, and Capy has 100+ thoughts that react to the chapter and to the friends nearby.
- **A place for every chapter:** the scenery is built in code from layered SVG parts (sky, mountains, hills, trees, lanterns, sun and moon) with its own weather: snow, petals, falling leaves, fireflies.
- **Prestige ("Great Nap"):** reset for golden mandarins that give a permanent bonus.
- **38 achievements** that each give a permanent +2% bonus.
- **Golden mandarin events** with random rewards.
- **Friends appear in the hot spring** next to Capy as you buy them, with a small bobbing animation.
- **Settings:** music and sound volume, language (Russian / English), progress reset.
- **Offline progress:** friends keep earning at a reduced rate for up to 8 hours.
- **Builds:** Web (HTML5) and Windows. The game is designed for portrait mobile (720×1280), with an Android release planned.

## Technical highlights

- **UI built entirely in code** with no hand-placed scenes, so the layout adapts to any screen size. It is split into small modules: scenery, the Capy stage, pop-ups, audio and one file per tab.
- **Clean split** between data (`data.gd`), game logic and saves (`game.gd`, autoload) and presentation (`main.gd`).
- **Safe saves:** JSON with a versioned format, atomic writes (`.tmp` file, then rename) and a `.bak` backup.
- **Balance tuned with simulation scripts** that model casual and active players; a second script derives chapter thresholds from a target play-time schedule.
- **159 automated headless checks** covering saves, UI, story progression, the economy and the friend limit.
- **Procedurally generated background music** written as a Godot script.
- **Web touch-input fix** that prevents doubled taps from emulated mouse events.

## Project structure

```
scripts/
  data.gd          # numbers: friends, upgrades, achievements, UI strings
  data/story.gd    # chapters, friend lines, Capy thoughts
  game.gd          # economy, saves, prestige, achievements (autoload "Game")
  main.gd          # main screen: puts the modules together, input
  ui/backdrop.gd   # scenery and weather for each chapter
  ui/capy_stage.gd # Capy, friends in the spring, thoughts, golden mandarin
  ui/popups.gd     # story pop-ups and settings
  ui/audio.gd      # music and sounds
  ui/tabs/*.gd     # one file per tab
assets/      # graphics (SVG/PNG), sounds, music, font
docs/        # screenshots and design notes (in Russian)
```

## Run locally

1. Install [Godot 4](https://godotengine.org/download) (the project uses 4.7).
2. In Godot, choose **Import**, select `project.godot`, then click **Import & Edit**.
3. Press **F5** to play.

## Credits and licenses

- **Code, story, capybara art, sounds and music:** made for this project.
- **Animal sprites:** [Kenney](https://kenney.nl/assets), Animal Pack Remastered, CC0. See `assets/friends/KENNEY_LICENSE.txt`.
- **Font:** [Nunito](https://fonts.google.com/specimen/Nunito), SIL Open Font License 1.1. See `assets/fonts/NUNITO_OFL.txt`.

© 2026 poetiha. The code is published for viewing; all rights reserved.

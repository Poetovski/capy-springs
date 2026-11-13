# Changelog

## 1.2 — "Summer and Autumn"

### New look
- Capy and all 24 friends are redrawn in one flat cartoon style with soft shading and a thick rounded outline.
- Capy has two faces: sleepy, and happy with open eyes for a moment when you tap.
- Every chapter now has its own scenery and weather:
  - snowy pines and a bamboo grove;
  - cherry blossoms and a moonlit night with fireflies;
  - sunflowers and a sunset over the lake;
  - maple forests and a mandarin orchard.
- When a new chapter opens, the old scenery fades into the new one.

### Story
- **Book Three, "Summer and Autumn":** 8 new chapters, 24 in total.
- A summer that won't end, a Summer who is afraid to stop, and her shy brother Autumn.
- **6 new friends:** red panda, otter, koi, crane, turtle and fox. Each has a greeting and three friendship lines.

### Capy talks more
- About 140 thoughts instead of 24:
  - cozy thoughts;
  - 40 short meme phrases with no rude words;
  - thoughts about the friends who are in the spring right now;
  - lines about chapter events and callbacks to Capy's own earlier thoughts.
- The thought bubble stays for 8–14 seconds depending on length. The same thought doesn't come back too soon.

### Online leaderboard
- The trophy button opens the top 50 players by taps.
- To join, sign up in the game. A code is sent to your email, which keeps bots out.
- Your score updates once a minute and when you close the game.
- A score is not sent if taps grew faster than a human can tap.

### Gameplay and balance
- **Friend limit:** each kind of friend has a limited number of places in the spring. It starts at 50 and grows by 25 with every chapter, up to 400.
- **Right click:** the right mouse button taps Capy too.
- **Great Nap:** it now gives fewer golden mandarins (4th root instead of cube root).
- **Pacing:** chapters 9–24 were rebalanced with a simulation. With active play, Book One takes about 7 h, Book Two about 34 h and Book Three about 90 h.
- **Rewards:** 8 new achievements (38 in total) and 4 new "all friends +20%" upgrades.

### Under the hood
- `main.gd` (about 1500 lines) is split into small modules: scenery, the Capy stage, pop-ups, audio, the leaderboard and one file per tab.
- Story text moved to `scripts/data/story.gd`.
- New test suites cover the friend limit, Book Three, Capy's thoughts, scenery and the leaderboard.

## 1.1 — "Cozy Company"

- Friends you invite appear in a shared hot spring next to Capy, each bobbing in the water.
- New Capy model with a happy face when tapped.
- Relaxing lo-fi background music and a settings menu (music and sound volume, language, reset).
- The **Awards** tab: 30 achievements, each giving +2% to all zen forever.
- **Balance:**
  - friends give 2× zen;
  - golden mandarins appear more often;
  - more upgrade tiers and "all friends" upgrades;
  - offline earnings are slower than active play.
- A progress bar to the next chapter.

## 1.0

- First release: tap Capy, invite 18 friends, upgrades, golden mandarins, the Great Nap prestige and two books of story in Russian and English.

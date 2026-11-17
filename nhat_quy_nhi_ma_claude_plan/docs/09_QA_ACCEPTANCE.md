# 09 — Definition of Done / Acceptance Gates

## Gate A — visuals
- [ ] Angle clearly **from desk on side**, not top-down or from behind.
- [ ] Main character's face/hands and teacher visible simultaneously.
- [ ] Frame reads as Vietnamese classroom without labels explaining it.
- [ ] Foreground desk doesn't eclipse gameplay; HUD usable on phone landscape.

## Gate B — mechanics
- [ ] Holding/releasing skill changes actual state, progress and risk.
- [ ] Teacher head orientation and detection match each other.
- [ ] Self-write exists as low-risk option.
- [ ] Timer pauses; input cancellation prevents stuck action.
- [ ] Wins/loses trigger once and give correct stars.

## Gate C — content
- [ ] 12 skills usable or explicitly disabled according to level config; no fake button.
- [ ] 5 playable levels with distinct hazards, teacher speed and timing.
- [ ] All 5 events trigger, telegraph and resolve.
- [ ] Vietnamese labels/proper encoding, no placeholder lorem ipsum in shipping UI.

## Gate D — persistence/UI
- [ ] Level unlock and best stars persist across restart.
- [ ] Menu, pause, retry, level select and settings all connected.
- [ ] Mute/volume persisted; empty assets don't crash.

## Gate E — quality
- [ ] `dart format`, `flutter analyze`, `flutter test` pass or logged blockers.
- [ ] APK debug built and opened on device/emulator or clearly marked not verified.
- [ ] Known limitations and screenshot evidence recorded.
- [ ] `docs/PROGRESS.md` reflects actual state; no unchecked task called complete.

**Phase gate:** Do not claim MVP complete until every gate is checked and verifiable. For any failure write a fix task referencing owning phase and rerun affected tests.

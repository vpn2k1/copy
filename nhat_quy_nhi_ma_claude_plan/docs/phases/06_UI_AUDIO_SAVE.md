# Phase 06 — UI, Feedback, Audio and Offline Save

## Steps
1. Finish menu, level select, settings, pause, win/lose UI with Vietnamese labels.
2. HUD with exam progress, timer, suspicion, cooldown, teacher attention; anchored outside face/hand region.
3. Create touch-friendly controls for cheat-hold, write, hide, skill-select. Finger pointer cancel and app lifecycle safety.
4. Add accessible audio cues with fallback no-op when file absent; toggle mute/volume.
5. Implement versioned `SaveRepository`, save only on relevant transitions, handle damaged JSON and restart; best stars never regress.
6. Widget tests navigation, pause, resume, save reload and phone viewport layout.

## Done when
- [ ] End-to-end player journey through 5 levels requires no debug screen.
- [ ] Progress persists after app restart, no invisible hotzones / unresponsive buttons.
- [ ] HUD does not cover player/teacher on landscape device.

# Phase 03 — Functional Loop / Teacher AI / Win-Lose

## Steps
1. Implement pure `GameState`, `GameController`, commands and `TeacherFsm` per architecture and contracts.
2. Add tick(dt), seeded randomness, bounded dt, timer, safe-writing, cheat-hold and hide action. Add pointer release/cancel via shell.
3. Implement teacher states, attention cues and SIDE-VIEW line-of-sight mapping; occlusion if modeled must match visible image.
4. Implement suspicion gain/decay, progress, timeout, caught and win precedence.
5. Bind model -> animated Flame view -> Flutter debug HUD; button triggers actual domain actions.
6. Unit tests for 3 end conditions, risk, pause, deterministic AI and visibility states.

## Done when
- [ ] A complete test loop from start to win/lose/retry functions.
- [ ] Teacher physically turns and game detector agrees.
- [ ] Holding / releasing input changes outcomes; pause freezes state.
- [ ] No frame rate dependent speed.

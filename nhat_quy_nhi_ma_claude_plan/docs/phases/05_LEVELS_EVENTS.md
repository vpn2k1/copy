# Phase 05 — Five Playable Levels / Events

## Steps
1. Implement `LevelConfig` with exactly five configs per levels document; use data table for allowed skills and unique event.
2. Level manager handles start/reset, duration, teacher count/speeds, seed, progression; no duplicated game code per level.
3. Add event scheduler and implement teacher_question, fan_wind, wrong_exam_code, teacher_swap and final_boss_mode; each telegraphed and resolved.
4. Add result star calculation, next level, locked levels, replay.
5. Add tests for every level/event, boundaries, boss last-20s, two teachers independent attention; seeded smoke simulations.

## Done when
- [ ] 5 playable levels; all 5 events fire and finish.
- [ ] Each level has distinct hazards and meaningful escalation.
- [ ] Win unlocks next; fail preserves previous progress.

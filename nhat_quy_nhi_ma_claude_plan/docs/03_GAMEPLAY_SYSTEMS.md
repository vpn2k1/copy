# 03 — Rules, AI, Interaction

## State (runtime)
`GameStatus { ready, running, paused, won, lostCaught, lostTime }`; `progress: double 0..100`; `suspicion: double 0..100`; `remainingSeconds: double`; `selectedSkillId`; `isHoldingAction`; `teacherSnapshots`; `cooldowns`; `eventState`; `seed`.

## Player actions
- `WRITE`: safe baseline `+0.50 progress/sec`, no skill cost.
- `CHEAT_HOLD`: gains `skill.progressPerSecond`; only if selected, ready, available; risk proportional to visibility and skill risk multiplier.
- `PRETEND/HIDE`: stop cheating, recover suspicion (`-10/sec` when unseen, `-4/sec` when seen), may trigger funny animation; no instant risk reset.
- Press/release must be paired; pointer cancel, app pause and screen exit always release.

## Detection model for 2D side view
Teacher perception is **not geometric top-down cone**. Represent in classroom staged 2D space: teacher `lane`, x-position, facing direction, attention target and occlusion flags. A player may be visible if: teacher is in watching state, facing player's x sector, has line-of-sight on player torso/hand, isn't occluded by a legitimate scene layer, and player is doing suspicious action. Show attention cue via head turn/eyes/exclamation; if rendering a cone, use stylized soft overlay matched to side projection.

## Teacher FSM
`idle -> patrol -> lookLeft/lookRight -> lookAway -> suspicious -> approach -> inspect -> caught` and valid returns. Configure dwell time intervals and seeded selection. Avoid instant detection with finite accumulation; suspicion changes every tick. Boss may fake lookAway but must telegraph tell (eyes/footstep) for fairness.

## Formula baseline
- `gain = (holding ? selectedSkill.progressPerSecond : writeRate) * dt`.
- `risk = visibleCheating ? level.suspicionPerSecond * skill.riskMultiplier * dt : passiveRisk * dt`; passive decay when not cheating; clamp 0..100.
- `cooldownRemaining = max(0, current-dt)`.
- Teacher approach and inspect may add extra risk **only once per event**; guard double counting.

## Balance constraints
Each level must have at least one viable path: safe writing alone may be slow, skills increase rate but increase risk; avoid guaranteed win with a single held button throughout. Allow >1 second warning before teacher switches from lookAway to hard inspect in easy level. Test with deterministic input script.

## Game over precedence
At tick boundary: suspicion>=100 -> caught; else remaining<=0 -> time out; else progress>=100 -> won. Clamp values. Trigger final event once and disable input.

## Difficulty knobs
- teacherSpeed = patrol speed multiplier, not both animation and AI timer unless intentional.
- `suspicionPerSecond` from level config; number of observers from teacherCount.
- event probabilities from seed; cooldowns/abilities configurable.

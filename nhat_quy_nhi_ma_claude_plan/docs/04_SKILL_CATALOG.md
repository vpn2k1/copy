# 04 — 12 Skills (fictional, game-balanced)

Data-driven: id, name, category, duration/hold, gainRate, riskMultiplier, cooldownSeconds, animationKey, soundKey, unlockLevel, effectType, failureEvent. Values below are **starting balance targets**, tune in QA. Percent rates are percent of total assignment per second of active use.

| ID | Tên | Cách kích hoạt | Gain/s | Risk x | CD(s) | Unlock |
|---|---|---|---:|---:|---:|---:|
| peek | Liếc bài bạn | hold | 2.2 | 0.65 | 2 | 1 |
| pretend | Diễn sâu | tap 1.5s | 0 | -0.18 recovery | 5 | 1 |
| cheat_sheet | Phao giấy | hold | 3.8 | 1.15 | 7 | 2 |
| pencil_case | Hộp bút bí ẩn | tap mini-event | +8 instant | 1.3 | 12 | 2 |
| pass_note | Chuyền giấy | timed tap | +12 instant | 1.6 | 15 | 3 |
| ask_friend | Đồng đội cứu viện | tap w/ friend-ready | +7 instant | 1.0 | 10 | 3 |
| eraser | Tẩy tiên tri | tap RNG | +0/+5/+10 | 0.9 | 13 | 4 |
| hide_note | Giấu phao | tap defense | 0 | -0.2 recovery | 6 | 4 |
| ruler | Thước thần | hold | 3.0 | 1.0 | 8 | 5 |
| calculator | Máy tính thần kỳ | short puzzle | +11 instant | 1.2 | 14 | 5 |
| signal | Tín hiệu mật | timed choice | +10 instant | 1.35 | 11 | 5 |
| oscar | Oscar học đường | timing defense | 0 | -0.30 recovery | 16 | 5 |

**Implementation detail:** Negative risk values signify recovery effects, NOT multiplication directly; model `effectType = recoverSuspicion` with nonnegative recovery rate. Never mix instant gain and per-second gain silently; model typed discriminated effect. All randomness injected and deterministic in tests.

## Skill UX
Selected button highlights icon/name/cooldown. Press begins action if ready; press too soon shows cooldown; release ends hold without triggering unintended taps. Interrupt on teacher catches, pause, game end. Wrong puzzle answers must provide feedback without trapping player.

## Funny failure mapping
`peek` → friend covers paper; `cheat_sheet` → paper slips; `pencil_case` → wrong compartment; `pass_note` → paper flies; `ask_friend` → friend refuses; `eraser` → wrong answer; `ruler` → ruler falls; `calculator` → error sound; `signal` → misread; `oscar` → overacting. Failures are stylized game events, not real-world instructions.

## Tests per skill
Validate unlock condition, cooldown, effect/invalid state, input cancellation, max clamp, animation resolves, seeded RNG, end-of-game stops. At least a table-driven unit test for 12 rows.

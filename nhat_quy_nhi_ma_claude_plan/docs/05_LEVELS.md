# 05 — Five Levels / Events / Stars

**Times are gameplay seconds, not actual class exam minutes.** `teacherSpeed` is multiplier. Each level uses same Vietnamese classroom, with modest decorative variants.

| ID | Title | Time | Teachers | Speed | Suspicion/s visible (before skill multiplier) | Skills | Unique event |
|---|---|---:|---:|---:|---:|---|---|
| 1 | Bài Kiểm Tra Bất Ổn | 90 | 1 | 0.6 | 20 | peek, pretend | teacher_question |
| 2 | Sát Thủ Môn Toán | 80 | 1 | 0.9 | 27 | +cheat_sheet, pencil_case | fan_wind |
| 3 | Đồng Đội Phản Chủ | 75 | 1 | 1.0 | 32 | +pass_note, ask_friend | wrong_exam_code |
| 4 | Song Sát Giám Thị | 70 | 2 | 1.2 | 38 | +eraser, hide_note | teacher_swap |
| 5 | Huyền Thoại Mắt Thần | 65 | 1 | 1.5 | 45 | +ruler, calculator, signal, oscar | final_boss_mode |

## Level details
1. **Tutorial**: first 10s guided prompts, no harsh catch during first action; teacher asks "Làm được mấy câu rồi?" once, player can tap acknowledge; teach safe write vs risky peek.
2. **Fan wind**: one announced event (fan wobble SFX + visual), extra chance for paper to fall; player has quick dismiss response, no unfair auto-lose.
3. **Wrong exam code**: ally may return incorrect hint; UI shows discrepancy and offers retry/self-write. Do not silently subtract earned progress.
4. **Teacher swap**: two teachers exchange stations after a warning, distinct glance markers, inspect if combined coverage remains high.
5. **Final boss**: last 20s transitions to faster observation pattern, visible warning and audio cue, still includes nonzero safe windows.

## Event scheduling
One or two deterministic timed events per run, plus bounded seeded random flavor events. Every event defines `id`, `trigger`, `duration`, `isBlocking`, `cooldown`, `effect`, `visualCue`, `audioCue`. Prevent repeats unless explicit.

## Unlock
Level 1 available; beating level N unlocks N+1, maximum 5. Persist best star count only if improved; replay never locks content. Unlock skills via level availability, not randomized loot.

## Stars
Win = 1; +1 if end suspicion<=40; +1 if end suspicion<=20 and time remaining>=30. No stars on failure. Tests for 0/1/2/3 and boundaries.

## Tuning test
For each level simulate at least: no-action fail, writing-only baseline, carefully timed skills success, reckless hold punished, quick pause/resume stable, deterministic seeded replay. Confirm user can beat levels with reasonable inputs; avoid mandatory perfectly timed 0.1s actions.

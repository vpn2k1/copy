# Phase 04 — Data-Driven 12 Skills

## Steps
1. Implement `SkillConfig` with typed effects and `skills.dart` from catalog.
2. Skill controller: selection, unlock checks, cooldowns, hold/tap action, progress/recovery, mini-events and RNG.
3. Connect player poses and teacher response/funny failures to every skill. Provide visible honest feedback if not ready.
4. Add quick-access skill bar / drawer, and ensure cancel/release on pause and navigation.
5. Implement table-driven tests: all 12 IDs unique, every skill triggers or is gated, cooldown and gain/risk bounded.

## Done when
- [ ] No decorative inert skills in available list.
- [ ] Every skill has legitimate gameplay effect and feedback, including timed choices in minimal form.
- [ ] All 12 pass data validation tests, UI consistent.

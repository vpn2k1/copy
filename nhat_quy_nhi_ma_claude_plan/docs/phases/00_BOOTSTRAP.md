# Phase 00 — Flutter/Flame Bootstrap

**Prerequisite:** repository inspection, product/architecture docs read. **Deliverable:** runnable shell and test scaffold; no pretend gameplay.

## Steps
1. Inspect repo; if missing initialize Flutter project safely (`flutter create .` only after checking target), select compatible stable Flame and persistence dependencies, record versions.
2. Organize directories from architecture and `pubspec.yaml` asset declarations; do not reference nonexistent mandatory files.
3. Implement `main`, app theme, landscape orientation via `SystemChrome.setPreferredOrientations`, lifecycle handling, root menu with Play and Settings placeholder that really navigates.
4. Add initial `ExamGame` with background layer and fixed logical 1600x900 layout; avoid cropping.
5. Add `test` smoke test for app navigation and landscape configuration where testable.

## Done when
- [ ] App boots (not just compiles), no missing asset crashes.
- [ ] Menu can start empty placeholder game and return.
- [ ] format/analyze/tests results logged.
- [ ] `docs/PROGRESS.md` updated.

**Do not:** build all skills/levels in bootstrap.

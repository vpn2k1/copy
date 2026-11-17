# Instructions for Claude Code — Nhất Quỷ Nhì Ma

You are implementing the project defined in `docs/`. **Treat the docs as product requirements**, not as proof that code exists.

## Required workflow
1. Read `docs/README` if present, otherwise root README; then read product, camera, architecture, contracts, and current phase.
2. Before edits: inspect project tree and package versions. Preserve existing working files where compatible. Summarize 3–7 concrete edits, then execute.
3. Implement **only the requested phase**, plus minimal fixes necessary for compilation; do not pre-implement future phases.
4. After each phase run `dart format .`, `flutter analyze`, `flutter test` where Flutter SDK is available; if unavailable, say so and provide exact commands, never invent successful results.
5. Add/update tests for new game logic. Capture screenshots or widget/golden tests when feasible.
6. Update `docs/PROGRESS.md`: changed files, decisions, commands and actual outcomes, known bugs, next phase. Do not mark unchecked criteria as passed.
7. Ask for approval before changing core camera style, removing planned skills/levels, or introducing online services/payment.

## Non-negotiable visual requirement
2D side/three-quarter viewpoint at **the neighboring desk to the LEFT or RIGHT**, as if a classmate sitting next to the player looks sideways across the classroom. **NOT top-down. NOT over-the-shoulder from behind.** Main cheating student's face and hands visible; teacher within the frame; broad view of Vietnamese classroom. Read `docs/01_VISUAL_CAMERA.md` and its rejection checklist before rendering.

## Engineering rules
- Flutter UI shell + Flame game layer; Dart sound null safety. Pin compatible stable dependencies chosen after inspection; don't hallucinate versions.
- Fixed logical world e.g. 1600x900, viewport adapt via letterboxing/contain. Respect safe areas and different Android display ratios.
- Delta-time updates, deterministic seeded Random for tests, no Timer.periodic game-loop. Pause freezes simulation.
- Stable IDs for skills/levels; structured local persistence with versioned save and migration fallback.
- Avoid TODO placeholders in any feature required by the current phase. Use actual minimal sprites/vector placeholders if assets absent.
- Separate presentation, domain simulation and persistence. Single source of truth for game state.
- All explanations, UI labels, test cases and comments may be Vietnamese; code identifiers in English.

## Completion response format
State what was completed, changed paths, actual test commands/results, how to verify visually, remaining limitations, and next phase. Never claim implemented without files.

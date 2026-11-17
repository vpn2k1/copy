# 10 — Copy/Paste Commands for Claude Code

## Kickoff (send once)
> Read `CLAUDE.md`, `docs/00_PRODUCT_SPEC.md`, `docs/01_VISUAL_CAMERA.md`, `docs/02_ARCHITECTURE.md`, `docs/07_DATA_CONTRACTS.md`, `docs/PROGRESS.md` and all phase file names. Inspect the existing repository. Summarize conflicts and the exact files you will change, but DO NOT write code yet. Verify the camera is from the side-neighboring desk, not behind and not top-down. Then identify the next incomplete phase. Do not implement multiple phases in one pass.

## Phase execution (repeat with n)
> Execute exactly `docs/phases/0N_PHASE_NAME.md` according to its steps and acceptance checklist. Inspect existing code before editing. Implement full working code for this phase, add tests, run format/analyze/test where possible, record actual results and changed paths in `docs/PROGRESS.md`. Stop after the phase, describe the new behavior and remaining blockers. Do not work on later phases unless strictly needed for compilation.

## Visual review request (after phase 01)
> Produce a screenshot or render at 1600x900 showing camera from the LEFT NEIGHBORING DESK (side-angle), player FACE and hands, teacher, desks, board and Vietnamese signage. Compare the result line-by-line with `docs/01_VISUAL_CAMERA.md`. If any rejection condition is true, fix it before phase 02. Do not switch to top-down or back-of-head camera.

## Fixing regressions
> Read `docs/PROGRESS.md`, identify red tests and review `docs/09_QA_ACCEPTANCE.md`. Fix only regressions introduced or blocking current phase. Run relevant tests and update actual evidence; do not mark other phases finished.

## Final audit
> Audit `docs/09_QA_ACCEPTANCE.md`, execute `docs/08_TESTING_PLAN.md` as environment permits, build Android APK, document real exit codes and blockers. Show traceability from every requirement to code/tests; create a short final handoff with commands to run and known limitations.

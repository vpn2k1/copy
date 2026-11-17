# 08 — Testing Strategy

## Unit tests (headless)
- Timer decrement respects dt and pause.
- Terminal precedence `caught > timeout > win`, one emitted result.
- `progress/suspicion` clamped to [0,100]; no NaN.
- AI valid transitions; seeded reproducibility; facing/visibility matrix; occluded vs visible.
- Every skill: unlock, cooldown, activation, release, recover, success/failure, no action after end.
- Level data: exactly five IDs 1..5; nonempty skills; valid event IDs; progression sequential.
- Stars thresholds boundaries; save migrate/corrupt fallback; volume clamp.

## Widget/golden tests
- Menu navigate -> level select -> start -> pause -> resume -> results.
- HUD labels in Vietnamese and value updates from controller; buttons respond to pointer down/up/cancel.
- At 16:9 and ~20:9 safe area: player/teacher not covered by HUD; left/right landscape rotate.
- Golden tests for one classroom frame, suspicion warning and end screen with stable fonts/settings.

## Manual smoke matrix
Android phone low resolution, Android phone high resolution, emulator if available, Chrome optionally. Test: cold boot; enter level; look turning; skill pressed 5s; leave finger outside button; background/resume; win; lose caught; lose time; retry 10x; restart app and unlock still saved.

## Commands
```
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```
Record actual command exit codes in progress, not just command list. If SDK unavailable, note `NOT RUN` with reason and test on developer machine.

## Performance
Measure FPS and memory during two-teacher phase and 10 rapid restarts. Target 60fps on typical midrange, acceptable consistent 30fps fallback; avoid per-frame asset loads, allocations and expensive repaint of static BG.

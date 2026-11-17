# 02 — Architecture

## Stack
Flutter (shell/UI), Flame (scene + update + components), Dart. Local persistence nhẹ (`shared_preferences` hoặc giải pháp tương đương). Chọn và khóa phiên bản dependency **sau khi tra cứu project SDK và kiểm tra tương thích**, không ép số phiên bản trong spec này.

## Layout đề xuất
```
lib/
  main.dart
  app/app.dart
  app/routes.dart
  game/exam_game.dart
  game/components/classroom_scene.dart
  game/components/player_component.dart
  game/components/teacher_component.dart
  game/components/student_npc_component.dart
  game/components/vision_indicator.dart
  game/controllers/game_controller.dart
  game/controllers/teacher_fsm.dart
  game/controllers/skill_controller.dart
  game/controllers/event_scheduler.dart
  game/models/game_state.dart
  game/models/level_config.dart
  game/models/skill_config.dart
  game/models/game_event.dart
  game/data/levels.dart
  game/data/skills.dart
  game/services/save_repository.dart
  ui/menu_screen.dart
  ui/level_select_screen.dart
  ui/game_screen.dart
  ui/widgets/game_hud.dart
  ui/widgets/hold_action_button.dart
  ui/result_screen.dart
  ui/settings_screen.dart
assets/images/...  assets/audio/...
test/game/... test/ui/...
```

## Dependency rules
- `GameController` owns authoritative `GameState`; Flame reads and dispatches actions; Flutter observes via ValueNotifier/ChangeNotifier or immutable snapshots (choose one consistent pattern).
- No `BuildContext` in domain logic; no direct Flame imports in pure rules/tests.
- Rendering reads state, does not change gameplay state.
- `TeacherFsm.update(dt, snapshot, random)` issues deterministic state changes; `SkillController` validates cooldowns and context.
- Game world coordinates separate from UI pixels; use logical world coordinates.

## Tick algorithm
1. If paused or ended: no simulation tick.
2. Clamp `dt` (e.g. max 0.05s) or use fixed timestep accumulation to avoid leaps after background.
3. Advance remaining time, teacher FSM, line-of-sight, player action, cooldowns, event scheduler.
4. Resolve detection/progress and terminal result once, using precedence in product spec.
5. Publish immutable state snapshot for HUD; render Flame components.

## Lifecycle
`inactive/paused`: stop held action, pause simulation; `resumed`: resume only after user explicitly taps Resume if a pause overlay is shown. Dispose listeners and input subscriptions on exit/restart.

## Coding constraints
Avoid circular imports, hardcoded config scattered in widgets, unbounded random globals, callbacks firing after disposed, asynchronous writes every frame. Persist only at end of level / settings changes. Test pure logic without graphics.

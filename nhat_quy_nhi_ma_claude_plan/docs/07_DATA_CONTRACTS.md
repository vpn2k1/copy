# 07 — Data and API Contracts (Dart oriented)

These contracts are targets; Claude should implement concrete immutable types and serialization rather than copying non-compiling pseudo-signatures.

```dart
enum GameStatus { ready, running, paused, won, lostCaught, lostTime }
enum TeacherMode { idle, patrol, lookLeft, lookRight, lookAway, suspicious, approach, inspect, caught }
enum SkillEffectKind { holdProgress, instantProgress, recoverSuspicion, randomProgress, minigame }

class LevelConfig {
  final int id;
  final String title;
  final int durationSeconds;
  final int teacherCount;
  final double teacherSpeed;
  final double suspicionPerSecond;
  final List<String> skillIds;
  final String specialEventId;
  // ctor, assertions, serializers or const data
}

class SkillConfig {
  final String id;
  final String displayName;
  final SkillEffectKind effectKind;
  final double value;
  final double riskMultiplier;
  final double cooldownSeconds;
  final int unlockLevel;
  final String animationKey;
}
```

## Events
Domain input union or typed command: `StartGame(levelId, seed)`, `ChooseSkill(skillId)`, `ActionPressed(action)`, `ActionReleased(action)`, `Pause`, `Resume`, `Restart`, `ReturnToMenu`. No UI code in state transition engine.

## Snapshot
`GameState` contains state + `playerPose` + teachers + skill cooldown map + active event + result. Expose immutable snapshot per tick. UI must never mutate progress directly.

## Save JSON version 1
```json
{
  "version": 1,
  "unlockedLevel": 1,
  "bestStars": {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0},
  "settings": {"musicVolume": 0.5, "sfxVolume": 0.8, "muted": false}
}
```
Missing/corrupt fields fall back safely; clamp unlocked 1–5, stars 0–3; forward-unknown version handled without deleting data silently.

## Test IDs
Use deterministic widget keys: `menu.play`, `level.1`, `hud.progress`, `hud.suspicion`, `hud.timer`, `action.cheat`, `action.write`, `action.hide`, `pause`, `result.retry`, `result.next`.

import 'level_config.dart';

/// Năm màn theo 05_LEVELS. Kỹ năng cộng dồn: màn sau có mọi kỹ năng của màn
/// trước cộng kỹ năng mới.
const allLevels = <LevelConfig>[
  levelOne,
  LevelConfig(
    id: 2,
    durationSeconds: 80,
    teacherCount: 1,
    teacherSpeed: 0.9,
    suspicionPerSecond: 27,
    skillIds: _level2Skills,
    specialEventId: 'fan_wind',
    watchWarningSeconds: 0.9,
  ),
  LevelConfig(
    id: 3,
    durationSeconds: 75,
    teacherCount: 1,
    teacherSpeed: 1.0,
    suspicionPerSecond: 32,
    skillIds: _level3Skills,
    specialEventId: 'wrong_exam_code',
    watchWarningSeconds: 0.8,
  ),
  LevelConfig(
    id: 4,
    durationSeconds: 70,
    teacherCount: 2,
    teacherSpeed: 1.2,
    suspicionPerSecond: 38,
    skillIds: _level4Skills,
    specialEventId: 'teacher_swap',
    watchWarningSeconds: 0.7,
  ),
  LevelConfig(
    id: 5,
    durationSeconds: 65,
    teacherCount: 1,
    teacherSpeed: 1.5,
    suspicionPerSecond: 45,
    skillIds: _level5Skills,
    specialEventId: 'final_boss_mode',
    watchWarningSeconds: 0.6,
  ),
];

const _level1Skills = ['peek', 'pretend'];
const _level2Skills = [..._level1Skills, 'cheat_sheet', 'pencil_case'];
const _level3Skills = [..._level2Skills, 'pass_note', 'ask_friend'];
const _level4Skills = [..._level3Skills, 'eraser', 'hide_note'];
const _level5Skills = [
  ..._level4Skills,
  'ruler',
  'calculator',
  'signal',
  'oscar',
];

/// Màn 1 "Bài Kiểm Tra Bất Ổn": có 10 giây hướng dẫn đầu ván.
const levelOne = LevelConfig(
  id: 1,
  durationSeconds: 90,
  teacherCount: 1,
  teacherSpeed: 0.6,
  suspicionPerSecond: 20,
  skillIds: _level1Skills,
  specialEventId: 'teacher_question',
  tutorialSeconds: 10,
);

const lastLevelId = 5;

/// Màn thử để review đủ 12 kỹ năng trên máy (`--dart-define=SKILL_SANDBOX=true`).
/// Không phải màn chơi thật và không có sự kiện.
const skillSandboxLevel = LevelConfig(
  id: 0,
  durationSeconds: 180,
  teacherCount: 1,
  teacherSpeed: 0.6,
  suspicionPerSecond: 20,
  skillIds: _level5Skills,
  specialEventId: 'none',
);

/// Tra màn theo id 1..5.
LevelConfig levelById(int id) {
  return allLevels.firstWhere(
    (level) => level.id == id,
    orElse: () => throw ArgumentError.value(id, 'id', 'màn không tồn tại'),
  );
}

import 'package:flame/flame.dart';

const examImageFiles = [
  'classroom.png',
  'student_writing.png',
  'student_idle.png',
  'student_nervous.png',
  'student_girl.png',
  'student_cheating.png',
  'student_caught.png',
  'student_celebrating.png',
  'teacher_purple.png',
  'teacher_blue.png',
  'teacher_pointing.png',
];

Future<void> preloadExamImages() async {
  await Flame.images.loadAll(examImageFiles);
}

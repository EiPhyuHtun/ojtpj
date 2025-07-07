import 'package:jlpt_quiz/questionScreen.dart';

class AudioFileInfo {
  final String path;
  final String level;
  final String examType;
  final String year;
  final String month;

  AudioFileInfo({
    required this.path,
    required this.level,
    required this.examType,
    required this.year,
    required this.month,
  });
}
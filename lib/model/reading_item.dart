import 'package:jlpt_quiz/model/passage.dart';
import 'package:jlpt_quiz/model/question.dart';

class ReadingItem {
  final int id;
  final int quizId;
  final int? passageId;
  final int? questionId;
  final int displayOrder;
  final Passage? passageData;
  final Question? questionData;

  ReadingItem({
    required this.id,
    required this.quizId,
    this.passageId,
    this.questionId,
    required this.displayOrder,
    this.passageData,
    this.questionData,
  });

  factory ReadingItem.fromMap(Map<String, dynamic> map,
      {Passage? passageData, Question? questionData}) {
    return ReadingItem(
      id: map['id'] as int,
      quizId: map['quiz_id'] as int,
      passageId: map['passage_id'] as int?,
      questionId: map['question_id'] as int?,
      displayOrder: map['display_order'] as int,
      passageData: passageData,
      questionData: questionData,
    );
  }

  bool get isPassage => passageId != null && passageData != null;
  bool get isQuestion => questionId != null && questionData != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'passage_id': passageId,
      'question_id': questionId,
      'display_order': displayOrder,
    };
  }
}

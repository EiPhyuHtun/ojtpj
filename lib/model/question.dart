// lib/models/question.dart
class Question {
  final int? id;
  final int questionGroupsId; // Corresponds to question_groups_id
  final int quizId; // Corresponds to quiz_id
  final String subQuestion;
  final String answer1;
  final String answer2;
  final String answer3;
  final String answer4;
  final int correctAnswer; // Corresponds to correct_answer (1-indexed from DB)

  Question({
    this.id,
    required this.questionGroupsId,
    required this.quizId,
    required this.subQuestion,
    required this.answer1,
    required this.answer2,
    required this.answer3,
    required this.answer4,
    required this.correctAnswer,
  });

  // Helper to get options as a List<String> for UI
  List<String> get options => [answer1, answer2, answer3, answer4];

  // Convert a Question object into a Map for database insertion/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_groups_id': questionGroupsId,
      'quiz_id': quizId,
      'sub_question': subQuestion,
      'answer1': answer1,
      'answer2': answer2,
      'answer3': answer3,
      'answer4': answer4,
      'correct_answer': correctAnswer,
    };
  }

  // Convert a Map from the database into a Question object
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int?,
      questionGroupsId: map['question_groups_id'] as int,
      quizId: map['quiz_id'] as int,
      subQuestion: map['sub_question'] as String,
      answer1: map['answer1'] as String,
      answer2: map['answer2'] as String,
      answer3: map['answer3'] as String,
      answer4: map['answer4'] as String,
      correctAnswer: map['correct_answer'] as int,
    );
  }
}

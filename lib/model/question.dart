class Question {
  final int? id; // Make ID nullable
  final String? subQuestion; // Make subQuestion nullable if it can be null
  final String? answer1;
  final String? answer2;
  final String? answer3;
  final String? answer4;
  final int? correctAnswer; // Make correctAnswer nullable
  final int? quizId; // Make quizId nullable

  Question({
    this.id,
    this.subQuestion,
    this.answer1,
    this.answer2,
    this.answer3,
    this.answer4,
    this.correctAnswer,
    this.quizId,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int?, // Use 'as int?' to allow null or cast to int
      subQuestion: map['sub_question'] as String?,
      answer1: map['answer1'] as String?,
      answer2: map['answer2'] as String?,
      answer3: map['answer3'] as String?,
      answer4: map['answer4'] as String?,
      correctAnswer: map['correct_answer'] as int?, // Use 'as int?'
      quizId: map['quiz_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sub_question': subQuestion,
      'answer1': answer1,
      'answer2': answer2,
      'answer3': answer3,
      'answer4': answer4,
      'correct_answer': correctAnswer,
      'quiz_id': quizId,
    };
  }
}

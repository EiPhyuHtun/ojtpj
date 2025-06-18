class UserAttempt {
  final int? id;
  final int userId;
  final int quizId;
  final int correctScore;
  final int incorrectScore;
  final int incompleteScore;
  final String createdAt;
  final String quizType;

  UserAttempt({
    this.id,
    required this.userId,
    required this.quizId,
    required this.correctScore,
    required this.incorrectScore,
    required this.incompleteScore,
    required this.createdAt,
    required this.quizType,
  });

  // Convert a UserAttempt object into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'correct_score': correctScore,
      'incorrect_score': incorrectScore,
      'incomplete_score': incompleteScore,
      'created_at': createdAt,
      'quiz_type': quizType,
    };
  }

  // Implement fromMap to create a UserAttempt from a Map (e.g., when reading from the database)
  factory UserAttempt.fromMap(Map<String, dynamic> map) {
    return UserAttempt(
      id: map['id'],
      userId: map['user_id'],
      quizId: map['quiz_id'],
      correctScore: map['correct_score'],
      incorrectScore: map['incorrect_score'],
      incompleteScore: map['incomplete_score'],
      createdAt: map['created_at'],
      quizType: map['quiz_type'],
    );
  }

  @override
  String toString() {
    return 'UserAttempt{id: $id, userId: $userId, quizId: $quizId, correctScore: $correctScore, incorrectScore: $incorrectScore, incompleteScore: $incompleteScore, createdAt: $createdAt}, quizType: $quizType';
  }
}

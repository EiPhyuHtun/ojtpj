class Quiz {
  final int id;
  final String type;
  final String level;
  final String year;
  final String month;

  Quiz({
    required this.id,
    required this.type,
    required this.level,
    required this.year,
    required this.month,
  });

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as int,
      type: map['type'] as String,
      level: map['level'] as String,
      year: map['year'] as String,
      month: map['month'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'level': level,
      'year': year,
      'month': month,
    };
  }
}

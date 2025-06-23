class Passage {
  final int id;
  final String?
      paragraph; // Use String? as it might be null if not a passage item

  Passage({required this.id, this.paragraph});

  factory Passage.fromMap(Map<String, dynamic> map) {
    return Passage(
      id: map['id'] as int,
      paragraph: map['paragraph'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paragraph': paragraph,
    };
  }
}

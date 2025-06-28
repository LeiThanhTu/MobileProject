class Result {
  // ?: có thể null
  final int? id;
  final int userId;
  final int categoryId;
  final int score;
  final int totalQuestions;
  final String date;
  String? categoryName;

  Result({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.score,
    required this.totalQuestions,
    required this.date,
    this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'score': score,
      'total_questions': totalQuestions,
      'date': date,
    };
  }

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int,
      score: map['score'] as int,
      totalQuestions: map['total_questions'] as int,
      date: map['date'] as String,
      categoryName: map['category_name'] as String?,
    );
  }

  Result copyWith({
    int? id,
    int? userId,
    int? categoryId,
    int? score,
    int? totalQuestions,
    String? date,
    String? categoryName,
  }) {
    return Result(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      date: date ?? this.date,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

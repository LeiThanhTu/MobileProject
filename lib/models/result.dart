class Result {
  final int? id;
  final int userId;
  final int categoryId;
  final int score;
  final int totalQuestions;
  final String date;
  final String dateTaken;

  Result({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.score,
    required this.totalQuestions,
    required this.date, required this.dateTaken,
  });

  Map toMap() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'score': score,
      'totalQuestions': totalQuestions,
      'date': date,
      'dateTaken': dateTaken,
    };
  }

  factory Result.fromMap(Map map) {
    return Result(
      id: map['id'],
      userId: map['userId'],
      categoryId: map['categoryId'],
      score: map['score'],
      date: map['date'],
      dateTaken: map['dateTaken'],
      totalQuestions: map['totalQuestions'],
      
    );
  }
}
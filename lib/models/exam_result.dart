class ExamResult {
  final int? id;
  final int userId;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent;
  final String timestamp;

  ExamResult({
    this.id,
    required this.userId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'time_spent': timeSpent,
      'timestamp': timestamp,
    };
  }

  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      id: map['id'],
      userId: map['user_id'],
      totalQuestions: map['total_questions'],
      correctAnswers: map['correct_answers'],
      timeSpent: map['time_spent'],
      timestamp: map['timestamp'],
    );
  }
}

class UserProgress {
  final int id;
  final int userId;
  final int questionId;
  final bool isCorrect;
  final DateTime reviewDate;

  UserProgress({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.isCorrect,
    required this.reviewDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'question_id': questionId,
      'is_correct': isCorrect ? 1 : 0,
      'review_date': reviewDate.toIso8601String(),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'],
      userId: map['user_id'],
      questionId: map['question_id'],
      isCorrect: map['is_correct'] == 1,
      // chuyển đổi chuỗi thành đối tượng DateTime
      reviewDate: DateTime.parse(map['review_date']),
    );
  }
}

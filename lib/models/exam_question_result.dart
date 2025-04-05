class ExamQuestionResult {
  final int? id;
  final int examResultId;
  final int questionId;
  final String userAnswer;
  final String correctAnswer;

  ExamQuestionResult({
    this.id,
    required this.examResultId,
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_result_id': examResultId,
      'question_id': questionId,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
    };
  }

  factory ExamQuestionResult.fromMap(Map<String, dynamic> map) {
    return ExamQuestionResult(
      id: map['id'],
      examResultId: map['exam_result_id'],
      questionId: map['question_id'],
      userAnswer: map['user_answer'],
      correctAnswer: map['correct_answer'],
    );
  }
}

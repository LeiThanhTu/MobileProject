// lib/models/question_result.dart
class QuestionResult {
  final int questionId;
  final String userAnswer;
  final String correctAnswer;

  QuestionResult({
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
  });

  factory QuestionResult.fromMap(Map<String, dynamic> map) {
    return QuestionResult(
      questionId: map['question_id'],
      userAnswer: map['user_answer'],
      correctAnswer: map['correct_answer'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question_id': questionId,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
    };
  }
}
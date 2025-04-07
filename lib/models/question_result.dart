// lib/models/question_result.dart
class QuestionResult {
  final int? id;
  final int resultId;
  final int questionId;
  final String userAnswer;
  final String correctAnswer;

  QuestionResult({
    this.id,
    required this.resultId,
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'result_id': resultId,
      'question_id': questionId,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
    };
  }

  factory QuestionResult.fromMap(Map<String, dynamic> map) {
    return QuestionResult(
      id: map['id'] as int?,
      resultId: map['result_id'] as int,
      questionId: map['question_id'] as int,
      userAnswer: map['user_answer'] as String,
      correctAnswer: map['correct_answer'] as String,
    );
  }
}

// kết quả của câu hỏi trong kỳ thi
class ExamQuestionResult {
  // ?: có thể null
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
// chuyển đổi đối tượng thành map lưu vào database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_result_id': examResultId,
      'question_id': questionId,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
    };
  }
// tạo lại đối tượng từ map lấy từ database
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
// Map là một kiểu dữ liệu dùng để lưu trữ dữ liệu theo cặp "key - value"

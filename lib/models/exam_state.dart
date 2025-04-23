import 'package:flutter/foundation.dart';
import 'question.dart';

// trạng thái của kỳ thi
// ChangeNotifier: 1 class Quản lý và thông báo khi dữ liệu thay đổi, cập nhật lại giao diện UI khi có thay đổi
class ExamState extends ChangeNotifier {
  final List<Question> questions;
  final int userId;
  final int categoryId;
  final int totalTime; // Thời gian làm bài tính bằng giây

  int currentQuestionIndex = 0;
  Map<int, String> userAnswers = {}; // questionId -> answer
  DateTime startTime;
  DateTime? endTime;
  bool isCompleted = false;

  ExamState({
    required this.questions,
    required this.userId,
    required this.categoryId,
    required this.totalTime,
  }) : startTime = DateTime.now();

// lấy câu hỏi hiện tại
  Question get currentQuestion => questions[currentQuestionIndex];
// có thể quay lại câu hỏi trước
  bool get canGoBack => currentQuestionIndex > 0;

// có thể qua câu hỏi tiếp theo
  bool get canGoForward => currentQuestionIndex < questions.length - 1;

// thời gian còn lại
  int get remainingTime {
    // thời gian đã trôi qua
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    // thời gian còn lại
    return totalTime - elapsed;
  }
// void: hàm không có giá trị trả về
  void answerQuestion(String answer) {
    userAnswers[currentQuestion.id!] = answer;
    notifyListeners(); // Báo cho UI biết dữ liệu đã thay đổi
  }

  void goToNextQuestion() {
    if (canGoForward) {
      currentQuestionIndex++;
      notifyListeners(); 
    }
  }
  void goToPreviousQuestion() {
    if (canGoBack) {
      currentQuestionIndex--;
      notifyListeners(); 
    }
  }

  void completeExam() {
    endTime = DateTime.now();
    isCompleted = true;
    notifyListeners();
  }
// tính điểm
  int calculateScore() {
    int correctAnswers = 0;
    for (var question in questions) {
      if (userAnswers[question.id] == question.correctAnswer) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  double get percentageScore {
    // tính phần trăm điểm
    // số câu đúng / tổng số câu * 100
    return (calculateScore() / questions.length) * 100;
  }
}

import 'package:flutter/foundation.dart';
import 'question.dart';

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

  Question get currentQuestion => questions[currentQuestionIndex];

  bool get canGoBack => currentQuestionIndex > 0;
  bool get canGoForward => currentQuestionIndex < questions.length - 1;

  int get remainingTime {
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return totalTime - elapsed;
  }
  void answerQuestion(String answer) {
    userAnswers[currentQuestion.id!] = answer;
    notifyListeners();
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
    return (calculateScore() / questions.length) * 100;
  }
}

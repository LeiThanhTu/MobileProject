import 'dart:async';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/question.dart';
import '../models/user_progress.dart';

class MockTestScreen extends StatefulWidget {
  final int userId;
  final int questionCount;
  final int timeInMinutes;

  const MockTestScreen({
    Key? key,
    required this.userId,
    required this.questionCount,
    required this.timeInMinutes,
  }) : super(key: key);

  @override
  _MockTestScreenState createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  late Future<List<Question>> _questionsFuture;
  late Timer _timer;
  int _timeLeft = 0;
  int _currentQuestionIndex = 0;
  List<Question> _questions = [];
  Map<int, String> _answers = {};
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timeInMinutes * 60;
    _loadQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _submitTest();
      }
    });
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _questionsFuture = DatabaseHelper.instance.getRandomQuestions(
        widget.questionCount,
      );
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitTest() async {
    _timer.cancel();
    setState(() {
      _isSubmitted = true;
    });

    // Lưu kết quả
    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final answer = _answers[i];
      final progress = UserProgress(
        id: 0,
        userId: widget.userId,
        questionId: question.id!,
        isCorrect: answer == question.correctAnswer,
        reviewDate: DateTime.now(),
      );
      await DatabaseHelper.instance.saveUserProgress(progress);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thi thử'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _formatTime(_timeLeft),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          _questions = snapshot.data!;
          final question = _questions[_currentQuestionIndex];
          final selectedAnswer = _answers[_currentQuestionIndex];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Câu hỏi ${_currentQuestionIndex + 1}/${_questions.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            question.questionText,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...question.options.map((option) {
                        final isSelected = selectedAnswer == option;
                        final isCorrect =
                            _isSubmitted && option == question.correctAnswer;
                        final isWrong =
                            _isSubmitted && isSelected && !isCorrect;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed:
                                _isSubmitted
                                    ? null
                                    : () => _selectAnswer(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isCorrect
                                      ? Colors.green
                                      : isWrong
                                      ? Colors.red
                                      : isSelected
                                      ? Theme.of(context).primaryColor
                                      : null,
                            ),
                            child: Text(option),
                          ),
                        );
                      }).toList(),
                      if (_isSubmitted && question.explanation != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giải thích:',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(question.explanation!),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed:
                            _currentQuestionIndex > 0
                                ? _previousQuestion
                                : null,
                        child: const Text('Câu trước'),
                      ),
                      if (!_isSubmitted)
                        ElevatedButton(
                          onPressed: _submitTest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Nộp bài'),
                        ),
                      ElevatedButton(
                        onPressed:
                            _currentQuestionIndex < _questions.length - 1
                                ? _nextQuestion
                                : _isSubmitted
                                ? () => Navigator.pop(context)
                                : null,
                        child: Text(
                          _currentQuestionIndex < _questions.length - 1
                              ? 'Câu sau'
                              : 'Hoàn thành',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

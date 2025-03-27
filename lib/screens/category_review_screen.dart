import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/question.dart';
import '../models/user_progress.dart';

class CategoryReviewScreen extends StatefulWidget {
  final int userId;
  final Category category;

  const CategoryReviewScreen({
    Key? key,
    required this.userId,
    required this.category,
  }) : super(key: key);

  @override
  _CategoryReviewScreenState createState() => _CategoryReviewScreenState();
}

class _CategoryReviewScreenState extends State<CategoryReviewScreen> {
  late Future<List<Question>> _questionsFuture;
  int _currentQuestionIndex = 0;
  List<Question> _questions = [];
  bool _showAnswer = false;
  String? _selectedAnswer;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _questionsFuture = _dbHelper.getQuestionsByCategory(widget.category.id!);
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _showAnswer = true;
    });

    // Lưu tiến độ
    final question = _questions[_currentQuestionIndex];
    final progress = UserProgress(
      id: 0, // ID sẽ được tự động tạo bởi SQLite
      userId: widget.userId,
      questionId: question.id!,
      isCorrect: answer == question.correctAnswer,
      reviewDate: DateTime.now(),
    );

    _dbHelper.saveUserProgress(progress);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showAnswer = false;
        _selectedAnswer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name ?? 'Review')),
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
          if (_questions.isEmpty) {
            return const Center(
              child: Text('Chưa có câu hỏi nào cho chủ đề này'),
            );
          }

          final question = _questions[_currentQuestionIndex];
          return SingleChildScrollView(
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
                  final isSelected = _selectedAnswer == option;
                  final isCorrect =
                      _showAnswer && option == question.correctAnswer;
                  final isWrong = _showAnswer && isSelected && !isCorrect;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed:
                          _showAnswer ? null : () => _checkAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCorrect
                                ? Colors.green
                                : isWrong
                                ? Colors.red
                                : null,
                      ),
                      child: Text(option),
                    ),
                  );
                }).toList(),
                if (_showAnswer) ...[
                  const SizedBox(height: 16),
                  if (question.explanation != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giải thích:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(question.explanation!),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_currentQuestionIndex < _questions.length - 1)
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      child: const Text('Câu hỏi tiếp theo'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hoàn thành'),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

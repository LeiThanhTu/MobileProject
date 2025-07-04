import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/category.dart';
import 'package:test/models/question.dart';
import 'package:test/models/result.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/screens/results/result_detail_screen.dart';
import '../../widgets/quiz_image.dart';

class QuizScreen extends StatefulWidget {
  final Category category;
  final List<Question> questions;

  QuizScreen({required this.category, required this.questions});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  String? _selectedAnswer;
  late Timer _timer;
  int _timeLeft = 60;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Map<int, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 60; // Reset timer for each question
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer.cancel();
          _moveToNextQuestion();
        }
      });
    });
  }

  void _checkAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _timer.cancel();

      final currentQuestion = widget.questions[_currentQuestionIndex];
      _userAnswers[currentQuestion.id!] = answer;

      if (answer == currentQuestion.correctAnswer) {
        _score++;
      }
    });

    // Move to next question after a delay
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        _moveToNextQuestion();
      }
    });
  }

  void _moveToNextQuestion() {
    // Lưu câu trả lời hiện tại nếu chưa có
    final currentQuestion = widget.questions[_currentQuestionIndex];
    if (!_userAnswers.containsKey(currentQuestion.id!)) {
      _userAnswers[currentQuestion.id!] = ''; // Lưu câu trả lời trống
    }

    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user == null || user.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng đăng nhập để lưu kết quả'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final result = Result(
      userId: user.id!,
      categoryId: widget.category.id,
      score: _score,
      totalQuestions: widget.questions.length,
      date: now.toIso8601String(),
    );

    try {
      // Lưu kết quả chính
      final resultId = await _dbHelper.insertResult(result);
      print('Result saved with ID: $resultId'); // Debug log

      // Lưu kết quả từng câu hỏi
      for (var entry in _userAnswers.entries) {
        final question = widget.questions.firstWhere(
          (q) => q.id == entry.key,
          orElse: () => throw Exception('Question not found: ${entry.key}'),
        );

        await _dbHelper.saveQuestionResult(
          resultId,
          entry.key,
          entry.value,
          question.correctAnswer,
        );
      }

      if (!mounted) return;

      // Hiển thị kết quả
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            'Kết quả',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Điểm số: $_score/${widget.questions.length}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Tỷ lệ đúng: ${((_score / widget.questions.length) * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ResultDetailScreen(
                      resultId: resultId,
                      categoryName: widget.category.name,
                      score: _score,
                      totalQuestions: widget.questions.length,
                    ),
                  ),
                );
              },
              child: Text(
                'Xem chi tiết',
                style: GoogleFonts.poppins(
                  color: Colors.indigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Quay lại màn hình trước
              },
              child: Text(
                'Đóng',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error saving result: $e'); // Debug log
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi lưu kết quả: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Thoát Quiz',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn thoát quiz không? \nKết quả sẽ không được lưu!',
            style: GoogleFonts.poppins(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Tiếp tục',
                style: GoogleFonts.poppins(
                  color: Colors.indigo[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Thoát',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    final answers = question.options.split('|');

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog();
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.indigo[600]),
            onPressed: () async {
              final shouldPop = await _showExitDialog();
              if (shouldPop ?? false) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            widget.category.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo[800],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTimerColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '$_timeLeft sec',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / widget.questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo[400]!),
              ),
              SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu ${_currentQuestionIndex + 1}. ${question.text}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.indigo[800],
                        ),
                      ),
                      if (question.imageUrl != null &&
                          question.imageUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: QuizImage.quiz(
                            context,
                            imageUrl: question.imageUrl,
                          ),
                        ),
                      SizedBox(height: 30),
                      ...List.generate(
                        answers.length,
                        (index) => _buildAnswerOption(
                          answers[index],
                          question.correctAnswer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String answer, String correctAnswer) {
    bool isSelected = _selectedAnswer == answer;
    final labels = ['A', 'B', 'C', 'D'];
    final currentIndex = widget.questions[_currentQuestionIndex].options
        .split('|')
        .indexOf(answer);

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    Color labelBackgroundColor = Colors.grey[300]!;
    Color labelTextColor = Colors.grey[600]!;

    if (isSelected) {
      backgroundColor = Colors.indigo[50]!;
      borderColor = Colors.indigo[400]!;
      labelBackgroundColor = Colors.indigo[600]!;
      labelTextColor = Colors.white;
    }

    return GestureDetector(
      onTap: _answered ? null : () => _checkAnswer(answer),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: labelBackgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  labels[currentIndex],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: labelTextColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.indigo[800] : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTimerColor() {
    if (_timeLeft > 30) {
      return Colors.green[600]!;
    } else if (_timeLeft > 10) {
      return Colors.orange[600]!;
    } else {
      return Colors.red[600]!;
    }
  }
}

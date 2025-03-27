import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/category.dart';
import 'package:test/models/question.dart';
import 'package:test/models/result.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/screens/result_detail_screen.dart';

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

    if (user != null) {
      final result = Result(
        id: 0,
        userId: user.id!,
        categoryId: widget.category.id!,
        score: _score,
        totalQuestions: widget.questions.length,
        dateTaken: DateTime.now().toString(),
        date: DateTime.now().toString(), // Add the required 'date' parameter
      );

      int resultId = await _dbHelper.insertResult(result);
      
      // Save individual question results
      for (var entry in _userAnswers.entries) {
        await _dbHelper.saveQuestionResult(
          resultId, 
          entry.key, 
          entry.value,
          widget.questions.firstWhere((q) => q.id == entry.key).correctAnswer
        );
      }

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    final answers = [
      question.optionA,
      question.optionB,
      question.optionC,
      question.optionD,
    ];

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Quit Quiz?'),
              content: Text('Are you sure you want to quit? Your progress will be lost.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.indigo[600]),
            onPressed: () {
              Navigator.of(context).pop();
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
                        Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 16,
                        ),
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
                        question.text,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo[800],
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
    bool isCorrect = answer == correctAnswer;
    
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    
    if (_answered) {
      if (isCorrect) {
        backgroundColor = Colors.green[50]!;
        borderColor = Colors.green[400]!;
      } else if (isSelected) {
        backgroundColor = Colors.red[50]!;
        borderColor = Colors.red[400]!;
      }
    } else if (isSelected) {
      backgroundColor = Colors.indigo[50]!;
      borderColor = Colors.indigo[400]!;
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
            Expanded(
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected && _answered
                      ? (isCorrect ? Colors.green[700] : Colors.red[700])
                      : Colors.black87,
                ),
              ),
            ),
            if (_answered)
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green[600] : Colors.red[600],
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
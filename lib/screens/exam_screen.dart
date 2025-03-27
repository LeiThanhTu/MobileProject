import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exam_state.dart';
import '../models/question.dart';
import '../database/database_helper.dart';
import '../models/result.dart';

class ExamScreen extends StatefulWidget {
  final int userId;
  final int categoryId;
  final List<Question> questions;

  const ExamScreen({
    Key? key,
    required this.userId,
    required this.categoryId,
    required this.questions,
  }) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late Timer _timer;
  final int examDuration = 30 * 60; // 30 phút

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final examState = context.read<ExamState>();
      if (examState.remainingTime <= 0) {
        _submitExam();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submitExam() async {
    _timer.cancel();
    final examState = context.read<ExamState>();
    examState.completeExam();

    final dbHelper = DatabaseHelper.instance;
    final result = Result(
      id: 0,
      userId: widget.userId,
      categoryId: widget.categoryId,
      score: examState.calculateScore(),
      totalQuestions: widget.questions.length,
      date: DateTime.now().toIso8601String(), dateTaken: '',
    );

    await dbHelper.insertResult(result);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExamResultScreen(
              score: examState.calculateScore(),
              totalQuestions: widget.questions.length,
              percentageScore: examState.percentageScore,
              questions: widget.questions,
              userAnswers: examState.userAnswers,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamState>(
      builder: (context, examState, child) {
        return WillPopScope(
          onWillPop: () async {
            final shouldPop = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Thoát bài thi?'),
                    content: const Text(
                      'Bạn có chắc muốn thoát? Kết quả sẽ không được lưu.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Không'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Có'),
                      ),
                    ],
                  ),
            );
            return shouldPop ?? false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Câu ${examState.currentQuestionIndex + 1}/${widget.questions.length}',
              ),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _formatTime(examState.remainingTime),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          examState.currentQuestion.questionText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...List<String>.from(examState.currentQuestion.options)
                            .map(
                              (option) => Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: RadioListTile<String>(
                                  title: Text(option),
                                  value: option,
                                  groupValue:
                                      examState.userAnswers[examState
                                          .currentQuestion
                                          .id],
                                  onChanged: (value) {
                                    if (value != null) {
                                      examState.answerQuestion(value);
                                    }
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (examState.canGoBack)
                          ElevatedButton(
                            onPressed: examState.goToPreviousQuestion,
                            child: const Text('Câu trước'),
                          )
                        else
                          const SizedBox(width: 85),
                        if (examState.currentQuestionIndex ==
                            widget.questions.length - 1)
                          ElevatedButton(
                            onPressed: _submitExam,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Nộp bài'),
                          )
                        else
                          ElevatedButton(
                            onPressed: examState.goToNextQuestion,
                            child: const Text('Câu sau'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ExamResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final double percentageScore;
  final List<Question> questions;
  final Map<int, String> userAnswers;

  const ExamResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.percentageScore,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade100,
            child: Column(
              children: [
                Text(
                  'Điểm số: $score/$totalQuestions',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tỷ lệ đúng: ${percentageScore.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final userAnswer = userAnswers[question.id];
                final isCorrect = userAnswer == question.correctAnswer;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Câu ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(question.questionText),
                        const SizedBox(height: 8),
                        Text(
                          'Câu trả lời của bạn: ${userAnswer ?? 'Chưa trả lời'}',
                          style: TextStyle(
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                        if (!isCorrect) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Đáp án đúng: ${question.correctAnswer}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                        if (question.explanation != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Giải thích: ${question.explanation}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Về trang chủ'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

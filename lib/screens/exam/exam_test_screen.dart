import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/exam_result.dart';
import 'package:test/models/exam_question_result.dart';
import 'package:test/models/question.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/widgets/quiz_image.dart';
import 'package:test/widgets/exam_result_dialog.dart';

class ExamTestScreen extends StatefulWidget {
  @override
  _ExamTestScreenState createState() => _ExamTestScreenState();
}

class _ExamTestScreenState extends State<ExamTestScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Question> _questions = [];
  Map<int, String> _userAnswers = {};
  Map<int, bool> _flaggedQuestions = {};
  int _currentQuestionIndex = 0;
  int _timeLeft = 1800; // 30 phút
  late Timer _timer;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await _dbHelper.getRandomQuestions(25);
    setState(() {
      _questions = questions;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // setState: cập nhật trạng thái của widget
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer.cancel();
          if (!_isSubmitted) {
            _submitExam(isTimeUp: true);
          }
        }
      });
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
  }

  void _toggleFlag() {
    setState(() {
      _flaggedQuestions[_currentQuestionIndex] =
          !(_flaggedQuestions[_currentQuestionIndex] ?? false);
    });
  }

  Future<void> _submitExam({bool isTimeUp = false}) async {
    if (_isSubmitted) return;

    // Hiển thị dialog xác nhận nộp bài nếu chưa hết giờ
    if (!isTimeUp) {
      final shouldSubmit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Xác nhận nộp bài'),
          content: Text('Bạn có chắc chắn muốn nộp bài?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Làm tiếp'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
              ),
              child: Text('Nộp bài', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (shouldSubmit != true) return;
    }

    setState(() {
      _isSubmitted = true;
    });
    _timer.cancel();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user == null || user.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng đăng nhập để lưu kết quả thi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Kiểm tra user có tồn tại trong database không
      final userExists = await _dbHelper.getUserById(user.id!);
      if (userExists == null) {
        throw Exception('User không tồn tại trong database');
      }

      int correctAnswers = 0;
      for (int i = 0; i < _questions.length; i++) {
        if (_userAnswers[i] == _questions[i].correctAnswer) {
          correctAnswers++;
        }
      }

      // Tạo exam result
      final examResult = ExamResult(
        userId: user.id!,
        totalQuestions: _questions.length,
        correctAnswers: correctAnswers,
        timeSpent: 1800 - _timeLeft,
        timestamp: DateTime.now().toIso8601String(),
      );

      // Lưu exam result
      try {
        final resultId = await _dbHelper.insertExamResult(examResult);
        print('Saved exam result with ID: $resultId');

        // Lưu từng câu trả lời
        for (int i = 0; i < _questions.length; i++) {
          if (_userAnswers.containsKey(i)) {
            final questionResult = ExamQuestionResult(
              examResultId: resultId,
              questionId: _questions[i].id!,
              userAnswer: _userAnswers[i]!,
              correctAnswer: _questions[i].correctAnswer,
            );
            await _dbHelper.insertExamQuestionResult(questionResult);
          }
        }
      } catch (dbError) {
        if (dbError.toString().contains('no such table')) {
          // Tạo lại database nếu bảng không tồn tại
          await _dbHelper.recreateDatabase();
          // Thử lại việc lưu
          final resultId = await _dbHelper.insertExamResult(examResult);
          print(
              'Saved exam result with ID: $resultId after recreating database');

          for (int i = 0; i < _questions.length; i++) {
            if (_userAnswers.containsKey(i)) {
              final questionResult = ExamQuestionResult(
                examResultId: resultId,
                questionId: _questions[i].id!,
                userAnswer: _userAnswers[i]!,
                correctAnswer: _questions[i].correctAnswer,
              );
              await _dbHelper.insertExamQuestionResult(questionResult);
            }
          }
        } else {
          throw dbError;
        }
      }
      if (!mounted) return;

      // Hiển thị kết quả với dialog mới
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ExamResultDialog(
          correctAnswers: correctAnswers,
          totalQuestions: _questions.length,
        ),
      );
      // Sau khi đóng dialog, pop màn hình thi thử để quay về màn hình cha có BottomNavigationBar
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      print('Error saving exam result: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi lưu kết quả: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentQuestionIndex];
    final options = question.options.split('|');
    final labels = ['A', 'B', 'C', 'D'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thi Thử',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.indigo[600]),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _flaggedQuestions[_currentQuestionIndex] == true
                  ? Icons.flag
                  : Icons.flag_outlined,
              color: _flaggedQuestions[_currentQuestionIndex] == true
                  ? Colors.orange[600]
                  : Colors.indigo[600],
            ),
            onPressed: _toggleFlag,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo[800],
                      ),
                    ),
                    _buildTimer(),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  height: 120,
                  child: GridView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1 / 1.2,
                    ),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      bool isAnswered = _userAnswers.containsKey(index);
                      bool isCurrent = index == _currentQuestionIndex;
                      bool isFlagged = _flaggedQuestions[index] == true;
                      return InkWell(
                        onTap: () => _goToQuestion(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Colors.indigo[100]
                                : isAnswered
                                    ? Colors.green[50]
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent
                                  ? Colors.indigo
                                  : isAnswered
                                      ? Colors.green
                                      : Colors.grey[300]!,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${index + 1}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: isCurrent || isAnswered
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isCurrent
                                            ? Colors.indigo
                                            : isAnswered
                                                ? Colors.green[700]
                                                : Colors.grey[700],
                                      ),
                                    ),
                                    if (isFlagged)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Icons.flag,
                                          size: 14,
                                          color: Colors.orange[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
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
                        question.imageUrl!.isNotEmpty) ...[
                      SizedBox(height: 20),
                      QuizImage.practice(context, imageUrl: question.imageUrl),
                    ],
                    SizedBox(height: 30),
                    ...List.generate(
                      options.length,
                      (index) =>
                          _buildAnswerOption(options[index], labels[index]),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  // Offset: khoảng cách giữa các widget
                  offset: Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentQuestionIndex > 0
                            ? () => _goToQuestion(_currentQuestionIndex - 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Câu trước',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentQuestionIndex < _questions.length - 1
                            ? () => _goToQuestion(_currentQuestionIndex + 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Câu sau',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submitExam(),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.indigo[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Nộp bài',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String option, String label) {
    final question = _questions[_currentQuestionIndex];
    final options = question.options.split('|');
    final optionMap = {'A': 0, 'B': 1, 'C': 2, 'D': 3};

    final answer = options[optionMap[label]!];
    final isSelected = _userAnswers[_currentQuestionIndex] == answer;

    return GestureDetector(
      // onTap: khi người dùng nhấn vào widget
      onTap: () => _selectAnswer(answer),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.indigo[400]! : Colors.grey[300]!,
            width: 1.5,
          ),
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
                color: isSelected ? Colors.indigo[400] : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
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

  Widget _buildTimer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _timeLeft > 600
            ? Colors.green[600]
            : _timeLeft > 300
                ? Colors.orange[600]
                : Colors.red[600],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            // ~/: chia lấy phần nguyên
            // %: chia lấy phần dư
            // toString().padLeft(2, '0'): chuyển số thành chuỗi và thêm 0 vào trước nếu cần
            '${_timeLeft ~/ 60}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
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
                Navigator.of(context)
                    .pop(); // Thêm dòng này để thoát màn hình thi
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
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/question.dart';
import 'package:test/widgets/quiz_image.dart';

class QuestionDetailScreen extends StatelessWidget {
  final int questionId;
  final String userAnswer;
  final String correctAnswer;
  final int questionIndex;

  QuestionDetailScreen({
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.indigo[600]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chi tiết câu hỏi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Question>(
        future: DatabaseHelper.instance.getQuestionById(questionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Không tim thấy câu hỏi'));
          }

          final question = snapshot.data!;
          final options = question.options.split('|');

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu ${questionIndex + 1}. ${question.text}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.indigo[800],
                  ),
                ),
                if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: QuizImage.detail(
                      context,
                      imageUrl: question.imageUrl,
                    ),
                  ),
                SizedBox(height: 30),
                ...options.map(
                  (option) => _buildAnswerOption(
                    option,
                    userAnswer: userAnswer,
                    correctAnswer: correctAnswer,
                  ),
                ),
                if (question.explanation != null &&
                    question.explanation!.isNotEmpty) ...[
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giải thích:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          question.explanation!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerOption(
    String answer, {
    required String userAnswer,
    required String correctAnswer,
  }) {
    bool isUserAnswer = answer == userAnswer;
    bool isCorrectAnswer = answer == correctAnswer;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    IconData? trailingIcon;
    Color? iconColor;

    if (isUserAnswer && isCorrectAnswer) {
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[400]!;
      trailingIcon = Icons.check_circle;
      iconColor = Colors.green[600];
    } else if (isUserAnswer) {
      backgroundColor = Colors.red[50]!;
      borderColor = Colors.red[400]!;
      trailingIcon = Icons.cancel;
      iconColor = Colors.red[600];
    } else if (isCorrectAnswer) {
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[400]!;
      trailingIcon = Icons.check_circle;
      iconColor = Colors.green[600];
    }

    return Container(
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
                fontWeight:
                    isUserAnswer || isCorrectAnswer
                        ? FontWeight.w600
                        : FontWeight.normal,
                color:
                    isUserAnswer && !isCorrectAnswer
                        ? Colors.red[700]
                        : Colors.black87,
              ),
            ),
          ),
          if (trailingIcon != null) Icon(trailingIcon, color: iconColor),
        ],
      ),
    );
  }
}

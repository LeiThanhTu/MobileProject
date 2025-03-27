import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/category.dart';
import 'package:test/models/question.dart';
import 'package:test/screens/quiz_screen.dart';

class QuizIntroScreen extends StatefulWidget {
  final Category category;

  QuizIntroScreen({required this.category});

  @override
  _QuizIntroScreenState createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends State {
  late Future<List> _questionsFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _questionsFuture = _dbHelper.getQuestionsByCategory((widget as QuizIntroScreen).category.id!);
  }

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
      ),
      body: FutureBuilder<List>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No questions available'));
          } else {
            int questionCount = snapshot.data!.length;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.indigo[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon((widget as QuizIntroScreen).category.name),
                          size: 64,
                          color: Colors.indigo[800],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: Text(
                      (widget as QuizIntroScreen).category.name,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      (widget as QuizIntroScreen).category.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildInfoItem('Questions', '$questionCount'),
                  SizedBox(height: 8),
                  _buildInfoItem('Duration', '$questionCount minutes'),
                  SizedBox(height: 8),
                  _buildInfoItem(
                      'Difficulty', _getDifficultyLevel(questionCount)),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              category: (widget as QuizIntroScreen).category,
                              questions: snapshot.data! as List<Question>,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Start Quiz',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.indigo[800],
            ),
          ),
        ),
      ],
    );
  }

  String _getDifficultyLevel(int questionCount) {
    if (questionCount <= 5) {
      return 'Easy';
    } else if (questionCount <= 10) {
      return 'Medium';
    } else {
      return 'Hard';
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history_edu;
      case 'geography':
        return Icons.public;
      case 'math':
        return Icons.calculate;
      case 'sports':
        return Icons.sports;
      case 'movies':
        return Icons.movie;
      case 'music':
        return Icons.music_note;
      case 'art':
        return Icons.palette;
      default:
        return Icons.quiz;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/result.dart';
import 'package:test/models/category.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/screens/result_detail_screen.dart';
import 'package:test/screens/quiz_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kết quả của tôi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          userId == null
              ? Center(
                child: Text(
                  'Vui lòng đăng nhập để xem kết quả',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              )
              : FutureBuilder<List<Result>>(
                future: DatabaseHelper.instance.getResultsByUser(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Lỗi: ${snapshot.error}',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    );
                  }

                  final results = snapshot.data ?? [];

                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có kết quả bài kiểm tra nào',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy thử làm một bài kiểm tra',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      final score =
                          (result.score / result.totalQuestions) * 100;
                      final scoreColor =
                          score >= 80
                              ? Colors.green
                              : score >= 60
                              ? Colors.orange
                              : Colors.red;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.quiz_outlined,
                                      color: Colors.indigo[800],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          result.categoryName ?? 'Unknown',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.indigo[800],
                                          ),
                                        ),
                                        Text(
                                          result.createdAt.split('T')[0],
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scoreColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${score.toStringAsFixed(0)}%',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: scoreColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: scoreColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: score / 100,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: scoreColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Text(
                                    'Score: ${result.score}/${result.totalQuestions}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ResultDetailScreen(
                                                resultId: result.id!,
                                                categoryName:
                                                    result.categoryName ??
                                                    'Unknown',
                                                score: result.score,
                                                totalQuestions:
                                                    result.totalQuestions,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Details',
                                      style: GoogleFonts.poppins(
                                        color: Colors.indigo[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () async {
                                      final questions = await DatabaseHelper
                                          .instance
                                          .getQuestionsByCategory(
                                            result.categoryId,
                                          );
                                      if (!context.mounted) return;

                                      if (questions.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'No questions available for this category',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => QuizScreen(
                                                category: Category(
                                                  id: result.categoryId,
                                                  name:
                                                      result.categoryName ??
                                                      'Unknown',
                                                ),
                                                questions: questions,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Retry',
                                      style: GoogleFonts.poppins(
                                        color: Colors.indigo[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
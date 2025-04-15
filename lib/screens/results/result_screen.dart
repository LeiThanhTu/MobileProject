import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/result.dart';
import 'package:test/models/exam_result.dart';
import 'package:test/models/category.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/screens/results/result_detail_screen.dart';
import 'package:test/screens/quizz/quiz_screen.dart';
import 'package:test/widgets/search_bar.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget searchBar;
  final double height;

  _SliverSearchBarDelegate({
    required this.searchBar,
    this.height = 80.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: searchBar,
    );
  }

  @override
  bool shouldRebuild(_SliverSearchBarDelegate oldDelegate) {
    return searchBar != oldDelegate.searchBar || height != oldDelegate.height;
  }
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _searchQuery = '';

  String _normalizeVietnamese(String str) {
    final vietnamese = 'aAeEoOuUiIdDyY';
    final latin =
        'áàạảãâấầậẩẫăắằặẳẵ/ÁÀẠẢÃÂẤẦẬẨẪĂẮẰẶẲẴ/éèẹẻẽêếềệểễ/ÉÈẸẺẼÊẾỀỆỂỄ/óòọỏõôốồộổỗơớờợởỡ/ÓÒỌỎÕÔỐỒỘỔỖƠỚỜỢỞỠ/úùụủũưứừựửữ/ÚÙỤỦŨƯỨỪỰỬỮ/íìịỉĩ/ÍÌỊỈĨ/đ/Đ/ýỳỵỷỹ/ÝỲỴỶỸ'
            .replaceAll('/', '');

    for (int i = 0; i < vietnamese.length; i++) {
      str = str.replaceAll(
          RegExp(latin.substring(i * 6, (i + 1) * 6)), vietnamese[i]);
    }
    return str;
  }

  List<Result> _filterResults(List<Result> results) {
    if (_searchQuery.isEmpty) return results;

    final query = _normalizeVietnamese(_searchQuery.toLowerCase().trim());
    return results.where((result) {
      final categoryName =
          _normalizeVietnamese(result.categoryName?.toLowerCase().trim() ?? '');

      // Tìm kiếm theo tên chính xác trước
      if (categoryName == query) return true;

      // Sau đó tìm theo từng từ trong tên
      final nameWords = categoryName.split(' ');
      final queryWords = query.split(' ');

      // Kiểm tra xem mỗi từ trong query có xuất hiện trong tên không
      return queryWords.every(
          (word) => nameWords.any((nameWord) => nameWord.contains(word)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.currentUser?.id;

    return Scaffold(
      body: userId == null
          ? Center(
              child: Text(
                'Vui lòng đăng nhập để xem kết quả',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            )
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    title: Text(
                      'Kết quả của tôi',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    floating: true,
                    pinned: true,
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverSearchBarDelegate(
                      searchBar: CustomSearchBar(
                        hintText: 'Tìm kiếm theo môn học...',
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        margin: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Kết quả ôn tập',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                    ),
                    _buildQuizResults(userId),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Kết quả thi thử',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                    ),
                    _buildExamResults(userId),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuizResults(int userId) {
    return FutureBuilder<List<Result>>(
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

        final results = _filterResults(snapshot.data ?? []);

        if (results.isEmpty) {
          if (_searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy kết quả nào',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
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
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            final score = (result.score / result.totalQuestions) * 10;
            final isPass = score >= 5.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isPass ? Colors.green[50] : Colors.red[50],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${score.toStringAsFixed(1)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isPass ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  '/10',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isPass ? Icons.emoji_events : Icons.stars,
                                    color: isPass
                                        ? Colors.amber
                                        : Colors.grey[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      result.categoryName ?? 'Unknown',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.indigo[800],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${result.score}/${result.totalQuestions} câu đúng',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result.date.split('T')[0],
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
                            color: isPass
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPass ? Icons.check_circle : Icons.info,
                                color: isPass ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPass ? 'Đạt' : 'Chưa đạt',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isPass ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResultDetailScreen(
                                    resultId: result.id!,
                                    categoryName:
                                        result.categoryName ?? 'Unknown',
                                    score: result.score,
                                    totalQuestions: result.totalQuestions,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.visibility_outlined,
                                size: 18, color: Colors.indigo[600]),
                            label: Text(
                              'Chi tiết',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.indigo[600],
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.indigo[200]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final questions = await DatabaseHelper.instance
                                  .getQuestionsByCategory(result.categoryId);
                              if (!context.mounted) return;

                              if (questions.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Không có câu hỏi cho môn học này',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    category: Category(
                                      id: result.categoryId,
                                      name: result.categoryName ?? 'Unknown',
                                    ),
                                    questions: questions,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              'Làm lại',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
          },
        );
      },
    );
  }

  Widget _buildExamResults(int userId) {
    return FutureBuilder<List<ExamResult>>(
      future: DatabaseHelper.instance.getExamResults(userId),
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
                Icon(Icons.assignment_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có kết quả thi thử nào',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy thử làm một bài thi thử',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Chỉ lấy kết quả gần nhất
        final result = results.first;
        final score = (result.correctAnswers / result.totalQuestions) * 10;
        final isPass = score >= 5.0;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isPass ? Colors.green[50] : Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${score.toStringAsFixed(1)}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isPass ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            '/10',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPass ? Icons.emoji_events : Icons.stars,
                              color: isPass ? Colors.amber : Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bài thi thử',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.correctAnswers}/${result.totalQuestions} câu đúng',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thời gian: ${(result.timeSpent / 60).floor()}:${(result.timeSpent % 60).toString().padLeft(2, '0')}',
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
                      color: isPass
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPass ? Icons.check_circle : Icons.info,
                          color: isPass ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPass ? 'Đạt' : 'Chưa đạt',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isPass ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

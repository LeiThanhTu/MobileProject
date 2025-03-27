import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/exam_state.dart';
import '../database/database_helper.dart';
import 'exam_screen.dart';
import 'category_review_screen.dart';

class CategoryScreen extends StatelessWidget {
  final int userId;

  const CategoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục')),
      body: FutureBuilder<List<Category>>(
        future: DatabaseHelper.instance.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text('Không có danh mục nào'));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Image.asset(
                        category.imageUrl ?? '',
                        width: 48,
                        height: 48,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.category),
                      ),
                      title: Text(category.name),
                      subtitle: Text(category.description ?? ''),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.book),
                          label: const Text('Ôn tập'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CategoryReviewScreen(
                                      userId: userId,
                                      category: category,
                                    ),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.timer),
                          label: const Text('Thi thử'),
                          onPressed: () async {
                            final questions = await DatabaseHelper.instance
                                .getQuestionsByCategory(category.id);
                            if (!context.mounted) return;

                            if (questions.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Không có câu hỏi cho danh mục này',
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChangeNotifierProvider(
                                      create:
                                          (context) => ExamState(
                                            questions: questions,
                                            userId: userId,
                                            categoryId: category.id,
                                            totalTime: 30 * 60, // 30 phút
                                          ),
                                      child: ExamScreen(
                                        userId: userId,
                                        categoryId: category.id,
                                        questions: questions,
                                      ),
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
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

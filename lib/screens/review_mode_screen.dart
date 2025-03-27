import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import 'category_review_screen.dart';

class ReviewModeScreen extends StatefulWidget {
  final int userId;

  const ReviewModeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ReviewModeScreenState createState() => _ReviewModeScreenState();
}

class _ReviewModeScreenState extends State<ReviewModeScreen> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DatabaseHelper.instance.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chế độ ôn tập')),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          final categories = snapshot.data!;
          if (categories.isEmpty) {
            return const Center(child: Text('Chưa có chủ đề nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                child: ListTile(
                  leading:
                      category.imageUrl != null
                          ? Image.network(
                            category.imageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.category),
                  title: Text(category.name),
                  subtitle:
                      category.description != null
                          ? Text(category.description!)
                          : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CategoryReviewScreen(
                              userId: widget.userId,
                              category: category,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/category.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/screens/quizz/quiz_intro_screen.dart';
import 'package:test/widgets/search_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}
class _CategoriesScreenState extends State<CategoriesScreen> {
  // late: khai báo biến sau khi khởi tạo
  late Future<List<Category>> _categoriesFuture;
  // DatabaseHelper: lưu trữ dữ liệu trong cơ sở dữ liệu
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _dbHelper.getCategories();
  }

  String _normalizeVietnamese(String str) {
    final vietnamese = 'aAeEoOuUiIdDyY';
    final latin =
        'áàạảãâấầậẩẫăắằặẳẵ/ÁÀẠẢÃÂẤẦẬẨẪĂẮẰẶẲẴ/éèẹẻẽêếềệểễ/ÉÈẸẺẼÊẾỀỆỂỄ/óòọỏõôốồộổỗơớờợởỡ/ÓÒỌỎÕÔỐỒỘỔỖƠỚỜỢỞỠ/úùụủũưứừựửữ/ÚÙỤỦŨƯỨỪỰỬỮ/íìịỉĩ/ÍÌỊỈĨ/đ/Đ/ýỳỵỷỹ/ÝỲỴỶỸ'
            .replaceAll('/', '');

    for (int i = 0; i < vietnamese.length; i++) {
      str = str.replaceAll(
        // RegExp: kiểm tra định dạng chuỗi
        // latin.substring(i * 6, (i + 1) * 6): lấy chuỗi con từ latin
        // vietnamese[i]: thay thế chuỗi con từ latin bằng chuỗi con từ vietnamese
          RegExp(latin.substring(i * 6, (i + 1) * 6)), vietnamese[i]);
    }
    return str;
  }
// _filterCategories: lọc danh mục theo tên và mô tả
  List<Category> _filterCategories(List<Category> categories) {
    if (_searchQuery.isEmpty) return categories;

    final query = _normalizeVietnamese(_searchQuery.toLowerCase().trim());
    return categories.where((category) {
      final name =
          _normalizeVietnamese(category.name?.toLowerCase().trim() ?? '');
      final description = _normalizeVietnamese(
          category.description?.toLowerCase().trim() ?? '');

      // Tìm kiếm theo tên chính xác trước
      if (name == query) return true;

      // Sau đó tìm theo từng từ trong tên
      final nameWords = name.split(' ');
      final queryWords = query.split(' ');

      // Kiểm tra xem mỗi từ trong query có xuất hiện trong tên không
      bool matchesName = queryWords.every(
          (word) => nameWords.any((nameWord) => nameWord.contains(word)));

      // Kiểm tra trong mô tả nếu không tìm thấy trong tên
      bool matchesDescription = !matchesName && description.contains(query);

      return matchesName || matchesDescription;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Quiz Categories',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${user?.name ?? 'User'}!',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bạn muốn học gì nào?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                CustomSearchBar(
                  hintText: 'Tìm kiếm danh mục...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có danh mục nào'));
                } else {
                  final filteredCategories = _filterCategories(snapshot.data!);

                  if (filteredCategories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không tìm thấy danh mục nào',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        
                        crossAxisSpacing: 16,
                        // mainAxisSpacing: 16: khoảng cách giữa các dòng
                        mainAxisSpacing: 16,
                        // childAspectRatio: 1.0: tỉ lệ chiều rộng và chiều cao của các widget
                        childAspectRatio: 1.0,
                      ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return _buildCategoryCard(context, category);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizIntroScreen(category: category),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.indigo[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(category.name ?? 'default'),
                    size: 40,
                    color: Colors.indigo[800],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      category.description ?? 'Chưa có mô tả',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase().trim();

    if (name.contains('java')) {
      return Icons.coffee;
    } else if (name.contains('javascript')) {
      return Icons.javascript;
    } else if (name.contains('kotlin')) {
      return Icons.android;
    } else if (name.contains('python')) {
      return Icons.terminal;
    } else if (name.contains('sql')) {
      return Icons.storage;
    } else if (name.contains('c#') || name.contains('c sharp')) {
      return Icons.code;
    } else {
      return Icons.quiz;
    }
  }
}

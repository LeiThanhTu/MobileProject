import 'package:test/models/category.dart';
import 'package:test/models/exam_question_result.dart';
import 'package:test/models/exam_result.dart';
import 'package:test/models/question.dart';
import 'package:test/models/question_result.dart';
import 'package:test/models/result.dart';
import 'package:test/models/user.dart';
import 'package:test/models/user_progress.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

// khởi tạo database
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database; // _database là biến static để lưu trữ kết nối db

  DatabaseHelper._init();
// Phương thức get database kiểm tra nếu database chưa được khởi tạo thì sẽ khởi tạo mới
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('db.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('Database path: $path');

    try {
      // Kiểm tra và tạo thư mục
      await Directory(dirname(path)).create(recursive: true);

      // Chỉ copy database từ assets nếu database chưa tồn tại
      if (!await databaseExists(path)) {
        print('Copying database from assets...');
        try {
          // Đọc file từ assets
          final ByteData data = await rootBundle.load(join('assets', 'db.db'));
          print('Database file size: ${data.lengthInBytes} bytes');

          // Ghi file vào thiết bị
          final List<int> bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          final File file = File(path);
          await file.writeAsBytes(bytes, flush: true);

          // Kiểm tra file đã được ghi
          if (await file.exists()) {
            print('Database file written successfully');
            print('Written file size: ${await file.length()} bytes');
          } else {
            throw Exception('Database file not written');
          }
        } catch (e) {
          print('Error copying database: $e');
          throw Exception('Failed to copy database: $e');
        }
      }

      // Mở và kiểm tra database
      print('Opening database...');
      final db = await openDatabase(
        path,
        version: 2,
        readOnly: false,
        singleInstance: true,
        onCreate: (db, version) async {
          // Tạo bảng users với các cột mới
          print('Created users table with new columns');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Thêm các cột mới vào bảng users
            try {
              await db.execute('ALTER TABLE users ADD COLUMN displayName TEXT');
              print('Added displayName column to users table');
            } catch (e) {
              print('displayName column might already exist: $e');
            }

            try {
              await db.execute('ALTER TABLE users ADD COLUMN photoURL TEXT');
              print('Added photoURL column to users table');
            } catch (e) {
              print('photoURL column might already exist: $e');
            }
          }
        },
      );

      // Kiểm tra cấu trúc database
      print('Checking database structure...');
      try {
        final tables = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type="table"',
        );
        print('Tables in database: ${tables.map((t) => t['name']).join(', ')}');

        // Kiểm tra từng bảng
        for (var table in tables) {
          final tableName = table['name'] as String;
          if (!['android_metadata', 'sqlite_sequence'].contains(tableName)) {
            try {
              final count = Sqflite.firstIntValue(
                await db.rawQuery('SELECT COUNT(*) FROM "$tableName"'),
              );
              print('$tableName count: $count');

              // In ra một vài bản ghi đầu tiên để kiểm tra
              final rows = await db.query(tableName, limit: 1);
              if (rows.isNotEmpty) {
                print('First row in $tableName: ${rows.first}');
              }
            } catch (e) {
              print('Error checking table $tableName: $e');
            }
          }
        }
      } catch (e) {
        print('Error checking database structure: $e');
        throw e;
      }

      return db;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // User operations
  Future<User> createUser(User user) async {
    final db = await database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    final db = await database;
    final result = await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
    return result > 0;
  }

  // Lấy user theo email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  // Cập nhật mật khẩu
  Future<bool> updatePassword(String email, String newPassword) async {
    final db = await database;
    try {
      final rowsAffected = await db.update(
        'users',
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [email],
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  // Cập nhật thông tin người dùng
  Future<bool> updateUser(User user) async {
    final db = await database;
    try {
      final updateData = {
        'username': user.username,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'provider': user.provider
      };
      if (user.password != null) {
        updateData['password'] = user.password;
      }
      final rowsAffected = await db.update(
        'users',
        updateData,
        where: 'email = ?',
        whereArgs: [user.email],
      );
      print('Updated user: ${user.email}, rows affected: $rowsAffected');
      return rowsAffected > 0;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Category methods
  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i].cast<String, dynamic>());
    });
  }

  Future<Category?> getCategory(int id) async {
    final db = await database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first.cast<String, dynamic>());
    }
    return null;
  }

  Future<Category> createCategory(Category category) async {
    final db = await database;
    final id = await db.insert('categories', category.toMap());
    return category.copyWith(id: id);
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Question methods
  Future<Question> createQuestion(Question question) async {
    final db = await database;
    final id = await db.insert('questions', question.toMap());
    return Question(
      id: id,
      categoryId: question.categoryId,
      text: question.text,
      correctAnswer: question.correctAnswer,
      options: question.options,
      explanation: question.explanation,
    );
  }

  Future<List<Question>> getQuestionsByCategory(int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) {
      return Question.fromMap(maps[i].cast<String, dynamic>());
    });
  }

  Future<List<Question>> getRandomQuestions(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM questions 
      ORDER BY RANDOM() 
      LIMIT ?
    ''',
      [limit],
    );
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<String> getQuestionText(int questionId) async {
    final db = await database;
    final result = await db.query(
      'questions',
      columns: ['question_text'],
      where: 'id = ?',
      whereArgs: [questionId],
    );
    return result.first['question_text'] as String;
  }

  Future<Question> getQuestionById(int questionId) async {
    final db = await database;
    final result = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );

    if (result.isEmpty) {
      throw Exception('Question not found');
    }

    return Question.fromMap(result.first);
  }

  // User Progress operations
  Future<UserProgress> saveUserProgress(UserProgress progress) async {
    final db = await database;
    final id = await db.insert('user_progress', progress.toMap());
    return UserProgress(
      id: id,
      userId: progress.userId,
      questionId: progress.questionId,
      isCorrect: progress.isCorrect,
      reviewDate: progress.reviewDate,
    );
  }

  Future<List<UserProgress>> getUserProgress(int userId) async {
    final db = await database;
    final maps = await db.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'review_date DESC',
    );
    return List.generate(maps.length, (i) {
      return UserProgress.fromMap(maps[i].cast<String, dynamic>());
    });
  }

  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total_questions,
        SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) as correct_answers
      FROM user_progress
      WHERE user_id = ?
    ''',
      [userId],
    );

    final map = result.first;
    return {
      'totalQuestions': map['total_questions'] as int,
      'correctAnswers': map['correct_answers'] as int,
      'accuracy': map['total_questions'] == 0
          ? 0.0
          : (map['correct_answers'] as int) / (map['total_questions'] as int),
    };
  }

  // Result methods
  Future<int> insertResult(Result result) async {
    final db = await database;
    return await db.insert('results', result.toMap().cast<String, Object?>());
  }

  Future<List<Result>> getResultsByUser(int userId) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT r.*, c.name as category_name 
      FROM results r
      LEFT JOIN categories c ON r.category_id = c.id
      INNER JOIN (
        SELECT category_id, MAX(date) as latest_date
        FROM results
        WHERE user_id = ?
        GROUP BY category_id
      ) latest ON r.category_id = latest.category_id AND r.date = latest.latest_date
      WHERE r.user_id = ?
      ORDER BY r.date DESC
      ''',
      [userId, userId],
    );

    return List.generate(maps.length, (i) {
      return Result.fromMap(maps[i].cast<String, dynamic>());
    });
  }

  Future<void> saveQuestionResult(
    int resultId,
    int questionId,
    String userAnswer,
    String correctAnswer,
  ) async {
    final db = await database;
    try {
      // Kiểm tra cấu trúc bảng
      final tableInfo = await db.rawQuery(
        'PRAGMA table_info(question_results)',
      );
      print(
        'question_results columns: ${tableInfo.map((col) => col['name']).join(', ')}',
      );

      await db.insert('question_results', {
        'result_id': resultId, // Sử dụng result_id thay vì quiz_result_id
        'question_id': questionId,
        'user_answer': userAnswer,
        'correct_answer': correctAnswer,
      });
    } catch (e) {
      print('Error saving question result: $e');
      rethrow;
    }
  }

  Future<List<QuestionResult>> getQuestionResults(int resultId) async {
    final db = await database;
    final maps = await db.query(
      'question_results',
      where: 'result_id = ?', // Sử dụng result_id thay vì quiz_result_id
      whereArgs: [resultId],
    );
    return List.generate(maps.length, (i) {
      return QuestionResult.fromMap(maps[i].cast<String, dynamic>());
    });
  }

  Future<String> getCategoryName(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'categories',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [categoryId],
    );
    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return 'Unknown Category';
  }

  Future<int> getQuestionCountForCategory(int categoryId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM questions WHERE category_id = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> insertExamResult(ExamResult result) async {
    final db = await database;
    final values = {
      'user_id': result.userId,
      'total_questions': result.totalQuestions,
      'correct_answers': result.correctAnswers,
      'time_spent': result.timeSpent,
      'timestamp': result.timestamp,
    };
    return await db.insert('exam_results', values);
  }

  Future<List<ExamResult>> getExamResults(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exam_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => ExamResult.fromMap(maps[i]));
  }

  Future<void> insertExamQuestionResult(ExamQuestionResult result) async {
    final db = await database;
    await db.insert('exam_question_results', result.toMap());
  }

  Future<List<ExamQuestionResult>> getExamQuestionResults(
    int examResultId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exam_question_results',
      where: 'exam_result_id = ?',
      whereArgs: [examResultId],
    );
    return List.generate(
      maps.length,
      (i) => ExamQuestionResult.fromMap(maps[i]),
    );
  }

  Future<void> deleteDatabase(String path) async {
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<void> recreateDatabase() async {
    await deleteDatabase(await getDatabasesPath() + '/db.db');
    await database; // This will trigger database creation
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }
}

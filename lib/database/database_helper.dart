import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:test/models/category.dart';
import 'package:test/models/question.dart';
import 'package:test/models/question_result.dart';
import 'dart:async';

import 'package:test/models/result.dart';
import 'package:test/models/user.dart';
import 'package:test/models/user_progress.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz_data.sql');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        question_text TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        options TEXT NOT NULL,
        explanation TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        question_id INTEGER,
        is_correct BOOLEAN,
        review_date DATETIME,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (question_id) REFERENCES questions (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        category_id INTEGER,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE question_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        result_id INTEGER,
        question_id INTEGER,
        user_answer TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        FOREIGN KEY (result_id) REFERENCES results (id),
        FOREIGN KEY (question_id) REFERENCES questions (id)
      )
    ''');

    try {
      final String sql = await rootBundle.loadString(
        'assets/database/quiz_data.sql',
      );
      List<String> statements = sql.split(';');

      for (String statement in statements) {
        if (statement.trim().isNotEmpty) {
          await db.execute(statement);
        }
      }
    } catch (e) {
      print('Error loading initial data: $e');
    }
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
      questionText: question.questionText,
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

  Future<List<Question>> getRandomQuestions(int count) async {
    final db = await database;
    final maps = await db.query('questions', orderBy: 'RANDOM()', limit: count);
    return List.generate(maps.length, (i) {
      return Question.fromMap(maps[i].cast<String, dynamic>());
    });
  }

  Future<String> getQuestionText(int questionId) async {
    final db = await database;
    final result = await db.query(
      'questions',
      columns: ['question_text'],
      where: 'id = ?',
      whereArgs: [questionId],
    );
    if (result.isNotEmpty) {
      return result.first['question_text'] as String;
    }
    throw Exception('Question not found');
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
      'accuracy':
          map['total_questions'] == 0
              ? 0.0
              : (map['correct_answers'] as int) /
                  (map['total_questions'] as int),
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
    await db.insert(
      'question_results',
      {
            'result_id': resultId,
            'question_id': questionId,
            'user_answer': userAnswer,
            'correct_answer': correctAnswer,
          }
          as Map<String, Object?>,
    );
  }

  Future<List<QuestionResult>> getQuestionResults(int resultId) async {
    final db = await database;
    final maps = await db.query(
      'question_results',
      where: 'result_id = ?',
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
}

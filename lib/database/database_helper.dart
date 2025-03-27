import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:test/models/category.dart';
import 'package:test/models/question.dart';
import 'package:test/models/question_result.dart';
import 'dart:async';

import 'package:test/models/result.dart';
import 'package:test/models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quiz_app.db');
    return await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Create Categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT
      )
    ''');

    // Create Questions table
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER NOT NULL,
        question TEXT NOT NULL,
        optionA TEXT NOT NULL,
        optionB TEXT NOT NULL,
        optionC TEXT NOT NULL,
        optionD TEXT NOT NULL,
        correctOption TEXT NOT NULL,
        explanation TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Create Results table
    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        categoryId INTEGER NOT NULL,
        score INTEGER NOT NULL,
        totalQuestions INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future _insertSampleData(Database db) async {
    // Insert sample categories
    await db.insert('categories', {
      'name': 'Science',
      'description': 'Test your knowledge about basic science concepts',
      'imageUrl': 'assets/images/science.png'
    });

    await db.insert('categories', {
      'name': 'History',
      'description': 'Questions about world history',
      'imageUrl': 'assets/images/history.png'
    });

    await db.insert('categories', {
      'name': 'Geography',
      'description': 'Questions about countries, capitals and landmarks',
      'imageUrl': 'assets/images/geography.png'
    });

    // Insert sample questions for Science
    List<Map> scienceQuestions = [
      {
        'categoryId': 1,
        'question': 'What is the chemical symbol for water?',
        'optionA': 'H2O',
        'optionB': 'CO2',
        'optionC': 'O2',
        'optionD': 'N2',
        'correctOption': 'A',
        'explanation': 'Water is made up of two hydrogen atoms and one oxygen atom, hence H2O.'
      },
      {
        'categoryId': 1,
        'question': 'Which planet is known as the Red Planet?',
        'optionA': 'Venus',
        'optionB': 'Mars',
        'optionC': 'Jupiter',
        'optionD': 'Saturn',
        'correctOption': 'B',
        'explanation': 'Mars appears red because of iron oxide (rust) on its surface.'
      },
      {
        'categoryId': 1,
        'question': 'What is the largest organ in the human body?',
        'optionA': 'Heart',
        'optionB': 'Liver',
        'optionC': 'Skin',
        'optionD': 'Lungs',
        'correctOption': 'C',
        'explanation': 'The skin is the largest organ, covering the entire body.'
      }
    ];

    for (var question in scienceQuestions) {
      await db.insert('questions', question.cast<String, Object?>());
    }

    // Insert sample questions for History
    List<Map> historyQuestions = [
      {
        'categoryId': 2,
        'question': 'Who was the first President of the United States?',
        'optionA': 'Thomas Jefferson',
        'optionB': 'George Washington',
        'optionC': 'Abraham Lincoln',
        'optionD': 'John Adams',
        'correctOption': 'B',
        'explanation': 'George Washington served as the first President from 1789 to 1797.'
      },
      {
        'categoryId': 2,
        'question': 'In which year did World War II end?',
        'optionA': '1943',
        'optionB': '1944',
        'optionC': '1945',
        'optionD': '1946',
        'correctOption': 'C',
        'explanation': 'World War II ended in 1945 with the surrender of Japan.'
      },
      {
        'categoryId': 2,
        'question': 'Who wrote the "I Have a Dream" speech?',
        'optionA': 'Malcolm X',
        'optionB': 'Martin Luther King Jr.',
        'optionC': 'Nelson Mandela',
        'optionD': 'Barack Obama',
        'correctOption': 'B',
        'explanation': 'Martin Luther King Jr. delivered this famous speech in 1963.'
      }
    ];

    for (var question in historyQuestions) {
      await db.insert('questions', question.cast<String, Object?>());
    }

    // Insert sample questions for Geography
    List<Map> geographyQuestions = [
      {
        'categoryId': 3,
        'question': 'What is the capital of France?',
        'optionA': 'London',
        'optionB': 'Berlin',
        'optionC': 'Paris',
        'optionD': 'Rome',
        'correctOption': 'C',
        'explanation': 'Paris is the capital and largest city of France.'
      },
      {
        'categoryId': 3,
        'question': 'Which is the longest river in the world?',
        'optionA': 'Amazon',
        'optionB': 'Nile',
        'optionC': 'Mississippi',
        'optionD': 'Yangtze',
        'correctOption': 'B',
        'explanation': 'The Nile River is the longest at approximately 6,650 kilometers.'
      },
      {
        'categoryId': 3,
        'question': 'Which country is known as the Land of the Rising Sun?',
        'optionA': 'China',
        'optionB': 'South Korea',
        'optionC': 'Japan',
        'optionD': 'Thailand',
        'correctOption': 'C',
        'explanation': 'Japan is known as the Land of the Rising Sun.'
      }
    ];

    for (var question in geographyQuestions) {
      await db.insert('questions', question.cast<String, Object?>());
    }
  }

  // User methods
  Future insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap().cast<String, Object?>());
  }

  Future getUserByEmail(String email) async {
    Database db = await database;
    List<Map> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future validateUser(String email, String password) async {
    Database db = await database;
    List<Map> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return maps.isNotEmpty;
  }

  // Category methods
  Future<List> getCategories() async {
    Database db = await database;
    List<Map> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i].cast<String, dynamic>());
    });
  }

  // Question methods
  Future<List> getQuestionsByCategory(int categoryId) async {
    Database db = await database;
    List<Map> maps = await db.query(
      'questions',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) {
      return Question.fromMap(maps[i]);
    });
  }

  // Result methods
  Future insertResult(Result result) async {
    Database db = await database;
    return await db.insert('results', result.toMap().cast<String, Object?>());
  }

  Future<List> getResultsByUser(int userId) async {
    Database db = await database;
    List<Map> maps = await db.query(
      'results',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Result.fromMap(maps[i]);
    });
  }

  // Existing methods and properties

  Future<void> saveQuestionResult(int resultId, int questionId, String userAnswer, String correctAnswer) async {
    // Implement the method to save the question result to the database
    // Example implementation:
    final db = await database;
    await db.insert('question_results', {
      'result_id': resultId,
      'question_id': questionId,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
    });
  }
    Future<List<QuestionResult>> getQuestionResults(int resultId) async {
    // Implement the method to fetch question results from the database
    // This is a placeholder implementation
    return [];
  }


  // existing code

  Future<String> getQuestionText(int questionId) async {
    // Implement the logic to fetch the question text from the database
    // For example:
    final db = await database;
    var result = await db.query('questions', where: 'id = ?', whereArgs: [questionId]);
    if (result.isNotEmpty) {
      return result.first['question_text'];
    } else {
      throw Exception('Question not found');
    }
  }
  // existing code

  Future<String> getCategoryName(int categoryId) async {
    // Implement the logic to get the category name from the database
    // For example:
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
    if (result.isNotEmpty) {
      return result.first['name'] as String;
    } else {
      return 'Unknown Category';
    }
  }
}


import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:jlpt_quiz/model/user.dart';
import 'package:jlpt_quiz/model/user_attempt.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Import your data model if you created one
import 'package:jlpt_quiz/model/question.dart';
import 'package:jlpt_quiz/model/passage.dart';
import 'package:jlpt_quiz/model/reading_item.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor(); // Private constructor for singleton

  Future<Database> get database async {
    print("database");
    if (_database != null) return _database!;
    print("if condition");
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print("init database: Attempting to open/create database.");

    // Get the default databases path for your application.
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'jlptquiz.db');
    print("#####");
    print(databasesPath); // Your database file name

    // Check if the database file already exists.
    bool databaseExists = await File(path).exists(); // Use File(path).exists()

    if (!databaseExists) {
      // If the database does not exist, copy it from assets.
      print("Database does not exist, copying from assets...");
      try {
        // Ensure the directory exists
        await Directory(dirname(path)).create(recursive: true);

        // Load the database from assets as a byte data.
        ByteData data =
            await rootBundle.load(join("assets", "database", "jlptquiz.db"));
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        print("##rs");
        print(data);
        print(bytes);

        // Write the bytes to the new database file.
        await File(path).writeAsBytes(bytes, flush: true);
        print("Database copied successfully from assets to: $path");
      } catch (e) {
        print("Error copying database from assets: $e");
        // Handle the error appropriately, maybe rethrow or log it.
        rethrow;
      }
    } else {
      print("Database already exists at: $path");
    }

    // Open the database. If it was just copied, it's now ready.
    // If it existed, it will just open it.
    return await openDatabase(
      path,
      version:
          3, // **IMPORTANT: Increment this to trigger onUpgrade for existing databases**
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Uncommented for database migrations
    );
  }

  // Helper method to load image bytes from assets
  Future<Uint8List?> _loadImageBytesFromAssets(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (e) {
      print("Error loading image from assets at $assetPath: $e");
      // Consider throwing an error or providing a fallback if the image is critical
      return null;
    }
  }

  // This is called when the database is first created.
  Future<void> _onCreate(Database db, int version) async {
    print("on create...");

    // Create users table
    await db.execute(
      '''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT,
        userImage BLOB
      )
      ''',
    );
    print("Users table created.");

    // Load default image bytes using 'profile.png'
    final Uint8List? defaultUserImageBytes = await _loadImageBytesFromAssets(
        'assets/images/profile.png'); // *** Changed here ***

    // Insert a default user with the image
    await db.insert(
      'users',
      {
        'userName': '名前未設定',
        'userImage': defaultUserImageBytes, // Use the loaded bytes
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Default user with profile.png image inserted into users table.");

    // Create user_attempt table
    await db.execute(
      '''
      CREATE TABLE user_attempt(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        quiz_id INTEGER NOT NULL,
        correct_score INTEGER DEFAULT 0,
        incorrect_score INTEGER DEFAULT 0,
        incomplete_score INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (quiz_id) REFERENCES quiz (id) ON DELETE CASCADE
      )
      ''',
    );
    print("user_attempt table created.");
  }

  // Called when the database needs to be upgraded (schema changes)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("onUpgrade called: $oldVersion -> $newVersion");
    // Example: Upgrade path from version 1 to 2
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE user_attempt(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          quiz_id INTEGER NOT NULL,
          correct_score INTEGER DEFAULT 0,
          incorrect_score INTEGER DEFAULT 0,
          incomplete_score INTEGER DEFAULT 0,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (quiz_id) REFERENCES quiz (id)
        )
      ''');
      print("user_attempt table created during upgrade.");

      // Logic for version 3: Insert default user with image if it doesn't exist
      if (oldVersion < 3) {
        List<Map<String, dynamic>> users = await db.query('users');
        if (users.isEmpty) {
          // Load default image bytes using 'profile.png' during upgrade
          final Uint8List? defaultUserImageBytes =
              await _loadImageBytesFromAssets(
                  'assets/images/profile.png'); // *** Changed here ***

          await db.insert(
            'users',
            {
              'userName': '名前未設定',
              'userImage': defaultUserImageBytes, // Use the loaded bytes
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          print(
              "Default 'Guest' user with profile.png image inserted during upgrade from oldVersion < 3.");
        } else {
          print(
              "Users table already contains data, skipping default user insertion during upgrade.");
        }
      }
    }
    // Add more 'if' blocks for future version upgrades:
    // if (oldVersion < 3) {
    //   // Add new tables or alter existing ones for version 3
    // }
  }

  // --- CRUD Operations ---

  Future<int> insertUser(User user) async {
    print("...Insert");
    final db = await database;
    return await db.insert(
      'users', // Table name
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Handle conflicts
    );
  }

  Future<int> updateUser(User user) async {
    print("...Update User: ${user.id}");
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getPassageWithQuestions(int quizId) async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT 
      p.id AS passage_id,
      p.paragraph,
      q.id AS question_id,
      q.sub_question,
      q.answer1,
      q.answer2,
      q.answer3,
      q.answer4,
      q.correct_answer
    FROM reading r
    LEFT JOIN passages p ON r.passage_id = p.id
    LEFT JOIN questions q ON r.question_id = q.id
    WHERE r.quiz_id = ?
    ORDER BY r.display_order ASC
  ''', [quizId]);

    // Group by passage_id
    Map<int, Map<String, dynamic>> grouped = {};

    for (var row in result) {
      final pid = row['passage_id'];
      if (pid == null) continue;

      final int passageId =
          pid is int ? pid : int.tryParse(pid.toString()) ?? -1;
      if (passageId == -1) continue;

      if (!grouped.containsKey(passageId)) {
        grouped[passageId] = {
          'paragraph': row['paragraph'],
          'questions': [],
        };
      }

      grouped[passageId]!['questions'].add({
        'id': row['question_id'],
        'sub_question': row['sub_question'],
        'answer1': row['answer1'],
        'answer2': row['answer2'],
        'answer3': row['answer3'],
        'answer4': row['answer4'],
        'correct_answer': row['correct_answer'],
      });
    }

    return grouped.entries
        .map((e) => {
              'passage_id': e.key,
              'paragraph': e.value['paragraph'],
              'questions': e.value['questions'],
            })
        .toList();
  }

  // New method to fetch questions based on year, month, level, and exam type
  Future<List<Question>> getQuestionsByQuizParameters(
      String year, String month, String level, String examType) async {
    final db = await database;

    // Use a JOIN query to filter questions based on quiz and year attributes
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        q.id,
        q.sub_question,
        q.answer1,
        q.answer2,
        q.answer3,
        q.answer4,
        q.correct_answer,
        q.quiz_id,
        qg.group_title AS group_title,
        p.paragraph AS passage
      FROM
        questions AS q
      JOIN quiz AS qz ON q.quiz_id = qz.id
      JOIN year AS y ON qz.year_id = y.id
      LEFT JOIN question_groups AS qg ON q.question_groups_id = qg.id
      LEFT JOIN reading AS r ON r.question_id = q.id
      LEFT JOIN passages AS p ON r.passage_id = p.id
      WHERE
        y.year = ? AND y.month = ? AND qz.type = ? AND qz.level = ?
    ''', [year, month, examType, level]); // Order of parameters matters!

    print(
        "Fetched ${maps.length} questions for Year: $year, Month: $month, Type: $examType, Level: $level");
    print("Query results: $maps");

    // Convert the List<Map<String, dynamic>> into a List<Question>.
    return List.generate(maps.length, (i) {
      return Question.fromMap(maps[i]);
    });
  }

  Future<Question?> getQuestionById(int id) async {
    print("####ABCD");
    print(getQuestionById);
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    print("Query result for question id=$id: $result");

    if (result.isNotEmpty) {
      return Question.fromMap(result.first);
    } else {
      return null;
    }
  }

  // Method to insert a user attempt
  Future<int> insertUserAttempt(int userId, int quizId, int correctScore,
      int incorrectScore, int incompleteScore) async {
    final db = await database;
    String createdAt = DateTime.now().toIso8601String();
    return await db.insert(
      'user_attempt',
      {
        'user_id': userId,
        'quiz_id': quizId,
        'correct_score': correctScore,
        'incorrect_score': incorrectScore,
        'incomplete_score': incompleteScore,
        'created_at': createdAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
// Inside DatabaseHelper class

  Future<List<UserAttempt>> getUserAttemptHistory(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT
        ua.id,
        ua.user_id,
        ua.quiz_id,
        ua.correct_score,
        ua.incorrect_score,
        ua.incomplete_score,
        ua.created_at,
        qz.type AS quiz_type
    FROM
        user_attempt AS ua
    JOIN
        quiz AS qz ON ua.quiz_id = qz.id
    JOIN
        year AS y ON qz.year_id = y.id
    WHERE
        ua.user_id = ?
    ORDER BY
        ua.created_at DESC
  ''', [userId]);

    print("Fetched ${maps.length} user attempts for user ID: $userId");
    print("User attempt history results: $maps");

    // Convert to List<UserAttempt>
    return List.generate(maps.length, (i) {
      return UserAttempt.fromMap(maps[i]);
    });
  }

  Future<Uint8List?> getUserImageById(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      columns: ['userImage'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['userImage'] as Uint8List?;
    }
    return null;
  }

  // Close the database (optional, as it's often kept open for the app's lifetime)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null; // Clear the instance
  }
}

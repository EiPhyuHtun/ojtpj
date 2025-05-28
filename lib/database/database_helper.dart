import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:jlpt_quiz/model/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Import your data model if you created one

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor(); // Private constructor for singleton

  Future<Database> get database async {

    print("database");
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print("init database: Attempting to open/create database.");

    // Get the default databases path for your application.
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'feqiz_db.db'); // Your database file name

    // Check if the database file already exists.
    bool databaseExists = await File(path).exists(); // Use File(path).exists()

    if (!databaseExists) {
      // If the database does not exist, copy it from assets.
      print("Database does not exist, copying from assets...");
      try {
        // Ensure the directory exists
        await Directory(dirname(path)).create(recursive: true);

        // Load the database from assets as a byte data.
        ByteData data = await rootBundle.load(join("assets", "database", "jlptquiz.db"));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

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
      version: 1, // Use the version of your pre-created database
      onCreate: _onCreate,
    );
  }

  // This is called when the database is first created.
  Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE TABLE statement on the database.
    print("on create...");
    await db.execute(
      '''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT,
        userImage BLOB
      )
      ''',
    );
  }

  // Optional: For database migrations if your schema changes in future versions
  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     // Example: Add a new column in version 2
  //     await db.execute('ALTER TABLE dogs ADD COLUMN breed TEXT');
  //   }
  // }

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
 
  // Get all images
    Future<List<Map<String, dynamic>>> getUsers() async {
      Database db = await database;
      return await db.query('users');
    }

  
  // Close the database (optional, as it's often kept open for the app's lifetime)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null; // Clear the instance
  }
}
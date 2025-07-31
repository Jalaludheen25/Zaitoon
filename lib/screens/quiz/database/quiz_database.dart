import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:zaitoon/screens/quiz/models/quiz_models.dart';

class QuizDatabase {
  static const _databaseName = "quiz_database.db";
  static const _databaseVersion = 1;

  // Tables
  static const tableQuizSessions = 'quiz_sessions';
  static const tableQuizAnswers = 'quiz_answers';

  QuizDatabase._privateConstructor();
  static final QuizDatabase instance = QuizDatabase._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableQuizSessions (
        session_id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_uuid TEXT NOT NULL UNIQUE,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        language TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER,
        total_time_taken INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        is_submitted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableQuizAnswers (
        answer_id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_uuid TEXT NOT NULL,
        question_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_answer INTEGER NOT NULL,
        selected_answer INTEGER,
        time_taken INTEGER NOT NULL,
        is_correct INTEGER NOT NULL,
        FOREIGN KEY (session_uuid) REFERENCES $tableQuizSessions (session_uuid)
      )
    ''');
  }

  // Quiz Session Operations
  Future<int> insertQuizSession(QuizSession session) async {
    Database db = await instance.database;
    return await db.insert(tableQuizSessions, session.toMap());
  }

  Future<QuizSession?> getQuizSession(String sessionUuid) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableQuizSessions,
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
    );
    
    if (maps.isNotEmpty) {
      return QuizSession.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateQuizSession(QuizSession session) async {
    Database db = await instance.database;
    return await db.update(
      tableQuizSessions,
      session.toMap(),
      where: 'session_uuid = ?',
      whereArgs: [session.sessionUuid],
    );
  }

  Future<List<QuizSession>> getAllQuizSessions() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableQuizSessions,
      orderBy: 'start_time DESC',
    );
    
    return List.generate(maps.length, (i) => QuizSession.fromMap(maps[i]));
  }

  Future<List<QuizSession>> getCompletedQuizSessions() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableQuizSessions,
      where: 'is_completed = ?',
      whereArgs: [1],
      orderBy: 'start_time DESC',
    );
    
    return List.generate(maps.length, (i) => QuizSession.fromMap(maps[i]));
  }

  Future<List<QuizSession>> getUnsubmittedQuizSessions() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableQuizSessions,
      where: 'is_completed = ? AND is_submitted = ?',
      whereArgs: [1, 0],
      orderBy: 'start_time DESC',
    );
    
    return List.generate(maps.length, (i) => QuizSession.fromMap(maps[i]));
  }

  // Quiz Answer Operations
  Future<int> insertQuizAnswer(QuizAnswer answer) async {
    Database db = await instance.database;
    return await db.insert(tableQuizAnswers, answer.toMap());
  }

  Future<List<QuizAnswer>> getQuizAnswers(String sessionUuid) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableQuizAnswers,
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
      orderBy: 'question_id ASC',
    );
    
    return List.generate(maps.length, (i) => QuizAnswer.fromMap(maps[i]));
  }

  Future<int> updateQuizAnswer(QuizAnswer answer) async {
    Database db = await instance.database;
    return await db.update(
      tableQuizAnswers,
      answer.toMap(),
      where: 'session_uuid = ? AND question_id = ?',
      whereArgs: [answer.sessionUuid, answer.questionId],
    );
  }

  // Quiz Statistics
  Future<Map<String, dynamic>> getQuizStatistics() async {
    Database db = await instance.database;
    
    // Total quizzes taken
    var totalQuizzesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableQuizSessions WHERE is_completed = 1'
    );
    int totalQuizzes = totalQuizzesResult.first['count'] as int;
    
    // Average score
    var avgScoreResult = await db.rawQuery(
      'SELECT AVG(CAST(correct_answers AS REAL) / total_questions * 100) as avg_score FROM $tableQuizSessions WHERE is_completed = 1'
    );
    double avgScore = (avgScoreResult.first['avg_score'] as double?) ?? 0.0;
    
    // Best score
    var bestScoreResult = await db.rawQuery(
      'SELECT MAX(CAST(correct_answers AS REAL) / total_questions * 100) as best_score FROM $tableQuizSessions WHERE is_completed = 1'
    );
    double bestScore = (bestScoreResult.first['best_score'] as double?) ?? 0.0;
    
    // Total time spent
    var totalTimeResult = await db.rawQuery(
      'SELECT SUM(total_time_taken) as total_time FROM $tableQuizSessions WHERE is_completed = 1'
    );
    int totalTime = (totalTimeResult.first['total_time'] as int?) ?? 0;
    
    return {
      'totalQuizzes': totalQuizzes,
      'averageScore': avgScore,
      'bestScore': bestScore,
      'totalTimeSpent': totalTime,
    };
  }

  // Utility functions
  Future<void> markSessionAsSubmitted(String sessionUuid) async {
    Database db = await instance.database;
    await db.update(
      tableQuizSessions,
      {'is_submitted': 1},
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
    );
  }

  Future<void> deleteQuizSession(String sessionUuid) async {
    Database db = await instance.database;
    await db.delete(
      tableQuizAnswers,
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
    );
    await db.delete(
      tableQuizSessions,
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
    );
  }

  Future<void> clearAllData() async {
    Database db = await instance.database;
    await db.delete(tableQuizAnswers);
    await db.delete(tableQuizSessions);
  }
} 
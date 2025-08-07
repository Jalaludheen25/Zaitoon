import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:zaitoon/screens/quiz/models/quiz_models.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'dart:convert'; // Added for jsonEncode

class QuizDatabase {
  static final QuizDatabase instance = QuizDatabase._init();
  static Database? _database;
  
  static const _databaseVersion = 3; // Increment version for new migration
  static const _databaseName = 'quiz_database_v3.db'; // Update name to force fresh DB
  
  // Table names
  static const String _tableQuizSessions = 'quiz_sessions';
  static const String _tableQuizAnswers = 'quiz_answers';

  QuizDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      // Add new columns to quiz_sessions table
      debugPrint('Adding new columns to quiz_sessions table');
      await db.execute('ALTER TABLE $_tableQuizSessions ADD COLUMN id INTEGER PRIMARY KEY AUTOINCREMENT');
      await db.execute('ALTER TABLE $_tableQuizSessions ADD COLUMN attempt_id TEXT');
      
      // Update existing records to have an id
      debugPrint('Updating existing records with new id');
      final List<Map<String, dynamic>> existingRecords = await db.query(_tableQuizSessions);
      for (var record in existingRecords) {
        await db.update(
          _tableQuizSessions,
          {'id': DateTime.now().millisecondsSinceEpoch},
          where: 'session_uuid = ?',
          whereArgs: [record['session_uuid']],
        );
      }
    }

    if (oldVersion < 3) {
      // Recreate quiz_answers table with correct column names
      debugPrint('Recreating quiz_answers table with correct schema');
      await db.execute('DROP TABLE IF EXISTS $_tableQuizAnswers');
      await db.execute('''
        CREATE TABLE $_tableQuizAnswers(
          answer_id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_uuid TEXT NOT NULL,
          question_id INTEGER NOT NULL,
          question TEXT NOT NULL,
          options TEXT NOT NULL,
          correct_answer INTEGER NOT NULL,
          selected_answer INTEGER,
          time_taken INTEGER NOT NULL,
          is_correct INTEGER NOT NULL
        )
      ''');
    }
  }

  Future _onCreate(Database db, int version) async {
    debugPrint('Creating new database at version $version');
    
    await db.execute('''
      CREATE TABLE $_tableQuizSessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_uuid TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        language TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER,
        total_time_taken INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        is_submitted INTEGER NOT NULL DEFAULT 0,
        attempt_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableQuizAnswers(
        answer_id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_uuid TEXT NOT NULL,
        question_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_answer INTEGER NOT NULL,
        selected_answer INTEGER,
        time_taken INTEGER NOT NULL,
        is_correct INTEGER NOT NULL
      )
    ''');
  }

  // Get latest submitted session
  Future<QuizSession?> getLatestSubmittedSession() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quiz_sessions',
      where: 'is_submitted = ? AND attempt_id IS NOT NULL',
      whereArgs: [1],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return QuizSession(
      sessionId: maps[0]['id'],
      sessionUuid: maps[0]['session_uuid'],
      startTime: DateTime.parse(maps[0]['start_time']),
      endTime: maps[0]['end_time'] != null ? DateTime.parse(maps[0]['end_time']) : null,
      language: maps[0]['language'],
      totalQuestions: maps[0]['total_questions'],
      correctAnswers: maps[0]['correct_answers'],
      totalTimeTaken: maps[0]['total_time_taken'],
      isCompleted: maps[0]['is_completed'] == 1,
      isSubmitted: maps[0]['is_submitted'] == 1,
      attemptId: maps[0]['attempt_id'],
    );
  }

  // Update existing methods to handle attemptId
  Future<void> insertQuizSession(QuizSession session) async {
    final db = await database;
    await db.insert(
      'quiz_sessions',
      {
        'session_uuid': session.sessionUuid,
        'start_time': session.startTime.toIso8601String(),
        'end_time': session.endTime?.toIso8601String(),
        'language': session.language,
        'total_questions': session.totalQuestions,
        'correct_answers': session.correctAnswers,
        'total_time_taken': session.totalTimeTaken,
        'is_completed': session.isCompleted ? 1 : 0,
        'is_submitted': session.isSubmitted ? 1 : 0,
        'attempt_id': session.attemptId,
      },
    );
  }

  Future<QuizSession?> getQuizSession(String sessionUuid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quiz_sessions',
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
    );
    
    if (maps.isEmpty) {
      return null;
    }

    return QuizSession(
      sessionId: maps[0]['id'],
      sessionUuid: maps[0]['session_uuid'],
      startTime: DateTime.parse(maps[0]['start_time']),
      endTime: maps[0]['end_time'] != null ? DateTime.parse(maps[0]['end_time']) : null,
      language: maps[0]['language'],
      totalQuestions: maps[0]['total_questions'],
      correctAnswers: maps[0]['correct_answers'],
      totalTimeTaken: maps[0]['total_time_taken'],
      isCompleted: maps[0]['is_completed'] == 1,
      isSubmitted: maps[0]['is_submitted'] == 1,
      attemptId: maps[0]['attempt_id'],
    );
  }

  Future<void> updateQuizSession(QuizSession session) async {
    final db = await database;
    await db.update(
      'quiz_sessions',
      {
        'end_time': session.endTime?.toIso8601String(),
        'correct_answers': session.correctAnswers,
        'total_time_taken': session.totalTimeTaken,
        'is_completed': session.isCompleted ? 1 : 0,
        'is_submitted': session.isSubmitted ? 1 : 0,
        'attempt_id': session.attemptId,
      },
      where: 'session_uuid = ?',
      whereArgs: [session.sessionUuid],
    );
  }

  Future<List<QuizSession>> getAllQuizSessions() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _tableQuizSessions,
      orderBy: 'start_time DESC',
    );
    
    return List.generate(maps.length, (i) => QuizSession.fromMap(maps[i]));
  }

  Future<List<QuizSession>> getCompletedQuizSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quiz_sessions',
      where: 'is_completed = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );
    
    return List.generate(maps.length, (i) {
      return QuizSession(
        sessionId: maps[i]['id'],
        sessionUuid: maps[i]['session_uuid'],
        startTime: DateTime.parse(maps[i]['start_time']),
        endTime: maps[i]['end_time'] != null ? DateTime.parse(maps[i]['end_time']) : null,
        language: maps[i]['language'],
        totalQuestions: maps[i]['total_questions'],
        correctAnswers: maps[i]['correct_answers'],
        totalTimeTaken: maps[i]['total_time_taken'],
        isCompleted: maps[i]['is_completed'] == 1,
        isSubmitted: maps[i]['is_submitted'] == 1,
        attemptId: maps[i]['attempt_id'],
      );
    });
  }

  Future<List<QuizSession>> getUnsubmittedQuizSessions() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _tableQuizSessions,
      where: 'is_completed = ? AND is_submitted = ?',
      whereArgs: [1, 0],
      orderBy: 'start_time DESC',
    );
    
    return List.generate(maps.length, (i) => QuizSession.fromMap(maps[i]));
  }

  // Quiz Answer Operations
  Future<int> insertQuizAnswer(QuizAnswer answer) async {
    final db = await database;
    return await db.insert(
      _tableQuizAnswers,
      {
        'session_uuid': answer.sessionUuid,
        'question_id': answer.questionId,
        'question': answer.question,
        'options': jsonEncode(answer.options),
        'correct_answer': answer.correctAnswer,
        'selected_answer': answer.selectedAnswer,
        'time_taken': answer.timeTaken,
        'is_correct': answer.isCorrect ? 1 : 0,
      },
    );
  }

  Future<List<QuizAnswer>> getQuizAnswers(String sessionUuid) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _tableQuizAnswers,
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
      orderBy: 'question_id ASC',
    );
    
    return List.generate(maps.length, (i) => QuizAnswer.fromMap(maps[i]));
  }

  Future<int> updateQuizAnswer(QuizAnswer answer) async {
    Database db = await instance.database;
    return await db.update(
      _tableQuizAnswers,
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
      'SELECT COUNT(*) as count FROM $_tableQuizSessions WHERE is_completed = 1'
    );
    int totalQuizzes = totalQuizzesResult.first['count'] as int;
    
    // Average score
    var avgScoreResult = await db.rawQuery(
      'SELECT AVG(CAST(correct_answers AS REAL) / total_questions * 100) as avg_score FROM $_tableQuizSessions WHERE is_completed = 1'
    );
    double avgScore = (avgScoreResult.first['avg_score'] as double?) ?? 0.0;
    
    // Best score
    var bestScoreResult = await db.rawQuery(
      'SELECT MAX(CAST(correct_answers AS REAL) / total_questions * 100) as best_score FROM $_tableQuizSessions WHERE is_completed = 1'
    );
    double bestScore = (bestScoreResult.first['best_score'] as double?) ?? 0.0;
    
    // Total time spent
    var totalTimeResult = await db.rawQuery(
      'SELECT SUM(total_time_taken) as total_time FROM $_tableQuizSessions WHERE is_completed = 1'
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
      _tableQuizSessions,
      {'is_submitted': 1},
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
    );
  }

  Future<void> deleteQuizSession(String sessionUuid) async {
    Database db = await instance.database;
    await db.delete(
      _tableQuizAnswers,
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
    );
    await db.delete(
      _tableQuizSessions,
      where: 'session_uuid = ?',
      whereArgs: [sessionUuid],
    );
  }

  Future<void> clearAllData() async {
    Database db = await instance.database;
    await db.delete(_tableQuizAnswers);
    await db.delete(_tableQuizSessions);
  }
} 
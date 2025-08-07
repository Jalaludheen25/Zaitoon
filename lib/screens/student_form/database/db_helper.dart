import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/student_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'students.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        mobile TEXT NOT NULL,
        gender TEXT NOT NULL,
        className TEXT NOT NULL,
        district TEXT NOT NULL
      )
    ''');
  }

  // Insert a new student
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  // Get all students
  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // Get a specific student by id
  Future<Student?> getStudent(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<Student?> getStudentByMobile(String mobile) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'mobile = ?',
      whereArgs: [mobile],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Student.fromMap(maps.first);
  }

  // Update a student
  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // Delete a student
  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

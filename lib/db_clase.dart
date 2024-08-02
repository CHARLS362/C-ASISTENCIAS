import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'school.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        period TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER,
        last_name TEXT,
        first_name TEXT,
        phone_number TEXT,
        FOREIGN KEY (course_id) REFERENCES courses (id)
      )
    ''');
  }

  // Métodos para la tabla de cursos
  Future<int> insertCourse(String name, String period) async {
    Database db = await database;
    return await db.insert('courses', {'name': name, 'period': period});
  }

  Future<int> updateCourse(int id, String name, String period) async {
    Database db = await database;
    return await db.update(
      'courses',
      {'name': name, 'period': period},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCourse(int id) async {
    Database db = await database;
    return await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    Database db = await database;
    return await db.query('courses');
  }

  // Métodos para la tabla de estudiantes
  Future<int> insertStudent(int courseId, String lastName, String firstName,
      String phoneNumber) async {
    Database db = await database;
    return await db.insert('students', {
      'course_id': courseId,
      'last_name': lastName,
      'first_name': firstName,
      'phone_number': phoneNumber,
    });
  }

  Future<int> updateStudent(
      int id, String lastName, String firstName, String phoneNumber) async {
    Database db = await database;
    return await db.update(
      'students',
      {
        'last_name': lastName,
        'first_name': firstName,
        'phone_number': phoneNumber,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStudent(int id) async {
    Database db = await database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getStudents(int courseId) async {
    Database db = await database;
    return await db.query(
      'students',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }
}

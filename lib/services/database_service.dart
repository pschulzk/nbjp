import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/training.dart';
import '../models/session.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nbjp.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE training(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        max_reps INTEGER NOT NULL,
        sets_count INTEGER NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        training_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        planned_reps TEXT NOT NULL,
        actual_reps TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        FOREIGN KEY (training_id) REFERENCES training (id)
      )
    ''');
  }

  // Training methods
  Future<int> insertTraining(Training training) async {
    final db = await database;
    return await db.insert('training', training.toMap());
  }

  Future<Training?> getTraining() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'training',
      orderBy: 'updated_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Training.fromMap(maps.first);
  }

  Future<int> updateTraining(Training training) async {
    final db = await database;
    return await db.update(
      'training',
      training.toMap(),
      where: 'id = ?',
      whereArgs: [training.id],
    );
  }

  // Session methods
  Future<int> insertSession(Session session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  Future<List<Session>> getSessions({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      orderBy: 'date DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Session.fromMap(maps[i]);
    });
  }

  Future<List<Session>> getSessionsByTrainingId(int trainingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'training_id = ?',
      whereArgs: [trainingId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Session.fromMap(maps[i]);
    });
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    // Get total sessions
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM sessions');
    final totalSessions = countResult.first['count'] as int;
    
    // Get total pushups
    final sessions = await getSessions();
    int totalPushups = 0;
    for (var session in sessions) {
      totalPushups += session.totalActualReps;
    }
    
    // Get average completion rate
    double avgCompletionRate = 0;
    if (sessions.isNotEmpty) {
      double totalRate = 0;
      for (var session in sessions) {
        totalRate += session.completionRate;
      }
      avgCompletionRate = totalRate / sessions.length;
    }
    
    return {
      'totalSessions': totalSessions,
      'totalPushups': totalPushups,
      'avgCompletionRate': avgCompletionRate,
    };
  }
}
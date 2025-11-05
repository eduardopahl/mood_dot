import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_entry_model.dart';

abstract class MoodLocalDataSource {
  Future<int> insertMoodEntry(MoodEntryModel entry);
  Future<List<MoodEntryModel>> getAllMoodEntries();
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<MoodEntryModel?> getMoodEntryByDate(DateTime date);
  Future<int> updateMoodEntry(MoodEntryModel entry);
  Future<int> deleteMoodEntry(int id);
  Future<Map<String, dynamic>> getMoodStatistics();
}

class MoodLocalDataSourceImpl implements MoodLocalDataSource {
  static Database? _database;
  static const String _databaseName = 'mooddot.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'mood_entries';

  // Singleton pattern
  MoodLocalDataSourceImpl._privateConstructor();
  static final MoodLocalDataSourceImpl instance =
      MoodLocalDataSourceImpl._privateConstructor();

  // Getter para o database
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Inicializar o banco de dados
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Criar tabelas
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        mood_level INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<int> insertMoodEntry(MoodEntryModel entry) async {
    Database db = await database;
    return await db.insert(_tableName, entry.toMap());
  }

  @override
  Future<List<MoodEntryModel>> getAllMoodEntries() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return MoodEntryModel.fromMap(maps[i]);
    });
  }

  @override
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return MoodEntryModel.fromMap(maps[i]);
    });
  }

  @override
  Future<MoodEntryModel?> getMoodEntryByDate(DateTime date) async {
    Database db = await database;

    // Normalizar a data para comparar apenas ano, mês e dia
    String dateString =
        DateTime(date.year, date.month, date.day).toIso8601String();

    List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'date LIKE ?',
      whereArgs: ['${dateString.substring(0, 10)}%'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return MoodEntryModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> updateMoodEntry(MoodEntryModel entry) async {
    Database db = await database;
    return await db.update(
      _tableName,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  @override
  Future<int> deleteMoodEntry(int id) async {
    Database db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Map<String, dynamic>> getMoodStatistics() async {
    Database db = await database;

    // Média geral do humor
    List<Map<String, dynamic>> avgResult = await db.rawQuery(
      'SELECT AVG(mood_level) as average FROM $_tableName',
    );

    // Contagem por nível de humor
    List<Map<String, dynamic>> countResult = await db.rawQuery(
      'SELECT mood_level, COUNT(*) as count FROM $_tableName GROUP BY mood_level',
    );

    // Última entrada
    List<Map<String, dynamic>> lastEntryResult = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
      limit: 1,
    );

    return {
      'average': avgResult.first['average'] ?? 0.0,
      'countByLevel': countResult,
      'lastEntry':
          lastEntryResult.isNotEmpty
              ? MoodEntryModel.fromMap(lastEntryResult.first)
              : null,
      'totalEntries': await _getTotalEntries(),
    };
  }

  // Buscar total de entradas
  Future<int> _getTotalEntries() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName',
    );
    return result.first['count'] ?? 0;
  }

  // Fechar o banco de dados
  Future<void> close() async {
    Database db = await database;
    await db.close();
  }

  // Limpar todos os dados (útil para desenvolvimento/testes)
  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete(_tableName);
  }
}

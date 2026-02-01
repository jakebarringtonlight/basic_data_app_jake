import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineDatabase {
  OfflineDatabase._();
  static final OfflineDatabase instance = OfflineDatabase._();

  static Database? _database;

  Future<Database> get database async {
    final database = _database;
    if (database != null) return database;
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'offline_warehouse.db');

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            server_id INTEGER,
            username TEXT NOT NULL UNIQUE,
            role TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          );
        ''');

        await database.execute('''
          CREATE TABLE maintenance_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            server_id INTEGER,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            priority TEXT NOT NULL,
            status TEXT NOT NULL,
            user_id INTEGER,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP,

            -- offline/sync fields
            is_synced INTEGER NOT NULL DEFAULT 0,
            needs_upload INTEGER NOT NULL DEFAULT 1
          );
        ''');

        await database.execute(
          'CREATE INDEX idx_logs_needs_upload ON maintenance_logs(needs_upload);',
        );
        await database.execute(
          'CREATE INDEX idx_logs_server_id ON maintenance_logs(server_id);',
        );
      },
    );
  }

  Future<int> addLog({
    required String title,
    required String description,
    required String priority,
    required String status,
    int? userId,
  }) async {
    final db = await database;
    return db.insert('maintenance_logs', {
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'user_id': userId,
      'created_at': DateTime.now(),
      'updated_at': DateTime.now(),
      'is_synced': 0,
      'needs_upload': 1,
    });
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    final db = await database;
    return db.query(
      'maintenance_logs',
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getLogById(int localId) async {
    final db = await database;
    final rows = await db.query(
      'maintenance_logs',
      where: 'id = ?',
      whereArgs: [localId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> getLogsForUpload() async {
    final db = await database;
    return db.query(
      'maintenance_logs',
      where: 'needs_upload = 1',
      orderBy: 'created_at ASC',
    );
  }

  Future<int> updateLog({
    required int localId,
    String? title,
    String? description,
    String? priority,
    String? status,
    int? userId,
  }) async {
    final db = await database;

    final Map<String, Object?> update = {};
    if (title != null) update['title'] = title;
    if (description != null) update['description'] = description;
    if (priority != null) update['priority'] = priority;
    if (status != null) update['status'] = status;
    if (userId != null) update['user_id'] = userId;

    if (update.isEmpty) return 0;

    update['updated_at'] = DateTime.now();
    update['needs_upload'] = 1;
    update['is_synced'] = 0;

    return db.update(
      'maintenance_logs',
      update,
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<int> logUploaded({
    required int localId,
    required int serverId,
  }) async {
    final db = await database;
    return db.update(
      'maintenance_logs',
      {
        'server_id': serverId,
        'is_synced': 1,
        'needs_upload': 0,
        'updated_at': DateTime.now(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> loadLogsFromServer({
    required int serverId,
    required String title,
    required String description,
    required String priority,
    required String status,
    int? userId,
    String? createdAt,
    String? updatedAt,
  }) async {
    final db = await database;
    
    final existing = await db.query(
      'maintenance_logs',
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    final row = <String, Object?>{
      'server_id': serverId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'user_id': userId,
      'created_at': createdAt ?? DateTime.now(),
      'updated_at': updatedAt ?? DateTime.now(),
      'is_synced': 1,
      'needs_upload': 0,
    };

    if (existing.isEmpty) {
      await db.insert('maintenance_logs', row);
    } else {
      await db.update(
        'maintenance_logs',
        row,
        where: 'server_id = ?',
        whereArgs: [serverId],
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

}

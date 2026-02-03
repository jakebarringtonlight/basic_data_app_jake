import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';


class OfflineDatabase {
  OfflineDatabase._();
  static final OfflineDatabase instance = OfflineDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Offline database is disabled on web');
    }
    final database = _database;
    if (database != null) return database;
    _database = await setup();
    return _database!;
  }

  // Setup offline database
  Future<Database> setup() async {
    if (kIsWeb) {
      throw UnsupportedError('Offline database is disabled on web');
    }
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
            summary TEXT NOT NULL,
            aircraft_reg TEXT NOT NULL,
            maintenance_type TEXT NOT NULL,
            priority TEXT NOT NULL,
            technician_name TEXT,
            notes TEXT,
            user_id INTEGER,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

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

  // Method to add log offline
  Future<int> addLog({
    required String summary,
    required String aircraft_reg,
    required String maintenance_type,
    required String priority,
    required String technician_name,
    required String notes,
    int? userId,
  }) async {
    if (kIsWeb) return 0;
    final databaseHandler = await database;
    return databaseHandler.insert('maintenance_logs', {
      'summary': summary,
      'aircraft_reg': aircraft_reg,
      'maintenance_type': maintenance_type,
      'priority': priority,
      'technician_name': technician_name,
      'notes': notes,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'needs_upload': 1,
    });
  }
  // Method to get all logs offline
  Future<List<Map<String, dynamic>>> getAllLogs() async {
    if (kIsWeb) return [];
    final databaseHandler = await database;
    return databaseHandler.query(
      'maintenance_logs',
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getLog(int offlineId) async {
    if (kIsWeb) return null;
    final databaseHandler = await database;
    final rows = await databaseHandler.query(
      'maintenance_logs',
      where: 'id = ?',
      whereArgs: [offlineId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

// Method to get all logs offline that are needing upload
  Future<List<Map<String, dynamic>>> getLogsForUpload() async {
    if (kIsWeb) return [];
    final databaseHandler = await database;
    return databaseHandler.query(
      'maintenance_logs',
      where: 'needs_upload = 1',
    );
  }
  // Method to update a log
  // Not used due to scope and time constraints.
  Future<int> updateLog({
    required int offlineId,
    String? summary,
    String? aircraft_reg,
    String? maintenance_type,
    String? priority,
    String? technician_name,
    String? notes,
    int? userId,
  }) async {
    if (kIsWeb) return 0;
    final databaseHandler = await database;

    final Map<String, Object?> update = {};
    if (summary != null) update['summary'] = summary;
    if (aircraft_reg != null) update['aircraft_reg'] = aircraft_reg;
    if (maintenance_type != null) update['maintenance_type'] = maintenance_type;
    if (priority != null) update['priority'] = priority;
    if (technician_name != null) update['technician_name'] = technician_name;
    if (notes != null) update['notes'] = notes;
    if (userId != null) update['user_id'] = userId;

    if (update.isEmpty) return 0;

    update['updated_at'] = DateTime.now().toIso8601String();
    update['needs_upload'] = 1;
    update['is_synced'] = 0;

    return databaseHandler.update(
      'maintenance_logs',
      update,
      where: 'id = ?',
      whereArgs: [offlineId],
    );
  }

  //Method for log upload
  Future<int> logUploadSuccess({
    required int offlineId,
    required int serverId,
  }) async {
    if (kIsWeb) return 0;
    final databaseHandler = await database;
    return databaseHandler.update(
      'maintenance_logs',
      {
        'server_id': serverId,
        'is_synced': 1,
        'needs_upload': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [offlineId],
    );
  }

  // Method to get all logs from online
  Future<void> downloadLogs({
    required int serverId,
    required String summary,
    required String aircraftReg,
    required String maintenanceType,
    required String priority,
    required String technicianName,
    required String notes,
    int? userId,
    String? createdAt,
    String? updatedAt,
  }) async {
    if (kIsWeb) return;
    final databaseHandler = await database;
    
    final existing = await databaseHandler.query(
      'maintenance_logs',
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    final row = <String, Object?>{
      'server_id': serverId,
      'summary': summary,
      'aircraft_reg': aircraftReg,
      'maintenance_type': maintenanceType,
      'priority': priority,
      'technician_name': technicianName,
      'notes': notes,
      'user_id': userId,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
      'is_synced': 1,
      'needs_upload': 0,
    };

    if (existing.isEmpty) {
      await databaseHandler.insert('maintenance_logs', row);
    } else {
      await databaseHandler.update(
        'maintenance_logs',
        row,
        where: 'server_id = ?',
        whereArgs: [serverId],
      );
    }
  }

  // Method to delete log offline with offline ID
  Future<int> deleteLogOffline(int offlineId) async
  {
    if (kIsWeb) return 0;
    final databaseHandler = await database;
    return databaseHandler.delete('maintenance_logs', where: 'id = ?', whereArgs: [offlineId]);
  }

  // Method to delete log offline with online ID
  Future<int> deleteLogWithServerId(int server_id) async
  {
    if (kIsWeb) return 0;
    final databaseHandler = await database;
    return databaseHandler.delete('maintenance_logs', where: 'server_id = ?', whereArgs: [server_id]);
  }

}

import 'package:my_menu_app/offline_database.dart';
import 'package:my_menu_app/warehouse_api.dart';
import 'package:flutter/foundation.dart';

class ServerSynchronize {
  ServerSynchronize._();
  static final ServerSynchronize instance = ServerSynchronize._();

  final offline = OfflineDatabase.instance;

  final WarehouseApi api = WarehouseApi(baseUrl: 'http://127.0.0.1:8080');

  // Method to synchronize a log
  Future<void> synchronizeLog(int offlineId) async {
    if (kIsWeb) return;
    final row = await offline.getLog(offlineId);
    if(row == null) return;

    final needsUpload = (row['needs_upload'] as int? ?? 0) == 1;
    if (!needsUpload) return;
      final createdLog = await api.createLog(summary: row['summary'], aircraftReg: row['aircraft_reg'], maintenanceType: row['maintenance_type'], 
      priority: row['priority'], technicianName: row['technician_name'], notes: row['notes']);

      final serverId = createdLog['id'];
      if (serverId is int)
      {
        await offline.logUploadSuccess(offlineId: offlineId, serverId: serverId);
      }
  }

  // Method to upload all offline logs
  Future<void> uploadAllLogs() async
  {
    if (kIsWeb) return;
    final pendingLog = await offline.getLogsForUpload();
    for (final row in pendingLog)
    {
      final offlineId = row['id'] as int;
      await synchronizeLog(offlineId);
    }
  }

  // Method to download all online logs
  Future<void> downloadAllLogs() async 
  {
      if (kIsWeb) return;
      final onlineLogs = await api.listLogs();

      for (final row in onlineLogs)
      {
        await offline.downloadLogs(serverId: row['id'], summary: row['summary'], aircraftReg: row['aircraft_reg'], maintenanceType: row['maintenance_type'], 
        priority: row['priority'], technicianName: row['technician_name'], notes: row['notes'], createdAt: row['created_at'], updatedAt: row['updated_at']);
      }
  }

  // Method to upload and download all logs at once to do one big synchronization
  Future<void> synchronizeAll() async
  {
    if (kIsWeb) return;
    await uploadAllLogs();
    await downloadAllLogs();
  }

}

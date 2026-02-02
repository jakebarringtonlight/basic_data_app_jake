import 'package:my_menu_app/offline_database.dart';
import 'package:my_menu_app/warehouse_api.dart';

class ServerSynchronize {
  ServerSynchronize._();
  static final ServerSynchronize instance = ServerSynchronize._();

  final offline = OfflineDatabase.instance;

  final WarehouseApi api = WarehouseApi(baseUrl: 'http://127.0.0.1:8080');


  Future<void> synchronizeLog(int offlineId) async {
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

  Future<void> uploadAllLogs() async
  {
    final pendingLog = await offline.getLogsForUpload();
    for (final row in pendingLog)
    {
      final offlineId = row['id'] as int;
      await synchronizeLog(offlineId);
    }
  }

  Future<void> downloadAllLogs() async 
  {
      final onlineLogs = await api.listLogs();

      for (final row in onlineLogs)
      {
        await offline.downloadLogs(serverId: row['id'], summary: row['summary'], aircraftReg: row['aircraft_reg'], maintenanceType: row['maintenance_type'], 
        priority: row['priority'], technicianName: row['technician_name'], notes: row['notes'], createdAt: row['created_at'], updatedAt: row['updated_at']);
      }
  }

  Future<void> synchronizeAll() async
  {
    await uploadAllLogs();
    await downloadAllLogs();
  }

}
import 'dart:convert';
import 'package:http/http.dart' as http;

class WarehouseApi {
  WarehouseApi({required this.baseUrl});

  final String baseUrl;

  static const apiKey = 'api_warehouse_student_key_1234567890abcdef';

  Map<String, String> _jsonHeaders() => {
        'Content-Type': 'application/json',
      };

  Map<String, String> _authHeaders() => {
        ..._jsonHeaders(),
        'X-API-Key': apiKey,
      };

  Future<Map<String, dynamic>> createUser({
    required String username,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/users'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/users/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200)
    {
      final body = jsonDecode(response.body);
      final error = body['error'] ?? "Login failed.";
      throw Exception(error);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createLog({
    required String summary,
    required String aircraftReg,
    required String maintenanceType,
    required String priority,
    required String technicianName,
    required String notes,
    int? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/logs'),
      headers: _authHeaders(),
      body: jsonEncode({
        'summary': summary,
        'aircraft_reg': aircraftReg,
        'maintenance_type': maintenanceType,
        'priority': priority,
        'technician_name': technicianName,
        'notes': notes,
        'user_id': userId,
      }),
    );
    if (response.statusCode != 201) 
    {
      final body = jsonDecode(response.body);
      final error = body['error'] ?? "Create log failed.";
      throw Exception(error);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listLogs() async {
    final response = await http.get(
    Uri.parse('$baseUrl/api/v1/logs'),
    headers: _authHeaders(),
    );
    if (response.statusCode != 200)
    {
      final body = jsonDecode(response.body);
      final error = body['error'] ?? "List logs failed.";
      throw Exception(error);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
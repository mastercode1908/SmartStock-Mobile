import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/providers/auth_provider.dart';

class PickingService {
  final String baseUrl = 'https://10.0.2.2:7207/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthProvider.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> fetchPickingTasks() async {
    final uri = Uri.parse('$baseUrl/picking-tasks');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải danh sách nhiệm vụ nhặt hàng.');
    }
  }

  Future<Map<String, dynamic>> fetchPickingTaskDetail(int id) async {
    final uri = Uri.parse('$baseUrl/picking-tasks/$id');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return Map<String, dynamic>.from(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Lỗi không xác định khi tải chi tiết nhiệm vụ.');
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải chi tiết nhiệm vụ.');
    }
  }

  Future<void> startPickingTask(int id) async {
    final uri = Uri.parse('$baseUrl/picking-tasks/$id/start');
    final response = await http.post(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi bắt đầu nhiệm vụ nhặt hàng.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi bắt đầu nhiệm vụ.');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }

  Future<void> savePickingTaskDraft(int id, List<Map<String, dynamic>> draftDetails) async {
    final uri = Uri.parse('$baseUrl/picking-tasks/$id/save-draft');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: json.encode(draftDetails),
    );

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi lưu nháp.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi lưu nháp.');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }

  Future<void> completePickingTask(int id) async {
    final uri = Uri.parse('$baseUrl/picking-tasks/$id/complete');
    final response = await http.post(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi hoàn thành nhiệm vụ.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi hoàn thành nhiệm vụ.');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchUnassignedIssues() async {
    final uri = Uri.parse('$baseUrl/picking-tasks/unassigned-issues');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      throw Exception(jsonResponse['message'] ?? 'Không thể tải phiếu xuất kho chưa phân công');
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải phiếu xuất kho chưa phân công.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchStaffs() async {
    final uri = Uri.parse('$baseUrl/users/staffs');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải danh sách nhân viên kho.');
    }
  }

  Future<void> assignPickingTask(int issueId, int staffId) async {
    final uri = Uri.parse('$baseUrl/picking-tasks/assign');
    final body = json.encode({
      'issueID': issueId,
      'assignedToUserId': staffId,
    });
    final response = await http.post(uri, headers: await _getHeaders(), body: body);

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi phân công nhiệm vụ.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi phân công nhiệm vụ.');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }
}

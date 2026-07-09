import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/providers/auth_provider.dart';

class NotificationService {
  final String baseUrl = 'https://10.0.2.2:7207/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthProvider.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> fetchNotifications({bool? isRead}) async {
    final Map<String, String> queryParams = {};
    if (isRead != null) {
      queryParams['isRead'] = isRead.toString();
    }
    
    final uri = Uri.parse('$baseUrl/Notifications').replace(queryParameters: queryParams);
    try {
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        }
        throw Exception(jsonResponse['message'] ?? 'Không thể tải danh sách thông báo');
      } else {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải thông báo.');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }

  Future<void> markRead(int id) async {
    final uri = Uri.parse('$baseUrl/Notifications/mark-read/$id');
    final response = await http.post(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi đánh dấu đã đọc.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi đánh dấu đã đọc');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }

  Future<void> markAllRead() async {
    final uri = Uri.parse('$baseUrl/Notifications/mark-all-read');
    final response = await http.post(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi đánh dấu đọc tất cả.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi đánh dấu đọc tất cả');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }

  Future<void> sendNotification({
    required String title,
    required String content,
    required String type,
    required String targetType,
    int? targetRoleId,
    List<int>? targetUserIds,
  }) async {
    final uri = Uri.parse('$baseUrl/Notifications/send');
    final body = json.encode({
      'title': title,
      'content': content,
      'type': type,
      'targetType': targetType,
      'targetRoleId': targetRoleId,
      'targetUserIds': targetUserIds,
    });

    final response = await http.post(uri, headers: await _getHeaders(), body: body);

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}). Vui lòng khởi chạy lại backend API.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Không thể gửi thông báo (Lỗi ${response.statusCode})');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final uri = Uri.parse('$baseUrl/Users');
    try {
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải danh sách người dùng.');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách nhân viên: $e');
    }
  }
}

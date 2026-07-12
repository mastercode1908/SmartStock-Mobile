import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/providers/auth_provider.dart';

class AiService {
  final String baseUrl = 'https://10.0.2.2:7207/api/AiAssistant';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthProvider.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: headers,
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'text': 'Lỗi kết nối tới máy chủ (Code: ${response.statusCode})',
          'actionCode': 'NONE',
          'actionData': {}
        };
      }
    } catch (e) {
      return {
        'text': 'Không thể kết nối với trợ lý AI. Vui lòng kiểm tra mạng.',
        'actionCode': 'NONE',
        'actionData': {}
      };
    }
  }
}

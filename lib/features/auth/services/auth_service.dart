import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class AuthService {
  final String baseUrl = 'https://10.0.2.2:7207/api';

  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return UserModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Login failed');
      }
    } else {
      try {
        final jsonResponse = json.decode(response.body);
        String errorMsg = jsonResponse['message'] ?? 'Đăng nhập thất bại';
        
        if (jsonResponse['errors'] != null) {
          final errors = jsonResponse['errors'];
          if (errors is String) {
            errorMsg = errors;
          } else if (errors is Map) {
            errorMsg = errors.values.map((e) => e is List ? e.join(', ') : e.toString()).join('\n');
          } else if (errors is List) {
            errorMsg = errors.join('\n');
          }
        }
        
        throw Exception(errorMsg);
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Đăng nhập thất bại (${response.statusCode})');
        }
        rethrow;
      }
    }
  }

  Future<void> updateProfile(String fullName, String phone, String avatarUrl) async {
    final token = await AuthProvider.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/Auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'fullName': fullName,
        'phone': phone,
        'avatarUrl': avatarUrl,
      }),
    );

    if (response.statusCode != 200) {
      try {
        final jsonResponse = json.decode(response.body);
        String errorMsg = jsonResponse['message'] ?? 'Cập nhật thất bại';
        if (jsonResponse['errors'] != null) {
          final errors = jsonResponse['errors'];
          if (errors is String) errorMsg = errors;
          else if (errors is Map) errorMsg = errors.values.map((e) => e is List ? e.join(', ') : e.toString()).join('\n');
          else if (errors is List) errorMsg = errors.join('\n');
        }
        throw Exception(errorMsg);
      } catch (e) {
        if (e is FormatException) throw Exception('Cập nhật thất bại (${response.statusCode})');
        rethrow;
      }
    }
  }

  Future<String> uploadAvatar(String imagePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Cloudinary/upload'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      return jsonResponse['url'];
    } else {
      throw Exception('Upload failed: ${response.statusCode}');
    }
  }

  Future<void> changePassword(String token, String oldPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['message'] ?? 'Failed to change password');
    }
  }
}

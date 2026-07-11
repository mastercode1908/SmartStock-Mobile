import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../auth/providers/auth_provider.dart';

class IncidentService {
  final String baseUrl = 'https://10.0.2.2:7207/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthProvider.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> fetchIncidentReports() async {
    final uri = Uri.parse('$baseUrl/incident-reports');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      throw Exception(jsonResponse['message'] ?? 'Lỗi không xác định khi tải danh sách sự cố.');
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải danh sách sự cố.');
    }
  }

  Future<Map<String, dynamic>> fetchIncidentReportDetail(int id) async {
    final uri = Uri.parse('$baseUrl/incident-reports/$id');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return Map<String, dynamic>.from(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Lỗi không xác định khi tải chi tiết sự cố.');
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải chi tiết sự cố.');
    }
  }

  Future<void> createIncidentReport(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/incident-reports');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi tạo báo cáo sự cố.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi tạo báo cáo sự cố.');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }

  Future<void> approveIncidentReport(int id) async {
    final uri = Uri.parse('$baseUrl/incident-reports/$id/approve');
    final response = await http.post(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi duyệt báo cáo sự cố.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi duyệt báo cáo sự cố.');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }

  Future<void> rejectIncidentReport(int id) async {
    final uri = Uri.parse('$baseUrl/incident-reports/$id/reject');
    final response = await http.post(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      if (response.body.isEmpty) {
        throw Exception('Lỗi máy chủ (${response.statusCode}) khi từ chối báo cáo sự cố.');
      }
      try {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Lỗi khi từ chối báo cáo sự cố.');
      } catch (_) {
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
    }
  }

  Future<List<String>> fetchIncidentTypes() async {
    final uri = Uri.parse('$baseUrl/incident-reports/types');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => item.toString()).toList();
      }
      throw Exception(jsonResponse['message'] ?? 'Lỗi không xác định khi tải loại sự cố.');
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải danh sách loại sự cố.');
    }
  }

  Future<String> uploadImage(String filePath) async {
    final uri = Uri.parse('$baseUrl/Cloudinary/upload');
    final token = await AuthProvider.getToken();

    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final file = File(filePath);
    final stream = http.ByteStream(file.openRead());
    final length = await file.length();

    final multipartFile = http.MultipartFile(
      'file',
      stream,
      length,
      filename: file.path.split('/').last,
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(multipartFile);
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['url'] ?? '';
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải ảnh lên.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductLocations(int variantId) async {
    final uri = Uri.parse('$baseUrl/StockBalances/by-product/$variantId');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải vị trí lưu trữ sản phẩm.');
    }
  }

  Future<List<String>> fetchAvailableSerials(int variantId, int locationId) async {
    final uri = Uri.parse('$baseUrl/Serials/available?variantId=$variantId&locationId=$locationId');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => item.toString()).toList();
    } else {
      throw Exception('Lỗi máy chủ (${response.statusCode}) khi tải danh sách mã serial.');
    }
  }
}

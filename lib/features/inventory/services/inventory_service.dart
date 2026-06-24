import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_session.dart';
import '../models/warehouse.dart';
import '../models/storage_location.dart';
import '../models/product_variant.dart';
import '../models/inventory_count_detail.dart';
import '../../auth/providers/auth_provider.dart';

class InventoryService {
  final String baseUrl = 'https://10.0.2.2:7207/api';

  // Helper method for headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthProvider.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Warehouse>> fetchWarehouses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Warehouses'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Warehouse.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load warehouses');
    }
  }

  Future<List<StorageLocation>> fetchStorageLocations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/StorageLocations/lookup'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => StorageLocation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load locations');
    }
  }

  Future<List<InventorySession>> fetchInventorySessions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory-counts'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<dynamic> dataList = [];
      if (jsonResponse is Map && jsonResponse.containsKey('value')) {
        dataList = jsonResponse['value'];
      } else if (jsonResponse is List) {
        dataList = jsonResponse;
      }
      return dataList.map((data) => InventorySession.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load inventory sessions: ${response.statusCode}');
    }
  }

  Future<InventorySession> fetchSessionDetails(int sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory-counts/$sessionId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        return InventorySession.fromJson(jsonResponse['data']);
      }
      return InventorySession.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to fetch session details: ${response.body}');
    }
  }

  Future<InventorySession> createInventorySession(InventorySession draft) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory-counts'),
      headers: await _getHeaders(),
      body: json.encode(draft.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        return InventorySession.fromJson(jsonResponse['data']);
      }
      return InventorySession.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to create session: ${response.body}');
    }
  }

  Future<List<ProductVariant>> fetchProductVariants() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ProductVariants'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<dynamic> dataList = [];
      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        dataList = jsonResponse['data'];
      } else if (jsonResponse is Map && jsonResponse.containsKey('value')) {
        dataList = jsonResponse['value'];
      } else if (jsonResponse is List) {
        dataList = jsonResponse;
      }
      return dataList.map((data) => ProductVariant.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load product variants: ${response.statusCode}');
    }
  }

  String _parseError(http.Response response) {
    try {
      final jsonResponse = json.decode(response.body);
      String errorMsg = jsonResponse['message'] ?? 'Đã xảy ra lỗi (${response.statusCode})';
      
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
      return errorMsg;
    } catch (e) {
      return 'Lỗi máy chủ (${response.statusCode})';
    }
  }

  Future<void> submitInventoryDetail(InventoryCountDetail detail, {bool isUpdate = false}) async {
    final uri = isUpdate 
        ? Uri.parse('$baseUrl/InventoryCountDetails/${detail.countDetailId}')
        : Uri.parse('$baseUrl/InventoryCountDetails');
        
    final response = await (isUpdate ? http.put : http.post)(
      uri,
      headers: await _getHeaders(),
      body: json.encode(detail.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_parseError(response));
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      final uri = Uri.parse('$baseUrl/Cloudinary/upload');
      final request = http.MultipartRequest('POST', uri);
      
      final token = await AuthProvider.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['url'] != null) {
          return jsonResponse['url'] as String;
        }
        throw Exception("Không tìm thấy dữ liệu ảnh trả về");
      }
      
      throw Exception(_parseError(response));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> submitSession(int sessionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory-counts/$sessionId/submit'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_parseError(response));
    }
  }

  Future<int> fetchSystemQuantity(int variantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/StockBalances/by-product/$variantId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        int totalQty = 0;
        for (var item in data) {
          totalQty += (item['quantity'] ?? item['Quantity'] ?? 0) as int;
        }
        return totalQty;
      }
    } catch (e) {
      // ignore error, return 0
    }
    return 0;
  }
}

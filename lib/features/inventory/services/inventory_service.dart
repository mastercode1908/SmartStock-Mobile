import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    final user = await AuthProvider.getCurrentUserStatic();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (user != null) 'X-User-Id': user.userId.toString(),
      if (user != null) 'X-User-Role': user.roleName,
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

  Future<Map<String, dynamic>> fetchLocationDetails(int locationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/StorageLocations/$locationId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
         return jsonResponse['data'];
      }
      return jsonResponse as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load location details');
    }
  }

  Future<List<Map<String, dynamic>>> fetchStaffs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Users/staffs'),
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
      return dataList.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load staffs');
    }
  }

  Future<List<InventorySession>> fetchInventorySessions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory-counts/mobile'),
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
      return List<InventorySession>.from(dataList.map((data) => InventorySession.fromJson(data)));
    } else {
      throw Exception('Failed to load inventory sessions: ${response.statusCode}');
    }
  }


  Future<InventorySession> fetchSessionDetails(int sessionId) async {
    final queryStr = '\$filter=SessionID eq $sessionId&\$expand=Details(\$expand=ProductVariant)';
    final uri = Uri.parse('$baseUrl/inventory-counts').replace(query: queryStr);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> dataList = [];
      if (jsonResponse is Map && jsonResponse.containsKey('value')) {
        dataList = jsonResponse['value'];
      } else if (jsonResponse is List) {
        dataList = jsonResponse;
      }
      
      if (dataList.isNotEmpty) {
        return InventorySession.fromJson(dataList.first);
      }
      throw Exception('Session not found in OData response.');
    } else {
      throw Exception('Failed to fetch session details: ${response.body}');
    }
  }

  // Fetch full session detail with location info (zone/rack/shelf) from new /mobile-detail endpoint
  Future<InventorySession> fetchSessionMobileDetail(int sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory-counts/$sessionId/mobile-detail'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Response is a plain JSON object (not OData)
      return InventorySession.fromJson(data is Map ? data : data['value']);
    } else {
      throw Exception('Failed to fetch mobile session detail: ${response.statusCode}');
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

  Future<void> updateSession(int sessionId, InventorySession session) async {
    final response = await http.put(
      Uri.parse('$baseUrl/inventory-counts/$sessionId'),
      headers: await _getHeaders(),
      body: json.encode(session.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_parseError(response));
    }
  }

  Future<void> approveSession(int sessionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory-counts/$sessionId/approve'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  Future<void> rejectSession(int sessionId, String reason) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory-counts/$sessionId/reject'),
      headers: await _getHeaders(),
      body: json.encode({'rejectReason': reason}),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  Future<void> postSession(int sessionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory-counts/$sessionId/post'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
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

  /// Single-step scan lookup: calls /api/ProductVariants/scan?code=...
  /// Backend handles barcode, SKU, and serial number lookup in one query.
  Future<ProductVariant?> fetchVariantByScan(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ProductVariants/scan?code=${Uri.encodeQueryComponent(code)}'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductVariant.fromJson(data);
      }
    } catch (e) {
      debugPrint('fetchVariantByScan error: $e');
    }
    return null;
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

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/storage_location.dart';
import '../../auth/providers/auth_provider.dart';

class StorageLocationService {
  final String baseUrl = 'https://10.0.2.2:7207/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthProvider.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> fetchStorageLocations({
    String? search,
    int? warehouseId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (warehouseId != null && warehouseId > 0) {
      queryParams['warehouseId'] = warehouseId.toString();
    }

    final uri = Uri.parse('$baseUrl/StorageLocations').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final data = jsonResponse['data'];
        final List<dynamic> itemsList = data['items'] ?? [];
        final items = itemsList.map((item) => StorageLocation.fromJson(item)).toList();
        return {
          'items': items,
          'totalCount': data['totalCount'] ?? 0,
        };
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to load storage locations');
    } else {
      throw Exception('Failed to load storage locations: ${response.statusCode}');
    }
  }

  Future<StorageLocation> fetchStorageLocationDetails(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/StorageLocations/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return StorageLocation.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to load storage location details');
    } else {
      throw Exception('Location details failed: ${response.statusCode}');
    }
  }

  Future<StorageLocation> createStorageLocation(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/StorageLocations'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return StorageLocation.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to create storage location');
    } else {
      _handleErrorResponse(response);
      throw Exception('Create storage location failed: ${response.statusCode}');
    }
  }

  Future<StorageLocation> updateStorageLocation(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/StorageLocations/$id'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return StorageLocation.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to update storage location');
    } else {
      _handleErrorResponse(response);
      throw Exception('Update storage location failed: ${response.statusCode}');
    }
  }

  Future<void> toggleStorageLocationStatus(int id, int status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/StorageLocations/$id/status'),
      headers: await _getHeaders(),
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      _handleErrorResponse(response);
      throw Exception('Toggle status failed: ${response.statusCode}');
    }
  }

  Future<void> deleteStorageLocation(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/StorageLocations/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      _handleErrorResponse(response);
      throw Exception('Delete location failed: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchActiveWarehouses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/StorageLocations/warehouses/active'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((w) => {
          'warehouseID': w['warehouseID'] ?? 0,
          'warehouseName': w['warehouseName'] ?? '',
        }).toList();
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to load warehouses');
    } else {
      throw Exception('Failed to load active warehouses');
    }
  }

  Future<List<Map<String, dynamic>>> fetchStorageLocationsLookup() async {
    final response = await http.get(
      Uri.parse('$baseUrl/StorageLocations/lookup'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((l) => {
        'locationID': l['locationID'] ?? l['locationId'] ?? 0,
        'locationCode': l['locationCode'] ?? '',
        'warehouseID': l['warehouseID'] ?? l['warehouseId'] ?? 0,
      }).toList();
    } else {
      throw Exception('Không thể tải danh sách vị trí khả dụng');
    }
  }

  Future<List<String>> fetchAvailableSerials({
    required int variantId,
    required int locationId,
    int? batchId,
  }) async {
    String url = '$baseUrl/Serials/available?variantId=$variantId&locationId=$locationId';
    if (batchId != null && batchId > 0) {
      url += '&batchId=$batchId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Không thể tải danh sách số serial khả dụng');
    }
  }

  Future<bool> transferStock({
    required int sourceLocationId,
    required int targetLocationId,
    required int variantId,
    int? batchId,
    required int quantity,
    required List<String> serialNumbers,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/StockBalances/transfer'),
      headers: await _getHeaders(),
      body: json.encode({
        'sourceLocationID': sourceLocationId,
        'targetLocationID': targetLocationId,
        'variantID': variantId,
        'batchID': batchId,
        'quantity': quantity,
        'serialNumbers': serialNumbers,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return true;
      }
      throw Exception(jsonResponse['message'] ?? 'Chuyển vị trí thất bại');
    } else {
      _handleErrorResponse(response);
      throw Exception('Chuyển vị trí thất bại (${response.statusCode})');
    }
  }

  void _handleErrorResponse(http.Response response) {
    try {
      final jsonResponse = json.decode(response.body);
      String errorMsg = jsonResponse['message'] ?? 'Có lỗi xảy ra';
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
        throw Exception('Lỗi hệ thống (${response.statusCode})');
      }
      rethrow;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../models/brand.dart';
import '../models/unit.dart';
import '../models/product_unit.dart';
import '../../auth/providers/auth_provider.dart';

class ProductService {
  final String baseUrl = 'https://10.0.2.2:7207/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthProvider.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> fetchProducts({
    String? search,
    int? categoryId,
    int? brandId,
    int? trackingMethod,
    int page = 1,
    int pageSize = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (categoryId != null) {
      queryParams['categoryId'] = categoryId.toString();
    }
    if (brandId != null) {
      queryParams['brandId'] = brandId.toString();
    }
    if (trackingMethod != null) {
      queryParams['trackingMethod'] = trackingMethod.toString();
    }

    final uri = Uri.parse('$baseUrl/Products').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final data = jsonResponse['data'];
        final List<dynamic> itemsList = data['items'] ?? [];
        final items = itemsList.map((item) => Product.fromJson(item)).toList();
        return {
          'items': items,
          'totalCount': data['totalCount'] ?? 0,
        };
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to load products');
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<Product> fetchProduct(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Products/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return Product.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to load product details');
    } else {
      throw Exception('Product details failed: ${response.statusCode}');
    }
  }


  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Categorys'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Category.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Brand>> fetchBrands() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Brands'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Brand.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  Future<List<Unit>> fetchUnits() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Units?pageSize=100'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> items = jsonResponse['data']?['items'] ?? [];
      return items.map((data) => Unit.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load units');
    }
  }


  Future<List<ProductUnit>> fetchProductUnits(int variantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ProductUnits/variant/$variantId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => ProductUnit.fromJson(item)).toList();
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to load variant units');
    } else {
      throw Exception('Load variant units failed: ${response.statusCode}');
    }
  }

}

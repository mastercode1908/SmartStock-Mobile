import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../models/brand.dart';
import '../models/unit.dart';
import '../models/product_variant.dart';
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

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Products'),
      headers: await _getHeaders(),
      body: json.encode(productData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return Product.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to create product');
    } else {
      _handleErrorResponse(response);
      throw Exception('Create product failed: ${response.statusCode}');
    }
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> productData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Products/$id'),
      headers: await _getHeaders(),
      body: json.encode(productData),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return Product.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to update product');
    } else {
      _handleErrorResponse(response);
      throw Exception('Update product failed: ${response.statusCode}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Products/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      _handleErrorResponse(response);
      throw Exception('Delete product failed: ${response.statusCode}');
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

  Future<ProductVariant> createVariant(int productId, Map<String, dynamic> variantData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ProductVariants?productId=$productId'),
      headers: await _getHeaders(),
      body: json.encode(variantData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return ProductVariant.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to create variant');
    } else {
      _handleErrorResponse(response);
      throw Exception('Create variant failed: ${response.statusCode}');
    }
  }

  Future<ProductVariant> updateVariant(int variantId, Map<String, dynamic> variantData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/ProductVariants/$variantId'),
      headers: await _getHeaders(),
      body: json.encode(variantData),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return ProductVariant.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to update variant');
    } else {
      _handleErrorResponse(response);
      throw Exception('Update variant failed: ${response.statusCode}');
    }
  }

  Future<void> deleteVariant(int variantId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ProductVariants/$variantId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      _handleErrorResponse(response);
      throw Exception('Delete variant failed: ${response.statusCode}');
    }
  }

  Future<String> uploadProductImage(String imagePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Cloudinary/upload'),
    );
    final token = await AuthProvider.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      return jsonResponse['url'] ?? '';
    } else {
      throw Exception('Image upload failed: ${response.statusCode}');
    }
  }

  Future<Category> createCategory(Map<String, dynamic> categoryData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Categorys'),
      headers: await _getHeaders(),
      body: json.encode(categoryData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Category.fromJson(categoryData);
    } else {
      _handleErrorResponse(response);
      throw Exception('Create category failed: ${response.statusCode}');
    }
  }

  Future<Brand> createBrand(Map<String, dynamic> brandData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Brands'),
      headers: await _getHeaders(),
      body: json.encode(brandData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Brand.fromJson(brandData);
    } else {
      _handleErrorResponse(response);
      throw Exception('Create brand failed: ${response.statusCode}');
    }
  }

  Future<Unit> createUnit(Map<String, dynamic> unitData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Units'),
      headers: await _getHeaders(),
      body: json.encode(unitData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return Unit.fromJson(jsonResponse['data']);
      }
      return Unit.fromJson(unitData);
    } else {
      _handleErrorResponse(response);
      throw Exception('Create unit failed: ${response.statusCode}');
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

  Future<ProductUnit> createProductUnit(Map<String, dynamic> productUnitData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ProductUnits'),
      headers: await _getHeaders(),
      body: json.encode(productUnitData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return ProductUnit.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to create variant unit');
    } else {
      _handleErrorResponse(response);
      throw Exception('Create variant unit failed: ${response.statusCode}');
    }
  }

  Future<void> deleteProductUnit(int productUnitId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ProductUnits/$productUnitId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      _handleErrorResponse(response);
      throw Exception('Delete variant unit failed: ${response.statusCode}');
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

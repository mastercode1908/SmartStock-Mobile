import 'package:flutter/foundation.dart' hide Category;
import '../services/product_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/brand.dart';
import '../models/unit.dart';
import '../models/product_unit.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> _products = [];
  int _totalCount = 0;
  int _currentPage = 1;
  final int _pageSize = 50;

  List<Category> _categories = [];
  List<Brand> _brands = [];
  List<Unit> _units = [];
  final Map<int, List<ProductUnit>> _variantUnits = {};

  Product? _selectedProduct;

  bool _isLoading = false;
  bool _isMetadataLoading = false;
  String? _error;

  // Filters
  String? _searchQuery;
  int? _selectedCategoryId;
  int? _selectedBrandId;
  int? _selectedTrackingMethod;

  // Getters
  List<Product> get products => _products;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  List<Category> get categories => _categories;
  List<Brand> get brands => _brands;
  List<Unit> get units => _units;
  Map<int, List<ProductUnit>> get variantUnits => _variantUnits;
  List<ProductUnit> getVariantUnits(int variantId) => _variantUnits[variantId] ?? [];
  Product? get selectedProduct => _selectedProduct;

  bool get isLoading => _isLoading;
  bool get isMetadataLoading => _isMetadataLoading;
  String? get error => _error;

  String? get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedBrandId => _selectedBrandId;
  int? get selectedTrackingMethod => _selectedTrackingMethod;

  // Filter setters
  void setSearchQuery(String? query) {
    _searchQuery = query;
  }

  void setFilters({int? categoryId, int? brandId, int? trackingMethod}) {
    _selectedCategoryId = categoryId;
    _selectedBrandId = brandId;
    _selectedTrackingMethod = trackingMethod;
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedCategoryId = null;
    _selectedBrandId = null;
    _selectedTrackingMethod = null;
  }

  Future<void> loadMetadata() async {
    try {
      _isMetadataLoading = true;
      _error = null;
      notifyListeners();

      final results = await Future.wait([
        _service.fetchCategories(),
        _service.fetchBrands(),
        _service.fetchUnits(),
      ]);

      _categories = results[0] as List<Category>;
      _brands = results[1] as List<Brand>;
      _units = results[2] as List<Unit>;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading metadata: $e');
    } finally {
      _isMetadataLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _service.fetchProducts(
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        brandId: _selectedBrandId,
        trackingMethod: _selectedTrackingMethod,
        page: _currentPage,
        pageSize: _pageSize,
      );

      final List<Product> fetchedItems = result['items'] as List<Product>;
      _totalCount = result['totalCount'] as int;

      if (_currentPage == 1) {
        _products = fetchedItems;
      } else {
        _products.addAll(fetchedItems);
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadProductDetails(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedProduct = await _service.fetchProduct(id);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading product details: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> loadVariantUnits(int variantId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final units = await _service.fetchProductUnits(variantId);
      _variantUnits[variantId] = units;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading variant units: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

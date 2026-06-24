import 'package:flutter/foundation.dart' hide Category;
import '../services/product_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/brand.dart';
import '../models/unit.dart';
import '../models/product_variant.dart';
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

  Future<bool> createProduct({
    required String productName,
    required int categoryId,
    required int? brandId,
    required int baseUnitId,
    required int trackingMethod,
    required String imageUrl,
    required String description,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final productData = {
        'productName': productName.trim(),
        'categoryID': categoryId,
        'brandID': brandId ?? 1,
        'baseUnitID': baseUnitId,
        'trackingMethod': trackingMethod,
        'imageUrl': imageUrl,
        'description': description.trim(),
      };

      final newProduct = await _service.createProduct(productData);
      _products.insert(0, newProduct);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required int id,
    required String productName,
    required int categoryId,
    required int? brandId,
    required int baseUnitId,
    required int trackingMethod,
    required String imageUrl,
    required String description,
    required int status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final productData = {
        'productName': productName.trim(),
        'categoryID': categoryId,
        'brandID': brandId ?? 1,
        'baseUnitID': baseUnitId,
        'trackingMethod': trackingMethod,
        'imageUrl': imageUrl,
        'description': description.trim(),
        'status': status,
      };

      final updated = await _service.updateProduct(id, productData);
      
      // Update in products list
      final index = _products.indexWhere((p) => p.productId == id);
      if (index != -1) {
        _products[index] = updated;
      }
      if (_selectedProduct?.productId == id) {
        _selectedProduct = updated;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteProduct(id);
      _products.removeWhere((p) => p.productId == id);
      if (_selectedProduct?.productId == id) {
        _selectedProduct = null;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createVariant({
    required int productId,
    required String variantName,
    required String sku,
    required String barcode,
    required int minimumStockLevel,
    required double costPrice,
    required String imageUrl,
    required int status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final variantData = {
        'variantName': variantName.trim(),
        'sku': sku.trim(),
        'barcode': barcode.trim(),
        'minimumStockLevel': minimumStockLevel,
        'costPrice': costPrice,
        'imageUrl': imageUrl,
        'status': status,
      };

      final newVariant = await _service.createVariant(productId, variantData);

      // Auto-create default base unit conversion with factor 1.0
      final parentProduct = _selectedProduct;
      if (parentProduct != null) {
        final baseUnitData = {
          'variantID': newVariant.variantId,
          'unitID': parentProduct.baseUnitId,
          'conversionFactor': 1.0,
        };
        try {
          await _service.createProductUnit(baseUnitData);
        } catch (e) {
          debugPrint('Error creating default base unit conversion: $e');
        }
      }

      // Reload details to get new variant list and values
      if (_selectedProduct?.productId == productId) {
        _selectedProduct = await _service.fetchProduct(productId);
      }
      // Update in products list if loaded
      final index = _products.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        _products[index] = await _service.fetchProduct(productId);
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVariant({
    required int variantId,
    required int productId,
    required String variantName,
    required String sku,
    required String barcode,
    required int minimumStockLevel,
    required double costPrice,
    required String imageUrl,
    required int status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final variantData = {
        'variantName': variantName.trim(),
        'sku': sku.trim(),
        'barcode': barcode.trim(),
        'minimumStockLevel': minimumStockLevel,
        'costPrice': costPrice,
        'imageUrl': imageUrl,
        'status': status,
      };

      await _service.updateVariant(variantId, variantData);
      // Reload details
      if (_selectedProduct?.productId == productId) {
        _selectedProduct = await _service.fetchProduct(productId);
      }
      // Update in products list if loaded
      final index = _products.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        _products[index] = await _service.fetchProduct(productId);
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVariant(int variantId, int productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteVariant(variantId);
      // Reload details
      if (_selectedProduct?.productId == productId) {
        _selectedProduct = await _service.fetchProduct(productId);
      }
      // Update in products list if loaded
      final index = _products.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        _products[index] = await _service.fetchProduct(productId);
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadImage(String imagePath) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      return await _service.uploadProductImage(imagePath);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Category?> createCategory({required String categoryName}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final categoryData = {'categoryName': categoryName.trim()};
      final newCategory = await _service.createCategory(categoryData);
      
      // Reload categories list to refresh cache
      _categories = await _service.fetchCategories();
      return newCategory;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error creating category: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Brand?> createBrand({required String brandName, String? country}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final brandData = {
        'brandName': brandName.trim(),
        'country': (country ?? 'Vietnam').trim(),
      };
      final newBrand = await _service.createBrand(brandData);
      
      // Reload brands list to refresh cache
      _brands = await _service.fetchBrands();
      return newBrand;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error creating brand: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Unit?> createUnit({required String unitName, required String symbol}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final unitData = {
        'unitName': unitName.trim(),
        'symbol': symbol.trim(),
      };
      final newUnit = await _service.createUnit(unitData);
      
      // Reload units list to refresh cache
      _units = await _service.fetchUnits();
      return newUnit;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error creating unit: $e');
      return null;
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

  Future<bool> createVariantUnit({
    required int variantId,
    required int unitId,
    required double conversionFactor,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final productUnitData = {
        'variantID': variantId,
        'unitID': unitId,
        'conversionFactor': conversionFactor,
      };

      await _service.createProductUnit(productUnitData);
      
      // Reload list of units for this variant
      final units = await _service.fetchProductUnits(variantId);
      _variantUnits[variantId] = units;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error creating variant unit: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVariantUnit({
    required int productUnitId,
    required int variantId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteProductUnit(productUnitId);
      
      // Reload list of units for this variant
      final units = await _service.fetchProductUnits(variantId);
      _variantUnits[variantId] = units;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error deleting variant unit: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

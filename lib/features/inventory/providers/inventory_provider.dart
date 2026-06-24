import 'package:flutter/foundation.dart';
import '../services/inventory_service.dart';
import '../models/inventory_session.dart';
import '../models/warehouse.dart';
import '../models/storage_location.dart';
import '../models/product_variant.dart';
import '../models/inventory_count_detail.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();

  List<InventorySession> _sessions = [];
  List<Warehouse> _warehouses = [];
  List<StorageLocation> _locations = [];
  List<ProductVariant> _productVariants = [];
  final List<ProductVariant> _selectedVariants = [];
  final Map<int, int> _systemQuantities = {};
  
  int? _activeSessionId;
  int? _lastSubmittedSessionId;
  InventorySession? _selectedSession;

  bool _isLoading = false;
  String? _error;

  List<InventorySession> get sessions => _sessions;
  List<Warehouse> get warehouses => _warehouses;
  List<StorageLocation> get locations => _locations;
  List<ProductVariant> get productVariants => _productVariants;
  List<ProductVariant> get selectedVariants => _selectedVariants;
  Map<int, int> get systemQuantities => _systemQuantities;
  int? get activeSessionId => _activeSessionId;
  int? get lastSubmittedSessionId => _lastSubmittedSessionId;
  InventorySession? get selectedSession => _selectedSession;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setActiveSession(int id) {
    _activeSessionId = id;
    notifyListeners();
  }

  void toggleVariantSelection(ProductVariant variant) {
    if (_selectedVariants.any((v) => v.variantId == variant.variantId)) {
      _selectedVariants.removeWhere((v) => v.variantId == variant.variantId);
    } else {
      _selectedVariants.add(variant);
    }
    notifyListeners();
  }

  Future<void> loadWarehouses() async {
    try {
      _isLoading = true;
      notifyListeners();
      _warehouses = await _service.fetchWarehouses();
      _locations = await _service.fetchStorageLocations();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading warehouses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessions() async {
    try {
      _isLoading = true;
      notifyListeners();
      _sessions = await _service.fetchInventorySessions();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessionDetails(int sessionId) async {
    try {
      _isLoading = true;
      notifyListeners();
      _selectedSession = await _service.fetchSessionDetails(sessionId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading session details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSession(InventorySession draft) async {
    try {
      _isLoading = true;
      notifyListeners();
      final newSession = await _service.createInventorySession(draft);
      _sessions.insert(0, newSession);
      _activeSessionId = newSession.id;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductVariants() async {
    try {
      _isLoading = true;
      notifyListeners();
      _productVariants = await _service.fetchProductVariants();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading variants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitCountDetails(List<InventoryCountDetail> details) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      for (var detail in details) {
        await _service.submitInventoryDetail(detail);
      }
      // Save for sync screen
      _lastSubmittedSessionId = _activeSessionId;
      // Clear selection after submit
      _selectedVariants.clear();
      _systemQuantities.clear();
      _activeSessionId = null;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error submitting details: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSystemQuantities() async {
    for (var variant in _selectedVariants) {
      final qty = await _service.fetchSystemQuantity(variant.variantId);
      _systemQuantities[variant.variantId] = qty;
    }
    notifyListeners();
  }

  Future<bool> syncSession(int sessionId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.submitSession(sessionId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error syncing session: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

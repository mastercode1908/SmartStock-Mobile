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
  List<Map<String, dynamic>> _staffs = [];
  final List<ProductVariant> _selectedVariants = [];
  final Map<int, int> _systemQuantities = {};
  
  int? _activeSessionId;
  int? _lastSubmittedSessionId;
  InventorySession? _selectedSession;
  List<InventoryCountDetail> _activeLocationGroup = []; // Products to count at a specific location

  bool _isLoading = false;
  String? _error;

  List<InventorySession> get sessions => _sessions;
  List<Warehouse> get warehouses => _warehouses;
  List<StorageLocation> get locations => _locations;
  List<ProductVariant> get productVariants => _productVariants;
  List<Map<String, dynamic>> get staffs => _staffs;
  List<ProductVariant> get selectedVariants => _selectedVariants;
  Map<int, int> get systemQuantities => _systemQuantities;
  int? get activeSessionId => _activeSessionId;
  int? get lastSubmittedSessionId => _lastSubmittedSessionId;
  InventorySession? get selectedSession => _selectedSession;
  List<InventoryCountDetail> get activeLocationGroup => _activeLocationGroup;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  String getStaffName(int staffId) {
    if (staffId <= 0) return 'Chưa rõ';
    try {
      final staff = _staffs.firstWhere((s) {
        final Map<String, dynamic> lowerCaseKeys = s.map((k, v) => MapEntry(k.toLowerCase(), v));
        final idValue = lowerCaseKeys['userid'] ?? lowerCaseKeys['id'];
        return idValue?.toString() == staffId.toString();
      }, orElse: () => <String, dynamic>{});
      if (staff.isNotEmpty) {
        final Map<String, dynamic> lowerCaseKeys = staff.map((k, v) => MapEntry(k.toLowerCase(), v));
        return lowerCaseKeys['fullname'] ?? lowerCaseKeys['name'] ?? lowerCaseKeys['username'] ?? 'Nhân viên $staffId';
      }
      return 'Quản trị viên ($staffId)';
    } catch (e) {
      return 'ID: $staffId';
    }
  }

  void setActiveSession(int id) {
    _activeSessionId = id;
    notifyListeners();
  }

  // Set the list of products at the location the staff is about to count
  void setActiveLocationGroup(List<InventoryCountDetail> details) {
    _activeLocationGroup = List.from(details);
    // Sync _selectedVariants from the group
    _selectedVariants.clear();
    _systemQuantities.clear();
    for (var detail in details) {
      final variant = _productVariants.firstWhere(
        (v) => v.variantId == detail.variantId,
        orElse: () => ProductVariant(
          variantId: detail.variantId,
          productId: 0,
          variantName: detail.variantName ?? 'Unknown',
          productName: detail.productName ?? '',
          sku: detail.sku ?? '',
          barcode: '',
          imageUrl: '',
          trackingMethod: 0,
          baseUnitId: detail.unitId,
          baseUnitSymbol: '',
        ),
      );
      if (!_selectedVariants.any((v) => v.variantId == variant.variantId)) {
        _selectedVariants.add(variant);
        _systemQuantities[variant.variantId] = detail.systemQuantity;
      }
    }
    notifyListeners();
  }

  Future<void> editSession(InventorySession session) async {
    _activeSessionId = session.id;
    _selectedVariants.clear();
    _systemQuantities.clear();
    _activeLocationGroup.clear();

    // Use the new mobile-detail API to get full location data
    try {
      final fullSession = await _service.fetchSessionMobileDetail(session.id);
      _selectedSession = fullSession;
      session = fullSession;
    } catch (e) {
      debugPrint('Failed to fetch mobile session detail: $e');
      // Fallback to old API
      try {
        final fallback = await _service.fetchSessionDetails(session.id);
        _selectedSession = fallback;
        session = fallback;
      } catch (e2) {
        debugPrint('Fallback also failed: $e2');
      }
    }

    if (_productVariants.isEmpty) {
      await loadProductVariants();
    }

    // Populate _selectedVariants from all details (for backwards compat with Step 2+)
    if (session.details != null) {
      for (var detail in session.details!) {
        var variant = _productVariants.firstWhere(
            (v) => v.variantId == detail.variantId,
            orElse: () => ProductVariant(
              variantId: detail.variantId,
              productId: 0,
              variantName: detail.variantName ?? 'Unknown',
              productName: detail.productName ?? '',
              sku: detail.sku ?? '',
              barcode: '',
              imageUrl: '',
              trackingMethod: 0,
              baseUnitId: detail.unitId,
              baseUnitSymbol: '',
            ),
        );
        if (!_selectedVariants.any((v) => v.variantId == variant.variantId)) {
          _selectedVariants.add(variant);
          _systemQuantities[variant.variantId] = detail.systemQuantity;
        }
      }
    }
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

  void updateActualQuantity(int countDetailId, int quantity, {InventoryCountDetail? fallbackDetail}) {
    bool isMatch(InventoryCountDetail d) {
      if (countDetailId != 0 && d.countDetailId == countDetailId) return true;
      if (fallbackDetail != null) {
        return d.variantId == fallbackDetail.variantId &&
               d.batchNumber == fallbackDetail.batchNumber &&
               d.serialNumber == fallbackDetail.serialNumber &&
               d.storageLocationId == fallbackDetail.storageLocationId;
      }
      return false;
    }

    if (_selectedSession != null && _selectedSession!.details != null) {
      final idx = _selectedSession!.details!.indexWhere(isMatch);
      if (idx != -1) {
        _selectedSession!.details![idx].actualQuantity = quantity;
      }
    }

    // Always update in _sessions list as well to ensure data consistency
    try {
      final sessionIdx = _sessions.indexWhere((s) => s.id == _activeSessionId);
      if (sessionIdx != -1 && _sessions[sessionIdx].details != null) {
        final dIdx = _sessions[sessionIdx].details!.indexWhere(isMatch);
        if (dIdx != -1) {
          _sessions[sessionIdx].details![dIdx].actualQuantity = quantity;
        }
      }
    } catch (e) {
      debugPrint('Error updating session list: $e');
    }

    // Also update in activeLocationGroup so UI reflects immediately
    final activeGroupIdx = _activeLocationGroup.indexWhere(isMatch);
    if (activeGroupIdx != -1) {
      _activeLocationGroup[activeGroupIdx].actualQuantity = quantity;
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

  Future<void> loadStaffs() async {
    try {
      _isLoading = true;
      notifyListeners();
      _staffs = await _service.fetchStaffs();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading staffs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchLocationPreview(int locationId) async {
    return await _service.fetchLocationDetails(locationId);
  }

  Future<void> loadSessions() async {
    try {
      _isLoading = true;
      notifyListeners();
      _sessions = await _service.fetchInventorySessions();
      _sessions.sort((a, b) => b.id.compareTo(a.id));
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

  // Load session detail for readonly view (does not modify provider state)
  Future<InventorySession> loadSessionReadonly(int sessionId) async {
    return await _service.fetchSessionMobileDetail(sessionId);
  }

  Future<bool> updateSessionStatus(InventorySession session, String newStatus) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final updatedSession = InventorySession(
        id: session.id,
        sessionCode: session.sessionCode,
        warehouseId: session.warehouseId,
        warehouseName: session.warehouseName,
        countType: session.countType,
        startDate: session.startDate,
        endDate: session.endDate,
        description: session.description,
        status: newStatus,
        countDate: session.countDate,
        createdBy: session.createdBy,
        createdByName: session.createdByName,
        assignedTo: session.assignedTo,
        assignedToName: session.assignedToName,
      );

      await _service.updateSession(session.id, updatedSession);
      await loadSessions();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating session status: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<InventorySession> addSession(InventorySession draft) async {
    try {
      _isLoading = true;
      notifyListeners();
      final newSession = await _service.createInventorySession(draft);
      _sessions.insert(0, newSession);
      _activeSessionId = newSession.id;
      return newSession;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding session: $e');
      rethrow; // Throw error to prevent navigation
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

  Future<ProductVariant?> lookupVariantByCode(String rawValue) async {
    // 1. Local Cache - Barcode/SKU/ID
    ProductVariant? match = _productVariants.where((v) => 
      v.barcode == rawValue || 
      v.sku == rawValue || 
      v.variantId.toString() == rawValue
    ).firstOrNull;

    if (match != null) return match;

    // 2. Deep search in loaded session details (serial/batch/sku)
    for (var session in _sessions) {
      if (session.details != null) {
        final detailMatch = session.details!.where((d) => 
          d.serialNumber == rawValue || 
          d.batchNumber == rawValue || 
          d.sku == rawValue
        ).firstOrNull;
        
        if (detailMatch != null) {
          match = _productVariants.where((v) => v.variantId == detailMatch.variantId).firstOrNull;
          if (match != null) return match;
        }
      }
    }

    // 3. Fallback to backend — handles barcode/SKU/serial in one call
    try {
      final remoteVariant = await _service.fetchVariantByScan(rawValue);
      if (remoteVariant != null) {
        // Cache locally so next scan is instant
        if (!_productVariants.any((v) => v.variantId == remoteVariant.variantId)) {
          _productVariants.add(remoteVariant);
        }
        return remoteVariant;
      }
    } catch (e) {
      debugPrint('lookupVariantByCode backend error: $e');
    }

    return null;
  }

  Future<bool> submitCountDetails([List<InventoryCountDetail>? details]) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (details != null && details.isNotEmpty) {
        for (var detail in details) {
          await _service.submitInventoryDetail(detail);
        }
      } else {
        if (_selectedSession == null) {
          throw Exception("No active session selected.");
        }
        await _service.updateSession(_selectedSession!.id, _selectedSession!);
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

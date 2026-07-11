import 'package:flutter/foundation.dart';
import '../services/storage_location_service.dart';
import '../models/storage_location.dart';

class StorageLocationProvider extends ChangeNotifier {
  final StorageLocationService _service = StorageLocationService();

  List<StorageLocation> _locations = [];
  List<Map<String, dynamic>> _activeWarehouses = [];
  StorageLocation? _selectedLocation;

  int _totalCount = 0;
  int _currentPage = 1;
  final int _pageSize = 15;

  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _error;

  // Filters
  String? _searchQuery;
  int? _selectedWarehouseId;

  // Getters
  List<StorageLocation> get locations => _locations;
  List<Map<String, dynamic>> get activeWarehouses => _activeWarehouses;
  StorageLocation? get selectedLocation => _selectedLocation;

  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get error => _error;

  String? get searchQuery => _searchQuery;
  int? get selectedWarehouseId => _selectedWarehouseId;

  void setSearchQuery(String? query) {
    _searchQuery = query;
  }

  void setWarehouseId(int? warehouseId) {
    _selectedWarehouseId = warehouseId;
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedWarehouseId = null;
  }

  Future<void> loadActiveWarehouses() async {
    try {
      _error = null;
      _activeWarehouses = await _service.fetchActiveWarehouses();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading active warehouses: $e');
    }
  }

  Future<void> loadStorageLocations({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _service.fetchStorageLocations(
        search: _searchQuery,
        warehouseId: _selectedWarehouseId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      final List<StorageLocation> fetchedItems = result['items'] as List<StorageLocation>;
      _totalCount = result['totalCount'] as int;

      if (_currentPage == 1) {
        _locations = fetchedItems;
      } else {
        _locations.addAll(fetchedItems);
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading storage locations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreLocations() async {
    if (_isLoading || _locations.length >= _totalCount) return;
    _currentPage++;
    await loadStorageLocations(isRefresh: false);
  }

  Future<bool> loadLocationDetails(int id) async {
    try {
      _isDetailLoading = true;
      _error = null;
      notifyListeners();

      _selectedLocation = await _service.fetchStorageLocationDetails(id);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading location details: $e');
      return false;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLocation({
    required int warehouseId,
    required String zone,
    required String rack,
    required String shelf,
    required String bin,
    required int status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final locationData = {
        'warehouseID': warehouseId,
        'zone': zone.trim(),
        'rack': rack.trim(),
        'shelf': shelf.trim(),
        'bin': bin.trim(),
        'status': status,
      };

      final newLocation = await _service.createStorageLocation(locationData);
      _locations.insert(0, newLocation);
      _totalCount++;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLocation({
    required int id,
    required int warehouseId,
    required String zone,
    required String rack,
    required String shelf,
    required String bin,
    required int status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final locationData = {
        'warehouseID': warehouseId,
        'zone': zone.trim(),
        'rack': rack.trim(),
        'shelf': shelf.trim(),
        'bin': bin.trim(),
        'status': status,
      };

      final updated = await _service.updateStorageLocation(id, locationData);

      // Update in local list
      final index = _locations.indexWhere((l) => l.locationId == id);
      if (index != -1) {
        _locations[index] = updated;
      }
      if (_selectedLocation?.locationId == id) {
        _selectedLocation = updated;
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

  Future<bool> toggleStatus(int id, int currentStatus) async {
    final targetStatus = currentStatus == 1 ? 0 : 1;
    try {
      _error = null;
      await _service.toggleStorageLocationStatus(id, targetStatus);
      
      // Update locally
      final index = _locations.indexWhere((l) => l.locationId == id);
      if (index != -1) {
        final loc = _locations[index];
        _locations[index] = StorageLocation(
          locationId: loc.locationId,
          warehouseId: loc.warehouseId,
          warehouseName: loc.warehouseName,
          zone: loc.zone,
          rack: loc.rack,
          shelf: loc.shelf,
          bin: loc.bin,
          locationCode: loc.locationCode,
          status: targetStatus,
          stockBalances: loc.stockBalances,
        );
      }
      if (_selectedLocation?.locationId == id) {
        final loc = _selectedLocation!;
        _selectedLocation = StorageLocation(
          locationId: loc.locationId,
          warehouseId: loc.warehouseId,
          warehouseName: loc.warehouseName,
          zone: loc.zone,
          rack: loc.rack,
          shelf: loc.shelf,
          bin: loc.bin,
          locationCode: loc.locationCode,
          status: targetStatus,
          stockBalances: loc.stockBalances,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLocation(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteStorageLocation(id);
      _locations.removeWhere((l) => l.locationId == id);
      _totalCount--;
      if (_selectedLocation?.locationId == id) {
        _selectedLocation = null;
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

  Future<List<Map<String, dynamic>>> loadLocationsLookupForWarehouse(int warehouseId, int excludeLocationId) async {
    try {
      final list = await _service.fetchStorageLocationsLookup();
      return list.where((l) => l['warehouseID'] == warehouseId && l['locationID'] != excludeLocationId).toList();
    } catch (e) {
      debugPrint('Error loading locations lookup: $e');
      return [];
    }
  }

  Future<List<String>> loadAvailableSerials({
    required int variantId,
    required int locationId,
    int? batchId,
  }) async {
    try {
      return await _service.fetchAvailableSerials(
        variantId: variantId,
        locationId: locationId,
        batchId: batchId,
      );
    } catch (e) {
      debugPrint('Error loading available serials: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _mapLocations = [];
  bool _isMapLoading = false;

  List<Map<String, dynamic>> get mapLocations => _mapLocations;
  bool get isMapLoading => _isMapLoading;

  Future<void> loadMapLocations(int warehouseId) async {
    try {
      _isMapLoading = true;
      _error = null;
      notifyListeners();

      final list = await _service.fetchStorageLocationsLookup();
      _mapLocations = list.where((l) => l['warehouseID'] == warehouseId).toList();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading map locations: $e');
    } finally {
      _isMapLoading = false;
      notifyListeners();
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _service.transferStock(
        sourceLocationId: sourceLocationId,
        targetLocationId: targetLocationId,
        variantId: variantId,
        batchId: batchId,
        quantity: quantity,
        serialNumbers: serialNumbers,
      );
      
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

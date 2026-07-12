import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storage_location_provider.dart';
import '../models/storage_location.dart';
import 'storage_location_detail_screen.dart';
import 'storage_location_form_screen.dart';
import 'warehouse_map_screen.dart';
import '../../auth/providers/auth_provider.dart';

class WarehouseLocationScreen extends StatefulWidget {
  final bool isReadOnly;
  const WarehouseLocationScreen({super.key, this.isReadOnly = false});

  @override
  State<WarehouseLocationScreen> createState() => _WarehouseLocationScreenState();
}

class _WarehouseLocationScreenState extends State<WarehouseLocationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int? _selectedWarehouseId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StorageLocationProvider>();
      provider.clearFilters();
      provider.loadActiveWarehouses();
      provider.loadStorageLocations(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<StorageLocationProvider>().loadMoreLocations();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = context.read<StorageLocationProvider>();
      provider.setSearchQuery(query);
      provider.loadStorageLocations(isRefresh: true);
    });
  }

  void _onWarehouseFilterChanged(int? warehouseId) {
    setState(() {
      _selectedWarehouseId = warehouseId;
    });
    final provider = context.read<StorageLocationProvider>();
    provider.setWarehouseId(warehouseId);
    provider.loadStorageLocations(isRefresh: true);
  }

  void _confirmDelete(StorageLocation location) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xóa?'),
        content: Text('Bạn có chắc chắn muốn xóa vị trí "${location.locationCode}"? Vị trí đã phát sinh giao dịch hoặc đang tồn kho sẽ không thể xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<StorageLocationProvider>();
              final success = await provider.deleteLocation(location.locationId);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa vị trí thành công!'), backgroundColor: Theme.of(context).colorScheme.tertiary),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? 'Xóa vị trí thất bại.'), backgroundColor: Theme.of(context).colorScheme.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            child: Text('Xóa', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  void _confirmToggleStatus(StorageLocation location) {
    final actionText = location.status == 1 ? 'vô hiệu hóa' : 'kích hoạt';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận đổi trạng thái?'),
        content: Text('Bạn có chắc chắn muốn $actionText vị trí "${location.locationCode}"? Vị trí đang còn hàng tồn kho sẽ không thể vô hiệu hóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<StorageLocationProvider>();
              final success = await provider.toggleStatus(location.locationId, location.status);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã $actionText vị trí thành công!'), backgroundColor: Theme.of(context).colorScheme.tertiary),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? 'Đổi trạng thái thất bại.'), backgroundColor: Theme.of(context).colorScheme.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            child: Text('Đồng ý', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorageLocationProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final isStaff = user?.roleName == 'Staff';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Vị trí lưu trữ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.map_outlined, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WarehouseMapScreen(
                    initialWarehouseId: _selectedWarehouseId,
                    isReadOnly: widget.isReadOnly || isStaff,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Panel
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Input
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo mã vị trí, zone, rack...',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                
                // Warehouse Dropdown Filter
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedWarehouseId,
                      hint: Text('Tất cả nhà kho', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 14)),
                      isExpanded: true,
                      onChanged: _onWarehouseFilterChanged,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Tất cả nhà kho', style: TextStyle(fontSize: 14)),
                        ),
                        ...provider.activeWarehouses.map((wh) {
                          return DropdownMenuItem<int?>(
                            value: wh['warehouseID'] as int,
                            child: Text(wh['warehouseName'] as String, style: TextStyle(fontSize: 14)),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Total counts summary bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              'Tìm thấy ${provider.totalCount} vị trí',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Locations List
          Expanded(
            child: provider.isLoading && provider.locations.isEmpty
                ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary)))
                : provider.locations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warehouse_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
                            SizedBox(height: 16),
                            Text(
                              'Không tìm thấy vị trí lưu trữ nào',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await provider.loadStorageLocations(isRefresh: true);
                        },
                        color: Theme.of(context).colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: provider.locations.length + (provider.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.locations.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary)),
                                ),
                              );
                            }

                            final loc = provider.locations[index];
                            final isActive = loc.status == 1;

                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              color: Theme.of(context).colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2), width: 1),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StorageLocationDetailScreen(
                                        locationId: loc.locationId,
                                        isReadOnly: widget.isReadOnly || isStaff,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Location Code
                                          Row(
                                            children: [
                                              Icon(Icons.pin_drop, color: Theme.of(context).colorScheme.primary, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                loc.locationCode,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          // Action button stack
                                          if (!widget.isReadOnly && !isStaff)
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => StorageLocationFormScreen(location: loc),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 20),
                                                  onPressed: () => _confirmDelete(loc),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      Divider(height: 16),
                                      
                                      // Details: Warehouse, Zone, Rack, Shelf, Bin
                                      Text(
                                        'Nhà kho: ${loc.warehouseName}',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87)),
                                      ),
                                      SizedBox(height: 6),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 6,
                                        children: [
                                          _buildDetailTag('Zone: ${loc.zone}'),
                                          _buildDetailTag('Rack: ${loc.rack}'),
                                          _buildDetailTag('Shelf: ${loc.shelf}'),
                                          _buildDetailTag('Bin: ${loc.bin}'),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      
                                      // Status Badge
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Trạng thái:',
                                            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
                                          ),
                                          InkWell(
                                            onTap: (widget.isReadOnly || isStaff) ? null : () => _confirmToggleStatus(loc),
                                            borderRadius: BorderRadius.circular(16),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isActive ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1) : Theme.of(context).colorScheme.error.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: isActive ? Theme.of(context).colorScheme.tertiary.withOpacity(0.3)! : Theme.of(context).colorScheme.error.withOpacity(0.3)!),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: isActive ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    isActive ? 'Hoạt động' : 'Vô hiệu hóa',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: isActive ? Theme.of(context).colorScheme.tertiary.withOpacity(0.8) : Theme.of(context).colorScheme.error.withOpacity(0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: (widget.isReadOnly || isStaff)
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StorageLocationFormScreen(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
            ),
    );
  }

  Widget _buildDetailTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

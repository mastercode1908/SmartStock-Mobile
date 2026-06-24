import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storage_location_provider.dart';
import '../models/storage_location.dart';
import 'storage_location_detail_screen.dart';
import 'storage_location_form_screen.dart';
import 'warehouse_map_screen.dart';

class WarehouseLocationScreen extends StatefulWidget {
  const WarehouseLocationScreen({super.key});

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
        title: const Text('Xác nhận xóa?'),
        content: Text('Bạn có chắc chắn muốn xóa vị trí "${location.locationCode}"? Vị trí đã phát sinh giao dịch hoặc đang tồn kho sẽ không thể xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<StorageLocationProvider>();
              final success = await provider.deleteLocation(location.locationId);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa vị trí thành công!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? 'Xóa vị trí thất bại.'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffb3272e)),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
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
        title: const Text('Xác nhận đổi trạng thái?'),
        content: Text('Bạn có chắc chắn muốn $actionText vị trí "${location.locationCode}"? Vị trí đang còn hàng tồn kho sẽ không thể vô hiệu hóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<StorageLocationProvider>();
              final success = await provider.toggleStatus(location.locationId, location.status);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã $actionText vị trí thành công!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? 'Đổi trạng thái thất bại.'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffb3272e)),
            child: const Text('Đồng ý', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorageLocationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb3272e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vị trí lưu trữ',
          style: TextStyle(
            color: Color(0xffb3272e),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Color(0xffb3272e)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WarehouseMapScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Input
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f3f5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo mã vị trí, zone, rack...',
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.black38),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.black38, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Warehouse Dropdown Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f3f5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedWarehouseId,
                      hint: const Text('Tất cả nhà kho', style: TextStyle(color: Colors.black54, fontSize: 14)),
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
                            child: Text(wh['warehouseName'] as String, style: const TextStyle(fontSize: 14)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              'Tìm thấy ${provider.totalCount} vị trí',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Locations List
          Expanded(
            child: provider.isLoading && provider.locations.isEmpty
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xffb3272e))))
                : provider.locations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              'Không tìm thấy vị trí lưu trữ nào',
                              style: TextStyle(color: Colors.black54, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await provider.loadStorageLocations(isRefresh: true);
                        },
                        color: const Color(0xffb3272e),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: provider.locations.length + (provider.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.locations.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xffb3272e))),
                                ),
                              );
                            }

                            final loc = provider.locations[index];
                            final isActive = loc.status == 1;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!, width: 1),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StorageLocationDetailScreen(locationId: loc.locationId),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Location Code
                                          Row(
                                            children: [
                                              const Icon(Icons.pin_drop, color: Color(0xffb3272e), size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                loc.locationCode,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xffb3272e),
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          // Action button stack
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
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
                                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                                onPressed: () => _confirmDelete(loc),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      
                                      // Details: Warehouse, Zone, Rack, Shelf, Bin
                                      Text(
                                        'Nhà kho: ${loc.warehouseName}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 6),
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
                                      const SizedBox(height: 12),
                                      
                                      // Status Badge
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Trạng thái:',
                                            style: TextStyle(fontSize: 13, color: Colors.black54),
                                          ),
                                          InkWell(
                                            onTap: () => _confirmToggleStatus(loc),
                                            borderRadius: BorderRadius.circular(16),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isActive ? Colors.green[50] : Colors.red[50],
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: isActive ? Colors.green[200]! : Colors.red[200]!),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: isActive ? Colors.green : Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    isActive ? 'Hoạt động' : 'Vô hiệu hóa',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: isActive ? Colors.green[700] : Colors.red[700],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StorageLocationFormScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xffb3272e),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDetailTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xffe9ecef),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

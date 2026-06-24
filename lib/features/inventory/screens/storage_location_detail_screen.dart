import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storage_location_provider.dart';
import 'storage_location_form_screen.dart';
import '../models/stock_balance.dart';

class StorageLocationDetailScreen extends StatefulWidget {
  final int locationId;

  const StorageLocationDetailScreen({super.key, required this.locationId});

  @override
  State<StorageLocationDetailScreen> createState() => _StorageLocationDetailScreenState();
}

class _StorageLocationDetailScreenState extends State<StorageLocationDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _storedItemsSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StorageLocationProvider>().loadLocationDetails(widget.locationId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool _isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    final nowVn = DateTime.now().toUtc().add(const Duration(hours: 7));
    final expiryVn = expiryDate.toUtc().add(const Duration(hours: 7));
    final nowVnDate = DateTime(nowVn.year, nowVn.month, nowVn.day);
    final expiryVnDate = DateTime(expiryVn.year, expiryVn.month, expiryVn.day);
    return expiryVnDate.isBefore(nowVnDate);
  }

  void _confirmDelete(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: Text('Bạn có chắc chắn muốn xóa vị trí "$code"? Vị trí đã phát sinh giao dịch hoặc đang tồn kho sẽ không thể xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<StorageLocationProvider>();
              final success = await provider.deleteLocation(widget.locationId);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa vị trí thành công!'), backgroundColor: Colors.green),
                );
                Navigator.pop(context); // Go back to list
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorageLocationProvider>();
    final loc = provider.selectedLocation;
    final isLoading = provider.isDetailLoading;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xffb3272e))),
        ),
      );
    }

    if (loc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết vị trí')),
        body: const Center(child: Text('Không tìm thấy thông tin vị trí lưu trữ này.')),
      );
    }

    final isActive = loc.status == 1;

    // Filter local stock balances based on search query
    final filteredBalances = loc.stockBalances.where((item) {
      final q = _storedItemsSearchQuery.toLowerCase();
      return item.productName.toLowerCase().contains(q) ||
          item.variantName.toLowerCase().contains(q) ||
          item.sku.toLowerCase().contains(q) ||
          item.barcode.toLowerCase().contains(q) ||
          (item.batchNumber?.toLowerCase().contains(q) ?? false);
    }).toList();

    // Statistics calculations
    final totalQuantity = loc.stockBalances.length;
    final lotQuantity = loc.stockBalances.where((item) => item.trackingMethod == 1).length;
    final serialQuantity = loc.stockBalances.where((item) => item.trackingMethod == 2).length;
    final basicQuantity = loc.stockBalances.where((item) => item.trackingMethod == 0).length;

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
        title: Text(
          'Chi tiết ${loc.locationCode}',
          style: const TextStyle(
            color: Color(0xffb3272e),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xffb3272e)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StorageLocationFormScreen(location: loc),
                ),
              );
              // Reload details on return
              provider.loadLocationDetails(widget.locationId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xffb3272e)),
            onPressed: () => _confirmDelete(loc.locationCode),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coordinate Details Card
              Card(
                color: Colors.white,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Thông Tin Tọa Độ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isActive ? Colors.green[200]! : Colors.red[200]!),
                            ),
                            child: Text(
                              isActive ? 'Hoạt động' : 'Vô hiệu hóa',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.green[700] : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDetailRow(Icons.warehouse, 'Nhà kho', loc.warehouseName),
                      const Divider(height: 24),
                      
                      Row(
                        children: [
                          Expanded(child: _buildCoordinateColumn('Khu (Zone)', loc.zone)),
                          Expanded(child: _buildCoordinateColumn('Dãy (Rack)', loc.rack)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildCoordinateColumn('Tầng (Shelf)', loc.shelf)),
                          Expanded(child: _buildCoordinateColumn('Ô (Bin)', loc.bin)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Tổng sản phẩm',
                      totalQuantity.toString(),
                      Icons.inventory_2_outlined,
                      const Color(0xfffef3f2),
                      const Color(0xff93000a),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Theo Lô (Batch)',
                      lotQuantity.toString(),
                      Icons.receipt_long_outlined,
                      const Color(0xffe6f3f0),
                      const Color(0xff006a67),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Theo Serial',
                      serialQuantity.toString(),
                      Icons.qr_code_outlined,
                      const Color(0xffeff2f7),
                      const Color(0xff005faf),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Hàng Thường (Basic)',
                      basicQuantity.toString(),
                      Icons.widgets_outlined,
                      const Color(0xfffff9db),
                      const Color(0xffe67e22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stored inventory header
              const Text(
                'Hàng hóa đang lưu trữ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Inner Search Field
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _storedItemsSearchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Tìm theo tên, SKU, barcode hoặc số lô...',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Stored Items List
              ...(() {
                final basicItems = filteredBalances.where((item) => item.trackingMethod == 0).toList();
                final lotItems = filteredBalances.where((item) => item.trackingMethod == 1).toList();
                final serialItems = filteredBalances.where((item) => item.trackingMethod == 2).toList();
                return [
                  _buildCategorySection('Hàng Thường (Basic)', basicItems, Icons.widgets_outlined, const Color(0xffe67e22)),
                  _buildCategorySection('Hàng Theo Lô (Batch)', lotItems, Icons.receipt_long_outlined, const Color(0xff006a67)),
                  _buildCategorySection('Hàng Theo Serial', serialItems, Icons.qr_code_outlined, const Color(0xff005faf)),
                ];
              })(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.black45, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ],
    );
  }

  Widget _buildCoordinateColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xfff1f3f5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValueChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Colors.black54),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodBadge(int trackingMethod) {
    String text = '';
    Color bgColor = Colors.grey;
    Color textColor = Colors.white;
    switch (trackingMethod) {
      case 0:
        text = 'Hàng thường';
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        break;
      case 1:
        text = 'Hàng lô';
        bgColor = Colors.teal.shade50;
        textColor = Colors.teal.shade800;
        break;
      case 2:
        text = 'Hàng serial';
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade800;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<StockBalance> items, IconData icon, Color headerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Row(
            children: [
              Icon(icon, size: 18, color: headerColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: headerColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: headerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          Card(
            color: Colors.white,
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  'Không có',
                  style: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[100]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildMethodBadge(item.trackingMethod),
                        ],
                      ),
                      if (item.variantName.isNotEmpty && item.variantName != item.productName) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Biến thể: ${item.variantName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          _buildLabelValueChip('SKU', item.sku),
                          const SizedBox(width: 8),
                          _buildLabelValueChip('Barcode', item.barcode),
                        ],
                      ),
                      const Divider(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lô: ${item.batchNumber ?? "N/A"}',
                                style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hạn dùng: ${_formatDate(item.expiryDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isExpired(item.expiryDate)
                                      ? Colors.red
                                      : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xffb3272e).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'SL: ${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffb3272e),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

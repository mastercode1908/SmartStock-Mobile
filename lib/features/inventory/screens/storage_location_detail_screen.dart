import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storage_location_provider.dart';
import 'storage_location_form_screen.dart';
import '../models/stock_balance.dart';
import '../models/storage_location.dart';

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

  void _openTransferDialog(BuildContext context, StockBalance item, StorageLocation loc) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransferBottomSheet(item: item, loc: loc),
    ).then((success) {
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chuyển vị trí hàng hóa thành công!'), backgroundColor: Colors.green),
        );
        context.read<StorageLocationProvider>().loadLocationDetails(widget.locationId);
      }
    });
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
    final lotQuantity = loc.stockBalances.where((item) => item.trackingMethod == 1 || item.trackingMethod == 3).length;
    final serialQuantity = loc.stockBalances.where((item) => item.trackingMethod == 2 || item.trackingMethod == 3).length;
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
                final serialItems = filteredBalances.where((item) => item.trackingMethod == 2 || item.trackingMethod == 3).toList();
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
      case 3:
        text = 'Lô & Serial';
        bgColor = Colors.deepPurple.shade50;
        textColor = Colors.deepPurple.shade800;
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
                      if ((item.trackingMethod == 2 || item.trackingMethod == 3) && item.serialNumbers.isNotEmpty) ...[
                        const Divider(height: 20),
                        const Text(
                          'Danh sách số Serial:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: item.serialNumbers.map((sn) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xfff1f3f5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.qr_code, size: 12, color: Colors.black54),
                                const SizedBox(width: 4),
                                Text(
                                  sn,
                                  style: const TextStyle(fontSize: 11, fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final loc = context.read<StorageLocationProvider>().selectedLocation!;
                            _openTransferDialog(context, item, loc);
                          },
                          icon: const Icon(Icons.swap_horiz, size: 16),
                          label: const Text('Chuyển vị trí'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xffb3272e),
                            side: const BorderSide(color: Color(0xffb3272e)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
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

class _TransferBottomSheet extends StatefulWidget {
  final StockBalance item;
  final StorageLocation loc;

  const _TransferBottomSheet({Key? key, required this.item, required this.loc}) : super(key: key);

  @override
  State<_TransferBottomSheet> createState() => _TransferBottomSheetState();
}

class _TransferBottomSheetState extends State<_TransferBottomSheet> {
  int? _targetLocationId;
  int _quantity = 1;
  final TextEditingController _qtyController = TextEditingController(text: '1');
  List<Map<String, dynamic>> _targetLocations = [];
  List<String> _availableSerials = [];
  final List<String> _selectedSerials = [];
  bool _isLoadingLocations = true;
  bool _isLoadingSerials = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<StorageLocationProvider>();
    setState(() {
      _isLoadingLocations = true;
    });
    
    // Load locations lookup
    final locs = await provider.loadLocationsLookupForWarehouse(widget.loc.warehouseId, widget.loc.locationId);
    
    setState(() {
      _targetLocations = locs;
      _isLoadingLocations = false;
    });

    // If serial tracking, load available serials
    if (widget.item.trackingMethod == 2 || widget.item.trackingMethod == 3) {
      setState(() {
        _isLoadingSerials = true;
      });
      final serials = await provider.loadAvailableSerials(
        variantId: widget.item.variantId,
        locationId: widget.loc.locationId,
        batchId: widget.item.batchId,
      );
      setState(() {
        _availableSerials = serials;
        _isLoadingSerials = false;
      });
    }
  }

  void _onQtyChanged(String val) {
    int? parsed = int.tryParse(val);
    if (parsed != null) {
      if (parsed > widget.item.quantity) {
        parsed = widget.item.quantity;
        _qtyController.text = parsed.toString();
        _qtyController.selection = TextSelection.fromPosition(TextPosition(offset: _qtyController.text.length));
      }
      setState(() {
        _quantity = parsed!;
      });
    }
  }

  Future<void> _submitTransfer() async {
    if (_targetLocationId == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn vị trí nhận.';
      });
      return;
    }

    if (_quantity <= 0 || _quantity > widget.item.quantity) {
      setState(() {
        _errorMessage = 'Số lượng không hợp lệ.';
      });
      return;
    }

    if ((widget.item.trackingMethod == 2 || widget.item.trackingMethod == 3) && _selectedSerials.length != _quantity) {
      setState(() {
        _errorMessage = 'Vui lòng chọn đúng $_quantity số Serial tương ứng.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final provider = context.read<StorageLocationProvider>();
    final success = await provider.transferStock(
      sourceLocationId: widget.loc.locationId,
      targetLocationId: _targetLocationId!,
      variantId: widget.item.variantId,
      batchId: widget.item.batchId,
      quantity: _quantity,
      serialNumbers: _selectedSerials,
    );

    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = provider.error ?? 'Đã có lỗi xảy ra khi chuyển vị trí.';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSerialTracking = widget.item.trackingMethod == 2 || widget.item.trackingMethod == 3;
    
    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar Indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chuyển vị trí hàng hóa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffb3272e),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),
            
            // Info Row
            Text(
              widget.item.productName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            if (widget.item.variantName.isNotEmpty && widget.item.variantName != widget.item.productName) ...[
              const SizedBox(height: 2),
              Text(
                'Biến thể: ${widget.item.variantName}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      children: [
                        const TextSpan(text: 'Vị trí nguồn: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: widget.loc.locationCode),
                      ],
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    children: [
                      const TextSpan(text: 'Hiện có: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: '${widget.item.quantity}',
                        style: const TextStyle(color: Color(0xffb3272e), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.item.batchNumber != null) ...[
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  children: [
                    const TextSpan(text: 'Số lô: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: widget.item.batchNumber!),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Dropdown chọn vị trí nhận
            const Text(
              'Chọn vị trí nhận',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            _isLoadingLocations
                ? const Center(child: Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))))))
                : _targetLocations.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text('Không tìm thấy vị trí khả dụng nào khác cùng nhà kho.', style: TextStyle(color: Colors.amber.shade900, fontSize: 13)),
                      )
                    : DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          hintText: 'Chọn vị trí đích',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffb3272e))),
                        ),
                        value: _targetLocationId,
                        items: _targetLocations.map((l) {
                          return DropdownMenuItem<int>(
                            value: l['locationID'] as int,
                            child: Text(l['locationCode'] as String),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _targetLocationId = val;
                          });
                        },
                      ),
            const SizedBox(height: 16),

            // Số lượng cần chuyển
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Số lượng cần chuyển',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xffb3272e)),
                      onPressed: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity--;
                                _qtyController.text = _quantity.toString();
                              });
                            }
                          : null,
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: _onQtyChanged,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xffb3272e)),
                      onPressed: _quantity < widget.item.quantity
                          ? () {
                              setState(() {
                                _quantity++;
                                _qtyController.text = _quantity.toString();
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Serial Numbers (if applicable)
            if (isSerialTracking) ...[
              Text(
                'Chọn số Serial tương ứng (Đã chọn ${_selectedSerials.length}/$_quantity)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              _isLoadingSerials
                  ? const Center(child: Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))))))
                  : _availableSerials.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                          child: const Text('Không tìm thấy số serial khả dụng nào.', style: TextStyle(color: Colors.red, fontSize: 13)),
                        )
                      : Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _availableSerials.length,
                            itemBuilder: (context, index) {
                              final sn = _availableSerials[index];
                              final isSelected = _selectedSerials.contains(sn);
                              return CheckboxListTile(
                                title: Text(sn, style: const TextStyle(fontFamily: 'Courier', fontSize: 14)),
                                value: isSelected,
                                activeColor: const Color(0xffb3272e),
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      if (_selectedSerials.length < _quantity) {
                                        _selectedSerials.add(sn);
                                      } else {
                                        _errorMessage = 'Bạn chỉ được chọn tối đa $_quantity số Serial.';
                                      }
                                    } else {
                                      _selectedSerials.remove(sn);
                                      _errorMessage = null;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 16),
            ],

            // Error Message
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb3272e),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                    : const Text('Xác nhận chuyển', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

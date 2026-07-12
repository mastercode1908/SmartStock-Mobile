import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'choose_product_screen.dart';
import '../providers/inventory_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/inventory_session.dart';
import '../models/inventory_count_detail.dart';
import 'count/create_success_screen.dart';

class CreateInventoryScreen extends StatefulWidget {
  const CreateInventoryScreen({Key? key}) : super(key: key);

  @override
  State<CreateInventoryScreen> createState() => _CreateInventoryScreenState();
}

class _CreateInventoryScreenState extends State<CreateInventoryScreen> {
  // Define Colors from Tailwind Config
  final Color _primary = const Color(0xFFB3272E);
  final Color _surface = const Color(0xFFF1FBFF);
  final Color _surfaceContainerHighest = const Color(0xFFD9E4E9);
  final Color _surfaceContainerLow = const Color(0xFFEAF5FA);
  final Color _onSurfaceVariant = const Color(0xFF59413F);
  final Color _surfaceVariant = const Color(0xFFE1BEBC);
  final Color _primaryContainer = const Color(0xFFFF5F5F);
  final Color _secondary = const Color(0xFF586062);
  final Color _secondaryContainer = const Color(0xFFDAE1E3);
  
  final Color _onSurface = const Color(0xFF131D21);

  int? _selectedWarehouseId;
  int? _selectedLocationId;
  int? _selectedStaffId;
  String _selectedCountType = 'LOCATION';
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedCountDate = DateTime.now();

  // PRODUCT COUNT
  final Set<int> _selectedProductVariantIds = {};
  final Map<int, int> _warehouseVariantQuantities = {};
  final List<Map<String, dynamic>> _warehouseStockBalances = [];

  // LOCATION COUNT
  bool _isLoadingLocationPreview = false;
  List<dynamic> _locationPreviewProducts = [];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InventoryProvider>();
      provider.loadWarehouses();
      provider.loadStaffs();
      provider.loadProductVariants();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn kho')),
      );
      return;
    }

    if (_selectedCountType == 'LOCATION' && _selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn vị trí')),
      );
      return;
    }

    if (_selectedCountType == 'PRODUCT' && _selectedProductVariantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 sản phẩm')),
      );
      return;
    }

    final provider = context.read<InventoryProvider>();
    final auth = context.read<AuthProvider>();
    
    // Xây dựng danh sách chi tiết
    List<InventoryCountDetail> sessionDetails = [];
    
    if (_selectedCountType == 'LOCATION') {
      sessionDetails = _locationPreviewProducts.map((p) {
        return InventoryCountDetail(
          countDetailId: 0,
          sessionId: 0,
          variantId: p['variantID'] ?? p['productVariant']?['variantID'] ?? 0,
          storageLocationId: _selectedLocationId!,
          systemQuantity: p['quantity'] ?? 0,
          actualQuantity: null,
          difference: 0,
          status: 'PENDING',
          batchId: p['batchID'],
          unitId: p['productVariant']?['unitID'] ?? 0,
        );
      }).toList();
    } else if (_selectedCountType == 'PRODUCT') {
      // Tìm tất cả các dòng stock liên quan tới các sản phẩm được chọn
      final matchingStocks = _warehouseStockBalances.where((s) => _selectedProductVariantIds.contains(s['variantId'])).toList();
      
      if (matchingStocks.isNotEmpty) {
        sessionDetails = matchingStocks.map((stock) {
          return InventoryCountDetail(
            countDetailId: 0,
            sessionId: 0,
            variantId: stock['variantId'],
            storageLocationId: stock['locationId'], // Sử dụng đúng vị trí có hàng
            systemQuantity: stock['quantity'],
            actualQuantity: null,
            difference: 0,
            status: 'PENDING',
            batchId: stock['batchId'],
            unitId: stock['unitId'] ?? 0,
          );
        }).toList();
      } else {
        // Trường hợp fallback nếu không tìm thấy stock nào (dù đã lọc qty > 0)
        sessionDetails = _selectedProductVariantIds.map((vId) {
          return InventoryCountDetail(
            countDetailId: 0,
            sessionId: 0,
            variantId: vId,
            storageLocationId: null,
            systemQuantity: 0,
            actualQuantity: null,
            difference: 0,
            status: 'PENDING',
            unitId: 0,
          );
        }).toList();
      }
    }

    final newSession = InventorySession(
      id: 0, // Server will generate the ID
      warehouseId: _selectedWarehouseId!,
      sessionCode: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      countType: _selectedCountType,
      status: 'DRAFT', // Trạng thái nháp để hỗ trợ offline sync
      description: _notesController.text.isNotEmpty ? _notesController.text : 'Phiếu kiểm kê mới',
      startDate: DateTime.now(),
      countDate: _selectedCountDate,
      createdBy: auth.currentUser?.userId ?? 0,
      assignedTo: _selectedStaffId ?? auth.currentUser?.userId,
      details: sessionDetails.isNotEmpty ? sessionDetails : null,
    );

    try {
      // Add the session and get the new session returned with its generated ID
      final addedSession = await provider.addSession(newSession);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateSuccessScreen(session: addedSession)),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        // Cố gắng parse JSON từ chuỗi lỗi để lấy message thân thiện
        try {
          final jsonStartIndex = errorMsg.indexOf('{');
          final jsonEndIndex = errorMsg.lastIndexOf('}');
          if (jsonStartIndex != -1 && jsonEndIndex != -1 && jsonEndIndex > jsonStartIndex) {
            final jsonString = errorMsg.substring(jsonStartIndex, jsonEndIndex + 1);
            final jsonMap = jsonDecode(jsonString);
            if (jsonMap is Map<String, dynamic> && jsonMap.containsKey('message')) {
              errorMsg = jsonMap['message'].toString();
            }
          } else {
            errorMsg = errorMsg.replaceAll('Exception: Failed to create session:', '').trim();
          }
        } catch (_) {
          errorMsg = errorMsg.replaceAll('Exception: Failed to create session:', '').trim();
        }

        // Hiện hộp thoại cảnh báo đẹp hơn thay vì SnackBar
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                const Text('Lỗi tạo phiếu'),
              ],
            ),
            content: Text(errorMsg),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672), // max-w-2xl
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Điền thông tin chi tiết để bắt đầu quá trình kiểm kê kho mới.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _buildForm(),
                const SizedBox(height: 24),
                _buildSubmitButton(context),
                const SizedBox(height: 64), // pb-32
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: _surfaceContainerHighest, width: 1)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _onSurfaceVariant),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Tạo phiếu kiểm kê',
        style: TextStyle(
          color: _primary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(Icons.inventory_2, color: _primary),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final userName = auth.currentUser?.fullName ?? 'Không xác định';
        final userId = auth.currentUser?.userId ?? 0;
        final currentDate = DateTime.now().toString().split(' ')[0];

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCountTypeSelection(),
              const SizedBox(height: 24),
              _buildWarehouseDropdown(),
              const SizedBox(height: 24),
              if (_selectedCountType == 'LOCATION') ...[
                _buildLocationDropdown(),
                const SizedBox(height: 16),
                _buildLocationPreview(),
                const SizedBox(height: 24),
              ] else ...[
                _buildProductCheckList(),
                const SizedBox(height: 24),
              ],
              _buildDatePickerField(),
              const SizedBox(height: 24),
              _buildStaffDropdown(),
              const SizedBox(height: 24),
              _buildTextArea('GHI CHÚ', 'Nhập ghi chú hoặc lý do kiểm kê...', _notesController),
            ],
          ),
        );
      }
    );
  }

  Widget _buildCountTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOẠI KIỂM KÊ',
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedCountType = 'LOCATION';
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedCountType == 'LOCATION' ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedCountType == 'LOCATION' ? _primary : _surfaceVariant,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Theo Vị trí',
                      style: TextStyle(
                        color: _selectedCountType == 'LOCATION' ? Colors.white : _onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedCountType = 'PRODUCT';
                  _selectedLocationId = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedCountType == 'PRODUCT' ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedCountType == 'PRODUCT' ? _primary : _surfaceVariant,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Theo Sản phẩm',
                      style: TextStyle(
                        color: _selectedCountType == 'PRODUCT' ? Colors.white : _onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaffDropdown() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NHÂN VIÊN THỰC HIỆN',
              style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _surfaceVariant),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedStaffId,
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline, color: _onSurfaceVariant.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Chọn nhân viên...'),
                items: provider.staffs.map((staff) {
                  return DropdownMenuItem<int>(
                    value: staff['userID'],
                    child: Text(staff['fullName'] ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStaffId = value;
                  });
                },
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildWarehouseDropdown() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.warehouses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TÊN KHO',
              style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _surfaceVariant),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedWarehouseId,
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.warehouse, color: _onSurfaceVariant.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Chọn kho cần kiểm kê...'),
                items: provider.warehouses.map((w) {
                  return DropdownMenuItem<int>(
                    value: w.id,
                    child: Text(w.warehouseName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWarehouseId = value;
                    _selectedLocationId = null; // reset location
                  });
                },
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildLocationDropdown() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.locations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredLocations = provider.locations
            .where((l) => l.warehouseId == _selectedWarehouseId)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VỊ TRÍ',
              style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _surfaceVariant),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedLocationId,
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on, color: _onSurfaceVariant.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Chọn vị trí...'),
                items: filteredLocations.map((l) {
                  return DropdownMenuItem<int>(
                    value: l.locationId,
                    child: Text(l.locationCode),
                  );
                }).toList(),
                onChanged: _selectedWarehouseId == null ? null : (value) async {
                  setState(() {
                    _selectedLocationId = value;
                    _isLoadingLocationPreview = true;
                    _locationPreviewProducts = [];
                  });
                  if (value != null) {
                    try {
                      final details = await context.read<InventoryProvider>().fetchLocationPreview(value);
                      if (mounted) {
                        setState(() {
                          _locationPreviewProducts = details['stockBalances'] ?? [];
                          _isLoadingLocationPreview = false;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          _isLoadingLocationPreview = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi tải danh sách sản phẩm: $e')),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildLocationPreview() {
    if (_isLoadingLocationPreview) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_selectedLocationId == null) {
      return const SizedBox.shrink();
    }

    final validProducts = _locationPreviewProducts.where((p) => (p['quantity'] ?? 0) > 0).toList();

    if (validProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _surfaceVariant),
        ),
        child: const Text('Không có sản phẩm nào có tồn kho tại vị trí này.'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: _surfaceVariant.withOpacity(0.5))),
            ),
            child: Text(
              'DANH SÁCH SẢN PHẨM (${validProducts.length})',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _onSurfaceVariant),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: validProducts.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: _surfaceVariant.withOpacity(0.3)),
            itemBuilder: (context, index) {
              final product = validProducts[index];
              final productName = product['productName'] ?? product['productVariant']?['product']?['productName'] ?? 'Unknown';
              final variantName = product['variantName'] ?? product['productVariant']?['variantName'] ?? '';
              final displayName = variantName.isNotEmpty && variantName != productName 
                  ? '$productName - $variantName' 
                  : productName;
              final quantity = product['quantity'] ?? 0;
              final batch = product['batchNumber'] ?? product['batch']?['batchNumber'];

              return ListTile(
                title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                subtitle: batch != null ? Text('Batch: $batch', style: TextStyle(fontSize: 12, color: _onSurfaceVariant)) : null,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Tồn: $quantity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primary)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCheckList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sản phẩm kiểm kê', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      _selectedProductVariantIds.isEmpty 
                        ? 'Chưa chọn sản phẩm nào' 
                        : 'Đã chọn: ${_selectedProductVariantIds.length} sản phẩm',
                      style: TextStyle(color: _selectedProductVariantIds.isEmpty ? Colors.red : _onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_selectedWarehouseId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn Tên kho trước khi chọn sản phẩm.')),
                    );
                    return;
                  }

                  // Hiện loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  final provider = context.read<InventoryProvider>();
                  
                  final warehouseLocations = provider.locations.where((l) => l.warehouseId == _selectedWarehouseId).toList();
                  Set<int> availableVariantIdsInWarehouse = {};
                  _warehouseVariantQuantities.clear();
                  _warehouseStockBalances.clear();
                  
                  for (var loc in warehouseLocations) {
                    try {
                      final locData = await provider.fetchLocationPreview(loc.locationId);
                      if (locData.containsKey('stockBalances') && locData['stockBalances'] is List) {
                        for (var stock in locData['stockBalances']) {
                          final vIdRaw = stock['variantID'] ?? stock['productVariant']?['variantID'];
                          final qtyRaw = stock['quantity'] ?? 0;
                          
                          int? variantId = vIdRaw is int ? vIdRaw : int.tryParse(vIdRaw.toString());
                          int qty = qtyRaw is num ? qtyRaw.toInt() : int.tryParse(qtyRaw.toString()) ?? 0;
                          
                          if (variantId != null && qty > 0) {
                            availableVariantIdsInWarehouse.add(variantId);
                            _warehouseVariantQuantities[variantId] = (_warehouseVariantQuantities[variantId] ?? 0) + qty;
                            _warehouseStockBalances.add({
                              'locationId': loc.locationId,
                              'variantId': variantId,
                              'quantity': qty,
                              'batchId': stock['batchID'],
                              'unitId': stock['productVariant']?['unitID'] ?? 0,
                            });
                          }
                        }
                      }
                    } catch (e) {
                      debugPrint('Error fetching location: $e');
                    }
                  }

                  // Đóng loading dialog
                  if (mounted) {
                    Navigator.pop(context);
                  }

                  provider.selectedVariants.clear();
                  provider.selectedVariants.addAll(
                    provider.productVariants.where((v) => _selectedProductVariantIds.contains(v.variantId))
                  );
                  
                  if (!mounted) return;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChooseProductScreen(
                        returnSelectedIds: true,
                        restrictToVariantIds: availableVariantIdsInWarehouse.isNotEmpty ? availableVariantIdsInWarehouse : null,
                      ),
                    ),
                  );
                  
                  // Dù nhận kết quả hay không, ta lấy trực tiếp từ provider
                  setState(() {
                    _selectedProductVariantIds.clear();
                    _selectedProductVariantIds.addAll(
                      context.read<InventoryProvider>().selectedVariants.map((v) => v.variantId)
                    );
                  });
                },
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('Chọn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _surfaceContainerLow,
                  foregroundColor: _primary,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        if (_selectedProductVariantIds.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _surfaceVariant.withOpacity(0.5)),
            ),
            child: Consumer<InventoryProvider>(
              builder: (context, provider, child) {
                final selectedProducts = provider.productVariants
                    .where((v) => _selectedProductVariantIds.contains(v.variantId))
                    .toList();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedProducts.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: _primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${p.productName} - ${p.sku}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Tồn: ${_warehouseVariantQuantities[p.variantId] ?? 0}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NGÀY KIỂM KÊ',
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedCountDate,
              firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: _primary, // header background color
                      onPrimary: Colors.white, // header text color
                      onSurface: _onSurface, // body text color
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != _selectedCountDate) {
              setState(() {
                _selectedCountDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _surfaceVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: _onSurfaceVariant.withOpacity(0.6)),
                const SizedBox(width: 12),
                Text(
                  '${_selectedCountDate.day.toString().padLeft(2, '0')}/${_selectedCountDate.month.toString().padLeft(2, '0')}/${_selectedCountDate.year}',
                  style: TextStyle(fontSize: 16, color: _onSurface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _onSurfaceVariant.withOpacity(0.6)),
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryContainer, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: value),
          style: TextStyle(color: _onSurfaceVariant),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _onSurfaceVariant.withOpacity(0.6)),
            filled: true,
            fillColor: _surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryContainer, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_task),
            SizedBox(width: 8),
            Text(
              'Tạo phiếu kiểm kê',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

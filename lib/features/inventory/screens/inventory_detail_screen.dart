import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../scanner/screens/scan_screen.dart';
import 'confirm_sync_screen.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_count_detail.dart';
import '../models/product_variant.dart';

class InventoryDetailScreen extends StatefulWidget {
  const InventoryDetailScreen({Key? key}) : super(key: key);

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  final Color _primary = const Color(0xFFB3272E);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _onSurfaceVariant = const Color(0xFF59413F);
  final Color _onSurface = const Color(0xFF131D21);
  final Color _surfaceContainerHigh = const Color(0xFFDFEAEF);
  final Color _outlineVariant = const Color(0xFFE1BEBC);
  final Color _tertiary = const Color(0xFF006A67);
  final Color _error = const Color(0xFFBA1A1A);
  final Color _errorContainer = const Color(0xFFFFDAD6);
  final Color _surfaceContainer = const Color(0xFFE4F0F4);

  // Map to hold text controllers for each variant
  final Map<int, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InventoryProvider>();
      final variants = provider.selectedVariants;
      for (var v in variants) {
        _quantityControllers[v.variantId] = TextEditingController();
      }
      provider.loadSystemQuantities();
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitCounts() async {
    final provider = context.read<InventoryProvider>();
    final sessionId = provider.activeSessionId ?? 0;
    
    List<InventoryCountDetail> details = [];
    
    for (var variant in provider.selectedVariants) {
      final controller = _quantityControllers[variant.variantId];
      final countedStr = controller?.text ?? '';
      if (countedStr.isEmpty) continue; // Skip if not counted
      
      final countedQty = int.tryParse(countedStr) ?? 0;
      final systemQty = provider.systemQuantities[variant.variantId] ?? 0;
      final diff = countedQty - systemQty;
      
      String status = 'MATCHED';
      if (diff != 0) status = 'DISCREPANCY';

      details.add(InventoryCountDetail(
        countDetailId: 0,
        sessionId: sessionId,
        variantId: variant.variantId,
        unitId: variant.baseUnitId,
        systemQuantity: systemQty,
        countedQuantity: countedQty,
        difference: diff,
        status: status,
      ));
    }

    if (details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ít nhất 1 số lượng đếm được')),
      );
      return;
    }

    await provider.submitCountDetails(details);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmSyncScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
            _buildProductList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Chi tiết Kiểm kê',
        style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.inventory_2, color: _primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final activeSession = provider.sessions.firstWhere(
          (s) => s.id == provider.activeSessionId,
          orElse: () => provider.sessions.isNotEmpty ? provider.sessions.first : throw Exception('No session'),
        );

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceContainerHigh.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow('Mã phiếu', activeSession.sessionCode, isValueBold: true, valueColor: _primary),
              const SizedBox(height: 8),
              _buildInfoRow('Ngày tạo', activeSession.startDate.toLocal().toString().split(' ')[0]),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isValueBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 12, color: _onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? _onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: _surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _outlineVariant),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(Icons.search, color: _onSurfaceVariant, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm tên/SKU...',
                      hintStyle: TextStyle(color: _onSurfaceVariant, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.selectedVariants.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Chưa có sản phẩm nào được chọn.")));
        }

        return Column(
          children: provider.selectedVariants.map((variant) {
            final controller = _quantityControllers[variant.variantId];
            String trackingStr = 'NONE';
            if (variant.trackingMethod == 1) trackingStr = 'LOT';
            if (variant.trackingMethod == 2) trackingStr = 'SERIAL';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildListItem(
                title: variant.variantName.isNotEmpty ? variant.variantName : variant.productName,
                sku: variant.sku,
                channel: trackingStr,
                systemQty: provider.systemQuantities[variant.variantId] ?? 0,
                controller: controller,
                statusIcon: Icons.help_outline,
                statusColor: _outlineVariant,
                borderColor: _surfaceContainerHigh.withOpacity(0.5),
              ),
            );
          }).toList(),
        );
      }
    );
  }

  Widget _buildListItem({
    required String title,
    required String sku,
    required String channel,
    required int systemQty,
    TextEditingController? controller,
    required IconData statusIcon,
    required Color statusColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                    Text('SKU: $sku', style: TextStyle(fontSize: 10, color: _onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(statusIcon, color: statusColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Hệ thống: ', style: TextStyle(fontSize: 11, color: _onSurfaceVariant)),
                  Text('$systemQty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _onSurface)),
                ],
              ),
              Row(
                children: [
                  Text('Thực tế: ', style: TextStyle(fontSize: 11, color: _onSurfaceVariant)),
                  const SizedBox(width: 4),
                  Container(
                    width: 60,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _surfaceContainer,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _outlineVariant),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '--',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest.withOpacity(0.9),
        border: Border(top: BorderSide(color: _surfaceContainerHigh.withOpacity(0.5))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanScreen()),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Quét mã nhanh', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: BorderSide(color: _primary),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _submitCounts,
                  child: const Text('Hoàn thành', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

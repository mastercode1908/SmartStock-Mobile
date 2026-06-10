import 'package:flutter/material.dart';

class InventoryDetailScreen extends StatelessWidget {
  const InventoryDetailScreen({Key? key}) : super(key: key);

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
      bottomSheet: _buildBottomActions(),
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
          _buildInfoRow('Mã phiếu', 'INV-2023-001', isValueBold: true, valueColor: _primary),
          const SizedBox(height: 8),
          _buildInfoRow('Kho', 'Kho Chính - Tầng 1'),
          const SizedBox(height: 8),
          _buildInfoRow('Ngày tạo', '24/10/2023'),
        ],
      ),
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
        const SizedBox(width: 16),
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _outlineVariant),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.tune, color: _onSurfaceVariant, size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return Column(
      children: [
        _buildListItem(
          title: 'Cáp sạc USB-C',
          sku: 'CAB-USBC-01',
          shelf: 'Kệ A1',
          lot: 'B-202310',
          serial: 'N/A',
          channel: 'Số lượng',
          systemQty: 150,
          actualQty: 150,
          statusIcon: Icons.check_circle,
          statusColor: _tertiary,
          borderColor: _surfaceContainerHigh.withOpacity(0.5),
        ),
        const SizedBox(height: 8),
        _buildListItem(
          title: 'Tai nghe Bluetooth',
          sku: 'AUD-BT-02',
          shelf: 'Kệ B3',
          lot: 'N/A',
          serial: 'SN-29384',
          channel: 'Serial',
          systemQty: 45,
          actualQty: 42,
          statusIcon: Icons.warning,
          statusColor: _error,
          borderColor: _error.withOpacity(0.2),
          actualBg: _errorContainer.withOpacity(0.2),
          actualColor: _error,
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: 0.8,
          child: _buildListItem(
            title: 'Bàn phím cơ',
            sku: 'KBD-MEC-05',
            shelf: 'Kệ C2',
            lot: 'N/A',
            serial: 'KBD-0912',
            channel: 'Serial',
            systemQty: 12,
            actualQty: null,
            statusIcon: Icons.help_outline,
            statusColor: _outlineVariant,
            borderColor: _surfaceContainerHigh.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildListItem({
    required String title,
    required String sku,
    required String shelf,
    required String lot,
    required String serial,
    required String channel,
    required int systemQty,
    required int? actualQty,
    required IconData statusIcon,
    required Color statusColor,
    required Color borderColor,
    Color? actualBg,
    Color? actualColor,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                  Text('SKU: $sku', style: TextStyle(fontSize: 10, color: _onSurfaceVariant)),
                ],
              ),
              Icon(statusIcon, color: statusColor, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 12),
                  const SizedBox(width: 4),
                  Text(shelf, style: const TextStyle(fontSize: 10)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('LÔ: ', style: TextStyle(fontSize: 10, color: _onSurfaceVariant.withOpacity(0.6))),
                  Text(lot, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SERIAL: ', style: TextStyle(fontSize: 10, color: _onSurfaceVariant.withOpacity(0.6))),
                  Text(serial, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
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
                      color: actualBg ?? _surfaceContainer,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: actualColor ?? _outlineVariant),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      actualQty != null ? '$actualQty' : '--',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: actualColor ?? _onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.rate_review, color: _primary, size: 18),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
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
            onPressed: () {},
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
                  onPressed: () {},
                  child: const Text('Lưu tạm', style: TextStyle(fontSize: 16)),
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
                  onPressed: () {},
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

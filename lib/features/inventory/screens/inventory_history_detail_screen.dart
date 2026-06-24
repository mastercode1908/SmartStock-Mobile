import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';

class InventoryHistoryDetailScreen extends StatefulWidget {
  final int sessionId;

  const InventoryHistoryDetailScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<InventoryHistoryDetailScreen> createState() => _InventoryHistoryDetailScreenState();
}

class _InventoryHistoryDetailScreenState extends State<InventoryHistoryDetailScreen> {
  final Color _primary = const Color(0xFFB3272E);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _onSurfaceVariant = const Color(0xFF59413F);
  final Color _onSurface = const Color(0xFF131D21);
  final Color _secondary = const Color(0xFF586062);
  final Color _outlineVariant = const Color(0xFFE1BEBC);
  final Color _surfaceContainerHigh = const Color(0xFFDFEAEF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadSessionDetails(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiết phiếu',
          style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final session = provider.selectedSession;
          if (session == null || session.id != widget.sessionId) {
            return Center(child: Text(provider.error ?? 'Không tìm thấy dữ liệu.'));
          }

          final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(session.startDate.toLocal());
          final details = session.details ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(session.sessionCode, dateStr, session.status, session.warehouseId.toString()),
                const SizedBox(height: 24),
                Text(
                  'Danh sách sản phẩm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _onSurface),
                ),
                const SizedBox(height: 16),
                if (details.isEmpty)
                  const Text('Chưa có chi tiết sản phẩm nào.')
                else
                  ...details.map((d) => _buildDetailItem(d)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String code, String date, String status, String warehouse) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          _buildInfoRow('Mã phiếu', code, isBold: true, color: _primary),
          const SizedBox(height: 8),
          _buildInfoRow('Ngày tạo', date),
          const SizedBox(height: 8),
          _buildInfoRow('Trạng thái', status),
          const SizedBox(height: 8),
          _buildInfoRow('Kho ID', warehouse),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 12, color: _onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? _onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(dynamic detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Variant ID: ${detail.variantId}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _onSurface)),
              Text(detail.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: detail.status == 'MATCHED' ? Colors.green : _primary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildValueCol('Hệ thống', detail.systemQuantity.toString()),
              _buildValueCol('Thực tế', detail.countedQuantity.toString()),
              _buildValueCol('Chênh lệch', detail.difference.toString(), isHighlight: detail.difference != 0),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildValueCol(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: _secondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlight ? _primary : _onSurface,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_session.dart';
import '../../models/inventory_count_detail.dart';

String _getTrackingLabel(int trackingMethod) {
  switch (trackingMethod) {
    case 1:
      return 'Theo lô (Batch)';
    case 2:
      return 'Số Serial';
    case 3:
      return 'Lô & Serial';
    default:
      return 'Không phân loại';
  }
}

class SessionReadonlyScreen extends StatefulWidget {
  final InventorySession session;
  const SessionReadonlyScreen({Key? key, required this.session}) : super(key: key);

  @override
  State<SessionReadonlyScreen> createState() => _SessionReadonlyScreenState();
}

class _SessionReadonlyScreenState extends State<SessionReadonlyScreen> {
  InventorySession? _fullSession;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final provider = context.read<InventoryProvider>();
      final s = await provider.loadSessionReadonly(widget.session.id);
      if (mounted) setState(() { _fullSession = s; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _fullSession ?? widget.session;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Chi tiết phiếu kiểm kê',
          style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)))
              : _buildBody(session),
    );
  }

  Widget _buildBody(InventorySession session) {
    final statusInfo = _getStatusInfo(session.status);

    final Map<String, List<InventoryCountDetail>> locationGroups = {};
    for (var d in session.details ?? []) {
      final key = _locationKey(d);
      locationGroups.putIfAbsent(key, () => []).add(d);
    }
    final locationKeys = locationGroups.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(session.sessionCode,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusInfo['bg'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusInfo['label'] as String,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusInfo['fg'] as Color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _infoRow(Icons.warehouse_outlined, 'Kho', session.warehouseName?.isNotEmpty == true ? session.warehouseName! : 'ID ${session.warehouseId}'),
                const SizedBox(height: 8),
                _infoRow(Icons.category_outlined, 'Loại kiểm kê', session.countType),
                const SizedBox(height: 8),
                _infoRow(Icons.calendar_today, 'Ngày tạo', _formatDate(session.startDate)),
                const SizedBox(height: 8),
                _infoRow(Icons.person_outline, 'Người tạo', session.createdByName?.isNotEmpty == true ? session.createdByName! : 'ID ${session.createdBy}'),
                if (session.assignedTo != null) ...[
                  const SizedBox(height: 8),
                  _infoRow(Icons.assignment_ind_outlined, 'Người được giao', session.assignedToName?.isNotEmpty == true ? session.assignedToName! : 'ID ${session.assignedTo}'),
                ],
                if (session.endDate != null) ...[
                  const SizedBox(height: 8),
                  _infoRow(Icons.event_available, 'Ngày kết thúc', _formatDate(session.endDate!)),
                ],
                if (session.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _infoRow(Icons.notes, 'Mô tả', session.description),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Summary row
          Row(children: [
            _summaryCard('Tổng SP', '${session.details?.length ?? 0}', Icons.inventory_2, AppColors.primary),
            const SizedBox(width: 12),
            _summaryCard(
              'Đã đếm',
              '${session.details?.where((d) => d.actualQuantity != null).length ?? 0}',
              Icons.check_circle,
              const Color(0xff0f5132),
            ),
            const SizedBox(width: 12),
            _summaryCard(
              'Chênh lệch',
              '${session.details?.where((d) => d.actualQuantity != null && (d.actualQuantity! - d.systemQuantity) != 0).length ?? 0}',
              Icons.warning_rounded,
              AppColors.error,
            ),
          ]),
          const SizedBox(height: 24),
          if (locationKeys.isEmpty)
            const Center(child: Text('Không có sản phẩm nào.', style: TextStyle(color: AppColors.onSurfaceVariant)))
          else ...[
            const Text('Danh sách sản phẩm theo vị trí',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            const SizedBox(height: 12),
            ...locationKeys.map((key) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLocationCard(key, locationGroups[key]!),
            )).toList(),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(String locationKey, List<InventoryCountDetail> details) {
    final first = details.first;
    final label = _locationLabel(first);
    final counted = details.where((d) => d.actualQuantity != null).length;
    final allDone = counted == details.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.location_on, color: AppColors.primary),
          title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          subtitle: Text('$counted/${details.length} sản phẩm', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          children: details.map((d) => _buildDetailRow(d)).toList(),
        ),
      ),
    );
  }

  Widget _buildDetailRow(InventoryCountDetail d) {
    final diff = d.actualQuantity != null ? d.actualQuantity! - d.systemQuantity : null;
    Color diffColor = AppColors.onSurface;
    if (diff != null) {
      if (diff > 0) diffColor = const Color(0xff0f5132);
      else if (diff < 0) diffColor = AppColors.error;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.variantName ?? d.sku ?? 'Unknown',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                if (d.sku != null && d.sku!.isNotEmpty)
                  Text(d.sku!, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 6),
                // Tracking Method Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTrackingColor(d.trackingMethod).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getTrackingLabel(d.trackingMethod),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getTrackingColor(d.trackingMethod)),
                  ),
                ),
                if (d.trackingMethod == 1 || d.trackingMethod == 3)
                  if (d.batchNumber != null && d.batchNumber!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Lô: ${d.batchNumber}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ),
                if (d.trackingMethod == 2 || d.trackingMethod == 3)
                  if (d.serialNumber != null && d.serialNumber!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Serial: ${d.serialNumber}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ),
              ],
            ),
          ),
          _detailCol('Hệ thống', '${d.systemQuantity}', AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          _detailCol('Thực tế', d.actualQuantity != null ? '${d.actualQuantity}' : '--', AppColors.onSurface),
          const SizedBox(width: 8),
          _detailCol(
            'Chênh lệch',
            diff != null ? (diff >= 0 ? '+$diff' : '$diff') : '--',
            diffColor,
          ),
        ],
      ),
    );
  }

  Widget _detailCol(String label, String value, Color valueColor) {
    return SizedBox(
      width: 64,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  String _locationKey(InventoryCountDetail d) {
    if (d.locationCode != null && d.locationCode!.isNotEmpty) return d.locationCode!;
    final parts = [d.zone, d.rack, d.shelf].where((x) => x != null && x.isNotEmpty).join('-');
    return parts.isNotEmpty ? parts : 'UNKNOWN';
  }

  String _locationLabel(InventoryCountDetail d) {
    final parts = [
      if (d.zone != null && d.zone!.isNotEmpty) 'Khu ${d.zone}',
      if (d.rack != null && d.rack!.isNotEmpty) 'Dãy ${d.rack}',
      if (d.shelf != null && d.shelf!.isNotEmpty) 'Tầng ${d.shelf}',
      if (d.bin != null && d.bin!.isNotEmpty) 'Ô ${d.bin}',
    ];
    if (parts.isNotEmpty) return parts.join(' - ');
    if (d.locationCode != null && d.locationCode!.isNotEmpty) return d.locationCode!;
    return 'Chưa xác định vị trí';
  }

  Color _getTrackingColor(int method) {
    switch (method) {
      case 1: return const Color(0xff1976D2); // Blue for Batch
      case 2: return const Color(0xffE64A19); // Deep Orange for Serial
      case 3: return const Color(0xff00796B); // Teal for Batch & Serial
      default: return const Color(0xff616161); // Grey for None
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'DRAFT':
        return {'label': 'Nháp', 'bg': const Color(0xffe9ecef), 'fg': const Color(0xff495057)};
      case 'PENDING':
        return {'label': 'Chờ duyệt', 'bg': const Color(0xfffff3cd), 'fg': const Color(0xff997404)};
      case 'APPROVED':
        return {'label': 'Đã duyệt', 'bg': const Color(0xffd1e7dd), 'fg': const Color(0xff0f5132)};
      case 'REJECTED':
        return {'label': 'Từ chối', 'bg': const Color(0xfff8d7da), 'fg': const Color(0xff842029)};
      case 'CANCELLED':
        return {'label': 'Đã hủy', 'bg': const Color(0xffe2e3e5), 'fg': const Color(0xff636464)};
      case 'POSTED':
        return {'label': 'Đã ghi nhận', 'bg': const Color(0xffcfe2ff), 'fg': const Color(0xff084298)};
      default:
        return {'label': status, 'bg': AppColors.surfaceContainerHigh, 'fg': AppColors.onSurface};
    }
  }
}

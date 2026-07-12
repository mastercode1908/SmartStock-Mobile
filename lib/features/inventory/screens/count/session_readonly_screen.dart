import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_session.dart';
import '../../models/inventory_count_detail.dart';
import '../../../auth/providers/auth_provider.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Chi tiết phiếu kiểm kê',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : _error != null
              ? Center(child: Text('Lỗi: $_error', style: TextStyle(color: Theme.of(context).colorScheme.error)))
              : _buildBody(session),
      bottomNavigationBar: _loading || _error != null ? null : _buildBottomBar(context, session),
    );
  }

  Widget? _buildBottomBar(BuildContext context, InventorySession session) {
    final role = context.read<AuthProvider>().currentUser?.roleName ?? '';
    final isManager = role.toLowerCase().contains('admin') || role.toLowerCase().contains('manager');

    if (!isManager || (session.status != 'PENDING' && session.status != 'APPROVED')) return null;

    if (session.status == 'APPROVED') {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: ElevatedButton(
          onPressed: () => _updateStatus(session, 'POSTED'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error, // Red for POSTED as requested
            foregroundColor: Theme.of(context).colorScheme.onError,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('GHI NHẬN ĐỒNG BỘ KHO', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    // PENDING state
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus(session, 'REJECTED'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('TỪ CHỐI', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(session, 'APPROVED'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error, // Red for Approve as requested
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('DUYỆT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(InventorySession session, String newStatus) async {
    final provider = context.read<InventoryProvider>();
    final success = await provider.updateSessionStatus(session, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật trạng thái thành công!')));
      Navigator.pop(context); // Trở về trang danh sách
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: ${provider.error}')));
    }
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(session.sessionCode,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                SizedBox(height: 12),
                Divider(height: 1),
                SizedBox(height: 12),
                _infoRow(Icons.warehouse_outlined, 'Kho', session.warehouseName?.isNotEmpty == true ? session.warehouseName! : 'Chưa rõ'),
                SizedBox(height: 8),
                _infoRow(Icons.category_outlined, 'Loại kiểm kê', session.countType),
                SizedBox(height: 8),
                _infoRow(Icons.calendar_today, 'Ngày tạo', _formatDate(session.startDate)),
                SizedBox(height: 8),
                _infoRow(Icons.person_outline, 'Người tạo', session.createdByName?.isNotEmpty == true ? session.createdByName! : context.read<InventoryProvider>().getStaffName(session.createdBy)),
                if (session.assignedTo != null) ...[
                  SizedBox(height: 8),
                  _infoRow(Icons.assignment_ind_outlined, 'Người được giao', session.assignedToName?.isNotEmpty == true ? session.assignedToName! : context.read<InventoryProvider>().getStaffName(session.assignedTo!)),
                ],
                if (session.endDate != null) ...[
                  SizedBox(height: 8),
                  _infoRow(Icons.event_available, 'Ngày kết thúc', _formatDate(session.endDate!)),
                ],
                if (session.description.isNotEmpty) ...[
                  SizedBox(height: 8),
                  _infoRow(Icons.notes, 'Mô tả', session.description),
                ],
              ],
            ),
          ),
          if (session.status != 'DRAFT') ...[
            SizedBox(height: 16), // Thêm khoảng cách cho giao diện dịch xuống
            // Summary row
            Row(children: [
              _summaryCard('Tổng SP', '${session.details?.length ?? 0}', Icons.inventory_2, Theme.of(context).colorScheme.primary),
              SizedBox(width: 12),
              _summaryCard(
                'Đã đếm',
                '${session.details?.where((d) => d.actualQuantity != null).length ?? 0}',
                Icons.check_circle,
                Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              SizedBox(width: 12),
              _summaryCard(
                'Chênh lệch',
                '${session.details?.where((d) => d.actualQuantity != null && (d.actualQuantity! - d.systemQuantity) != 0).length ?? 0}',
                Icons.warning_rounded,
                Theme.of(context).colorScheme.error,
              ),
            ]),
            SizedBox(height: 24),
          ],
          SizedBox(height: 24), // Thêm khoảng cách cho giao diện dịch xuống
          if (locationKeys.isEmpty)
            Center(child: Text('Không có sản phẩm nào.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
          else ...[
            Text('Danh sách sản phẩm theo vị trí',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 12),
            ...locationKeys.map((key) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildLocationCard(key, locationGroups[key]!, session.status),
            )).toList(),
          ],
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Expanded(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface))),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(String locationKey, List<InventoryCountDetail> details, String status) {
    final first = details.first;
    final label = _locationLabel(first);
    final counted = details.where((d) => d.actualQuantity != null).length;
    final allDone = counted == details.length;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.outlineVariant,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
          title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text('$counted/${details.length} sản phẩm', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          children: details.map((d) => _buildDetailRow(d, status)).toList(),
        ),
      ),
    );
  }

  Widget _buildDetailRow(InventoryCountDetail d, String status) {
    final diff = d.actualQuantity != null ? d.actualQuantity! - d.systemQuantity : null;
    Color diffColor = Theme.of(context).colorScheme.onSurface;
    if (diff != null) {
      if (diff > 0) diffColor = Theme.of(context).colorScheme.onTertiaryContainer;
      else if (diff < 0) diffColor = Theme.of(context).colorScheme.error;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.variantName ?? d.sku ?? 'Unknown',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                if (d.sku != null && d.sku!.isNotEmpty)
                  Text(d.sku!, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                SizedBox(height: 6),
                // Tracking Method Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Lô: ${d.batchNumber}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                if (d.trackingMethod == 2 || d.trackingMethod == 3)
                  if (d.serialNumber != null && d.serialNumber!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Serial: ${d.serialNumber}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
              ],
            ),
          ),
          _detailCol('Hệ thống', '${d.systemQuantity}', Theme.of(context).colorScheme.onSurfaceVariant),
          SizedBox(width: 8),
          if (status == 'DRAFT') ...[
            _detailCol('Thực tế', 'Chưa kiểm', Theme.of(context).colorScheme.onSurfaceVariant, isText: true),
          ] else ...[
            _detailCol('Thực tế', d.actualQuantity != null ? '${d.actualQuantity}' : '--', Theme.of(context).colorScheme.onSurface),
            SizedBox(width: 8),
            _detailCol(
              'Chênh lệch',
              diff != null ? (diff >= 0 ? '+$diff' : '$diff') : '--',
              diffColor,
            ),
          ]
        ],
      ),
    );
  }

  Widget _detailCol(String label, String value, Color valueColor, {bool isText = false}) {
    return SizedBox(
      width: isText ? 72 : 64,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: isText ? 13 : 18, fontWeight: FontWeight.bold, color: valueColor)),
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
        return {'label': 'Nháp', 'bg': Theme.of(context).colorScheme.surfaceContainer, 'fg': Theme.of(context).colorScheme.onSurface};
      case 'PENDING':
        return {'label': 'Chờ duyệt', 'bg': Theme.of(context).colorScheme.secondaryContainer, 'fg': Theme.of(context).colorScheme.onSecondaryContainer};
      case 'APPROVED':
        return {'label': 'Đã duyệt', 'bg': Theme.of(context).colorScheme.tertiaryContainer, 'fg': Theme.of(context).colorScheme.onTertiaryContainer};
      case 'REJECTED':
        return {'label': 'Từ chối', 'bg': Theme.of(context).colorScheme.errorContainer, 'fg': Theme.of(context).colorScheme.onErrorContainer};
      case 'CANCELLED':
        return {'label': 'Đã hủy', 'bg': Theme.of(context).colorScheme.surfaceContainerHigh, 'fg': Theme.of(context).colorScheme.onSurfaceVariant};
      case 'POSTED':
        return {'label': 'Đã ghi nhận', 'bg': Theme.of(context).colorScheme.primaryContainer, 'fg': Theme.of(context).colorScheme.onPrimaryContainer};
      default:
        return {'label': status, 'bg': Theme.of(context).colorScheme.surfaceContainerHigh, 'fg': Theme.of(context).colorScheme.onSurface};
    }
  }
}
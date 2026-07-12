import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../models/incident_report.dart';

class IncidentDetailScreen extends StatefulWidget {
  final int incidentId;

  const IncidentDetailScreen({
    super.key,
    required this.incidentId,
  });

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _isManager = user?.roleName == 'Admin' || user?.roleName == 'Manager';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().fetchIncidentReportDetail(widget.incidentId);
    });
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ duyệt';
      case 1:
        return 'Đang xử lý';
      case 2:
        return 'Đã duyệt';
      case 3:
        return 'Đã đóng';
      case 4:
        return 'Bị từ chối';
      default:
        return 'Không rõ';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xfff59e0b);
      case 1:
        return const Color(0xff3b82f6);
      case 2:
        return const Color(0xff10b981);
      case 3:
        return Colors.grey;
      case 4:
        return const Color(0xffef4444);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBgColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xfffef3c7);
      case 1:
        return const Color(0xffdbeafe);
      case 2:
        return const Color(0xffd1fae5);
      case 3:
        return const Color(0xfff3f4f6);
      case 4:
        return const Color(0xfffee2e2);
      default:
        return const Color(0xfff3f4f6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final detail = provider.currentReportDetail;
    final isLoading = provider.isLoadingDetail;

    if (isLoading && detail == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))),
        ),
      );
    }

    if (detail == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Theme.of(context).scaffoldBackgroundColor, elevation: 0),
        body: const Center(
          child: Text('Không thể tải chi tiết báo cáo sự cố.'),
        ),
      );
    }

    final report = detail.report;
    final user = report.reportedByUser;
    final variant = report.productVariant;
    final location = report.storageLocation;
    final batch = report.batch;

    final locationText = location != null ? '${location.rack}-${location.shelf}-${location.bin}' : 'KĐX';
    final zone = location?.zone ?? '';

    final name = variant?.variantName ?? 'Sản phẩm';
    final sku = variant?.sku ?? 'N/A';
    final barcode = variant?.barcode ?? 'N/A';
    final image = variant?.imageUrl?.isNotEmpty == true
        ? variant!.imageUrl!
        : 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=100';

    final createdDateStr = report.createdAt.isNotEmpty
        ? DateTime.parse(report.createdAt).toLocal().toString().substring(0, 16)
        : '-';

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb3272e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi Tiết Sự Cố',
          style: TextStyle(
            color: Color(0xffb3272e),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status & Title Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              report.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusBgColor(report.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getStatusText(report.status),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(report.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        _buildMetaRow(Icons.person_outline, 'Người báo cáo:', user?.fullName ?? 'Nhân viên'),
                        const SizedBox(height: 8),
                        _buildMetaRow(Icons.calendar_today_outlined, 'Ngày báo:', createdDateStr),
                        const SizedBox(height: 8),
                        _buildMetaRow(Icons.priority_high, 'Mức độ:', report.severity),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Details Card
                  const Text('Sản phẩm & Vị trí', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text('SKU: $sku | Barcode: $barcode', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: Color(0xffb3272e)),
                                  const SizedBox(width: 4),
                                  if (zone.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffb3272e).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        zone,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xffb3272e)),
                                      ),
                                    ),
                                  Text(
                                    locationText,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                  ),
                                ],
                              ),
                              if (batch != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.layers_outlined, size: 16, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text('Lô hàng: ${batch.batchNumber}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity Affected Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xfffee2e2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xfffca5a5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số lượng ảnh hưởng:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff991b1b), fontSize: 16),
                        ),
                        Text(
                          '${report.quantity} sản phẩm',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xff991b1b), fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Linked Serials Card
                  if (detail.linkedSerials.isNotEmpty) ...[
                    const Text('Danh sách mã Serial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: detail.linkedSerials.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final serial = detail.linkedSerials[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.qr_code, size: 18, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Text(serial.serialNumber, style: const TextStyle(fontFamily: 'monospace', fontSize: 15)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: serial.status == 4 ? const Color(0xfffee2e2) : const Color(0xffd1fae5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    serial.status == 4 ? 'Hư hỏng (DAMAGED)' : 'Đang xử lý',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: serial.status == 4 ? const Color(0xff991b1b) : const Color(0xff065f46),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Notes Description
                  const Text('Mô tả & Ghi chú', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      report.description.isNotEmpty ? report.description : 'Không có mô tả chi tiết.',
                      style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image Evidence Card
                  if (report.imageUrl.isNotEmpty) ...[
                    const Text('Hình ảnh bằng chứng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        report.imageUrl,
                        fit: BoxFit.cover,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(child: Text('Không thể tải ảnh bằng chứng.')),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Bottom buttons for Manager/Admin
          if (report.status == 0 && _isManager)
            _buildApprovalFooter(provider, report.incidentId),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: const TextStyle(color: Colors.black54, fontSize: 15),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalFooter(IncidentProvider provider, int id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _rejectIncident(provider, id),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffef4444)),
                  foregroundColor: const Color(0xffef4444),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('TỪ CHỐI', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _approveIncident(provider, id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb3272e),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('DUYỆT BÁO CÁO', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveIncident(IncidentProvider provider, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyệt báo cáo sự cố?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hệ thống sẽ trừ số lượng sản phẩm tương ứng trong kho và cập nhật trạng thái hư hỏng của serial/lô. Bạn đồng ý chứ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('HỦY', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DUYỆT', style: TextStyle(color: Color(0xffb3272e), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await provider.approveIncident(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã phê duyệt báo cáo sự cố và trừ kho thành công!'), backgroundColor: Color(0xffb3272e)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectIncident(IncidentProvider provider, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối báo cáo?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hành động này sẽ từ chối báo cáo sự cố và giải phóng các mã serial được liên kết. Tiếp tục chứ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('HỦY', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('TỪ CHỐI', style: TextStyle(color: Color(0xffef4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await provider.rejectIncident(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối báo cáo sự cố thành công!'), backgroundColor: Color(0xff006a67)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

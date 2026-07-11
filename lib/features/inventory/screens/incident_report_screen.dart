import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import 'create_incident_screen.dart';
import 'incident_detail_screen.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    final user = context.read<AuthProvider>().currentUser;
    _isManager = user?.roleName == 'Admin' || user?.roleName == 'Manager';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().fetchIncidentReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        return const Color(0xfff59e0b); // yellow
      case 1:
        return const Color(0xff3b82f6); // blue
      case 2:
        return const Color(0xff10b981); // green
      case 3:
        return Colors.grey;
      case 4:
        return const Color(0xffef4444); // red
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
    final reportsList = provider.reports;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb3272e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Color(0xffb3272e)),
            SizedBox(width: 8),
            Text(
              'Báo cáo Sự cố',
              style: TextStyle(
                color: Color(0xffb3272e),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xffb3272e),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xffb3272e),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Đã duyệt'),
            Tab(text: 'Từ chối'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsList(provider, null),
          _buildReportsList(provider, 0), // PENDING
          _buildReportsList(provider, 2), // RESOLVED
          _buildReportsList(provider, 4), // REJECTED
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateIncidentScreen()),
          );
        },
        backgroundColor: const Color(0xffb3272e),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Báo cáo mới', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildReportsList(IncidentProvider provider, int? statusFilter) {
    var list = provider.reports;
    if (statusFilter != null) {
      list = list.where((r) => r.status == statusFilter).toList();
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchIncidentReports(),
      color: const Color(0xffb3272e),
      child: provider.isLoading && list.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))))
          : list.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final report = list[index];
                    final dateStr = report.createdAt.isNotEmpty
                        ? DateTime.parse(report.createdAt).toLocal().toString().substring(0, 16)
                        : '-';
                    final reporter = report.reportedByUser?.fullName ?? 'Nhân viên';
                    final productName = report.productVariant?.variantName ?? 'Sản phẩm không xác định';
                    final locationName = report.storageLocation != null
                        ? '${report.storageLocation!.rack}-${report.storageLocation!.shelf}-${report.storageLocation!.bin}'
                        : 'Không rõ vị trí';

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      elevation: 1,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IncidentDetailScreen(incidentId: report.incidentId),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type (Title) and Status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    report.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusBgColor(report.status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getStatusText(report.status),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(report.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Product
                              Text(
                                productName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),

                              // Location and Qty details
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                                      const SizedBox(width: 4),
                                      Text(
                                        locationName,
                                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Số lượng: ${report.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xffb3272e)),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Người báo: $reporter',
                                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(color: Colors.black38, fontSize: 11),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Không có báo cáo sự cố nào.',
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

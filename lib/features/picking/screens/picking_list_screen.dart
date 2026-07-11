import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/picking_provider.dart';
import 'picking_detail_screen.dart';
import 'assign_picking_dialog.dart';

class PickingListScreen extends StatefulWidget {
  const PickingListScreen({super.key});

  @override
  State<PickingListScreen> createState() => _PickingListScreenState();
}

class _PickingListScreenState extends State<PickingListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _isManager = user?.roleName == 'Admin' || user?.roleName == 'Manager';
    _tabController = TabController(length: _isManager ? 2 : 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PickingProvider>();
      provider.fetchPickingTasks();
      if (_isManager) {
        provider.fetchUnassignedIssues();
        provider.fetchStaffs();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTaskStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ thực hiện';
      case 1:
        return 'Đang nhặt hàng';
      case 2:
        return 'Hoàn thành';
      case 3:
        return 'Đã hủy';
      default:
        return 'Không rõ';
    }
  }

  Color _getTaskStatusColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xfff59e0b); // Orange/Yellow
      case 1:
        return const Color(0xff3b82f6); // Blue
      case 2:
        return const Color(0xff10b981); // Green
      case 3:
        return const Color(0xffef4444); // Red
      default:
        return Colors.grey;
    }
  }

  Color _getTaskStatusBgColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xfffef3c7);
      case 1:
        return const Color(0xffdbeafe);
      case 2:
        return const Color(0xffd1fae5);
      case 3:
        return const Color(0xfffee2e2);
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PickingProvider>();

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
            Icon(Icons.inventory_2, color: Color(0xffb3272e)),
            SizedBox(width: 8),
            Text(
              'Nhặt Hàng (Picking)',
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
          tabs: _isManager
              ? const [
                  Tab(text: 'Nhiệm vụ'),
                  Tab(text: 'Chờ phân công'),
                ]
              : const [
                  Tab(text: 'Chờ lấy'),
                  Tab(text: 'Đang lấy'),
                  Tab(text: 'Hoàn thành'),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _isManager
            ? [
                _buildTasksTab(provider, null),
                _buildUnassignedTab(provider),
              ]
            : [
                _buildTasksTab(provider, 0), // PENDING
                _buildTasksTab(provider, 1), // IN_PROGRESS
                _buildTasksTab(provider, 2), // COMPLETED
              ],
      ),
    );
  }

  Widget _buildTasksTab(PickingProvider provider, int? statusFilter) {
    var list = provider.pickingTasks;
    if (statusFilter != null) {
      list = list.where((t) => t.status == statusFilter).toList();
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchPickingTasks(),
      color: const Color(0xffb3272e),
      child: provider.isLoading && list.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))))
          : list.isEmpty
              ? _buildEmptyState('Không có nhiệm vụ nào.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final task = list[index];
                    final dateStr = task.createdAt.isNotEmpty
                        ? DateTime.parse(task.createdAt).toLocal().toString().substring(0, 16)
                        : '-';
                    final assignedName = task.assignedToUser?.fullName ?? 'Chờ phân công';

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
                              builder: (context) => PickingDetailScreen(taskId: task.taskId),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    task.taskCode,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getTaskStatusBgColor(task.status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getTaskStatusText(task.status),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _getTaskStatusColor(task.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Nhân viên: $assignedName',
                                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Thời gian: $dateStr',
                                    style: const TextStyle(color: Colors.black54, fontSize: 12),
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

  Widget _buildUnassignedTab(PickingProvider provider) {
    final list = provider.unassignedIssues;

    return RefreshIndicator(
      onRefresh: () => provider.fetchUnassignedIssues(),
      color: const Color(0xffb3272e),
      child: provider.isLoadingAssign && list.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))))
          : list.isEmpty
              ? _buildEmptyState('Không có phiếu xuất kho nào chờ phân công.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final issue = list[index];
                    final dateStr = issue.createdAt.isNotEmpty
                        ? DateTime.parse(issue.createdAt).toLocal().toString().substring(0, 16)
                        : '-';
                    final creator = issue.createdByUser?.fullName ?? 'Hệ thống';

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    issue.issueCode,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Người tạo: $creator',
                                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Thời gian: $dateStr',
                                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AssignPickingDialog(
                                    issueId: issue.issueId,
                                    issueCode: issue.issueCode,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffb3272e),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Phân công', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

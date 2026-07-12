import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/picking_provider.dart';
import '../../models/picking_task.dart';
import 'pickup_step1_screen.dart';
import '../../../notifications/providers/notification_provider.dart';
import '../../../notifications/screens/notification_screen.dart';

class PickUpListScreen extends StatefulWidget {
  const PickUpListScreen({Key? key}) : super(key: key);

  @override
  State<PickUpListScreen> createState() => _PickUpListScreenState();
}

class _PickUpListScreenState extends State<PickUpListScreen> {
  int _activeFilter = -1; // -1: Tất cả, 0: Chờ thực hiện, 1: Đang làm, 2: Đã xong

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryPickingProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<InventoryPickingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchTasks(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Filter tasks based on _activeFilter
          final filteredTasks = provider.tasks.where((task) {
            if (_activeFilter == -1) {
              return true; // Include all tasks including CANCELLED ones
            }
            return task.status == _activeFilter;
          }).toList();

          return RefreshIndicator(
            onRefresh: () => provider.fetchTasks(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatusFilters(),
                  const SizedBox(height: 24),
                  if (filteredTasks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'Không có nhiệm vụ nào trong mục này.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ...filteredTasks.map((task) => _buildTaskCard(context, task)).toList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xfff9f9f9),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: const [
          Icon(Icons.inventory_2, color: Color(0xffb02528)),
          SizedBox(width: 8),
          Text(
            'Smart Stock',
            style: TextStyle(
              color: Color(0xffb02528),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            final unreadCount = provider.unreadCount;
            final displayCount = unreadCount > 99 ? '99+' : unreadCount.toString();
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Color(0xffb02528)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xffb02528),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        displayCount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey[300], height: 1.0),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Danh sách Nhặt hàng',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Chọn một nhiệm vụ được phân công để bắt đầu.',
                style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Tất cả', -1),
          const SizedBox(width: 8),
          _buildFilterChip('Chờ thực hiện', 0),
          const SizedBox(width: 8),
          _buildFilterChip('Đang làm', 1),
          const SizedBox(width: 8),
          _buildFilterChip('Đã xong', 2),
          const SizedBox(width: 8),
          _buildFilterChip('Đã hủy', 3),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int filterValue) {
    final bool isSelected = _activeFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = filterValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    String text = '';
    Color bgColor = Colors.grey;
    Color textColor = Colors.white;

    switch (status) {
      case 0:
        text = 'Chờ thực hiện (PENDING)';
        bgColor = const Color(0xFFFEF9C3); // yellow-100
        textColor = const Color(0xFF854D0E); // yellow-800
        break;
      case 1:
        text = 'Đang nhặt hàng (IN_PROGRESS)';
        bgColor = const Color(0xFFDBEAFE); // blue-100
        textColor = const Color(0xFF1E40AF); // blue-800
        break;
      case 2:
        text = 'Hoàn thành (COMPLETED)';
        bgColor = const Color(0xFFDCFCE7); // green-100
        textColor = const Color(0xFF166534); // green-800
        break;
      case 3:
        text = 'Đã hủy';
        bgColor = const Color(0xFFFEE2E2); // red-100
        textColor = const Color(0xFF991B1B); // red-800
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, PickingTask task) {
    final bool isNew = task.status == 0;
    final bool isHistorical = task.status == 2 || task.status == 3;
    int totalItems = task.details?.fold(0, (sum, d) => sum! + d.expectedQuantity) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.assignment, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.taskCode,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(task.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TỔNG SỐ LƯỢNG', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text('$totalItems', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CHI TIẾT', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text('${task.details?.length ?? 0} SKU', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isHistorical ? Colors.blueGrey : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            onPressed: () async {
              final provider = context.read<InventoryPickingProvider>();
              await provider.fetchTaskDetail(task.taskId);
              if (isNew) {
                await provider.startTask(task.taskId);
              }
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PickUpStep1Screen()),
                ).then((_) {
                  provider.fetchTasks();
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isHistorical
                    ? Icons.visibility
                    : isNew
                        ? Icons.play_arrow
                        : Icons.arrow_forward),
                const SizedBox(width: 8),
                Text(
                  isHistorical
                      ? 'Xem chi tiết'
                      : isNew
                          ? 'Nhận nhiệm vụ'
                          : 'Tiếp tục',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

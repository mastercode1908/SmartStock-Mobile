import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/picking_provider.dart';
import '../../models/picking_task.dart';
import 'pickup_step1_screen.dart';

class PickUpListScreen extends StatefulWidget {
  const PickUpListScreen({Key? key}) : super(key: key);

  @override
  State<PickUpListScreen> createState() => _PickUpListScreenState();
}

class _PickUpListScreenState extends State<PickUpListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PickingProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<PickingProvider>(
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
                  ElevatedButton(
                    onPressed: () => provider.fetchTasks(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatusFilters(),
                const SizedBox(height: 24),
                if (provider.tasks.isEmpty)
                  const Center(child: Text('Không có nhiệm vụ nào.'))
                else
                  ...provider.tasks.map((task) => _buildTaskCard(context, task)).toList(),
                const SizedBox(height: 80),
              ],
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
        IconButton(
          icon: const Icon(Icons.notifications, color: Color(0xffb02528)),
          onPressed: () {},
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
            children: [
              const Text(
                'Danh sách Nhặt hàng',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chọn một danh sách để bắt đầu thực hiện nhặt hàng.',
                style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Icon(Icons.filter_list, size: 18, color: AppColors.onSurface),
              SizedBox(width: 8),
              Text('Lọc', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
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
          _buildFilterChip('Tất cả', isSelected: true),
          const SizedBox(width: 8),
          _buildFilterChip('Mới', isSelected: false),
          const SizedBox(width: 8),
          _buildFilterChip('Đang làm', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, PickingTask task) {
    final bool isNew = task.status == 0;
    int totalItems = task.details?.fold(0, (sum, d) => sum! + d.expectedQuantity) ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    task.taskCode,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isNew 
                      ? AppColors.tertiaryContainer.withOpacity(0.2)
                      : AppColors.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isNew ? 'Mới' : 'Đang làm',
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w500, 
                    color: isNew ? AppColors.tertiary : AppColors.primary
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SỐ LƯỢNG', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    Text('$totalItems', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CHI TIẾT', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    Text('${task.details?.length ?? 0} SKU', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            onPressed: () async {
              final provider = context.read<PickingProvider>();
              await provider.fetchTaskDetail(task.taskId);
              if (isNew) {
                await provider.startTask(task.taskId);
              }
              if (context.mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PickUpStep1Screen()));
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isNew ? Icons.play_arrow : Icons.arrow_forward),
                const SizedBox(width: 8),
                Text(isNew ? 'Nhận nhiệm vụ' : 'Tiếp tục', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step1_screen.dart';

class CountListScreen extends StatelessWidget {
  const CountListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatusFilters(),
            const SizedBox(height: 24),
            _buildTaskList(context),
            const SizedBox(height: 80), // Padding for bottom nav
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
        onPressed: () {},
      ),
      title: const Text(
        'Warehouse Pro',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle, color: AppColors.onSurfaceVariant),
          onPressed: () {},
        ),
      ],
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
                'Danh sách Kiểm kê',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chọn một danh sách để bắt đầu xác minh kho.',
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

  Widget _buildTaskList(BuildContext context) {
    return Column(
      children: [
        _buildTaskCard(
          context,
          code: 'INV-2023-005',
          zone: 'Khu vực A',
          qtyTitle: 'TỔNG SẢN PHẨM',
          qty: '145',
          dateTitle: 'NGÀY DỰ KIẾN',
          date: 'Oct 24, 2023 - 08:00 AM',
          status: 'Mới',
        ),
        const SizedBox(height: 16),
        _buildTaskCard(
          context,
          code: 'INV-2023-006',
          zone: 'Khu vực C',
          qtyTitle: 'TIẾN ĐỘ',
          qty: '48 / 120 SKUs',
          dateTitle: 'NGÀY BẮT ĐẦU',
          date: 'Oct 24, 2023 - 09:15 AM',
          status: 'Đang làm',
          progress: 0.4,
        ),
        const SizedBox(height: 16),
        _buildTaskCard(
          context,
          code: 'INV-2023-007',
          zone: 'Khu vực D',
          qtyTitle: 'TỔNG SẢN PHẨM',
          qty: '85',
          dateTitle: 'NGÀY DỰ KIẾN',
          date: 'Oct 24, 2023 - 13:00 PM',
          status: 'Mới',
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, {
    required String code,
    required String zone,
    required String qtyTitle,
    required String qty,
    required String dateTitle,
    required String date,
    required String status,
    double? progress,
  }) {
    bool isNew = status == 'Mới';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (progress != null)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHigh,
              color: AppColors.primary,
              minHeight: 4,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assignment, color: isNew ? AppColors.onSurfaceVariant : AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          code,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isNew ? AppColors.tertiaryContainer.withOpacity(0.2) : AppColors.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: isNew ? null : Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isNew ? AppColors.tertiary : AppColors.primary),
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
                          const Text('KHU VỰC', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          Text(zone, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(qtyTitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          Text(qty, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateTitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),
                isNew
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep1Screen()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow),
                            SizedBox(width: 8),
                            Text('Nhận nhiệm vụ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          foregroundColor: AppColors.primary,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep1Screen()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Tiếp tục', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

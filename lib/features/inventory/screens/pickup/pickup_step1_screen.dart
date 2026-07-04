import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'pickup_step2_screen.dart';

class PickUpStep1Screen extends StatelessWidget {
  const PickUpStep1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressHeader(),
                const SizedBox(height: 32),
                _buildStatusFilter(),
                const SizedBox(height: 24),
                _buildPickingList(),
                const SizedBox(height: 100), // Padding for sticky bottom button
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 16,
            left: 16,
            child: _buildActionButton(context),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text(
        'Warehouse Pro',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
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

  Widget _buildProgressHeader() {
    return Column(
      children: [
        const Text(
          'Bước 1/5: Chọn Lô hàng',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Vui lòng chọn một danh sách lấy hàng đang chờ xử lý',
          style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.2, // 1/5
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trạng thái Lô hàng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
        const SizedBox(height: 12),
        _buildStatusCard(
          count: '12',
          title: 'Đang chờ xử lý',
          subtitle: 'Hàng trong kho • Zone A, B, C',
          isSelected: true,
        ),
        const SizedBox(height: 12),
        _buildStatusCard(
          count: '04',
          title: 'Ưu tiên cao',
          subtitle: 'Cần hoàn thành gấp',
          isSelected: false,
        ),
      ],
    );
  }

  Widget _buildStatusCard({required String count, required String title, required String subtitle, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceContainerLow : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceVariant, width: isSelected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer : AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildPickingList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Danh sách Lô hàng (Picking)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildPickingCard('BT-99201', '14:30', '24 Sản phẩm', false)),
            const SizedBox(width: 12),
            Expanded(child: _buildPickingCard('BT-99205', '16:00', '12 Sản phẩm', false)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildPickingCard('BT-99212', '17:45', '45 Sản phẩm', true)),
            const SizedBox(width: 12),
            Expanded(child: Container()), // Empty space for grid alignment
          ],
        ),
      ],
    );
  }

  Widget _buildPickingCard(String code, String deadline, String items, bool isPriority) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPriority ? AppColors.surfaceContainerLow : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              Icon(isPriority ? Icons.pending : Icons.inventory_2, color: isPriority ? AppColors.tertiary : AppColors.onSurfaceVariant, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text('Hạn chót: $deadline', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(items, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isPriority ? AppColors.tertiary : AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: 4,
            shadowColor: AppColors.primary.withOpacity(0.4),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PickUpStep2Screen()));
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tiếp tục Nhặt hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ],
    );
  }
}

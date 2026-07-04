import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step2_screen.dart';

class CountStep1Screen extends StatelessWidget {
  const CountStep1Screen({Key? key}) : super(key: key);

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
            _buildProgressHeader(),
            const SizedBox(height: 32),
            _buildZonesSelection(),
            const SizedBox(height: 32),
            _buildAislesSelection(),
            const SizedBox(height: 32),
            _buildActionArea(context),
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
          'Bước 1/5: Chọn Vị trí',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Chọn khu vực và dãy kệ cụ thể để bắt đầu kiểm kê',
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

  Widget _buildZonesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Khu vực Kho', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
        const SizedBox(height: 16),
        _buildZoneCard('A', 'Khu A - Điện tử', '12 Dãy kệ • 450 Thùng', true),
        const SizedBox(height: 12),
        _buildZoneCard('B', 'Khu B - Quần áo', '8 Dãy kệ • 320 Thùng', false),
        const SizedBox(height: 12),
        _buildZoneCard('C', 'Khu C - Hàng dễ hỏng', '5 Dãy kệ • 150 Thùng', false),
      ],
    );
  }

  Widget _buildZoneCard(String id, String title, String subtitle, bool isSelected) {
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
              id,
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
          Icon(
            isSelected ? Icons.check_circle : Icons.chevron_right,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildAislesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Các Dãy kệ trong Khu A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
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
            Expanded(child: _buildAisleCard('A-01', 'Chờ kiểm tra', false)),
            const SizedBox(width: 12),
            Expanded(child: _buildAisleCard('A-02', 'Chờ kiểm tra', false)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildAisleCard('A-03', 'Đang thực hiện', true)),
            const SizedBox(width: 12),
            Expanded(child: _buildAisleCard('A-04', 'Chờ kiểm tra', false)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildAisleCard('A-05', 'Chờ kiểm tra', false)),
            const SizedBox(width: 12),
            Expanded(child: Container()), // Empty space for alignment
          ],
        ),
      ],
    );
  }

  Widget _buildAisleCard(String title, String status, bool inProgress) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: inProgress ? AppColors.surfaceContainerLow : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: inProgress ? AppColors.outlineVariant : AppColors.surfaceVariant),
      ),
      child: Stack(
        children: [
          if (inProgress)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: Container(color: AppColors.tertiary),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    Icon(inProgress ? Icons.pending : Icons.shelves, color: inProgress ? AppColors.tertiary : AppColors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Trạng thái', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: inProgress ? AppColors.tertiary : AppColors.secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context) {
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
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep2Screen()));
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tiếp tục Kiểm đếm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/picking_provider.dart';
import 'pickup_step2_screen.dart';

class PickUpStep1Screen extends StatelessWidget {
  const PickUpStep1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<PickingProvider>(
        builder: (context, provider, child) {
          final task = provider.currentTask;
          if (task == null) {
            return const Center(child: Text('Không có dữ liệu nhiệm vụ.'));
          }

          final details = task.details ?? [];
          final pendingDetails = details.where((d) => d.status == 0 || d.status == 2).toList();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgressHeader(),
                    const SizedBox(height: 32),
                    Text(
                      'Sản phẩm cần lấy (Còn ${pendingDetails.length}/${details.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (pendingDetails.isEmpty)
                      const Center(child: Text('Đã nhặt xong tất cả sản phẩm.'))
                    else
                      ...pendingDetails.map((detail) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vị trí: ${detail.storageLocation?.locationCode ?? "N/A"}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text('Sản phẩm: ${detail.productVariant?.variantName ?? "N/A"}'),
                              Text('Số lượng cần lấy: ${detail.expectedQuantity}'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to next step with detail id
                                },
                                child: const Text('Bắt đầu nhặt ở đây'),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Positioned(
                bottom: 24,
                right: 16,
                left: 16,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pendingDetails.isEmpty ? AppColors.primary : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: pendingDetails.isEmpty ? () async {
                    await provider.completeTask(task.taskId);
                    Navigator.pop(context); // Go back to list
                  } : null,
                  child: const Text('Hoàn tất và Đồng bộ', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
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
        'Smart Stock',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        const Text(
          'Bước 1: Lộ trình',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Đến các vị trí kệ hàng dưới đây để nhặt đồ',
          style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

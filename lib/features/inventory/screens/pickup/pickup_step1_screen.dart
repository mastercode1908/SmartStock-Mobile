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
      body: Consumer<InventoryPickingProvider>(
        builder: (context, provider, child) {
          final task = provider.currentTask;
          if (task == null) {
            return const Center(child: Text('Không có dữ liệu nhiệm vụ.'));
          }

          final details = task.details ?? [];
          final pendingDetails = details.where((d) => d.status == 0).toList();
          final completedDetails = details.where((d) => d.status == 1 || d.status == 2).toList();
          final isCancelledTask = task.status == 3;
          final isCompletedTask = task.status == 2;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgressHeader(),
                    const SizedBox(height: 32),
                    if (isCancelledTask) ...[
                      // Cancelled banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xfffff5f5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xfffeb1b1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.cancel, color: Colors.red, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Nhiệm vụ đã bị hủy',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Nhiệm vụ nhặt hàng này đã bị hủy tự động do phát hiện thiếu hụt hàng hóa tại vị trí kệ.',
                                    style: TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Kết quả nhặt hàng thực tế (Đã hủy)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...details.map((detail) {
                        final isShort = detail.pickedQuantity < detail.expectedQuantity;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xfff8f9fa),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Vị trí: ${detail.storageLocation?.locationCode ?? "N/A"}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                  Icon(
                                    isShort ? Icons.error_outline : Icons.check_circle,
                                    color: isShort ? Colors.red : Colors.green,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Sản phẩm: ${detail.productVariant?.variantName ?? "N/A"}',
                                  style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 4),
                              Text(
                                'Số lượng nhặt: ${detail.pickedQuantity}/${detail.expectedQuantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isShort ? Colors.red[700] : Colors.green[700],
                                ),
                              ),
                              if (detail.serials != null && detail.serials!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text('Số Serials: ', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                    ...detail.serials!.map((s) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Text(
                                        s.serialNumber ?? 'N/A',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    )).toList(),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ] else ...[
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
                                if (detail.serials != null && detail.serials!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text('Số Serials: ', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                                      ...detail.serials!.map((s) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                        ),
                                        child: Text(
                                          s.serialNumber ?? 'N/A',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      )).toList(),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PickUpStep2Screen(detail: detail),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.play_arrow, size: 18),
                                    label: const Text('Bắt đầu nhặt ở đây', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      if (completedDetails.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Text(
                          'Sản phẩm đã nhặt',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...completedDetails.map((detail) {
                          final isFull = detail.pickedQuantity == detail.expectedQuantity;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xfff1f3f5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Vị trí: ${detail.storageLocation?.locationCode ?? "N/A"}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
                                    ),
                                    Icon(
                                      isFull ? Icons.check_circle : Icons.warning,
                                      color: isFull ? Colors.green : Colors.orange,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Sản phẩm: ${detail.productVariant?.variantName ?? "N/A"}',
                                    style: const TextStyle(color: Colors.black54)),
                                const SizedBox(height: 4),
                                Text(
                                  'Số lượng đã nhặt: ${detail.pickedQuantity}/${detail.expectedQuantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isFull ? Colors.green[700] : Colors.orange[700],
                                  ),
                                ),
                                if (detail.serials != null && detail.serials!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text('Số Serials: ', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                      ...detail.serials!.map((s) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Text(
                                          s.serialNumber ?? 'N/A',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                                        ),
                                      )).toList(),
                                    ],
                                  ),
                                ],
                                if (task.status != 2) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.primary),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        foregroundColor: AppColors.primary,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PickUpStep2Screen(detail: detail),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Nhập lại / Sửa số lượng', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
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
                    backgroundColor: (isCompletedTask || isCancelledTask || pendingDetails.isEmpty) ? AppColors.primary : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: (isCompletedTask || isCancelledTask)
                      ? () => Navigator.pop(context)
                      : (pendingDetails.isEmpty
                          ? () async {
                              // Show progress loader
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              );
                              final result = await provider.completeTask(task.taskId);
                              if (context.mounted) {
                                Navigator.pop(context); // Pop loading spinner
                                
                                final bool isSuccess = result['success'] == true;
                                final String message = (result['message'] ?? 'Hoàn tất nhiệm vụ.').toString();
                                final bool isShortage = message.toLowerCase().contains('hủy') || message.toLowerCase().contains('thiếu');

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(
                                          isShortage 
                                              ? Icons.warning_amber_rounded 
                                              : (isSuccess ? Icons.check_circle_outline : Icons.error_outline),
                                          color: isShortage 
                                              ? Colors.orange 
                                              : (isSuccess ? Colors.green : Colors.red),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(isShortage ? 'Nhiệm vụ bị hủy' : (isSuccess ? 'Thành công' : 'Thất bại')),
                                      ],
                                    ),
                                    content: Text(message),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx); // Pop alert dialog
                                          Navigator.pop(context); // Pop step 1 screen to go back to list
                                        },
                                        child: const Text('Đồng ý'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          : null),
                  child: Text(
                    (isCompletedTask || isCancelledTask) ? 'Quay lại' : 'Hoàn tất và Đồng bộ',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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

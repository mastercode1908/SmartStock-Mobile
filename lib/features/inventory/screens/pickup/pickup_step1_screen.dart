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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Consumer<InventoryPickingProvider>(
        builder: (context, provider, child) {
          final task = provider.currentTask;
          if (task == null) {
            return Center(child: Text('Không có dữ liệu nhiệm vụ.'));
          }

          final details = task.details ?? [];
          final pendingDetails = details.where((d) => d.status == 0).toList();
          final completedDetails = details.where((d) => d.status == 1 || d.status == 2).toList();
          final isCancelledTask = task.status == 3;
          final isCompletedTask = task.status == 2;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgressHeader(context),
                    SizedBox(height: 32),
                    if (isCancelledTask) ...[
                      // Cancelled banner
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xfffff5f5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xfffeb1b1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.cancel, color: Colors.red, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nhiệm vụ đã bị hủy',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Nhiệm vụ nhặt hàng này đã bị hủy tự động do phát hiện thiếu hụt hàng hóa tại vị trí kệ.',
                                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Kết quả nhặt hàng thực tế (Đã hủy)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      ...details.map((detail) {
                        final isShort = detail.pickedQuantity < detail.expectedQuantity;
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
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
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87)),
                                  ),
                                  Icon(
                                    isShort ? Icons.error_outline : Icons.check_circle,
                                    color: isShort ? Colors.red : Colors.green,
                                    size: 20,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text('Sản phẩm: ${detail.productVariant?.variantName ?? "N/A"}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54))),
                              SizedBox(height: 4),
                              Text(
                                'Số lượng nhặt: ${detail.pickedQuantity}/${detail.expectedQuantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isShort ? Colors.red[700] : Colors.green[700],
                                ),
                              ),
                              if (detail.serials != null && detail.serials!.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text('Số Serials: ', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54))),
                                    ...detail.serials!.map((s) => Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Text(
                                        s.serialNumber ?? 'N/A',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      if (pendingDetails.isEmpty)
                        Center(child: Text('Đã nhặt xong tất cả sản phẩm.'))
                      else
                        ...pendingDetails.map((detail) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vị trí: ${detail.storageLocation?.locationCode ?? "N/A"}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 8),
                                Text('Sản phẩm: ${detail.productVariant?.variantName ?? "N/A"}'),
                                Text('Số lượng cần lấy: ${detail.expectedQuantity}'),
                                if (detail.serials != null && detail.serials!.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text('Số Serials: ', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                      ...detail.serials!.map((s) => Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                        ),
                                        child: Text(
                                          s.serialNumber ?? 'N/A',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      )).toList(),
                                    ],
                                  ),
                                ],
                                SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Theme.of(context).colorScheme.surface,
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
                                    icon: Icon(Icons.play_arrow, size: 18),
                                    label: Text('Bắt đầu nhặt ở đây', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      if (completedDetails.isNotEmpty) ...[
                        SizedBox(height: 32),
                        Text(
                          'Sản phẩm đã nhặt',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        ...completedDetails.map((detail) {
                          final isFull = detail.pickedQuantity == detail.expectedQuantity;
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(16),
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
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
                                    ),
                                    Icon(
                                      isFull ? Icons.check_circle : Icons.warning,
                                      color: isFull ? Colors.green : Colors.orange,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text('Sản phẩm: ${detail.productVariant?.variantName ?? "N/A"}',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54))),
                                SizedBox(height: 4),
                                Text(
                                  'Số lượng đã nhặt: ${detail.pickedQuantity}/${detail.expectedQuantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isFull ? Colors.green[700] : Colors.orange[700],
                                  ),
                                ),
                                if (detail.serials != null && detail.serials!.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text('Số Serials: ', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54))),
                                      ...detail.serials!.map((s) => Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Text(
                                          s.serialNumber ?? 'N/A',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
                                        ),
                                      )).toList(),
                                    ],
                                  ),
                                ],
                                if (task.status != 2) ...[
                                  SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: AppColors.primary),
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
                                      icon: Icon(Icons.edit, size: 16),
                                      label: Text('Nhập lại / Sửa số lượng', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                    SizedBox(height: 100),
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
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: (isCompletedTask || isCancelledTask)
                      ? () => Navigator.pop(context)
                      : (pendingDetails.isEmpty
                          ? () async {
                              // Show progress loader
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => Center(
                                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.surface),
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
                                        SizedBox(width: 8),
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
                                        child: Text('Đồng ý'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          : null),
                  child: Text(
                    (isCompletedTask || isCancelledTask) ? 'Quay lại' : 'Hoàn tất và Đồng bộ',
                    style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'Smart Stock',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bước 1: Lộ trình',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Đến các vị trí kệ hàng dưới đây để nhặt đồ',
          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/picking_detail.dart';
import 'pickup_step3_screen.dart';

class PickUpStep2Screen extends StatefulWidget {
  final PickingDetail detail;
  const PickUpStep2Screen({Key? key, required this.detail}) : super(key: key);

  @override
  State<PickUpStep2Screen> createState() => _PickUpStep2ScreenState();
}

class _PickUpStep2ScreenState extends State<PickUpStep2Screen> {
  void _showManualInputDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập mã vị trí thủ công'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nhập mã vị trí kệ hàng (ví dụ: ${widget.detail.storageLocation?.locationCode ?? "A-12-04"})',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final val = controller.text.trim().toUpperCase();
              final target = (widget.detail.storageLocation?.locationCode ?? '').trim().toUpperCase();
              Navigator.pop(ctx); // Close dialog
              
              if (val == target) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PickUpStep3Screen(detail: widget.detail),
                  ),
                );
              } else {
                _showErrorDialog(context, val);
              }
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String enteredCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Sai kệ hàng!'),
          ],
        ),
        content: Text(
          'Mã vị trí "$enteredCode" không khớp với vị trí kệ hàng cần nhặt "${widget.detail.storageLocation?.locationCode}".\n\nVui lòng di chuyển đến đúng vị trí kệ để tiếp tục.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildTargetLocationCard(),
          Expanded(child: _buildScannerMockup(context)),
          _buildInventoryInfoTip(),
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
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text(
        'Bước 2/5: Quét mã Vị trí',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: AppColors.onSurfaceVariant),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTargetLocationCard() {
    final locationCode = widget.detail.storageLocation?.locationCode ?? "N/A";
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('VỊ TRÍ CẦN ĐẾN', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                Text(locationCode, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warehouse, color: AppColors.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerMockup(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Simulate successful scan
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PickUpStep3Screen(detail: widget.detail),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background image mockup
            Opacity(
              opacity: 0.5,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCTqL5EcExNMBEN3q3OYv_pW-wP3Cx5hCUoo8exohltYS28kZNkNcfOxBKpKoDqY8JPge5nljrLzRYiIPDiohfY4Lowumir6ql897Sawa5Xc4FZbuNE8zMyyWBc2zBpInVq5KDWV_Jj2vmu1y23iGLMZEcCyRMBbRCio-oQKeLqC17vSYUh7uF5cYHJE3BoOmI-ylG390XldcFG_tRykiXwnht5rF4D51wdCy7LAeUozWYu_7w7ZdRNApfAlup4wrvxflJd0ubJQjqF',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Scanner Frame
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 2,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.primary, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 120,
              child: Text(
                'Căn chỉnh mã QR/Barcode\ncủa vị trí vào giữa khung để quét\n(Bấm vào khung để tiếp tục)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Positioned(
              bottom: 32,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHighest.withOpacity(0.9),
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => _showManualInputDialog(context),
                icon: const Icon(Icons.keyboard),
                label: const Text('Nhập thủ công'),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.flashlight_on, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryInfoTip() {
    final productName = widget.detail.productVariant?.variantName ?? "Sản phẩm N/A";
    final expectedQty = widget.detail.expectedQuantity;
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'Sản phẩm: '),
                    TextSpan(text: '$productName\n', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    const TextSpan(text: 'Số lượng yêu cầu: '),
                    TextSpan(text: '$expectedQty', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

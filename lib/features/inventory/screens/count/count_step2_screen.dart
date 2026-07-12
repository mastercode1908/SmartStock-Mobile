import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step3_screen.dart';
import 'count_step4_screen.dart';
import '../../providers/inventory_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/product_variant.dart';
import 'package:collection/collection.dart';

class CountStep2Screen extends StatefulWidget {
  const CountStep2Screen({Key? key}) : super(key: key);

  @override
  State<CountStep2Screen> createState() => _CountStep2ScreenState();
}

class _CountStep2ScreenState extends State<CountStep2Screen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late MobileScannerController _scannerController;
  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _processBarcode(String rawValue, InventoryProvider provider) {
    if (_isProcessing) return;
    _isProcessing = true;
    _scannerController.stop();

    final details = provider.activeLocationGroup;
    final match = details.firstWhereOrNull((d) => 
      d.serialNumber == rawValue || 
      d.batchNumber == rawValue || 
      d.sku == rawValue || 
      d.variantId.toString() == rawValue
    );

    if (match != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CountStep3Screen(detail: match)),
      ).then((_) {
        if (mounted) {
          _isProcessing = false;
          _scannerController.start();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy sản phẩm với mã: $rawValue')),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _isProcessing = false;
          _scannerController.start();
        }
      });
    }
  }

  Future<void> _scanFromImage(InventoryProvider provider) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      final capture = await _scannerController.analyzeImage(file.path);
      if (capture != null && capture.barcodes.isNotEmpty && capture.barcodes.first.rawValue != null) {
        _processBarcode(capture.barcodes.first.rawValue!, provider);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy mã vạch nào trong ảnh.')),
        );
      }
    }
  }

  void _showManualEntryBottomSheet(BuildContext context, InventoryProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            final details = provider.activeLocationGroup;
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Chọn sản phẩm cần đếm',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                Expanded(
                  child: details.isEmpty
                      ? Center(child: Text('Không có sản phẩm nào để kiểm đếm.'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: details.length,
                          itemBuilder: (context, index) {
                            final detail = details[index];
                            final title = (detail.variantName != null && detail.variantName!.isNotEmpty) ? detail.variantName! : (detail.productName ?? 'Unknown');
                            final skuText = 'SKU: ${detail.sku ?? ""}';
                            
                            // Build subtitle with Serial / Batch on new line
                            List<String> trackingInfo = [];
                            if (detail.trackingMethod == 1 || detail.trackingMethod == 3) {
                              if (detail.batchNumber != null && detail.batchNumber!.isNotEmpty) {
                                trackingInfo.add('Lô: ${detail.batchNumber}');
                              }
                            }
                            if (detail.trackingMethod == 2 || detail.trackingMethod == 3) {
                              if (detail.serialNumber != null && detail.serialNumber!.isNotEmpty) {
                                trackingInfo.add('Serial: ${detail.serialNumber}');
                              }
                            }
                            
                            final hasCounted = detail.actualQuantity != null;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                child: Icon(Icons.inventory_2, color: AppColors.primary),
                              ),
                              title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(skuText),
                                  if (trackingInfo.isNotEmpty)
                                    Text(trackingInfo.join(' | ')),
                                ],
                              ),
                              trailing: Icon(
                                hasCounted ? Icons.check_circle : Icons.chevron_right, 
                                color: hasCounted ? const Color(0xff0f5132) : Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CountStep3Screen(detail: detail),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Camera Background
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  final provider = context.read<InventoryProvider>();
                  _processBarcode(barcodes.first.rawValue!, provider);
                }
              },
            ),
          ),
          
          // Header Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: EdgeInsets.only(top: 48, bottom: 16, left: 16, right: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: AppColors.primary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Smart Stock',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.help_outline, color: AppColors.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Text(
                    'Bước 2/5: Quét mã sản phẩm',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Căn chỉnh mã vạch vào trong khung đỏ',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),

          // Scanner Overlay
          Center(
            child: Container(
              width: 288,
              height: 192,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Corner Accents
                  _buildCorner(top: true, left: true),
                  _buildCorner(top: true, left: false),
                  _buildCorner(top: false, left: true),
                  _buildCorner(top: false, left: false),
                  
                  // Laser Line
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value * (192 - 4),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.inverseSurface,
                    AppColors.inverseSurface.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Consumer<InventoryProvider>(
                builder: (context, provider, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                                ),
                                child: IconButton(
                                  icon: Icon(_isFlashOn ? Icons.flashlight_off : Icons.flashlight_on, color: Theme.of(context).colorScheme.surface),
                                  onPressed: () {
                                    _scannerController.toggleTorch();
                                    setState(() {
                                      _isFlashOn = !_isFlashOn;
                                    });
                                  },
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.image, color: Theme.of(context).colorScheme.surface),
                                  onPressed: () => _scanFromImage(provider),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep4Screen()));
                            },
                            icon: Icon(Icons.checklist),
                            label: Text('Xem danh sách'),
                          )
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Theme.of(context).colorScheme.surface,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          minimumSize: const Size(double.infinity, 56),
                          elevation: 4,
                        ),
                        onPressed: () {
                          _showManualEntryBottomSheet(context, provider);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.keyboard),
                            SizedBox(width: 8),
                            Text('Nhập thủ công', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: top ? BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            bottom: !top ? BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            left: left ? BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            right: !left ? BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

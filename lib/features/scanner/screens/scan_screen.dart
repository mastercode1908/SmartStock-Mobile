import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../inventory/models/product_variant.dart';
import '../../../main_tab_screen.dart';
import '../../products/screens/product_detail_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late MobileScannerController controller;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    controller.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  Future<void> _processBarcode(String rawValue) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    controller.stop();

    final provider = context.read<InventoryProvider>();
    
    // Use the new async lookup that checks local cache -> local sessions -> backend API
    final match = await provider.lookupVariantByCode(rawValue);

    if (match != null) {
      _showProductDetails(match);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy sản phẩm với mã: $rawValue')),
        );
      }
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isProcessing = false);
          controller.start();
        }
      });
    }
  }

  Future<void> _scanFromImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      final capture = await controller.analyzeImage(file.path);
      if (capture != null && capture.barcodes.isNotEmpty && capture.barcodes.first.rawValue != null) {
        _processBarcode(capture.barcodes.first.rawValue!);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy mã vạch nào trong ảnh.')),
        );
      }
    }
  }

  void _showProductDetails(ProductVariant match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: match.productId),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isProcessing = false);
        controller.start();
      }
    });
  }

  void _showManualEntryDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nhập mã thủ công'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Nhập Barcode, SKU hoặc Serial...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                Navigator.pop(context);
                _processBarcode(value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _processBarcode(textController.text);
                }
              },
              child: const Text('Tìm kiếm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Background
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!mounted) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final rawValue = barcode.rawValue;
                if (rawValue != null) {
                  _processBarcode(rawValue);
                  break; // Process one barcode at a time
                }
              }
            },
          ),

          // Dark Overlay with Cutout
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black54, // Semi-transparent dark overlay
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60), // Offset up for ergonomics
                    child: Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.red, // Transparent due to BlendMode.srcOut
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, weight: 300),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MainTabScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                  const Text(
                    'Quét mã',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),
            ),
          ),

          // Scanner Frame Highlights & Laser
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  children: [
                    // Corners
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xffff5f5f), width: 3),
                            left: BorderSide(color: Color(0xffff5f5f), width: 3),
                          ),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xffff5f5f), width: 3),
                            right: BorderSide(color: Color(0xffff5f5f), width: 3),
                          ),
                          borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xffff5f5f), width: 3),
                            left: BorderSide(color: Color(0xffff5f5f), width: 3),
                          ),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xffff5f5f), width: 3),
                            right: BorderSide(color: Color(0xffff5f5f), width: 3),
                          ),
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
                        ),
                      ),
                    ),
                    // Laser Line
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Positioned(
                          top: _animation.value * 276,
                          left: 16,
                          right: 16,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xffff5f5f),
                              borderRadius: BorderRadius.circular(1),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xffff5f5f),
                                  blurRadius: 12,
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
          ),

          // Instruction Text
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 280), // Below frame
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Text(
                  'Căn chỉnh mã vào khung để quét',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 48,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.black54, Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flash Toggle
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _isFlashOn ? Colors.white24 : Colors.white10,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Icon(
                                _isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
                                color: _isFlashOn ? const Color(0xffff5f5f) : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'FLASH',
                              style: TextStyle(
                                color: _isFlashOn ? const Color(0xffff5f5f) : Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Gallery Upload
                      GestureDetector(
                        onTap: () {
                          _scanFromImage();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'THƯ VIỆN',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Manual Entry Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showManualEntryDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff1fbff),
                        foregroundColor: const Color(0xff131d21),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white54),
                        ),
                        elevation: 8,
                      ),
                      icon: const Icon(Icons.keyboard, color: Color(0xffff5f5f)),
                      label: const Text(
                        'Nhập mã thủ công',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

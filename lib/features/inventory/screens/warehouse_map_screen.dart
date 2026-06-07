import 'package:flutter/material.dart';

class WarehouseMapScreen extends StatefulWidget {
  const WarehouseMapScreen({super.key});

  @override
  State<WarehouseMapScreen> createState() => _WarehouseMapScreenState();
}

class _WarehouseMapScreenState extends State<WarehouseMapScreen> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final Matrix4 current = _transformationController.value;
    final Matrix4 next = current.clone()..scale(1.2, 1.2, 1.0);
    _transformationController.value = next;
  }

  void _zoomOut() {
    final Matrix4 current = _transformationController.value;
    final Matrix4 next = current.clone()..scale(0.8, 0.8, 1.0);
    _transformationController.value = next;
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
  }

  void _showRackTooltip(BuildContext context, String rackName, String category, String capacityText, int capacityValue) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        Color barColor;
        Color textColor;
        if (capacityValue >= 90) {
          barColor = const Color(0xffff5f5f); // primary-container
          textColor = const Color(0xffb3272e); // primary
        } else if (capacityValue > 0) {
          barColor = const Color(0xff00a7a3); // tertiary-container
          textColor = const Color(0xff006a67); // tertiary
        } else {
          barColor = const Color(0xffd9e4e9); // surface-variant
          textColor = const Color(0xff59413f); // on-surface-variant
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 32, offset: const Offset(0, 12)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rackName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(category, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lấp đầy', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                    Text(capacityText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: capacityValue / 100.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xffb3272e),
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('XEM CHI TIẾT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb3272e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bản đồ Kho',
          style: TextStyle(
            color: Color(0xffb3272e),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map Canvas
          Positioned.fill(
            bottom: 120, // Leave space for footer
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(100),
              child: Center(
                child: Container(
                  width: 400,
                  height: 600,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Section A
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Khu A', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            const SizedBox(height: 8),
                            _buildRackBlock('A-10', 'Điện tử', '95%', 95, const Color(0xffff5f5f), Colors.white),
                            _buildRackBlock('A-11', 'Điện tử', '60%', 60, const Color(0xff00a7a3), Colors.white),
                            _buildRackBlock('A-12', 'Trống', '0%', 0, const Color(0xffd9e4e9), Colors.black87, isOutline: true),
                            _buildRackBlock('A-13', 'Gia dụng', '45%', 45, const Color(0xff00a7a3), Colors.white),
                          ],
                        ),
                      ),
                      // Section B
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Khu B', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            const SizedBox(height: 8),
                            _buildRackBlock('B-01', 'Phụ tùng', '70%', 70, const Color(0xff00a7a3), Colors.white),
                            _buildRackBlock('B-02', 'Hóa chất', '98%', 98, const Color(0xffff5f5f), Colors.white),
                            _buildRackBlock('B-03', 'Phụ tùng', '20%', 20, const Color(0xff00a7a3), Colors.white),
                            _buildRackBlock('B-04', 'Phụ tùng', '55%', 55, const Color(0xff00a7a3), Colors.white),
                          ],
                        ),
                      ),
                      // Aisle with pulse
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 16,
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(4, (index) => Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle))),
                              ),
                            ),
                            Positioned(
                              top: 100,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 32 + (_pulseController.value * 16),
                                    height: 32 + (_pulseController.value * 16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xffff5f5f).withOpacity(1 - _pulseController.value),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: Color(0xffffb3af),
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                        ),
                                        child: const Icon(Icons.person, size: 16, color: Color(0xff64000d)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Section C
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Khu C', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            const SizedBox(height: 8),
                            _buildRackBlock('C-01', 'Trống', '0%', 0, const Color(0xffd9e4e9), Colors.black87, isOutline: true),
                            _buildRackBlock('C-02', 'Đóng gói', '85%', 85, const Color(0xff00a7a3), Colors.white),
                            _buildRackBlock('C-03', 'Đóng gói', '40%', 40, const Color(0xff00a7a3), Colors.white),
                            _buildRackBlock('C-04', 'Lỗi/Trả về', '100%', 100, const Color(0xffff5f5f), Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Legend
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TRẠNG THÁI', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildLegendItem(const Color(0xffff5f5f), 'Đầy / Cảnh báo (>90%)'),
                  const SizedBox(height: 4),
                  _buildLegendItem(const Color(0xff00a7a3), 'Bình thường (<90%)'),
                  const SizedBox(height: 4),
                  _buildLegendItem(const Color(0xffd9e4e9), 'Trống', isOutline: true),
                ],
              ),
            ),
          ),

          // Zoom Controls
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                _buildZoomButton(Icons.add, _zoomIn),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.remove, _zoomOut),
                const SizedBox(height: 16),
                _buildZoomButton(Icons.my_location, _resetView),
              ],
            ),
          ),

          // Fixed Bottom Footer
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb3272e),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Quét vị trí', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xffb3272e),
                        side: const BorderSide(color: Color(0xffb3272e)),
                        backgroundColor: const Color(0xfff1fbff),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Danh sách chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildRackBlock(String id, String category, String capText, int capVal, Color color, Color textColor, {bool isOutline = false}) {
    return GestureDetector(
      onTap: () => _showRackTooltip(context, id, category, capText, capVal),
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isOutline ? Border.all(color: Colors.grey[300]!) : null,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Center(
          child: Text(
            id,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isOutline = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isOutline ? Border.all(color: Colors.grey[400]!) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xffb3272e), size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

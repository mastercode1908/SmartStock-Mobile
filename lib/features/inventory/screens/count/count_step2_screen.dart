import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step3_screen.dart';

class CountStep2Screen extends StatefulWidget {
  const CountStep2Screen({Key? key}) : super(key: key);

  @override
  State<CountStep2Screen> createState() => _CountStep2ScreenState();
}

class _CountStep2ScreenState extends State<CountStep2Screen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Camera Feed Placeholder
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDAyk0c8uRuF72bB7fS2xeDbNse09i_8fqg8KD_5iOrx11zgoo02chVYmm4cP9KeXyA0HYMGEwnrXGPhGDcQtgQxu3EHnqrKREPVVHbzp0z66xPaZsag20ClodSis4-ZLYRfTtVOGU3IckSH0UXJbBEvOyGRJBH7TDf40mskCgUMBqRRUDc1BwnIbGCPE01KWiYZhFD7l0ujOw_B_Q1MbHjDtI4m0Rot484x4egVLCGJzSpFEV2kkHnK_2OTlx_9aOrsjUdOrypuF12',
              fit: BoxFit.cover,
            ),
          ),
          
          // Header Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.only(top: 48, bottom: 16, left: 16, right: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.primary),
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline, color: AppColors.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const Text(
                    'Bước 2/5: Quét mã sản phẩm',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Căn chỉnh mã vạch vào trong khung đỏ',
                    style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),

          // Location Indicator Overlay
          Positioned(
            top: 180, // Adjust based on header height
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Khu vực B - Kệ 04 - Tầng 2',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scanner Overlay
          Center(
            child: Container(
              width: 288, // 72 * 4
              height: 192, // 48 * 4
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
              height: 160,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outline.withOpacity(0.3)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.flashlight_on, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep3Screen()));
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard),
                        SizedBox(width: 8),
                        Text('Nhập thủ công', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
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
            top: top ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            bottom: !top ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            left: left ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            right: !left ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

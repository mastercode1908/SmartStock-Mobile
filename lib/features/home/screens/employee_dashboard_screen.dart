import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../inventory/screens/pickup/pickup_list_screen.dart';
import '../../inventory/screens/count/count_list_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/theme/app_colors.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  const EmployeeDashboardScreen({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  String _getCurrentShift() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 14) {
      return 'Sáng';
    } else if (hour >= 14 && hour < 22) {
      return 'Chiều';
    } else {
      return 'Đêm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGreeting(context),
            const SizedBox(height: 32),
            _buildBentoGrid(),
            const SizedBox(height: 40),
            _buildQuickAccess(context),
            const SizedBox(height: 80), // Padding for bottom nav
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xfff9f9f9),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: const [
          Icon(Icons.inventory_2, color: Color(0xffb02528)),
          SizedBox(width: 8),
          Text(
            'Smart Stock',
            style: TextStyle(
              color: Color(0xffb02528),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Color(0xffb02528)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey[300], height: 1.0),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Nguyễn Văn A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe2bebb)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chào, $displayName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              Text('Ca làm việc: ${_getCurrentShift()}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xffe2bebb)),
              image: DecorationImage(
                image: NetworkImage(
                  user?.avatarUrl.isNotEmpty == true
                      ? user!.avatarUrl
                      : 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid() {
    return Row(
      children: [
        // Large Primary Card
        Expanded(
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffb02528),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: -16,
                  top: -16,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.assignment, size: 80, color: Colors.white),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nhiệm vụ hôm nay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xffffb3ae))),
                    const SizedBox(height: 8),
                    const Text('124', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Spacer(),
                    const Text('Theo thời gian thực', style: TextStyle(fontSize: 12, color: Color(0xffffb3ae))),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Stacked Small Cards
        Expanded(
          child: SizedBox(
            height: 160,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffe2bebb)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('ĐÃ XONG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.0)),
                            const SizedBox(height: 4),
                            const Text('84 đơn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                        const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xffffdad6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffba1a1a).withOpacity(0.2)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('LỆCH TỒN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff93000a), letterSpacing: 1.0)),
                            const SizedBox(height: 4),
                            const Text('3 lỗi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff93000a))),
                          ],
                        ),
                        const Icon(Icons.warning_rounded, color: Color(0xffba1a1a)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chức năng chính',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildBigActionCard(
                context,
                icon: Icons.inventory,
                label: 'Nhặt đồ',
                subtitle: 'Lấy hàng theo đơn',
                bgColor: AppColors.primary,
                textColor: Colors.white,
                iconBg: Colors.white.withOpacity(0.2),
                screen: const PickUpListScreen(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBigActionCard(
                context,
                icon: Icons.manage_search,
                label: 'Kiểm kê',
                subtitle: 'Kiểm đếm tồn kho',
                bgColor: AppColors.surfaceContainerLowest,
                textColor: AppColors.primary,
                iconBg: AppColors.primaryFixed,
                borderColor: AppColors.primary,
                screen: const CountListScreen(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBigActionCard(
                context,
                icon: Icons.qr_code_scanner,
                label: 'Quét mã',
                subtitle: 'Tra cứu thông tin',
                bgColor: AppColors.surfaceContainerLowest,
                textColor: AppColors.onSurface,
                iconBg: AppColors.surfaceVariant,
                borderColor: AppColors.outlineVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBigActionCard(
                context,
                icon: Icons.history,
                label: 'Lịch sử',
                subtitle: 'Đơn đã xử lý',
                bgColor: AppColors.surfaceContainerLowest,
                textColor: AppColors.onSurface,
                iconBg: AppColors.surfaceVariant,
                borderColor: AppColors.outlineVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBigActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color bgColor,
    required Color textColor,
    required Color iconBg,
    Color? borderColor,
    Widget? screen,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == 'Nhặt đồ' && widget.onNavigateToTab != null) {
          widget.onNavigateToTab!(1); // Index of PickUp in MainTabScreen
        } else if (label == 'Kiểm kê' && widget.onNavigateToTab != null) {
          widget.onNavigateToTab!(3); // Index of Count in MainTabScreen
        } else if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor ?? Colors.transparent, width: borderColor != null ? 1.5 : 0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: textColor, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

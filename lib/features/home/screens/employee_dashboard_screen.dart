import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../inventory/screens/pickup/pickup_list_screen.dart';
import '../../inventory/screens/count/count_list_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  // Define Colors based on Tailwind Config from HTML
  final Color _primary = const Color(0xFFB02528);
  final Color _primaryFixed = const Color(0xFFFFDAD7);
  final Color _primaryContainer = const Color(0xFFD23E3E);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _surfaceContainer = const Color(0xFFEEEEEE);
  final Color _surfaceVariant = const Color(0xFFE2E2E2);
  final Color _onSurfaceVariant = const Color(0xFF5A413F);
  final Color _onSurface = const Color(0xFF1A1C1C);
  final Color _outlineVariant = const Color(0xFFE2BEBB);
  final Color _error = const Color(0xFFBA1A1A);
  final Color _errorContainer = const Color(0xFFFFDAD6);
  final Color _secondary = const Color(0xFF546067);
  final Color _secondaryContainer = const Color(0xFFD7E4EC);
  final Color _onSecondaryContainer = const Color(0xFF5A666D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGreeting(context),
            const SizedBox(height: 24),
            _buildBentoGrid(),
            const SizedBox(height: 32),
            _buildQuickAccess(),
            const SizedBox(height: 32),
            _buildRecentActivity(),
            const SizedBox(height: 80), // Padding for bottom nav
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: _surfaceContainer, width: 1)),
      centerTitle: true,
      title: const Text(
        'Dashboard',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.black),
        onPressed: () {},
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Nguyễn Văn A',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Operator #42',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryContainer, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Nguyễn Văn A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào, $displayName',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tổng quan công việc hôm nay của bạn.',
          style: TextStyle(fontSize: 18, color: _onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildBentoGrid() {
    return Column(
      children: [
        // Primary Card
        Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Đơn kiểm kê hôm nay',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    '124', // Mocked
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Secondary Cards Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: _outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryFixed,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bar_chart,
                                color: _primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đã quét',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '+12%',
                          style: TextStyle(fontSize: 16, color: _secondary),
                        ),
                      ],
                    ),
                    Text(
                      '8,432', // Mocked
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _onSurface,
                      ),
                    ),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _surfaceContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.75,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: _outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _errorContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: _error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lệch tồn',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '3', // Mocked
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _error,
                      ),
                    ),
                    Text(
                      'Cần xử lý trong ca',
                      style: TextStyle(fontSize: 12, color: _onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Truy cập nhanh',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildQuickAccessItem(
              context,
              Icons.conveyor_belt,
              'Nhặt đồ',
              _primaryFixed,
              _primary,
              fallbackIcon: Icons.shopping_cart,
              screen: const PickUpListScreen(),
            ),
            const SizedBox(width: 12),
            _buildQuickAccessItem(
              context,
              Icons.play_arrow,
              'Tiếp tục',
              _secondaryContainer,
              _onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            _buildQuickAccessItem(
              context,
              Icons.qr_code_scanner,
              'Quét mã',
              _surfaceVariant,
              _onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            _buildQuickAccessItem(
              context,
              Icons.manage_search,
              'Kiểm kê',
              _surfaceVariant,
              _onSurfaceVariant,
              screen: const CountListScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(
    BuildContext context,
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor, {
    IconData? fallbackIcon,
    Widget? screen,
  }) {
    final safeIcon = fallbackIcon != null && icon.codePoint == 0
        ? fallbackIcon
        : icon;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (screen != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(safeIcon, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hoạt động gần đây',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: _onSurface,
              ),
            ),
            Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.inventory_2,
                iconBg: _primaryFixed,
                iconColor: _primary,
                title: 'Khu vực A - Kệ 04',
                time: '10 phút trước',
                progress: 1.0,
                status: 'Hoàn thành',
                statusColor: _primary,
              ),
              Divider(height: 1, color: _surfaceContainer),
              _buildActivityItem(
                icon: Icons.conveyor_belt,
                fallbackIcon: Icons.shopping_cart,
                iconBg: _secondaryContainer,
                iconColor: _onSecondaryContainer,
                title: 'Khu vực B - Kệ 12',
                time: '45 phút trước',
                progress: 0.5,
                status: '50%',
                statusColor: _onSurfaceVariant,
              ),
              Divider(height: 1, color: _surfaceContainer),
              _buildActivityItem(
                icon: Icons.warning_amber_rounded,
                iconBg: _errorContainer,
                iconColor: _error,
                title: 'Khu vực C - Kệ 01 (Lệch tồn)',
                time: '2 giờ trước',
                status: 'Chờ xử lý',
                statusColor: _error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    IconData? fallbackIcon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String time,
    double? progress,
    required String status,
    required Color statusColor,
  }) {
    final safeIcon = fallbackIcon != null && icon.codePoint == 0
        ? fallbackIcon
        : icon;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(safeIcon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: _onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (progress != null) ...[
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _surfaceVariant,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

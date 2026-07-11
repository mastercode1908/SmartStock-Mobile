import 'package:flutter/material.dart';
import '../../inventory/screens/inventory_list_screen.dart';
import '../../inventory/screens/inventory_history_screen.dart';
import '../../notifications/screens/notification_screen.dart';
import '../../inventory/screens/warehouse_location_screen.dart';
import '../../inventory/screens/warehouse_map_screen.dart';
import '../../inventory/screens/incident_report_screen.dart';
import '../../scanner/screens/scan_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../inventory/screens/create_inventory_screen.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../products/screens/product_list_screen.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../picking/screens/picking_list_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  String? _pressedQuickAccessLabel;

  // Define Colors from Tailwind Config
  final Color _primary = const Color(0xFFB02528);
  final Color _primaryFixedDim = const Color(0xFFFFB3AE);
  final Color _primaryContainer = const Color(0xFFD23E3E);
  final Color _onPrimaryContainer = const Color(0xFFFFFbFF);

  final Color _surface = const Color(0xFFF9F9F9);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _surfaceVariant = const Color(0xFFE2E2E2);
  final Color _onSurfaceVariant = const Color(0xFF5A413F);
  final Color _onSurface = const Color(0xFF1A1C1C);

  final Color _outlineVariant = const Color(0xFFE2BEBB);
  final Color _tertiary = const Color(0xFF93405F);
  final Color _tertiaryContainer = const Color(0xFFB15878);
  final Color _onTertiaryContainer = const Color(0xFFFFFbFF);

  final Color _error = const Color(0xFFBA1A1A);
  final Color _errorContainer = const Color(0xFFFFDAD6);
  final Color _onErrorContainer = const Color(0xFF93000A);

  final Color _secondary = const Color(0xFF546067);
  final Color _secondaryContainer = const Color(0xFFD7E4EC);
  final Color _onSecondaryContainer = const Color(0xFF5A666D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadSessions();
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  String _getCurrentShift() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 14)
      return 'Sáng';
    else if (hour >= 14 && hour < 22)
      return 'Chiều';
    else
      return 'Đêm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: 24),
            _buildSummaryCards(context),
            const SizedBox(height: 24),
            _buildQuickAccess(context),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: _outlineVariant, width: 1)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _primary),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      title: Row(
        children: [
          Icon(Icons.inventory_2, color: _primary),
          const SizedBox(width: 8),
          Text(
            'Smart Stock',
            style: TextStyle(
              color: _primary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            final unreadCount = provider.unreadCount;
            final displayCount = unreadCount > 99 ? '99+' : unreadCount.toString();
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none, color: _primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        displayCount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Nhân viên';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào, $displayName',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ca làm việc: ${_getCurrentShift()}',
                  style: TextStyle(fontSize: 12, color: _onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _outlineVariant),
              image: DecorationImage(
                image: NetworkImage(
                  user?.avatarUrl?.isNotEmpty == true
                      ? user!.avatarUrl!
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

  Widget _buildSummaryCards(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    var sessions = provider.sessions
        .where((s) => s.createdBy == user?.userId)
        .toList();

    if (user?.roleName == 'Staff') {
      sessions = sessions
          .where(
            (s) =>
                s.startDate.year == DateTime.now().year &&
                s.startDate.month == DateTime.now().month &&
                s.startDate.day == DateTime.now().day,
          )
          .toList();
    }

    final todaySessions = sessions
        .where(
          (s) =>
              s.startDate.year == DateTime.now().year &&
              s.startDate.month == DateTime.now().month &&
              s.startDate.day == DateTime.now().day,
        )
        .length;

    final draftSessions = sessions.where((s) => s.status == 'DRAFT').length;
    final pendingSessions = sessions.where((s) => s.status == 'PENDING').length;

    return Row(
      children: [
        // Left Card (Primary)
        Expanded(
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.category,
                    size: 100,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đơn kiểm kê\nhôm nay',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primaryFixedDim,
                      ),
                    ),
                    Text(
                      '$todaySessions',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Theo thời gian thực',
                      style: TextStyle(fontSize: 12, color: _primaryFixedDim),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Right Column Cards
        Expanded(
          child: SizedBox(
            height: 160,
            child: Column(
              children: [
                // Top Right Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ĐANG KIỂM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: _onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$draftSessions đơn',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _onSurface,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.inventory, color: _tertiary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Bottom Right Card (Error)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _error.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'CHỜ DUYỆT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: _error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$pendingSessions đơn',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _error,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.pending_actions, color: _error),
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

  Widget _buildQuickAccessButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final isPressed = _pressedQuickAccessLabel == label;
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressedQuickAccessLabel = label;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressedQuickAccessLabel = null;
        });
        onTap();
      },
      onTapCancel: () {
        setState(() {
          _pressedQuickAccessLabel = null;
        });
      },
      child: _buildQuickAccessItem(
        icon,
        label,
        isPressed ? _surfaceVariant : _primary,
        isPressed ? _onSurfaceVariant : Colors.white,
        isPressed,
        null,
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
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
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: [
            _buildQuickAccessButton(context, Icons.analytics, 'Báo cáo', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncidentReportScreen(),
                ),
              );
            }),
            _buildQuickAccessButton(context, Icons.assignment, 'Nhiệm vụ', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryListScreen(),
                ),
              );
            }),
            _buildQuickAccessButton(context, Icons.inventory_2, 'Kiểm kê', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateInventoryScreen(),
                ),
              );
            }),
            _buildQuickAccessButton(context, Icons.directions_walk, 'Nhặt hàng', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PickingListScreen(),
                ),
              );
            }),
            _buildQuickAccessButton(
              context,
              Icons.location_on,
              'Vị trí lưu trữ',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WarehouseLocationScreen(),
                  ),
                );
              },
            ),
            _buildQuickAccessButton(
              context,
              Icons.map_outlined,
              'Sơ đồ kho',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WarehouseMapScreen(),
                  ),
                );
              },
            ),
            _buildQuickAccessButton(context, Icons.widgets, 'Sản phẩm', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductListScreen(),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor, [
    bool hasBorder = false,
    VoidCallback? onTap,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: hasBorder ? Border.all(color: _outlineVariant) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
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
                fontSize: 12,
                color: _primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          icon: Icons.inventory,
          iconColor: _primary,
          title: 'Kiểm kê - Kệ B-04',
          time: '10:45',
          subtitle: 'Người thực hiện: N.V.A',
          badgeText: 'Hoàn thành',
          badgeBg: _tertiaryContainer,
          badgeColor: _onTertiaryContainer,
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          icon: Icons.inventory_2,
          iconColor: _secondary,
          title: 'Kiểm kê - Khu vực A1',
          time: '09:15',
          subtitle: 'Đang đối soát dữ liệu',
          badgeText: 'Đang thực hiện',
          badgeBg: _secondaryContainer,
          badgeColor: _onSecondaryContainer,
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          icon: Icons.inventory,
          iconColor: _onErrorContainer,
          iconBg: _errorContainer,
          title: 'Kiểm kê - Kệ A2',
          time: 'HÔM QUA',
          subtitle: 'Sai lệch: -2 sản phẩm',
          subtitleColor: _error,
          badgeText: 'Cần xử lý',
          badgeBg: _errorContainer,
          badgeColor: _onErrorContainer,
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    Color? iconBg,
    required String title,
    required String time,
    required String subtitle,
    Color? subtitleColor,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg ?? _surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _onSurface,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor ?? _onSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 12,
                          color: badgeColor,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFB02528),
      unselectedItemColor: const Color(0xFF546067),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, a1, a2) => const InventoryListScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, a1, a2) => const ScanScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, a1, a2) => const InventoryHistoryScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, a1, a2) => const ProfileScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Kiểm kê',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Cá nhân',
        ),
      ],
    );
  }
}

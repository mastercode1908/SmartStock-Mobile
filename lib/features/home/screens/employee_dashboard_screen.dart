import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../inventory/screens/pickup/pickup_list_screen.dart';
import '../../inventory/screens/count/count_list_screen.dart';
import '../../inventory/screens/incident_report_screen.dart';
import '../../inventory/screens/warehouse_map_screen.dart';
import '../../inventory/screens/warehouse_location_screen.dart';
import '../../inventory/screens/inventory_history_screen.dart';
import '../../products/screens/product_list_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../notifications/screens/notification_screen.dart';
import '../../inventory/providers/picking_provider.dart';
import '../../inventory/providers/inventory_provider.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  const EmployeeDashboardScreen({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
      context.read<InventoryPickingProvider>().fetchTasks();
      context.read<InventoryProvider>().loadSessions();
    });
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGreeting(context),
            const SizedBox(height: 32),
            _buildBentoGrid(context),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            final unreadCount = provider.unreadCount;
            final displayCount = unreadCount > 99 ? '99+' : unreadCount.toString();
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Color(0xffb02528)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
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
                        color: const Color(0xffb02528),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        displayCount,
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 10,
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Theme.of(context).colorScheme.surfaceContainerHigh, height: 1.0),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe2bebb)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chào, $displayName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 4),
              Text('Ca làm việc: ${_getCurrentShift()}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

  Widget _buildBentoGrid(BuildContext context) {
    final pickingProvider = context.watch<InventoryPickingProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    final today = DateTime.now();

    // Helper to check if a DateTime is today
    bool isToday(DateTime? dt) {
      if (dt == null) return false;
      return dt.year == today.year && dt.month == today.month && dt.day == today.day;
    }

    // 1. Calculate active tasks (today's outstanding tasks):
    // Active picking tasks (status 0: PENDING, status 1: IN_PROGRESS)
    final activePickingTasks = pickingProvider.tasks.where((t) => t.status == 0 || t.status == 1).length;
    // Active counting sessions (status NOT 'POSTED' and NOT 'CANCELLED')
    final activeCountSessions = inventoryProvider.sessions.where((s) => s.status != 'POSTED' && s.status != 'CANCELLED').length;
    final todayTasks = activePickingTasks + activeCountSessions;

    // 2. Calculate completed tasks completed TODAY:
    // Completed picking tasks (status 2) completed today
    final completedPickingTasks = pickingProvider.tasks.where((t) => t.status == 2 && isToday(t.completedAt ?? t.createdAt)).length;
    // Completed counting sessions (status 'POSTED') posted today
    final completedCountSessions = inventoryProvider.sessions.where((s) => s.status == 'POSTED' && isToday(s.endDate ?? s.startDate)).length;
    final completedTasks = completedPickingTasks + completedCountSessions;

    // 3. Calculate discrepancies (Lệch tồn) found/recorded TODAY:
    int totalDiscrepancies = 0;
    for (var session in inventoryProvider.sessions) {
      if (isToday(session.endDate ?? session.startDate)) {
        if (session.details != null) {
          for (var detail in session.details!) {
            if (detail.actualQuantity != null && detail.actualQuantity != detail.systemQuantity) {
              totalDiscrepancies++;
            }
          }
        }
      }
    }

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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  top: -16,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.assignment, size: 80, color: Theme.of(context).cardColor),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nhiệm vụ hôm nay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xffffb3ae))),
                    const SizedBox(height: 8),
                    Text('$todayTasks', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
                    const SizedBox(height: 4),
                    Text('Cần nhặt: $activePickingTasks\nCần kiểm: $activeCountSessions', style: const TextStyle(fontSize: 11, color: Color(0xffffb3ae), height: 1.3)),
                    const Spacer(),
                    const Text('Theo thời gian thực', style: TextStyle(fontSize: 10, color: Color(0xffffb3ae))),
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffe2bebb)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('ĐÃ XONG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('$completedTasks nhiệm vụ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                              const SizedBox(height: 2),
                              Text('Nhặt: $completedPickingTasks · Kiểm: $completedCountSessions', style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xffffdad6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffba1a1a).withOpacity(0.2)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('LỆCH TỒN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff93000a), letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('$totalDiscrepancies sản phẩm', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff93000a))),
                              const SizedBox(height: 2),
                              const Text('Số lượng lệch thực tế', style: TextStyle(fontSize: 9, color: Color(0xffba1a1a)), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const Icon(Icons.warning_rounded, color: Color(0xffba1a1a), size: 20),
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
        Text(
          'Chức năng chính',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
                textColor: Theme.of(context).colorScheme.onPrimary,
                iconBg: Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
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
                bgColor: Theme.of(context).colorScheme.surface,
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
                bgColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).colorScheme.onSurface,
                iconBg: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderColor: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBigActionCard(
                context,
                icon: Icons.history,
                label: 'Lịch sử',
                subtitle: 'Đơn đã xử lý',
                bgColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).colorScheme.onSurface,
                iconBg: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderColor: Theme.of(context).colorScheme.outline,
                screen: const InventoryHistoryScreen(),
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
                icon: Icons.warning_amber_rounded,
                label: 'Báo cáo sự cố',
                subtitle: 'Khai báo hư hỏng',
                bgColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).colorScheme.onSurface,
                iconBg: Colors.orange.withValues(alpha: 0.15),
                borderColor: Theme.of(context).colorScheme.outline,
                screen: const IncidentReportScreen(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBigActionCard(
                context,
                icon: Icons.map_outlined,
                label: 'Sơ đồ kho',
                subtitle: 'Bản đồ lưu kho',
                bgColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).colorScheme.onSurface,
                iconBg: Colors.teal.withValues(alpha: 0.15),
                borderColor: Theme.of(context).colorScheme.outline,
                screen: const WarehouseMapScreen(),
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
                icon: Icons.warehouse_outlined,
                label: 'Vị trí lưu trữ',
                subtitle: 'Danh sách vị trí',
                bgColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).colorScheme.onSurface,
                iconBg: Colors.indigo.withValues(alpha: 0.15),
                borderColor: Theme.of(context).colorScheme.outline,
                screen: const WarehouseLocationScreen(isReadOnly: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBigActionCard(
                context,
                icon: Icons.inventory_2_outlined,
                label: 'Sản phẩm',
                subtitle: 'Danh mục hàng',
                bgColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).colorScheme.onSurface,
                iconBg: Colors.amber.withValues(alpha: 0.15),
                borderColor: Theme.of(context).colorScheme.outline,
                screen: const ProductListScreen(),
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
        } else if (label == 'Quét mã' && widget.onNavigateToTab != null) {
          widget.onNavigateToTab!(2); // Index of Scan in MainTabScreen
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
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
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

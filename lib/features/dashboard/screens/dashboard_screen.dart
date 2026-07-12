import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../inventory/screens/inventory_list_screen.dart';
import '../../inventory/screens/inventory_history_screen.dart';
import '../../scanner/screens/scan_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../notifications/screens/notification_screen.dart';
import '../../inventory/screens/warehouse_location_screen.dart';
import '../../inventory/screens/warehouse_map_screen.dart';
import '../../inventory/screens/incident_report_screen.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../picking/screens/picking_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.inventory_2, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Smart Stock',
              style: TextStyle(
                color: colorScheme.primary,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          final user = context.watch<AuthProvider>().currentUser;
          final role = user?.roleName.toLowerCase() ?? '';
          final isManager = role.contains('admin') || role.contains('manager');
          
          final sessions = isManager 
              ? provider.sessions 
              : provider.sessions.where((s) => s.createdBy == user?.userId || s.assignedTo == user?.userId).toList();
              
          final todaySessions = sessions.where((s) => 
            s.startDate.year == DateTime.now().year && 
            s.startDate.month == DateTime.now().month && 
            s.startDate.day == DateTime.now().day).length;
          
          final completedSessions = sessions.where((s) => s.status == 'APPROVED').length;
          final pendingSessions = sessions.where((s) => s.status == 'PENDING').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.currentUser;
                    final displayName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Admin';
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.surfaceContainerHigh),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Chào, $displayName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                              const SizedBox(height: 4),
                              Text('Ca làm việc: ${_getCurrentShift()}', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surfaceContainerHigh),
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
                ),
                const SizedBox(height: 16),

                // Summary Cards (Bento Grid)
                Row(
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
                                child: Icon(Icons.category, size: 80, color: Colors.white),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Đơn kiểm kê hôm nay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xffffb3ae))),
                                const SizedBox(height: 8),
                                Text('$todaySessions', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
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
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colorScheme.surfaceContainerHigh),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('ĐÃ DUYỆT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant, letterSpacing: 1.0)),
                                        const SizedBox(height: 4),
                                        Text('$completedSessions đơn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                      ],
                                    ),
                                    const Icon(Icons.check_circle_outline, color: Color(0xff93405f)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark ? colorScheme.errorContainer.withValues(alpha: 0.2) : const Color(0xffffdad6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('CHỜ DUYỆT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.brightness == Brightness.dark ? const Color(0xffffb4ab) : const Color(0xff93000a), letterSpacing: 1.0)),
                                        const SizedBox(height: 4),
                                        Text('$pendingSessions đơn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.brightness == Brightness.dark ? const Color(0xffffb4ab) : const Color(0xff93000a))),
                                      ],
                                    ),
                                    const Icon(Icons.pending_actions, color: Color(0xffba1a1a)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
    
                // Quick Access Grid
                Text('Truy cập nhanh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildQuickAccessButton(
                            icon: Icons.analytics, 
                            label: 'Báo cáo', 
                            bgColor: const Color(0xffb02528), 
                            iconColor: Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const IncidentReportScreen()),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildQuickAccessButton(
                            icon: Icons.inventory_2, 
                            label: 'Kiểm kê', 
                            bgColor: const Color(0xffb02528), 
                            iconColor: Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const InventoryListScreen()),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildQuickAccessButton(
                            icon: Icons.directions_walk, 
                            label: 'Nhặt hàng', 
                            bgColor: const Color(0xffb02528), 
                            iconColor: Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PickingListScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildQuickAccessButton(
                            icon: Icons.location_on, 
                            label: 'Vị trí', 
                            bgColor: const Color(0xffb02528), 
                            iconColor: Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const WarehouseLocationScreen()),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildQuickAccessButton(
                            icon: Icons.map_outlined, 
                            label: 'Sơ đồ kho', 
                            bgColor: const Color(0xffb02528), 
                            iconColor: Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const WarehouseMapScreen()),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildQuickAccessButton(
                            icon: Icons.notifications, 
                            label: 'Thông báo', 
                            bgColor: Theme.of(context).colorScheme.primary, 
                            iconColor: Theme.of(context).colorScheme.onPrimary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NotificationScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            const SizedBox(height: 24),

            // Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Hoạt động gần đây', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                InkWell(
                  onTap: () {},
                  child: Text('Xem tất cả', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...() {
              final sorted = List.of(sessions)..sort((a, b) => b.startDate.compareTo(a.startDate));
              final top3 = sorted.take(3).toList();
              
              if (top3.isEmpty) {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('Chưa có hoạt động nào', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                  )
                ];
              }

              return top3.map((session) {
                String statusText = 'Không xác định';
                Color statusColor = Colors.black;
                Color statusBgColor = Colors.grey[300]!;
                IconData icon = Icons.inventory;
                Color iconColor = const Color(0xffb02528);
                Color iconBgColor = const Color(0xffe2e2e2);

                switch (session.status) {
                  case 'DRAFT':
                    statusText = 'Đang kiểm';
                    statusColor = const Color(0xff5a666d);
                    statusBgColor = const Color(0xffd7e4ec);
                    break;
                  case 'PENDING':
                    statusText = 'Chờ duyệt';
                    statusColor = const Color(0xff93000a);
                    statusBgColor = const Color(0xffffdad6);
                    iconColor = const Color(0xff93000a);
                    iconBgColor = const Color(0xffffdad6);
                    break;
                  case 'APPROVED':
                    statusText = 'Đã duyệt';
                    statusColor = const Color(0xff006a67);
                    statusBgColor = const Color(0xffccf2f0);
                    break;
                  case 'POSTED':
                  case 'SYNCED':
                    statusText = 'Đã ghi nhận';
                    statusColor = const Color(0xfffffbff);
                    statusBgColor = const Color(0xffb15878);
                    break;
                  case 'REJECTED':
                    statusText = 'Từ chối';
                    statusColor = const Color(0xffba1a1a);
                    statusBgColor = const Color(0xffffdad6);
                    break;
                  case 'CANCELLED':
                    statusText = 'Đã hủy';
                    statusColor = const Color(0xffba1a1a);
                    statusBgColor = const Color(0xffffdad6);
                    break;
                }

                final timeStr = DateFormat('dd/MM HH:mm').format(session.startDate);
                String assigneeName = session.assignedToName ?? '';
                if (assigneeName.isEmpty && session.assignedTo != null) {
                  if (session.assignedTo == user?.userId) {
                    assigneeName = user?.fullName ?? '';
                  } else {
                    assigneeName = provider.getStaffName(session.assignedTo!);
                    if (assigneeName.startsWith('Quản trị viên') && session.createdBy == session.assignedTo && session.createdByName?.isNotEmpty == true) {
                      assigneeName = session.createdByName!;
                    }
                  }
                }
                if (assigneeName.isEmpty) assigneeName = 'Chưa giao';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildActivityItem(
                    icon: icon,
                    iconColor: iconColor,
                    iconBgColor: iconBgColor,
                    title: 'Kiểm kê - ${session.sessionCode}',
                    time: timeStr,
                    subtitle: 'Người TH: $assigneeName',
                    status: statusText,
                    statusColor: statusColor,
                    statusBgColor: statusBgColor,
                  ),
                );
              }).toList();
            }(),
          ],
        ),
      );
    },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    bool isOutline = false,
    VoidCallback? onTap,
  }) {
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
              border: isOutline ? Border.all(color: const Color(0xffe2bebb)) : null,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    Color iconColor = const Color(0xffb02528),
    Color iconBgColor = const Color(0xffe2e2e2),
    required String title,
    required String time,
    required String subtitle,
    Color subtitleColor = Colors.black54,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
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
                    Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    Text(time, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(subtitle, style: TextStyle(fontSize: 14, color: subtitleColor)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 12, color: statusColor),
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
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: const Color(0xFFB02528),
      unselectedItemColor: const Color(0xFF546067),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Kiểm kê'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
      ],
    );
  }
}

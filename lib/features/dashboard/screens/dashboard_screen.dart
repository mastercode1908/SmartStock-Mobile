import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../inventory/screens/inventory_list_screen.dart';
import '../../inventory/screens/inventory_history_screen.dart';
import '../../scanner/screens/scan_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../notifications/screens/notification_screen.dart';
import '../../inventory/screens/warehouse_location_screen.dart';
import '../../inventory/screens/warehouse_map_screen.dart';
import '../../inventory/screens/create_inventory_screen.dart';
import '../../inventory/screens/incident_report_screen.dart';
import '../../notifications/providers/notification_provider.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9), // background
      appBar: AppBar(
        backgroundColor: const Color(0xfff9f9f9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb02528)),
          onPressed: () => Navigator.pop(context),
        ),
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
          final sessions = provider.sessions.where((s) => s.createdBy == user?.userId).toList();
          final todaySessions = sessions.where((s) => 
            s.startDate.year == DateTime.now().year && 
            s.startDate.month == DateTime.now().month && 
            s.startDate.day == DateTime.now().day).length;
          
          final draftSessions = sessions.where((s) => s.status == 'DRAFT').length;
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
                                        const Text('ĐANG KIỂM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.0)),
                                        const SizedBox(height: 4),
                                        Text('$draftSessions đơn', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                      ],
                                    ),
                                    const Icon(Icons.inventory, color: Color(0xff93405f)),
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
                                        const Text('CHỜ DUYỆT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff93000a), letterSpacing: 1.0)),
                                        const SizedBox(height: 4),
                                        Text('$pendingSessions đơn', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff93000a))),
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
                const Text('Truy cập nhanh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildQuickAccessButton(
                      icon: Icons.analytics, 
                      label: 'Báo cáo', 
                      bgColor: const Color(0xffd23e3e), 
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const IncidentReportScreen()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.assignment, 
                      label: 'Nhiệm vụ', 
                      bgColor: const Color(0xffd23e3e), 
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InventoryListScreen()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.inventory_2, 
                      label: 'Kiểm kê', 
                      bgColor: const Color(0xffe2e2e2), 
                      iconColor: const Color(0xff5a413f), 
                      isOutline: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateInventoryScreen()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.location_on, 
                      label: 'Vị trí lưu trữ', 
                      bgColor: const Color(0xffb02528), 
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WarehouseLocationScreen()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
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
                    _buildQuickAccessButton(
                      icon: Icons.notifications, 
                      label: 'Thông báo', 
                      bgColor: const Color(0xffb02528), 
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationScreen()),
                        );
                      },
                    ),
                  ],
                ),
            const SizedBox(height: 24),

            // Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Hoạt động gần đây', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                InkWell(
                  onTap: () {},
                  child: const Text('Xem tất cả', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xffb02528))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.inventory,
              title: 'Kiểm kê - Kệ B-04',
              time: '10:45',
              subtitle: 'Người thực hiện: N.V.A',
              status: 'Hoàn thành',
              statusColor: const Color(0xfffffbff),
              statusBgColor: const Color(0xffb15878),
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              icon: Icons.inventory_2,
              title: 'Kiểm kê - Khu vực A1',
              time: '09:15',
              subtitle: 'Đang đối soát dữ liệu',
              status: 'Đang thực hiện',
              statusColor: const Color(0xff5a666d),
              statusBgColor: const Color(0xffd7e4ec),
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              icon: Icons.inventory,
              iconColor: const Color(0xff93000a),
              iconBgColor: const Color(0xffffdad6),
              title: 'Kiểm kê - Kệ A2',
              time: 'Hôm qua',
              subtitle: 'Sai lệch: -2 sản phẩm',
              subtitleColor: const Color(0xffba1a1a),
              status: 'Cần xử lý',
              statusColor: const Color(0xff93000a),
              statusBgColor: const Color(0xffffdad6),
            ),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: isOutline ? Border.all(color: const Color(0xffe2bebb)) : null,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe2bebb)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
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
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54, letterSpacing: 1.0)),
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
      backgroundColor: Colors.white,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../home/screens/employee_dashboard_screen.dart';
import 'inventory_history_screen.dart';
import 'create_inventory_screen.dart';
import '../../scanner/screens/scan_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_session.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({Key? key}) : super(key: key);

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  // Define Colors from Tailwind Config
  final Color _primary = const Color(0xFFB02528);
  final Color _secondary = const Color(0xFF546067);
  final Color _tertiary = const Color(0xFF93405F);
  
  final Color _surface = const Color(0xFFFFFFFF);
  final Color _surfaceContainerLow = const Color(0xFFF3F3F3);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _onSurface = const Color(0xFF1A1C1C);
  final Color _onSurfaceVariant = const Color(0xFF5A413F);
  
  final Color _outlineVariant = const Color(0xFFE2BEBB);
  final Color _secondaryContainer = const Color(0xFFF0F0F0);
  final Color _background = const Color(0xFFFFFFFF);

  String _currentFilter = 'TẤT CẢ';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 24),
            _buildInventoryList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateInventoryScreen()),
          );
        },
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: _outlineVariant.withOpacity(0.3), width: 1)),
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
        IconButton(
          icon: Icon(Icons.notifications_none, color: _primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _outlineVariant.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search, color: _secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo mã đợt kiểm kê...',
                      hintStyle: TextStyle(color: _secondary, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.filter_list, color: _onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách kiểm kê',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Quản lý các đợt kiểm kê tài sản và kho bãi.',
          style: TextStyle(
            fontSize: 14,
            color: _secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final sessions = provider.sessions;
        int allCount = sessions.length;
        int inProgressCount = sessions.where((s) => s.status == 'IN_PROGRESS').length;
        int draftCount = sessions.where((s) => s.status == 'DRAFT').length;
        int completedCount = sessions.where((s) => s.status == 'COMPLETED').length;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip('TẤT CẢ ($allCount)', 'TẤT CẢ'),
              const SizedBox(width: 8),
              _buildChip('ĐANG THỰC HIỆN ($inProgressCount)', 'IN_PROGRESS'),
              const SizedBox(width: 8),
              _buildChip('CHỜ XỬ LÝ ($draftCount)', 'DRAFT'),
              const SizedBox(width: 8),
              _buildChip('HOÀN THÀNH ($completedCount)', 'COMPLETED'),
            ],
          ),
        );
      }
    );
  }

  Widget _buildChip(String label, String filterValue) {
    bool isSelected = _currentFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filterValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.1) : _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _primary.withOpacity(0.3) : _outlineVariant.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? _primary : _secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.sessions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        List<InventorySession> filteredSessions = provider.sessions;
        if (_currentFilter != 'TẤT CẢ') {
          filteredSessions = filteredSessions.where((s) => s.status == _currentFilter).toList();
        }

        if (filteredSessions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Chưa có phiếu kiểm kê nào.'),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredSessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final session = filteredSessions[index];
            final dateStr = DateFormat('dd/MM/yyyy').format(session.startDate);

            Widget statusWidget;
            IconData icon;
            Color iconColor;
            Color iconBg;
            bool isCompleted = false;

            if (session.status == 'COMPLETED') {
              icon = Icons.check_circle;
              iconColor = _secondary;
              iconBg = _secondaryContainer;
              isCompleted = true;
              statusWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hoàn thành', style: TextStyle(color: _secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('XEM BÁO CÁO', style: TextStyle(color: _secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            } else if (session.status == 'DRAFT') {
              icon = Icons.pending_actions;
              iconColor = _primary;
              iconBg = _primary.withOpacity(0.1);
              statusWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chờ xử lý (Nháp)', style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('TIẾP TỤC', style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            } else {
              // IN_PROGRESS
              icon = Icons.inventory;
              iconColor = _tertiary;
              iconBg = _tertiary.withOpacity(0.1);
              statusWidget = Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.5, // Dummy progress
                        backgroundColor: _surfaceContainerLow,
                        valueColor: AlwaysStoppedAnimation<Color>(_tertiary),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Đang xử lý', style: TextStyle(fontSize: 12)),
                ],
              );
            }

            return _buildInventoryCard(
              icon: icon,
              iconColor: iconColor,
              iconBg: iconBg,
              title: session.sessionCode,
              date: dateStr,
              statusWidget: statusWidget,
              isCompleted: isCompleted,
            );
          },
        );
      },
    );
  }

  Widget _buildInventoryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String date,
    required Widget statusWidget,
    bool isCompleted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _onSurface,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                statusWidget,
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
      currentIndex: 1,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, a1, a2) => const EmployeeDashboardScreen(),
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
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Kiểm kê'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
      ],
    );
  }
}

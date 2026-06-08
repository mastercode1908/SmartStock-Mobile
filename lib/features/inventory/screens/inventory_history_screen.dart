import 'package:flutter/material.dart';
import '../../home/screens/employee_dashboard_screen.dart';
import 'inventory_list_screen.dart';

class InventoryHistoryScreen extends StatelessWidget {
  const InventoryHistoryScreen({Key? key}) : super(key: key);

  final Color _primary = const Color(0xFFB3272E);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _onSurfaceVariant = const Color(0xFF59413F);
  final Color _onSurface = const Color(0xFF131D21);
  final Color _secondary = const Color(0xFF586062);
  final Color _error = const Color(0xFFBA1A1A);
  final Color _surfaceContainerLow = const Color(0xFFEAF5FA);
  final Color _outlineVariant = const Color(0xFFE1BEBC);
  final Color _secondaryContainer = const Color(0xFFDAE1E3);
  final Color _onSecondaryContainer = const Color(0xFF5D6466);
  final Color _surfaceContainerHigh = const Color(0xFFDFEAEF);
  final Color _background = const Color(0xFFF1FBFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPageHeader(),
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
            _buildHistoryList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _surfaceContainerLowest,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2, color: _primary),
          const SizedBox(width: 8),
          Text(
            'Smart Stock',
            style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 20),
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

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử kiểm kê',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          'Xem lại nhật ký phiên và báo cáo độ chính xác.',
          style: TextStyle(fontSize: 14, color: _onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _outlineVariant),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, color: _secondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm theo ID hoặc Người...',
                          hintStyle: TextStyle(color: _secondary.withOpacity(0.6), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.tune, size: 20),
              label: const Text('Lọc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip('Tất Cả', true),
              const SizedBox(width: 8),
              _buildChip('Khu A (Thô)', false),
              const SizedBox(width: 8),
              _buildChip('Khu B (Thành Phẩm)', false),
              const SizedBox(width: 8),
              _buildChip('Kho Lạnh', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? _primary : _surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.transparent : _outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : _onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      children: [
        _buildHistoryCard(
          id: '#INV-2310-04',
          name: 'Sarah Jenkins',
          zone: 'Khu A',
          date: '24/10/2023',
          accuracy: '99.8%',
          accColor: _primary,
          diff: '1',
          diffColor: _onSurface,
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          id: '#INV-2310-03',
          name: 'Marcus Reed',
          zone: 'Kho Lạnh',
          date: '20/10/2023',
          accuracy: '94.2%',
          accColor: _error,
          diff: '12',
          diffColor: _error,
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          id: '#INV-2310-02',
          name: 'Elena Lopez',
          zone: 'Khu B',
          date: '15/10/2023',
          accuracy: '100%',
          accColor: _onSurface,
          diff: '0',
          diffColor: _onSurface,
        ),
      ],
    );
  }

  Widget _buildHistoryCard({
    required String id,
    required String name,
    required String zone,
    required String date,
    required String accuracy,
    required Color accColor,
    required String diff,
    required Color diffColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(id, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _secondary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _onSurface)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(zone.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _onSecondaryContainer)),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.schedule, size: 13, color: _secondary),
                  const SizedBox(width: 4),
                  Text(date, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _secondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(accuracy, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accColor)),
                      Text('ĐỘ CHÍNH XÁC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _secondary)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(diff, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: diffColor)),
                      Text('CHÊNH LỆCH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _secondary)),
                    ],
                  ),
                ],
              ),
              Icon(Icons.chevron_right, color: _secondary.withOpacity(0.6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFB3272E),
      unselectedItemColor: const Color(0xFF586062),
      showUnselectedLabels: true,
      currentIndex: 3,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(pageBuilder: (context, a1, a2) => const EmployeeDashboardScreen(), transitionDuration: Duration.zero),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(pageBuilder: (context, a1, a2) => const InventoryListScreen(), transitionDuration: Duration.zero),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Kiểm kê'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'features/home/screens/employee_dashboard_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/scanner/screens/scan_screen.dart';
import 'features/inventory/screens/pickup/pickup_list_screen.dart';
import 'features/inventory/screens/count/count_list_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({Key? key}) : super(key: key);

  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EmployeeDashboardScreen(),
    const PickUpListScreen(), // Nhặt đồ
    const ScanScreen(),
    const CountListScreen(), // Kiểm kê
    const ProfileScreen(), // Thiết lập
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onTabTapped(2); // Go to Scan Screen
        },
        backgroundColor: const Color(0xFFB02528),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTabItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Trang chủ',
                index: 0,
              ),
              _buildTabItem(
                icon: Icons.conveyor_belt, // Need to handle icon if not available
                activeIcon: Icons.conveyor_belt,
                label: 'Nhặt đồ',
                index: 1,
                fallbackIcon: Icons.shopping_cart_outlined,
                fallbackActiveIcon: Icons.shopping_cart,
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildTabItem(
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Kiểm kê',
                index: 3,
              ),
              _buildTabItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Thiết lập',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    IconData? fallbackIcon,
    IconData? fallbackActiveIcon,
  }) {
    final isSelected = _currentIndex == index;
    final displayIcon = isSelected 
        ? activeIcon 
        : icon;
        
    // Use fallback icon if conveyor_belt is not in material icons yet (sometimes in newer flutter versions)
    final safeIcon = fallbackIcon != null && icon.codePoint == 0 ? fallbackIcon : icon;
    final safeActiveIcon = fallbackActiveIcon != null && activeIcon.codePoint == 0 ? fallbackActiveIcon : activeIcon;
    final finalIcon = isSelected ? safeActiveIcon : safeIcon;

    return MaterialButton(
      minWidth: 40,
      onPressed: () => _onTabTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            finalIcon,
            color: isSelected ? const Color(0xFFB02528) : const Color(0xFF5A666D),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFFB02528) : const Color(0xFF5A666D),
            ),
          ),
        ],
      ),
    );
  }
}

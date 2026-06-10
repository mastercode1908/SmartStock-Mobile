import 'package:flutter/material.dart';
import 'features/home/screens/employee_dashboard_screen.dart';
import 'features/inventory/screens/inventory_list_screen.dart';
import 'features/inventory/screens/inventory_history_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({Key? key}) : super(key: key);

  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EmployeeDashboardScreen(),
    const InventoryListScreen(),
    const Center(child: Text('Scan Screen')),
    const InventoryHistoryScreen(),
    const Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFB3272E),
        unselectedItemColor: const Color(0xFF586062),
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Kiểm kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

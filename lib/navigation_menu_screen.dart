import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/employee_dashboard_screen.dart';
import 'main_tab_screen.dart';
import 'features/inventory/screens/inventory_list_screen.dart';
import 'features/inventory/screens/create_inventory_screen.dart';
import 'features/inventory/screens/choose_product_screen.dart';
import 'features/inventory/screens/inventory_detail_screen.dart';
import 'features/inventory/screens/confirm_sync_screen.dart';
import 'features/inventory/screens/inventory_history_screen.dart';

class NavigationMenuScreen extends StatelessWidget {
  const NavigationMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Navigation Menu'),
        backgroundColor: const Color(0xFFB3272E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuButton(context, '1. Login Screen', const LoginScreen()),
          const SizedBox(height: 12),
          _buildMenuButton(context, '2. Employee Dashboard', const EmployeeDashboardScreen()),
          const SizedBox(height: 12),
          _buildMenuButton(context, '3. Inventory List', const InventoryListScreen()),
          const SizedBox(height: 12),
          _buildMenuButton(context, '4. Create Inventory', const CreateInventoryScreen()),
          const SizedBox(height: 12),
          _buildMenuButton(context, '5. Choose Product', const ChooseProductScreen()),
          const SizedBox(height: 12),
          _buildMenuButton(context, '6. Inventory Detail', const InventoryDetailScreen()),
          const SizedBox(height: 12),
          _buildMenuButton(context, '7. Confirm & Sync', const ConfirmSyncScreen()),
          const SizedBox(height: 12),
          _buildMenuButton(context, '8. Inventory History', const InventoryHistoryScreen()),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.centerLeft,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

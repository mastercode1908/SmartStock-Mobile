import 'package:flutter/material.dart';
import '../../home/screens/employee_dashboard_screen.dart';

class ConfirmSyncScreen extends StatelessWidget {
  const ConfirmSyncScreen({Key? key}) : super(key: key);

  final Color _primary = const Color(0xFFB3272E);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _onSurfaceVariant = const Color(0xFF59413F);
  final Color _onSurface = const Color(0xFF131D21);
  final Color _secondary = const Color(0xFF586062);
  final Color _error = const Color(0xFFBA1A1A);
  final Color _errorContainer = const Color(0xFFFFDAD6);
  final Color _primaryContainer = const Color(0xFFFF5F5F);
  final Color _secondaryContainer = const Color(0xFFDAE1E3);
  final Color _onSecondaryContainer = const Color(0xFF5D6466);
  final Color _tertiaryContainer = const Color(0xFF00A7A3);
  final Color _surfaceContainerLow = const Color(0xFFEAF5FA);
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
            _buildSummaryGrid(),
            const SizedBox(height: 24),
            _buildListSection(),
            const SizedBox(height: 80), // Padding for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Xác nhận & Đồng bộ',
        style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: _onSurfaceVariant),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return Column(
      children: [
        // Top Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_off, color: _error, size: 32),
              ),
              const SizedBox(height: 12),
              Text('Ngoại tuyến', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _onSurface)),
              Text('Mất kết nối mạng', style: TextStyle(fontSize: 14, color: _secondary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Left Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pending_actions, color: const Color(0xFF006A67), size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text('DỮ LIỆU CHỜ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _secondary))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('8', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _onSurface)),
                        const SizedBox(width: 4),
                        Text('phiên', style: TextStyle(fontSize: 12, color: _secondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Right Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: _secondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text('LẦN ĐỒNG BỘ CUỐI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _secondary))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('14:30', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _onSurface)),
                    Text('24/10/2023', style: TextStyle(fontSize: 12, color: _secondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết phiên chờ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _onSurface),
        ),
        const SizedBox(height: 16),
        _buildListItem(
          id: 'INV-2023-004',
          status: 'Pending',
          statusIcon: Icons.pending,
          statusColor: _tertiaryContainer,
          statusBg: _tertiaryContainer.withOpacity(0.2),
          iconBg: _primaryContainer.withOpacity(0.1),
          iconColor: _primary,
          iconData: Icons.inventory_2,
          location: 'Khu vực: Kệ A-12',
          desc: '45 sản phẩm • Cập nhật lúc 15:10',
        ),
        const SizedBox(height: 16),
        _buildListItem(
          id: 'INV-2023-003',
          status: 'Failed',
          statusIcon: Icons.sync_problem,
          statusColor: _error,
          statusBg: _errorContainer,
          iconBg: _errorContainer.withOpacity(0.5),
          iconColor: _error,
          iconData: Icons.error,
          location: 'Khu vực: Kho lạnh B',
          desc: 'Lỗi kết nối khi tải lên',
          descColor: _error,
        ),
        const SizedBox(height: 16),
        _buildListItem(
          id: 'INV-2023-002',
          status: 'Pending',
          statusIcon: Icons.pending,
          statusColor: _tertiaryContainer,
          statusBg: _tertiaryContainer.withOpacity(0.2),
          iconBg: _primaryContainer.withOpacity(0.1),
          iconColor: _primary,
          iconData: Icons.inventory_2,
          location: 'Khu vực: Kệ C-05',
          desc: '12 sản phẩm • Cập nhật lúc 14:45',
        ),
      ],
    );
  }

  Widget _buildListItem({
    required String id,
    required String status,
    required IconData statusIcon,
    required Color statusColor,
    required Color statusBg,
    required Color iconBg,
    required Color iconColor,
    required IconData iconData,
    required String location,
    required String desc,
    Color? descColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(id, style: TextStyle(fontSize: 12, color: _onSecondaryContainer, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(status, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(location, style: TextStyle(fontSize: 14, color: _onSurface)),
                    Text(desc, style: TextStyle(fontSize: 12, color: descColor ?? _secondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: BorderSide(color: _primary.withOpacity(0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('XEM CHI TIẾT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.sync),
            label: const Text('ĐỒNG BỘ NGAY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const EmployeeDashboardScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.home, color: _primary),
            label: Text('Về trang chủ', style: TextStyle(fontWeight: FontWeight.bold, color: _primary)),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

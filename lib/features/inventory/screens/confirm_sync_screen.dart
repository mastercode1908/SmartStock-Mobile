import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/screens/employee_dashboard_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/inventory_provider.dart';

class ConfirmSyncScreen extends StatefulWidget {
  const ConfirmSyncScreen({Key? key}) : super(key: key);

  @override
  State<ConfirmSyncScreen> createState() => _ConfirmSyncScreenState();
}

class _ConfirmSyncScreenState extends State<ConfirmSyncScreen> {

  Color get _primary => Theme.of(context).colorScheme.primary;
  Color get _surfaceContainerLowest => Theme.of(context).cardColor;
  Color get _onSurfaceVariant => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _onSurface => Theme.of(context).colorScheme.onSurface;
  Color get _secondary => Theme.of(context).colorScheme.secondary;
  Color get _error => Theme.of(context).colorScheme.error;
  Color get _errorContainer => Theme.of(context).colorScheme.errorContainer;
  Color get _primaryContainer => Theme.of(context).colorScheme.primaryContainer;
  Color get _secondaryContainer => Theme.of(context).colorScheme.secondaryContainer;
  Color get _onSecondaryContainer => Theme.of(context).colorScheme.onSecondaryContainer;
  final Color _tertiaryContainer = const Color(0xFF00A7A3);
  Color get _surfaceContainerLow => Theme.of(context).colorScheme.surfaceContainerLow;
  Color get _background => Theme.of(context).scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              return ElevatedButton.icon(
                onPressed: provider.isLoading ? null : () async {
                  final sessionId = provider.lastSubmittedSessionId;
                  if (sessionId != null) {
                    final success = await provider.syncSession(sessionId);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đồng bộ thành công!')),
                      );
                      final user = context.read<AuthProvider>().currentUser;
                      provider.loadSessions();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đồng bộ lỗi: ${provider.error}')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không tìm thấy phiên kiểm kê cần đồng bộ.')),
                    );
                  }
                },
                icon: provider.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.sync),
                label: Text(provider.isLoading ? 'ĐANG ĐỒNG BỘ...' : 'ĐỒNG BỘ NGAY', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              );
            }
          ),
          const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step1_screen.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_session.dart';

class CountListScreen extends StatefulWidget {
  const CountListScreen({Key? key}) : super(key: key);

  @override
  State<CountListScreen> createState() => _CountListScreenState();
}

class _CountListScreenState extends State<CountListScreen> {
  String _currentFilter = 'Tất cả';

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
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.sessions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // Filter sessions: only show DRAFT or IN_PROGRESS
          var activeSessions = provider.sessions.where((s) => s.status == 'DRAFT' || s.status == 'IN_PROGRESS').toList();

          if (_currentFilter == 'Mới') {
            activeSessions = activeSessions.where((s) => s.status == 'DRAFT').toList();
          } else if (_currentFilter == 'Đang làm') {
            activeSessions = activeSessions.where((s) => s.status == 'IN_PROGRESS').toList();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadSessions(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatusFilters(),
                  const SizedBox(height: 24),
                  if (activeSessions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Không có nhiệm vụ kiểm kê nào.',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    _buildTaskList(context, activeSessions),
                  const SizedBox(height: 80), // Padding for bottom nav
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xfff9f9f9),
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
        IconButton(
          icon: const Icon(Icons.notifications, color: Color(0xffb02528)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey[300], height: 1.0),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Danh sách Kiểm kê',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chọn một danh sách để bắt đầu xác minh kho.',
                style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Icon(Icons.filter_list, size: 18, color: AppColors.onSurface),
              SizedBox(width: 8),
              Text('Lọc', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Tất cả'),
          const SizedBox(width: 8),
          _buildFilterChip('Mới'),
          const SizedBox(width: 8),
          _buildFilterChip('Đang làm'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _currentFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<InventorySession> sessions) {
    return Column(
      children: sessions.map((session) {
        bool isNew = session.status == 'DRAFT';
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildTaskCard(
            context,
            session: session,
            isNew: isNew,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskCard(BuildContext context, {
    required InventorySession session,
    required bool isNew,
  }) {
    // Determine progress if IN_PROGRESS
    double? progress;
    String qtyTitle = 'TỔNG SẢN PHẨM';
    String qty = '${session.details?.length ?? 0}';

    if (!isNew && session.details != null && session.details!.isNotEmpty) {
      qtyTitle = 'TIẾN ĐỘ';
      int counted = session.details!.where((d) => d.actualQuantity != null).length;
      qty = '$counted / ${session.details!.length} SKUs';
      progress = counted / session.details!.length;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (progress != null)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHigh,
              color: AppColors.primary,
              minHeight: 4,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assignment, color: isNew ? AppColors.onSurfaceVariant : AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          session.sessionCode,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isNew ? AppColors.tertiaryContainer.withOpacity(0.2) : AppColors.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: isNew ? null : Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Text(
                        isNew ? 'Mới' : 'Đang làm',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isNew ? AppColors.tertiary : AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LOẠI KIỂM KÊ', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          Text(session.countType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(qtyTitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          Text(qty, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NGÀY TẠO', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    Text(
                      '${session.startDate.toLocal().toString().split('.')[0]}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                isNew
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          // Switch status to IN_PROGRESS via some backend call if needed, but here we just go to Step 1
                          await context.read<InventoryProvider>().editSession(session);
                          if (context.mounted) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep1Screen()));
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow),
                            SizedBox(width: 8),
                            Text('Nhận nhiệm vụ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          foregroundColor: AppColors.primary,
                        ),
                        onPressed: () async {
                          await context.read<InventoryProvider>().editSession(session);
                          if (context.mounted) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep1Screen()));
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Tiếp tục', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

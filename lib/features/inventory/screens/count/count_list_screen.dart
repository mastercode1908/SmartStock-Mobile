import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step1_screen.dart';
import 'session_readonly_screen.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_session.dart';

class CountListScreen extends StatefulWidget {
  const CountListScreen({Key? key}) : super(key: key);

  @override
  State<CountListScreen> createState() => _CountListScreenState();
}

class _CountListScreenState extends State<CountListScreen> {
  String _currentFilter = 'Tất cả';
  DateTime? _startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);

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

          // Show all sessions (backend already filters by assignedTo for Staff)
          var activeSessions = provider.sessions.toList();

          if (_currentFilter == 'Nháp') {
            activeSessions = activeSessions.where((s) => s.status == 'DRAFT').toList();
          } else if (_currentFilter == 'Chờ duyệt') {
            activeSessions = activeSessions.where((s) => s.status == 'PENDING').toList();
          } else if (_currentFilter == 'Đã duyệt') {
            activeSessions = activeSessions.where((s) => s.status == 'APPROVED').toList();
          } else if (_currentFilter == 'Từ chối') {
            activeSessions = activeSessions.where((s) => s.status == 'REJECTED').toList();
          } else if (_currentFilter == 'Đã hủy') {
            activeSessions = activeSessions.where((s) => s.status == 'CANCELLED').toList();
          } else if (_currentFilter == 'Đã ghi nhận') {
            activeSessions = activeSessions.where((s) => s.status == 'POSTED').toList();
          }

          if (_startDate != null && _endDate != null) {
            activeSessions = activeSessions.where((s) {
              return s.startDate.isAfter(_startDate!.subtract(const Duration(seconds: 1))) && 
                     s.startDate.isBefore(_endDate!.add(const Duration(seconds: 1)));
            }).toList();
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
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Danh sách Kiểm kê',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
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
        GestureDetector(
          onTap: () async {
            final result = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      onSurface: AppColors.onSurface,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (result != null) {
              setState(() {
                _startDate = result.start;
                _endDate = DateTime(result.end.year, result.end.month, result.end.day, 23, 59, 59);
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 18, color: AppColors.onSurface),
                const SizedBox(width: 8),
                Text(
                  _startDate != null ? '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}' : 'Chọn ngày',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)
                ),
              ],
            ),
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
          _buildFilterChip('Nháp'),
          const SizedBox(width: 8),
          _buildFilterChip('Chờ duyệt'),
          const SizedBox(width: 8),
          _buildFilterChip('Đã duyệt'),
          const SizedBox(width: 8),
          _buildFilterChip('Từ chối'),
          const SizedBox(width: 8),
          _buildFilterChip('Đã hủy'),
          const SizedBox(width: 8),
          _buildFilterChip('Đã ghi nhận'),
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

    String statusLabel = 'Không rõ';
    Color statusColor = AppColors.onSurfaceVariant;
    Color statusBgColor = AppColors.surfaceContainerHigh;

    switch (session.status) {
      case 'DRAFT':
        statusLabel = 'Nháp';
        statusColor = const Color(0xff495057);
        statusBgColor = const Color(0xffe9ecef);
        break;
      case 'PENDING':
        statusLabel = 'Chờ duyệt';
        statusColor = const Color(0xff997404);
        statusBgColor = const Color(0xfffff3cd);
        break;
      case 'APPROVED':
        statusLabel = 'Đã duyệt';
        statusColor = const Color(0xff0f5132);
        statusBgColor = const Color(0xffd1e7dd);
        break;
      case 'REJECTED':
        statusLabel = 'Từ chối';
        statusColor = const Color(0xff842029);
        statusBgColor = const Color(0xfff8d7da);
        break;
      case 'CANCELLED':
        statusLabel = 'Đã hủy';
        statusColor = const Color(0xff636464);
        statusBgColor = const Color(0xffe2e3e5);
        break;
      case 'POSTED':
        statusLabel = 'Đã ghi nhận';
        statusColor = const Color(0xff084298);
        statusBgColor = const Color(0xffcfe2ff);
        break;
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
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: statusColor),
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
                      '${session.countDate.toString().split('.')[0]}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionButtons(context, session),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, InventorySession session) {
    String buttonText = 'Xem chi tiết';
    IconData buttonIcon = Icons.visibility;
    bool isPrimary = false;

    if (session.status == 'DRAFT') {
      buttonText = 'Bắt đầu kiểm kê';
      buttonIcon = Icons.play_arrow;
      isPrimary = true;
    } else if (session.status == 'PENDING') {
      buttonText = 'Xem tiến độ';
      buttonIcon = Icons.visibility;
    } else if (session.status == 'APPROVED') {
      buttonText = 'Xem chi tiết';
      buttonIcon = Icons.visibility;
    } else if (session.status == 'POSTED') {
      buttonText = 'Xem chi tiết';
      buttonIcon = Icons.check_circle_outline;
    }

    if (isPrimary) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
        onPressed: () async {
          await context.read<InventoryProvider>().editSession(session);
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep1Screen()));
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(buttonIcon),
            const SizedBox(width: 8),
            Text(buttonText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    } else {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          foregroundColor: AppColors.primary,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => SessionReadonlyScreen(session: session),
          ));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(buttonText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(buttonIcon),
          ],
        ),
      );
    }
  }

}

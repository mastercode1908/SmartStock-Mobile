import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../home/screens/employee_dashboard_screen.dart';
import 'inventory_list_screen.dart';
import '../../scanner/screens/scan_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/inventory_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/inventory_session.dart';
import 'inventory_history_detail_screen.dart';
import 'count/session_readonly_screen.dart';

class InventoryHistoryScreen extends StatefulWidget {
  const InventoryHistoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
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

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String _searchQuery = '';

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
      backgroundColor: Colors.white,
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
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm theo mã phiếu...',
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
              onPressed: _showAdvancedFilter,
              icon: const Icon(Icons.tune, size: 20),
              label: const Text('Lọc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: (_filterStartDate != null || _filterEndDate != null) ? _primary : _surfaceContainerLowest,
                foregroundColor: (_filterStartDate != null || _filterEndDate != null) ? Colors.white : _primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: _primary.withOpacity(0.5))
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Consumer2<InventoryProvider, AuthProvider>(
      builder: (context, provider, auth, child) {
        if (provider.isLoading && provider.sessions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = context.watch<AuthProvider>().currentUser;
        var completedSessions = provider.sessions.where((s) => s.status == 'POSTED').toList();
        
        // Staff filter
        if (auth.currentUser?.roleName == 'Staff') {
          completedSessions = completedSessions.where((s) => s.createdBy == user?.userId).toList();
        }

        // Apply search query
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          completedSessions = completedSessions.where((s) {
            String assigneeName = s.assignedToName ?? '';
            if (assigneeName.isEmpty && s.assignedTo != null) {
              if (s.assignedTo == user?.userId) {
                assigneeName = user?.fullName ?? '';
              } else {
                assigneeName = provider.getStaffName(s.assignedTo!);
                if (assigneeName.startsWith('Quản trị viên') && s.createdBy == s.assignedTo && s.createdByName?.isNotEmpty == true) {
                  assigneeName = s.createdByName!;
                }
              }
            }
            return s.sessionCode.toLowerCase().contains(query) || 
                   s.description.toLowerCase().contains(query) ||
                   assigneeName.toLowerCase().contains(query);
          }).toList();
        }

        // Apply date filters
        if (_filterStartDate != null) {
          completedSessions = completedSessions.where((s) {
            final sessionDate = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
            final filterDate = DateTime(_filterStartDate!.year, _filterStartDate!.month, _filterStartDate!.day);
            return sessionDate.isAtSameMomentAs(filterDate) || sessionDate.isAfter(filterDate);
          }).toList();
        }
        if (_filterEndDate != null) {
          completedSessions = completedSessions.where((s) {
            final sessionDate = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
            final filterDate = DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day);
            return sessionDate.isAtSameMomentAs(filterDate) || sessionDate.isBefore(filterDate);
          }).toList();
        }

        if (completedSessions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Chưa có phiếu kiểm kê hoàn thành nào.'),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: completedSessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final session = completedSessions[index];
            final dateStr = DateFormat('dd/MM/yyyy').format(session.startDate);

            Widget statusWidget = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đã ghi nhận', style: TextStyle(color: _secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                Text('CHI TIẾT', style: TextStyle(color: _secondary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            );

            String assigneeName = session.assignedToName ?? '';
            if (assigneeName.isEmpty && session.assignedTo != null) {
              if (session.assignedTo == user?.userId) {
                assigneeName = user?.fullName ?? '';
                if (assigneeName.isEmpty) assigneeName = user?.email ?? '';
              } else {
                assigneeName = provider.getStaffName(session.assignedTo!);
                if (assigneeName.startsWith('Quản trị viên') && session.createdBy == session.assignedTo && session.createdByName?.isNotEmpty == true) {
                  assigneeName = session.createdByName!;
                }
              }
            }
            if (assigneeName.isEmpty) assigneeName = 'Chưa giao';

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SessionReadonlyScreen(session: session),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: _buildInventoryCard(
                icon: Icons.check_circle,
                iconColor: _secondary,
                iconBg: _secondaryContainer,
                title: session.sessionCode,
                date: dateStr,
                warehouseName: session.warehouseName?.isNotEmpty == true ? session.warehouseName! : 'Chưa rõ',
                countType: session.countType,
                createdBy: assigneeName,
                statusWidget: statusWidget,
                isCompleted: true,
              ),
            );
          },
        );
      },
    );
  }

  void _showAdvancedFilter() {
    DateTime? tempStartDate = _filterStartDate;
    DateTime? tempEndDate = _filterEndDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bộ lọc thời gian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Date filters
                        const Text('Theo khoảng thời gian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: tempStartDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (d != null) {
                                    setModalState(() => tempStartDate = d);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(tempStartDate != null ? DateFormat('dd/MM/yyyy').format(tempStartDate!) : 'Từ ngày',
                                        style: TextStyle(color: tempStartDate != null ? Colors.black : Colors.grey)),
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: tempEndDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (d != null) {
                                    setModalState(() => tempEndDate = d);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(tempEndDate != null ? DateFormat('dd/MM/yyyy').format(tempEndDate!) : 'Đến ngày',
                                        style: TextStyle(color: tempEndDate != null ? Colors.black : Colors.grey)),
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Footer buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _filterStartDate = null;
                                _filterEndDate = null;
                              });
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Xóa bộ lọc'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _filterStartDate = tempStartDate;
                                _filterEndDate = tempEndDate;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Áp dụng', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    required String warehouseName,
    required String countType,
    required String createdBy,
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
                      style: TextStyle(fontSize: 12, color: _secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.warehouse_outlined, size: 14, color: _secondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        warehouseName,
                        style: TextStyle(fontSize: 13, color: _secondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 14, color: _secondary),
                    const SizedBox(width: 4),
                    Text(
                      'Loại: $countType',
                      style: TextStyle(fontSize: 13, color: _secondary),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.person_outline, size: 14, color: _secondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        createdBy,
                        style: TextStyle(fontSize: 13, color: _secondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
      selectedItemColor: const Color(0xFFB3272E),
      unselectedItemColor: const Color(0xFF586062),
      showUnselectedLabels: true,
      currentIndex: 3,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
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
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
      ],
    );
  }
}

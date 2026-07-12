import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import 'package:intl/intl.dart';
import 'inventory_history_screen.dart';
import 'create_inventory_screen.dart';
import '../../scanner/screens/scan_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_session.dart';
import 'count/session_readonly_screen.dart';
import 'count/count_step1_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({Key? key}) : super(key: key);

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  Color get _primary => Theme.of(context).colorScheme.primary;
  Color get _secondary => Theme.of(context).colorScheme.secondary;
  Color get _tertiary => const Color(0xFF93405F); // Not defined in ColorScheme easily, keep hardcoded or use tertiary if available

  Color get _surface => Theme.of(context).cardColor;
  Color get _surfaceContainerLow => Theme.of(context).colorScheme.surfaceContainerLow;
  Color get _surfaceContainerLowest => Theme.of(context).cardColor;
  Color get _onSurface => Theme.of(context).colorScheme.onSurface;
  Color get _onSurfaceVariant => Theme.of(context).colorScheme.onSurfaceVariant;
  
  Color get _outlineVariant => Theme.of(context).colorScheme.surfaceContainerHigh;
  Color get _secondaryContainer => Theme.of(context).colorScheme.secondaryContainer;
  Color get _background => Theme.of(context).scaffoldBackgroundColor;

  String _currentFilter = 'TẤT CẢ';
  String _searchQuery = '';
  
  // Advanced Filter states
  DateTime? _filterStartDate = DateTime.now();
  DateTime? _filterEndDate = DateTime.now();
  int? _filterStaffId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InventoryProvider>();
      provider.loadSessions();
      if (provider.staffs.isEmpty) {
        provider.loadStaffs();
      }
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

  bool _isFilterActive() {
    // Active only if user explicitly changed dates away from today or set a staff
    final today = DateTime.now();
    final isDefaultStart = _filterStartDate != null &&
        _filterStartDate!.year == today.year &&
        _filterStartDate!.month == today.month &&
        _filterStartDate!.day == today.day;
    final isDefaultEnd = _filterEndDate != null &&
        _filterEndDate!.year == today.year &&
        _filterEndDate!.month == today.month &&
        _filterEndDate!.day == today.day;
    // Not default = filter is actively customised
    return !isDefaultStart || !isDefaultEnd || _filterStaffId != null;
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light ? Colors.white : Theme.of(context).cardColor,
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
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
        InkWell(
          onTap: _showAdvancedFilter,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _isFilterActive() ? _primary.withOpacity(0.1) : _surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: _isFilterActive() ? Border.all(color: _primary.withOpacity(0.5)) : null,
            ),
            child: Icon(
              Icons.filter_list, 
              color: _isFilterActive() ? _primary : _onSurfaceVariant
            ),
          ),
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

  List<InventorySession> _getBaseFilteredSessions(InventoryProvider provider, UserModel? user) {
    List<InventorySession> sessions = provider.sessions.where((s) =>
        (s.createdBy == user?.userId || s.assignedTo == user?.userId)).toList();
    if (user?.roleName == 'Staff') {
      sessions = sessions.where((s) => 
        s.startDate.year == DateTime.now().year && 
        s.startDate.month == DateTime.now().month && 
        s.startDate.day == DateTime.now().day
      ).toList();
    }

    // Apply advanced filters
    if (_filterStartDate != null) {
      sessions = sessions.where((s) {
        final sessionDate = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
        final filterDate = DateTime(_filterStartDate!.year, _filterStartDate!.month, _filterStartDate!.day);
        return sessionDate.isAtSameMomentAs(filterDate) || sessionDate.isAfter(filterDate);
      }).toList();
    }
    if (_filterEndDate != null) {
      sessions = sessions.where((s) {
        final sessionDate = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
        final filterDate = DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day);
        return sessionDate.isAtSameMomentAs(filterDate) || sessionDate.isBefore(filterDate);
      }).toList();
    }
    if (_filterStaffId != null) {
      sessions = sessions.where((s) => s.assignedTo == _filterStaffId).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      sessions = sessions.where((s) {
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

    return sessions;
  }

  Widget _buildFilterChips() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final user = context.watch<AuthProvider>().currentUser;
        final sessions = _getBaseFilteredSessions(provider, user);
        
        int allCount = sessions.length;
        int pendingCount = sessions.where((s) => s.status == 'PENDING').length;
        int approvedCount = sessions.where((s) => s.status == 'APPROVED').length;
        int rejectedCount = sessions.where((s) => s.status == 'REJECTED').length;
        int postedCount = sessions.where((s) => s.status == 'POSTED').length;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip('TẤT CẢ ($allCount)', 'TẤT CẢ'),
              const SizedBox(width: 8),
              _buildChip('CHỜ DUYỆT ($pendingCount)', 'PENDING'),
              const SizedBox(width: 8),
              _buildChip('ĐÃ DUYỆT ($approvedCount)', 'APPROVED'),
              const SizedBox(width: 8),
              _buildChip('TỪ CHỐI ($rejectedCount)', 'REJECTED'),
              const SizedBox(width: 8),
              _buildChip('ĐÃ GHI NHẬN ($postedCount)', 'POSTED'),
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

        final user = context.watch<AuthProvider>().currentUser;
        List<InventorySession> activeSessions = _getBaseFilteredSessions(provider, user);

        if (_currentFilter != 'TẤT CẢ') {
          activeSessions = activeSessions.where((s) => s.status == _currentFilter).toList();
        }

        if (activeSessions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Không có phiếu kiểm kê nào.'),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeSessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final session = activeSessions[index];
            final dateStr = DateFormat('dd/MM/yyyy').format(session.startDate);

            Widget statusWidget;
            IconData icon;
            Color iconColor;
            Color iconBg;
            bool isCompleted = false;

            if (session.status == 'POSTED') {
              icon = Icons.check_circle;
              iconColor = _secondary;
              iconBg = _secondaryContainer;
              isCompleted = true;
              statusWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Đã ghi nhận', style: TextStyle(color: _secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('CHI TIẾT', style: TextStyle(color: _secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            } else if (session.status == 'PENDING') {
              icon = Icons.hourglass_top;
              iconColor = Colors.orange;
              iconBg = Colors.orange.withOpacity(0.1);
              statusWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chờ quản lý duyệt', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('CHI TIẾT', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            } else if (session.status == 'APPROVED') {
              icon = Icons.verified;
              iconColor = Colors.green;
              iconBg = Colors.green.withOpacity(0.1);
              statusWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Đã duyệt', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('CHI TIẾT', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            } else if (session.status == 'REJECTED') {
              icon = Icons.cancel;
              iconColor = _primary;
              iconBg = _primary.withOpacity(0.1);
              statusWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bị từ chối', style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('CHI TIẾT', style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            } else if (session.status == 'CANCELLED') {
              icon = Icons.cancel;
              iconColor = Colors.grey;
              iconBg = Colors.grey.withOpacity(0.1);
              isCompleted = true;
              statusWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Đã hủy', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('CHI TIẾT', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            } else {
              // DRAFT or others
              icon = Icons.inventory;
              iconColor = _tertiary;
              iconBg = _tertiary.withOpacity(0.1);
              
              final role = context.read<AuthProvider>().currentUser?.roleName ?? '';
              final isManager = role.toLowerCase().contains('admin') || role.toLowerCase().contains('manager');

              statusWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bản nháp (Đang kiểm)', style: TextStyle(color: _tertiary, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(isManager ? 'CHI TIẾT' : 'TIẾP TỤC', style: TextStyle(color: _tertiary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            }

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
                final role = context.read<AuthProvider>().currentUser?.roleName ?? '';
                final isManager = role.toLowerCase().contains('admin') || role.toLowerCase().contains('manager');

                if (session.status == 'DRAFT' && !isManager) {
                  // Gọi provider load chi tiết session trước khi vào đếm
                  context.read<InventoryProvider>().editSession(session).then((_) {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CountStep1Screen(),
                      ),
                    );
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SessionReadonlyScreen(session: session),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: _buildInventoryCard(
                icon: icon,
                iconColor: iconColor,
                iconBg: iconBg,
                title: session.sessionCode,
                date: dateStr,
                warehouseName: session.warehouseName?.isNotEmpty == true ? session.warehouseName! : 'Chưa rõ',
                countType: session.countType,
                createdBy: assigneeName,
                statusWidget: statusWidget,
                isCompleted: isCompleted,
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

  void _showAdvancedFilter() {
    DateTime? tempStartDate = _filterStartDate;
    DateTime? tempEndDate = _filterEndDate;
    int? tempStaffId = _filterStaffId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final staffs = context.read<InventoryProvider>().staffs;
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                        const Text('Bộ lọc nâng cao', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        const SizedBox(height: 24),
                        // Staff filter
                        const Text('Theo nhân viên (được giao)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              isExpanded: true,
                              value: tempStaffId,
                              hint: const Text('Chọn nhân viên'),
                              items: [
                                const DropdownMenuItem<int?>(value: null, child: Text('Tất cả nhân viên')),
                                ...staffs.map((s) {
                                  final Map<String, dynamic> keys = s.map((k, v) => MapEntry(k.toLowerCase(), v));
                                  final id = int.tryParse(keys['userid']?.toString() ?? keys['id']?.toString() ?? '0');
                                  final name = keys['fullname'] ?? keys['name'] ?? keys['username'] ?? 'User $id';
                                  return DropdownMenuItem<int?>(
                                    value: id,
                                    child: Text(name),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setModalState(() => tempStaffId = val);
                              },
                            ),
                          ),
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
                              final today = DateTime.now();
                              setModalState(() {
                                tempStartDate = today;
                                tempEndDate = today;
                                tempStaffId = null;
                              });
                              setState(() {
                                _filterStartDate = today;
                                _filterEndDate = today;
                                _filterStaffId = null;
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
                                _filterStaffId = tempStaffId;
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

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      showUnselectedLabels: true,
      currentIndex: 1,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
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

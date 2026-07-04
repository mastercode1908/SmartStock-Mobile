import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step5_screen.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_count_detail.dart';

class CountStep4Screen extends StatefulWidget {
  const CountStep4Screen({Key? key}) : super(key: key);

  @override
  State<CountStep4Screen> createState() => _CountStep4ScreenState();
}

class _CountStep4ScreenState extends State<CountStep4Screen> {
  String _currentFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          final session = provider.selectedSession ?? provider.sessions.firstWhere((s) => s.id == provider.activeSessionId);
          final details = session.details ?? [];

          final matched = details.where((d) => d.actualQuantity != null && d.actualQuantity == d.systemQuantity).toList();
          final discrepant = details.where((d) => d.actualQuantity != null && d.actualQuantity != d.systemQuantity).toList();
          final pending = details.where((d) => d.actualQuantity == null).toList();

          List<InventoryCountDetail> displayList = [];
          if (_currentFilter == 'Khớp') {
            displayList = matched;
          } else if (_currentFilter == 'Sai lệch') {
            displayList = discrepant;
          } else if (_currentFilter == 'Chờ đếm') {
            displayList = pending;
          } else {
            displayList = details;
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressHeader(),
                      const SizedBox(height: 32),
                      _buildFilterChips(details.length, matched.length, discrepant.length, pending.length),
                      const SizedBox(height: 32),
                      
                      if (_currentFilter == 'Tất cả' || _currentFilter == 'Sai lệch') ...[
                        Text('Sai lệch (${discrepant.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                        const SizedBox(height: 16),
                        _buildDiscrepancyList(discrepant),
                        const SizedBox(height: 32),
                      ],
                      
                      if (_currentFilter == 'Tất cả' || _currentFilter == 'Khớp') ...[
                        Text('Các mục đã khớp (${matched.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                        const SizedBox(height: 16),
                        _buildMatchedList(matched),
                        const SizedBox(height: 32),
                      ],

                      if (_currentFilter == 'Tất cả' || _currentFilter == 'Chờ đếm') ...[
                        Text('Chờ đếm (${pending.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                        const SizedBox(height: 16),
                        _buildPendingList(pending),
                      ],
                      
                      const SizedBox(height: 100), // Padding for sticky bottom area
                    ],
                  ),
                ),
              ),
              _buildQuickActions(context),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text(
        'Warehouse Pro',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        const Text(
          'Bước 4/5: Kiểm tra danh sách',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Xem lại các mục đã kiểm kê và xác nhận sai lệch',
          style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.8, // 4/5
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(int total, int matched, int discrepant, int pending) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Tất cả ($total)', AppColors.primary, Colors.white, null, 'Tất cả'),
          const SizedBox(width: 8),
          _buildChip('Khớp ($matched)', AppColors.surfaceContainerHighest, AppColors.onSurface, Colors.green, 'Khớp'),
          const SizedBox(width: 8),
          _buildChip('Sai lệch ($discrepant)', const Color(0xFFFEEBEE), AppColors.primary, AppColors.primary, 'Sai lệch'),
          const SizedBox(width: 8),
          _buildChip('Chờ đếm ($pending)', AppColors.surfaceContainerLow, AppColors.onSurfaceVariant, Colors.orange, 'Chờ đếm'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor, Color? dotColor, String filterValue) {
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
          color: isSelected ? bgColor : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected && dotColor != null ? dotColor.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          children: [
            if (dotColor != null && isSelected) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
            ],
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? textColor : AppColors.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscrepancyList(List<InventoryCountDetail> discrepant) {
    if (discrepant.isEmpty) return const Text('Không có mục sai lệch nào.', style: TextStyle(color: AppColors.onSurfaceVariant));
    return Column(
      children: discrepant.map((d) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildDiscrepancyItem(d.variantName ?? 'Sản phẩm', d.sku ?? '', '${d.systemQuantity}', '${d.actualQuantity}'),
      )).toList(),
    );
  }

  Widget _buildDiscrepancyItem(String name, String sku, String sysQty, String actualQty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEEBEE)),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFEEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text('SKU: $sku', style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('HT: $sysQty', style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, decoration: TextDecoration.lineThrough)),
                  const SizedBox(width: 8),
                  Text('Đếm: $actualQty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Đếm lại', style: TextStyle(fontSize: 14, color: AppColors.primary, decoration: TextDecoration.underline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchedList(List<InventoryCountDetail> matched) {
    if (matched.isEmpty) return const Text('Không có mục khớp nào.', style: TextStyle(color: AppColors.onSurfaceVariant));
    return Column(
      children: matched.map((d) => _buildMatchedItem(d.variantName ?? 'Sản phẩm', d.sku ?? '', '${d.actualQuantity}')).toList(),
    );
  }

  Widget _buildMatchedItem(String name, String sku, String qty) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceContainer)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text('SKU: $sku', style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text('SL: $qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildPendingList(List<InventoryCountDetail> pending) {
    if (pending.isEmpty) return const Text('Không còn mục nào chờ đếm.', style: TextStyle(color: AppColors.onSurfaceVariant));
    return Column(
      children: pending.map((d) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.surfaceContainer)),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.variantName ?? 'Sản phẩm', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Text('SKU: ${d.sku}', style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const Text('Chưa đếm', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceContainer)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  foregroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.pop(context); // Go back to Scanner
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Tiếp tục đếm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep5Screen()));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Tiếp tục Bước 5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressHeader(),
                      SizedBox(height: 32),
                      _buildFilterChips(details.length, matched.length, discrepant.length, pending.length),
                      SizedBox(height: 32),
                      
                      if (_currentFilter == 'Tất cả' || _currentFilter == 'Sai lệch') ...[
                        Text('Sai lệch (${discrepant.length})', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        SizedBox(height: 16),
                        _buildDiscrepancyList(discrepant),
                        SizedBox(height: 32),
                      ],
                      
                      if (_currentFilter == 'Tất cả' || _currentFilter == 'Khớp') ...[
                        Text('Các mục đã khớp (${matched.length})', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        SizedBox(height: 16),
                        _buildMatchedList(matched),
                        SizedBox(height: 32),
                      ],

                      if (_currentFilter == 'Tất cả' || _currentFilter == 'Chờ đếm') ...[
                        Text('Chờ đếm (${pending.length})', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        SizedBox(height: 16),
                        _buildPendingList(pending),
                      ],
                      
                      SizedBox(height: 100), // Padding for sticky bottom area
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'Smart Stock',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        Text(
          'Bước 4/5: Kiểm tra danh sách',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Xem lại các mục đã kiểm kê và xác nhận sai lệch',
          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
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
          _buildChip('Tất cả ($total)', AppColors.primary, Theme.of(context).colorScheme.surface, null, 'Tất cả'),
          SizedBox(width: 8),
          _buildChip('Khớp ($matched)', Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.onSurface, Colors.green, 'Khớp'),
          SizedBox(width: 8),
          _buildChip('Sai lệch ($discrepant)', const Color(0xFFFEEBEE), AppColors.primary, AppColors.primary, 'Sai lệch'),
          SizedBox(width: 8),
          _buildChip('Chờ đếm ($pending)', Theme.of(context).colorScheme.surfaceContainerLow, Theme.of(context).colorScheme.onSurfaceVariant, Colors.orange, 'Chờ đếm'),
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Theme.of(context).colorScheme.surfaceContainerHighest,
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
              SizedBox(width: 8),
            ],
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? textColor : Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscrepancyList(List<InventoryCountDetail> discrepant) {
    if (discrepant.isEmpty) return Text('Không có mục sai lệch nào.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
    return Column(
      children: discrepant.map((d) => Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: _buildDiscrepancyItem(d),
      )).toList(),
    );
  }

  Widget _buildDiscrepancyItem(InventoryCountDetail d) {
    final name = d.variantName ?? d.productName ?? 'Sản phẩm';
    final sku = d.sku ?? '';
    final sysQty = '${d.systemQuantity}';
    final actualQty = '${d.actualQuantity}';
    
    List<String> trackingInfo = [];
    if (d.trackingMethod == 1 || d.trackingMethod == 3) {
      if (d.batchNumber != null && d.batchNumber!.isNotEmpty) trackingInfo.add('Lô: ${d.batchNumber}');
    }
    if (d.trackingMethod == 2 || d.trackingMethod == 3) {
      if (d.serialNumber != null && d.serialNumber!.isNotEmpty) trackingInfo.add('Serial: ${d.serialNumber}');
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEEBEE)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.error.withOpacity(0.08),
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
            child: Icon(Icons.warning, color: AppColors.primary),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 4),
                Text('SKU: $sku', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                if (trackingInfo.isNotEmpty)
                  Text(trackingInfo.join(' | '), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('HT: $sysQty', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant, decoration: TextDecoration.lineThrough)),
                  SizedBox(width: 8),
                  Text('Đếm: $actualQty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              SizedBox(height: 4),
              Text('Đếm lại', style: TextStyle(fontSize: 14, color: AppColors.primary, decoration: TextDecoration.underline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchedList(List<InventoryCountDetail> matched) {
    if (matched.isEmpty) return Text('Không có mục khớp nào.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
    return Column(
      children: matched.map((d) => _buildMatchedItem(d)).toList(),
    );
  }

  Widget _buildMatchedItem(InventoryCountDetail d) {
    final name = d.variantName ?? d.productName ?? 'Sản phẩm';
    final sku = d.sku ?? '';
    final qty = '${d.actualQuantity}';

    List<String> trackingInfo = [];
    if (d.trackingMethod == 1 || d.trackingMethod == 3) {
      if (d.batchNumber != null && d.batchNumber!.isNotEmpty) trackingInfo.add('Lô: ${d.batchNumber}');
    }
    if (d.trackingMethod == 2 || d.trackingMethod == 3) {
      if (d.serialNumber != null && d.serialNumber!.isNotEmpty) trackingInfo.add('Serial: ${d.serialNumber}');
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.surfaceContainer)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 4),
                Text('SKU: $sku', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                if (trackingInfo.isNotEmpty)
                  Text(trackingInfo.join(' | '), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text('SL: $qty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildPendingList(List<InventoryCountDetail> pending) {
    if (pending.isEmpty) return Text('Không còn mục nào chờ đếm.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
    return Column(
      children: pending.map((d) {
        List<String> trackingInfo = [];
        if (d.trackingMethod == 1 || d.trackingMethod == 3) {
          if (d.batchNumber != null && d.batchNumber!.isNotEmpty) trackingInfo.add('Lô: ${d.batchNumber}');
        }
        if (d.trackingMethod == 2 || d.trackingMethod == 3) {
          if (d.serialNumber != null && d.serialNumber!.isNotEmpty) trackingInfo.add('Serial: ${d.serialNumber}');
        }

        return Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.surfaceContainer)),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.orange),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.variantName ?? d.productName ?? 'Sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    SizedBox(height: 4),
                    Text('SKU: ${d.sku ?? ""}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    if (trackingInfo.isNotEmpty)
                      Text(trackingInfo.join(' | '), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.surfaceContainer)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  foregroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.pop(context); // Go back to Scanner
                },
                icon: Icon(Icons.restart_alt),
                label: Text('Tiếp tục đếm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep5Screen()));
                },
                child: Row(
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

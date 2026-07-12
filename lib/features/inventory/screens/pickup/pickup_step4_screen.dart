import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'pickup_step5_screen.dart';

class PickUpStep4Screen extends StatefulWidget {
  const PickUpStep4Screen({Key? key}) : super(key: key);
  @override
  State<PickUpStep4Screen> createState() => _PickUpStep4ScreenState();
}

class _PickUpStep4ScreenState extends State<PickUpStep4Screen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressHeader(),
                  SizedBox(height: 32),
                  _buildFilterChips(),
                  SizedBox(height: 32),
                  Text('Sai lệch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  SizedBox(height: 16),
                  _buildDiscrepancyList(),
                  SizedBox(height: 32),
                  Text('Các mục đã khớp', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  SizedBox(height: 16),
                  _buildMatchedList(),
                  SizedBox(height: 100), // Padding for sticky bottom area
                ],
              ),
            ),
          ),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.primary),
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
      ),
      centerTitle: true,
      title: Text(
        'Warehouse Pro',
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Tất cả (24)', AppColors.primary, Theme.of(context).colorScheme.surface, null),
          SizedBox(width: 8),
          _buildChip('Khớp (21)', Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.onSurface, Colors.green),
          SizedBox(width: 8),
          _buildChip('Sai lệch (3)', const Color(0xFFFEEBEE), AppColors.primary, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor, Color? dotColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dotColor != null ? dotColor.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            SizedBox(width: 8),
          ],
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildDiscrepancyList() {
    return Column(
      children: [
        _buildDiscrepancyItem('iPhone 15 Pro Max 256GB', 'APP-I15PM-256-BLK', '1', '0'),
        SizedBox(height: 12),
        _buildDiscrepancyItem('Chuột Logitech MX Master 3S', 'LOG-MXM3S-GRY', '1', '0'),
      ],
    );
  }

  Widget _buildDiscrepancyItem(String name, String sku, String sysQty, String actualQty) {
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

  Widget _buildMatchedList() {
    return Column(
      children: [
        _buildMatchedItem('Bàn phím Keychron K2V2', 'KEY-K2V2-RGB', '5/5'),
        _buildMatchedItem('Hub USB-C 7-in-1 Baseus', 'BAS-HUB-71-GR', '7/7'),
      ],
    );
  }

  Widget _buildMatchedItem(String name, String sku, String qty) {
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
              ],
            ),
          ),
          Text('SL: $qty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
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
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  foregroundColor: AppColors.primary,
                ),
                onPressed: () {},
                child: Text('Đếm lại tất cả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PickUpStep5Screen()));
                },
                child: Text('Tiếp tục (Bước 5)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

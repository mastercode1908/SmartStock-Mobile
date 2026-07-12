import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PickUpStep5Screen extends StatefulWidget {
  const PickUpStep5Screen({Key? key}) : super(key: key);

  @override
  State<PickUpStep5Screen> createState() => _PickUpStep5ScreenState();
}

class _PickUpStep5ScreenState extends State<PickUpStep5Screen> {
  bool _isSyncing = false;
  bool _isSynced = false;

  void _handleSync() async {
    setState(() {
      _isSyncing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _isSynced = true;
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProgressHeader(),
                SizedBox(height: 32),
                _buildSummaryGrid(),
                SizedBox(height: 32),
                _buildDiscrepancyList(),
                SizedBox(height: 120), // Padding for sticky bottom area
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildActionButtons(context),
          ),
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
        icon: Icon(Icons.menu, color: AppColors.primary),
        onPressed: () {},
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
          icon: Icon(Icons.account_circle, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        Text(
          'Bước 5/5: Hoàn tất & Đồng bộ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Tóm tắt kết quả kiểm kê và đẩy dữ liệu lên hệ thống',
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
            widthFactor: 1.0, // 5/5
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

  Widget _buildSummaryGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.dataset,
            iconColor: AppColors.secondary,
            title: 'TỔNG SỐ SKU',
            value: '1.248',
            valueColor: Theme.of(context).colorScheme.onSurface,
            bgColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderColor: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.check_circle,
            iconColor: AppColors.primary,
            title: 'ĐÃ KHỚP',
            value: '1.242',
            valueColor: AppColors.primary,
            bgColor: const Color(0xFFFEEBEE).withOpacity(0.4),
            borderColor: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.warning,
            iconColor: Theme.of(context).colorScheme.error,
            title: 'CHÊNH LỆCH',
            value: '6',
            valueColor: Theme.of(context).colorScheme.error,
            bgColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderColor: Theme.of(context).colorScheme.error.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      height: 140,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 32,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 32),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildDiscrepancyList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chi tiết chênh lệch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                Text('Xem tất cả', style: TextStyle(fontSize: 14, color: AppColors.primary, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildDiscrepancyListItem('SKU-892-A', 'Dự kiến: 140 | Thực tế: 138', '-2'),
          Divider(height: 1, color: Theme.of(context).colorScheme.surfaceContainer),
          _buildDiscrepancyListItem('SKU-411-B', 'Dự kiến: 50 | Thực tế: 54', '+4'),
        ],
      ),
    );
  }

  Widget _buildDiscrepancyListItem(String title, String subtitle, String diff) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.qr_code, color: Theme.of(context).colorScheme.onErrorContainer, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(diff, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              foregroundColor: AppColors.primary,
            ),
            onPressed: () {},
            icon: Icon(Icons.edit_document),
            label: Text('Xem báo cáo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSynced ? Colors.green : AppColors.primary,
              foregroundColor: Theme.of(context).colorScheme.surface,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 4,
            ),
            onPressed: _isSyncing || _isSynced ? null : _handleSync,
            icon: _isSyncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.surface, strokeWidth: 2),
                  )
                : Icon(_isSynced ? Icons.check_circle : Icons.sync),
            label: Text(
              _isSyncing ? 'Đang đồng bộ...' : (_isSynced ? 'Đã đồng bộ!' : 'Đồng bộ'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

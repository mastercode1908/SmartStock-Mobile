import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/inventory_session.dart';
import '../../providers/inventory_provider.dart';
import 'count_success_screen.dart';
import '../../../sync/screens/pending_sync_screen.dart';

class CountStep5Screen extends StatefulWidget {
  const CountStep5Screen({Key? key}) : super(key: key);

  @override
  State<CountStep5Screen> createState() => _CountStep5ScreenState();
}

class _CountStep5ScreenState extends State<CountStep5Screen> {
  bool _isSyncing = false;
  bool _isSynced = false;
  String? _error;

  void _handleSync() async {
    setState(() {
      _isSyncing = true;
      _error = null;
    });

    final provider = context.read<InventoryProvider>();
    final session =
        provider.selectedSession ??
        provider.sessions.firstWhere((s) => s.id == provider.activeSessionId);
    final details = session.details ?? [];

    final hasUncounted = details.any((d) => d.actualQuantity == null);
    if (hasUncounted) {
      setState(() {
        _isSyncing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng kiểm hết tất cả các sản phẩm trước khi gửi duyệt!'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Filter only those with actual quantities
    final countedDetails = details
        .where((d) => d.actualQuantity != null)
        .toList();

    // API calls to submit counted details and then sync the session
    bool submitSuccess = await provider.submitCountDetails();

    if (submitSuccess && mounted) {
      bool syncSuccess = await provider.syncSession(session.id);

      if (mounted) {
        if (syncSuccess) {
          setState(() {
            _isSyncing = false;
            _isSynced = true;
          });

          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            if (provider.isOfflineSaved) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PendingSyncScreen(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CountSuccessScreen(session: session),
                ),
              );
            }
          }
        } else {
          setState(() {
            _isSyncing = false;
            _error = provider.error ?? "Lỗi khi đồng bộ.";
          });
        }
      }
    } else if (mounted) {
      setState(() {
        _isSyncing = false;
        _error = provider.error ?? "Lỗi khi gửi kết quả.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          final session =
              provider.selectedSession ??
              provider.sessions.firstWhere(
                (s) => s.id == provider.activeSessionId,
              );
          final details = session.details ?? [];

          final totalSku = details.length;
          final matched = details
              .where(
                (d) =>
                    d.actualQuantity != null &&
                    d.actualQuantity == d.systemQuantity,
              )
              .length;
          final discrepant = details
              .where(
                (d) =>
                    d.actualQuantity != null &&
                    d.actualQuantity != d.systemQuantity,
              )
              .toList();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProgressHeader(),
                    SizedBox(height: 32),
                    if (_error != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildSummaryGrid(totalSku, matched, discrepant.length),
                    SizedBox(height: 32),
                    _buildDiscrepancyList(discrepant),
                    SizedBox(
                      height: 120,
                    ), // Padding for sticky bottom area
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
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        Text(
          'Bước 5/5: Hoàn tất & Gửi duyệt',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
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

  Widget _buildSummaryGrid(int total, int matched, int discrepant) {
    return Column(
      children: [
        _buildSummaryCard(
          icon: Icons.dataset,
          iconColor: AppColors.secondary,
          title: 'TỔNG SỐ SẢN PHẨM',
          value: '$total',
          valueColor: Theme.of(context).colorScheme.onSurface,
          bgColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderColor: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
        SizedBox(height: 12),
        _buildSummaryCard(
          icon: Icons.check_circle,
          iconColor: const Color(0xff0f5132),
          title: 'ĐÃ KHỚP',
          value: '$matched',
          valueColor: const Color(0xff0f5132),
          bgColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderColor: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
        SizedBox(height: 12),
        _buildSummaryCard(
          icon: Icons.warning,
          iconColor: Theme.of(context).colorScheme.error,
          title: 'CHÊNH LỆCH',
          value: '$discrepant',
          valueColor: Theme.of(context).colorScheme.error,
          bgColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderColor: Theme.of(context).colorScheme.error.withOpacity(0.2),
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
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscrepancyList(List<dynamic> discrepantItems) {
    if (discrepantItems.isEmpty) return const SizedBox.shrink();
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chi tiết chênh lệch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...discrepantItems
              .map(
                (d) => Column(
                  children: [
                    _buildDiscrepancyListItem(
                      d.sku ?? '',
                      'Dự kiến: ${d.systemQuantity} | Thực tế: ${d.actualQuantity}',
                      '${d.actualQuantity! - d.systemQuantity}',
                    ),
                    Divider(height: 1, color: Theme.of(context).colorScheme.surfaceContainer),
                  ],
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDiscrepancyListItem(String title, String subtitle, String diff) {
    final diffInt = int.tryParse(diff) ?? 0;
    final diffStr = diffInt > 0 ? '+$diff' : diff;
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
            child: Icon(
              Icons.qr_code,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              diffStr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSynced ? Colors.green : AppColors.primary,
              foregroundColor: Theme.of(context).colorScheme.surface,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
            ),
            onPressed: _isSyncing || _isSynced ? null : _handleSync,
            icon: _isSyncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.surface,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(_isSynced ? Icons.check_circle : Icons.send_rounded),
            label: Text(
              _isSyncing
                  ? 'Đang gửi duyệt...'
                  : (_isSynced ? 'Đã gửi duyệt!' : 'Gửi duyệt'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/inventory_provider.dart';
import 'count_success_screen.dart';

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
        const SnackBar(
          content: Text('Vui lòng kiểm hết tất cả các sản phẩm trước khi gửi duyệt!'),
          backgroundColor: AppColors.error,
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CountSuccessScreen(session: session),
              ),
            );
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
      backgroundColor: AppColors.background,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProgressHeader(),
                    const SizedBox(height: 32),
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppColors.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildSummaryGrid(totalSku, matched, discrepant.length),
                    const SizedBox(height: 32),
                    _buildDiscrepancyList(discrepant),
                    const SizedBox(
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
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text(
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
        const Text(
          'Bước 5/5: Hoàn tất & Gửi duyệt',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Tóm tắt kết quả kiểm kê và đẩy dữ liệu lên hệ thống',
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
          valueColor: AppColors.onSurface,
          bgColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.outlineVariant.withOpacity(0.3),
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          icon: Icons.check_circle,
          iconColor: const Color(0xff0f5132),
          title: 'ĐÃ KHỚP',
          value: '$matched',
          valueColor: const Color(0xff0f5132),
          bgColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.outlineVariant.withOpacity(0.3),
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          icon: Icons.warning,
          iconColor: AppColors.error,
          title: 'CHÊNH LỆCH',
          value: '$discrepant',
          valueColor: AppColors.error,
          bgColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.error.withOpacity(0.2),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chi tiết chênh lệch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const Text(
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
                    const Divider(height: 1, color: AppColors.surfaceContainer),
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code,
              color: AppColors.onErrorContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              diffStr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
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
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
            ),
            onPressed: _isSyncing || _isSynced ? null : _handleSync,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(_isSynced ? Icons.check_circle : Icons.send_rounded),
            label: Text(
              _isSyncing
                  ? 'Đang gửi duyệt...'
                  : (_isSynced ? 'Đã gửi duyệt!' : 'Gửi duyệt'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step2_screen.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_count_detail.dart';

String _getTrackingLabel(int trackingMethod) {
  switch (trackingMethod) {
    case 1:
      return 'Theo lô (Batch)';
    case 2:
      return 'Số Serial';
    case 3:
      return 'Lô & Serial';
    default:
      return 'Không phân loại';
  }
}

class CountStep1Screen extends StatelessWidget {
  const CountStep1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final session = provider.selectedSession;
          if (session == null || session.details == null || session.details!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Không có sản phẩm nào trong phiếu kiểm kê này.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
                ),
              ),
            );
          }

          // Group details by locationCode (zone-rack-shelf)
          final Map<String, List<InventoryCountDetail>> locationGroups = {};
          for (var detail in session.details!) {
            final key = _buildLocationKey(detail);
            locationGroups.putIfAbsent(key, () => []).add(detail);
          }

          final locationKeys = locationGroups.keys.toList()..sort();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressHeader(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.sessionCode,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            ),
                            Text(
                              'Loại: ${session.countType}',
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${session.details!.length} SP',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Chọn vị trí để bắt đầu kiểm kê',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  '${locationKeys.length} vị trí cần kiểm kê',
                  style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                ...locationKeys.map((key) {
                  final details = locationGroups[key]!;
                  final firstDetail = details.first;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLocationGroupCard(context, key, firstDetail, details, provider),
                  );
                }).toList(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  String _buildLocationKey(InventoryCountDetail detail) {
    if (detail.locationCode != null && detail.locationCode!.isNotEmpty) {
      return detail.locationCode!;
    }
    final parts = [
      if (detail.zone != null && detail.zone!.isNotEmpty) detail.zone!,
      if (detail.rack != null && detail.rack!.isNotEmpty) detail.rack!,
      if (detail.shelf != null && detail.shelf!.isNotEmpty) detail.shelf!,
    ];
    return parts.isNotEmpty ? parts.join('-') : 'UNKNOWN';
  }

  String _buildLocationLabel(InventoryCountDetail detail) {
    final parts = [
      if (detail.zone != null && detail.zone!.isNotEmpty) 'Khu ${detail.zone}',
      if (detail.rack != null && detail.rack!.isNotEmpty) 'Dãy ${detail.rack}',
      if (detail.shelf != null && detail.shelf!.isNotEmpty) 'Tầng ${detail.shelf}',
      if (detail.bin != null && detail.bin!.isNotEmpty) 'Ô ${detail.bin}',
    ];
    if (parts.isNotEmpty) return parts.join(' - ');
    if (detail.locationCode != null && detail.locationCode!.isNotEmpty) return detail.locationCode!;
    return 'Chưa xác định vị trí';
  }



  Widget _buildLocationGroupCard(
    BuildContext context,
    String locationKey,
    InventoryCountDetail firstDetail,
    List<InventoryCountDetail> details,
    InventoryProvider provider,
  ) {
    final label = _buildLocationLabel(firstDetail);
    final countedInGroup = details.where((d) => d.actualQuantity != null).length;
    final isDone = countedInGroup == details.length && details.isNotEmpty;

    return GestureDetector(
      onTap: () {
        provider.setActiveLocationGroup(details);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep2Screen()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: LinearProgressIndicator(
                value: details.isNotEmpty ? countedInGroup / details.length : 0,
                backgroundColor: AppColors.surfaceContainerHigh,
                color: isDone ? const Color(0xff0f5132) : AppColors.primary,
                minHeight: 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDone
                              ? const Color(0xff0f5132).withOpacity(0.1)
                              : AppColors.primaryContainer.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check_circle : Icons.location_on,
                          size: 20,
                          color: isDone ? const Color(0xff0f5132) : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDone ? const Color(0xff0f5132) : AppColors.onSurface,
                              ),
                            ),
                            if (firstDetail.locationCode != null && firstDetail.locationCode!.isNotEmpty)
                              Text(
                                firstDetail.locationCode!,
                                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$countedInGroup/${details.length}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDone ? const Color(0xff0f5132) : AppColors.primary,
                            ),
                          ),
                          const Text(
                            'sản phẩm',
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...details.map((d) {
                    final checked = d.actualQuantity != null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            checked ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 20,
                            color: checked ? const Color(0xff0f5132) : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (d.sku != null && d.sku!.isNotEmpty ? d.sku! : '') +
                                      (d.variantName != null && d.variantName!.isNotEmpty ? ' · ${d.variantName}' : ''),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: checked ? FontWeight.normal : FontWeight.w500,
                                    color: checked ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                    decoration: checked ? TextDecoration.lineThrough : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (d.trackingMethod != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerHigh,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getTrackingLabel(d.trackingMethod),
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                          ),
                                        ),
                                        if ((d.trackingMethod == 1 || d.trackingMethod == 3) && d.batchNumber != null && d.batchNumber!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4),
                                            child: Text('Lô: ${d.batchNumber}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                          ),
                                        if ((d.trackingMethod == 2 || d.trackingMethod == 3) && d.serialNumber != null && d.serialNumber!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4),
                                            child: Text('Serial: ${d.serialNumber}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SL: ${d.systemQuantity}',
                            style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: isDone
                        ? OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xff0f5132)),
                              foregroundColor: const Color(0xff0f5132),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              provider.setActiveLocationGroup(details);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep2Screen()));
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Kiểm tra lại', style: TextStyle(fontSize: 14)),
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                            onPressed: () {
                              provider.setActiveLocationGroup(details);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep2Screen()));
                            },
                            icon: const Icon(Icons.qr_code_scanner, size: 16),
                            label: const Text('Bắt đầu kiểm tại đây', style: TextStyle(fontSize: 14)),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text(
        'Smart Stock',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        const Text(
          'Bước 1/5: Chọn Vị trí Kệ',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Đến từng vị trí kệ và bấm để bắt đầu kiểm đếm sản phẩm tại đó',
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(4)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.2,
            child: Container(
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }
}

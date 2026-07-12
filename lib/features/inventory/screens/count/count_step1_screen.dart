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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          }

          final session = provider.selectedSession;
          if (session == null || session.details == null || session.details!.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Không có sản phẩm nào trong phiếu kiểm kê này.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
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
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressHeader(context),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.sessionCode,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            Text(
                              'Loại: ${session.countType}',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${session.details!.length} SP',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Chọn vị trí để bắt đầu kiểm kê',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                ),
                SizedBox(height: 4),
                Text(
                  '${locationKeys.length} vị trí cần kiểm kê',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: 16),
                ...locationKeys.map((key) {
                  final details = locationGroups[key]!;
                  final firstDetail = details.first;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _buildLocationGroupCard(context, key, firstDetail, details, provider),
                  );
                }).toList(),
                SizedBox(height: 80),
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
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
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                color: isDone ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                minHeight: 4,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDone
                              ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check_circle : Icons.location_on,
                          size: 20,
                          color: isDone ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDone ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (firstDetail.locationCode != null && firstDetail.locationCode!.isNotEmpty)
                              Text(
                                firstDetail.locationCode!,
                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                              color: isDone ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            'sản phẩm',
                            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(height: 1),
                  SizedBox(height: 8),
                  ...details.map((d) {
                    final checked = d.actualQuantity != null;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            checked ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 20,
                            color: checked ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 12),
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
                                    color: checked ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurface,
                                    decoration: checked ? TextDecoration.lineThrough : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (d.trackingMethod != 0)
                                  Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getTrackingLabel(d.trackingMethod),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                                          ),
                                        ),
                                        if ((d.trackingMethod == 1 || d.trackingMethod == 3) && d.batchNumber != null && d.batchNumber!.isNotEmpty)
                                          Text('Lô: ${d.batchNumber}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                        if ((d.trackingMethod == 2 || d.trackingMethod == 3) && d.serialNumber != null && d.serialNumber!.isNotEmpty)
                                          Text('Serial: ${d.serialNumber}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'SL: ${d.systemQuantity}',
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: isDone
                        ? OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xff0f5132)),
                              foregroundColor: Theme.of(context).colorScheme.tertiary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              provider.setActiveLocationGroup(details);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep2Screen()));
                            },
                            icon: Icon(Icons.edit, size: 16),
                            label: Text('Kiểm tra lại', style: TextStyle(fontSize: 14)),
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                            onPressed: () {
                              provider.setActiveLocationGroup(details);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep2Screen()));
                            },
                            icon: Icon(Icons.qr_code_scanner, size: 16),
                            label: Text('Bắt đầu kiểm tại đây', style: TextStyle(fontSize: 14)),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'Smart Stock',
        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bước 1/5: Chọn Vị trí Kệ',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          'Đến từng vị trí kệ và bấm để bắt đầu kiểm đếm sản phẩm tại đó',
          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(4)),
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
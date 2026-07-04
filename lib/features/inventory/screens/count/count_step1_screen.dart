import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step2_screen.dart';
import '../../providers/inventory_provider.dart';
import '../../models/storage_location.dart';

class CountStep1Screen extends StatefulWidget {
  const CountStep1Screen({Key? key}) : super(key: key);

  @override
  State<CountStep1Screen> createState() => _CountStep1ScreenState();
}

class _CountStep1ScreenState extends State<CountStep1Screen> {
  String? _selectedZone;
  String? _selectedRack;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InventoryProvider>();
      if (provider.locations.isEmpty) {
        provider.loadWarehouses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.locations.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final session = provider.selectedSession ?? provider.sessions.firstWhere((s) => s.id == provider.activeSessionId);
          
          // Filter locations by session's warehouse
          final warehouseLocations = provider.locations.where((l) => l.warehouseId == session.warehouseId).toList();
          
          // Get unique zones
          final zones = warehouseLocations.map((l) => l.zone).toSet().toList()..sort();
          if (_selectedZone == null && zones.isNotEmpty) {
            _selectedZone = zones.first;
          }

          // Get racks for selected zone
          final racksInZone = warehouseLocations
              .where((l) => l.zone == _selectedZone)
              .map((l) => l.rack)
              .toSet()
              .toList()..sort();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressHeader(),
                const SizedBox(height: 32),
                _buildZonesSelection(zones),
                const SizedBox(height: 32),
                if (_selectedZone != null) _buildAislesSelection(racksInZone),
                const SizedBox(height: 32),
                _buildActionArea(context),
              ],
            ),
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
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
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
          icon: const Icon(Icons.account_circle, color: AppColors.onSurfaceVariant),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        const Text(
          'Bước 1/5: Chọn Vị trí',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Chọn khu vực và dãy kệ cụ thể để bắt đầu kiểm kê',
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
            widthFactor: 0.2, // 1/5
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

  Widget _buildZonesSelection(List<String> zones) {
    if (zones.isEmpty) {
      return const Text('Không có khu vực nào trong kho này.', style: TextStyle(color: AppColors.onSurfaceVariant));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Khu vực Kho', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
        const SizedBox(height: 16),
        ...zones.map((zone) {
          bool isSelected = _selectedZone == zone;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedZone = zone;
                  _selectedRack = null;
                });
              },
              child: _buildZoneCard(zone, 'Khu $zone', '', isSelected),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildZoneCard(String id, String title, String subtitle, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceContainerLow : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceVariant, width: isSelected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer : AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              id.isNotEmpty ? id[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.check_circle : Icons.chevron_right,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildAislesSelection(List<String> racks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Các Dãy kệ trong Khu $_selectedZone', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: racks.length,
          itemBuilder: (context, index) {
            String rack = racks[index];
            bool isSelected = _selectedRack == rack;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRack = rack;
                });
              },
              child: _buildAisleCard(rack, isSelected ? 'Đã chọn' : 'Chờ kiểm tra', isSelected),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAisleCard(String title, String status, bool inProgress) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: inProgress ? AppColors.surfaceContainerLow : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: inProgress ? AppColors.primary : AppColors.surfaceVariant),
      ),
      child: Stack(
        children: [
          if (inProgress)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: Container(color: AppColors.primary),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    Icon(inProgress ? Icons.check_circle : Icons.shelves, color: inProgress ? AppColors.primary : AppColors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 8),
                Text(status, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: inProgress ? AppColors.primary : AppColors.secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context) {
    bool canProceed = _selectedRack != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canProceed ? AppColors.primary : AppColors.surfaceVariant,
            foregroundColor: canProceed ? Colors.white : AppColors.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: canProceed ? 4 : 0,
          ),
          onPressed: canProceed ? () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep2Screen()));
          } : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Tiếp tục Kiểm đếm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ],
    );
  }
}

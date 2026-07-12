import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storage_location_provider.dart';
import 'storage_location_detail_screen.dart';

class WarehouseMapScreen extends StatefulWidget {
  final int? initialWarehouseId;
  final bool isReadOnly;

  const WarehouseMapScreen({super.key, this.initialWarehouseId, this.isReadOnly = false});

  @override
  State<WarehouseMapScreen> createState() => _WarehouseMapScreenState();
}

class _WarehouseMapScreenState extends State<WarehouseMapScreen> {
  int? _selectedWarehouseId;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _selectedWarehouseId = widget.initialWarehouseId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<StorageLocationProvider>();
      
      // Load warehouses if not loaded
      if (provider.activeWarehouses.isEmpty) {
        await provider.loadActiveWarehouses();
      }

      // If no initial warehouse, pick the first one
      if (_selectedWarehouseId == null && provider.activeWarehouses.isNotEmpty) {
        _selectedWarehouseId = provider.activeWarehouses.first['warehouseID'] as int?;
      }

      if (_selectedWarehouseId != null) {
        provider.loadMapLocations(_selectedWarehouseId!);
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final Matrix4 current = _transformationController.value;
    final Matrix4 next = current.clone()..scale(1.2, 1.2, 1.0);
    _transformationController.value = next;
  }

  void _zoomOut() {
    final Matrix4 current = _transformationController.value;
    final Matrix4 next = current.clone()..scale(0.8, 0.8, 1.0);
    _transformationController.value = next;
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
  }

  // Parse location code formatted as Zone-Rack-Shelf-Bin
  Map<String, dynamic> _parseLocationCode(Map<String, dynamic> rawLoc) {
    final String code = rawLoc['locationCode'] ?? '';
    final parts = code.split('-');
    
    return {
      'locationId': rawLoc['locationID'] ?? 0,
      'locationCode': code,
      'zone': parts.isNotEmpty ? parts[0].trim().toUpperCase() : 'UNKNOWN',
      'rack': parts.length > 1 ? parts[1].trim().toUpperCase() : '0',
      'shelf': parts.length > 2 ? parts[2].trim().toUpperCase() : '0',
      'bin': parts.length > 3 ? parts[3].trim().toUpperCase() : '0',
    };
  }

  void _showRackDetails(BuildContext context, String zone, String rack, List<Map<String, dynamic>> locations) {
    // Sort locations by shelf, then bin
    locations.sort((a, b) {
      int shelfCompare = (a['shelf'] as String).compareTo(b['shelf'] as String);
      if (shelfCompare != 0) return shelfCompare;
      return (a['bin'] as String).compareTo(b['bin'] as String);
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khu $zone - Dãy $rack',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                      Text(
                        'Có ${locations.length} ô lưu trữ (Bin) tại dãy này',
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: locations.length,
                  itemBuilder: (context, idx) {
                    final item = locations[idx];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.errorContainer,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          child: Icon(Icons.grid_view_rounded, size: 20),
                        ),
                        title: Text(
                          'Tầng ${item['shelf']} - Ô ${item['bin']}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          'Mã vị trí: ${item['locationCode']}',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx); // Close sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StorageLocationDetailScreen(
                                  locationId: item['locationId'] as int,
                                  isReadOnly: widget.isReadOnly,
                                ),
                              ),
                            ).then((_) {
                              if (_selectedWarehouseId != null) {
                                context.read<StorageLocationProvider>().loadMapLocations(_selectedWarehouseId!);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Xem', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorageLocationProvider>();
    final isMapLoading = provider.isMapLoading;
    final warehouses = provider.activeWarehouses;
    
    // Parse all map locations
    final List<Map<String, dynamic>> parsedLocs = provider.mapLocations.map((l) => _parseLocationCode(l)).toList();
    
    // Group locations of selected zone by Zone and Rack
    final Map<String, Map<String, List<Map<String, dynamic>>>> groupedByZoneAndRack = {};
    for (var l in parsedLocs) {
      final String zone = l['zone'] as String;
      final String rack = l['rack'] as String;
      
      if (!groupedByZoneAndRack.containsKey(zone)) {
        groupedByZoneAndRack[zone] = {};
      }
      if (!groupedByZoneAndRack[zone]!.containsKey(rack)) {
        groupedByZoneAndRack[zone]![rack] = [];
      }
      groupedByZoneAndRack[zone]![rack]!.add(l);
    }
    
    final List<String> sortedZones = groupedByZoneAndRack.keys.toList()..sort();

    // Calculate max racks count in any zone to size canvas dynamically
    int maxRacksCount = 0;
    for (var zone in groupedByZoneAndRack.keys) {
      final racksCount = groupedByZoneAndRack[zone]!.keys.length;
      if (racksCount > maxRacksCount) {
        maxRacksCount = racksCount;
      }
    }
    if (maxRacksCount < 4) maxRacksCount = 4; // minimum rows height

    final double canvasHeight = (maxRacksCount * 76.0) + 80.0;
    final double aisleHeight = canvasHeight - 80.0;

    // Build Map Columns dynamically with an Aisle track between EVERY zone column
    final List<Widget> mapColumns = [];
    
    for (int i = 0; i < sortedZones.length; i++) {
      final zone = sortedZones[i];
      final zoneRacks = groupedByZoneAndRack[zone] ?? {};
      final sortedZoneRacks = zoneRacks.keys.toList()..sort();
      
      mapColumns.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Khu $zone', 
              style: TextStyle(
                fontSize: 13, 
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87), 
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 12),
            ...sortedZoneRacks.map((rackName) {
              final locs = zoneRacks[rackName]!;
              final String fullRackName = '$zone-$rackName';
              
              Color blockColor = Theme.of(context).colorScheme.surfaceContainerLowest;
              Color blockTextColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.87);
              
              return _buildRackBlock(
                context, 
                fullRackName, 
                'Khu vực', 
                '0%', 
                0, 
                blockColor, 
                blockTextColor, 
                locs,
                isOutline: true
              );
            }).toList(),
          ],
        ),
      );
      
      if (i < sortedZones.length - 1) {
        mapColumns.add(SizedBox(width: 8));
        mapColumns.add(_buildAisle(aisleHeight));
        mapColumns.add(SizedBox(width: 8));
      }
    }

    // Dynamic width calculation for the warehouse sheet canvas to pan/zoom correctly
    final double canvasWidth = sortedZones.isEmpty
        ? 300
        : (sortedZones.length * 100) + ((sortedZones.length - 1) * 46) + 48;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bản đồ Kho',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Icon(Icons.warehouse, color: Theme.of(context).colorScheme.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedWarehouseId,
                      isExpanded: true,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87)),
                      hint: Text('Chọn nhà kho'),
                      items: warehouses.map((w) {
                        return DropdownMenuItem<int>(
                          value: w['warehouseID'] as int,
                          child: Text(w['warehouseName'] as String),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedWarehouseId = val;
                          });
                          provider.loadMapLocations(val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic Map Canvas sheet
          Positioned.fill(
            bottom: 0,
            child: InteractiveViewer(
              transformationController: _transformationController,
              constrained: false,
              minScale: 0.1, // Allow zooming out very far to see the entire warehouse sheet
              maxScale: 3.0,
              boundaryMargin: EdgeInsets.all(240), // Large boundary margin so user can pan canvas anywhere
              child: isMapLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary)))
                  : parsedLocs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
                              SizedBox(height: 12),
                              Text(
                                'Không có vị trí lưu trữ nào.',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: canvasWidth,
                          height: canvasHeight,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: mapColumns,
                          ),
                        ),
            ),
          ),

          // Floating Zoom Buttons (Top Right Overlay)
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                _buildZoomButton(Icons.add, _zoomIn),
                SizedBox(height: 8),
                _buildZoomButton(Icons.remove, _zoomOut),
                SizedBox(height: 12),
                _buildZoomButton(Icons.my_location, _resetView),
              ],
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildRackBlock(
    BuildContext context, 
    String id, 
    String category, 
    String capText, 
    int capVal, 
    Color color, 
    Color textColor, 
    List<Map<String, dynamic>> locations,
    {bool isOutline = false}
  ) {
    return GestureDetector(
      onTap: () => _showRackDetails(context, id.split('-')[0], id.split('-')[1], locations),
      child: Container(
        width: 70,
        height: 64,
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: isOutline ? Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4), width: 1.5) : null,
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12), blurRadius: 2, offset: Offset(0, 1.5))
          ],
        ),
        child: Center(
          child: Text(
            id,
            style: TextStyle(
              color: textColor, 
              fontWeight: FontWeight.bold, 
              fontSize: 13
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAisle(double height) {
    return SizedBox(
      width: 30,
      height: height,
      child: Center(
        child: Container(
          width: 12,
          height: height > 40 ? height - 40 : height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) => Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12), shape: BoxShape.circle),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

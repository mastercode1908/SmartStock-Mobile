import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'inventory_detail_screen.dart';
import '../providers/inventory_provider.dart';
import '../models/product_variant.dart';

class ChooseProductScreen extends StatefulWidget {
  final bool returnSelectedIds;
  final Set<int>? restrictToVariantIds;
  const ChooseProductScreen({Key? key, this.returnSelectedIds = false, this.restrictToVariantIds}) : super(key: key);

  @override
  _ChooseProductScreenState createState() => _ChooseProductScreenState();
}

class _ChooseProductScreenState extends State<ChooseProductScreen> {
  final Color _primary = const Color(0xFFB3272E);
  final Color _primaryContainer = const Color(0xFFFF5F5F);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _surfaceContainerLow = const Color(0xFFEAF5FA);
  final Color _surfaceContainerHighest = const Color(0xFFD9E4E9);
  final Color _onSurface = const Color(0xFF131D21);
  final Color _onSurfaceVariant = const Color(0xFF59413F);
  final Color _outlineVariant = const Color(0xFFE1BEBC);
  final Color _secondary = const Color(0xFF586062);
  final Color _secondaryContainer = const Color(0xFFDAE1E3);
  final Color _background = const Color(0xFFF1FBFF);

  String _searchQuery = '';
  int _selectedTrackingMethod = -1; // -1: All, 0: None, 1: Lot, 2: Serial


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadProductVariants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 16),
            _buildProductList(),
            const SizedBox(height: 80), // Padding for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Chọn Sản phẩm',
        style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.inventory_2, color: _primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.search, color: _onSurfaceVariant.withOpacity(0.5), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm tên, SKU...',
                hintStyle: TextStyle(color: _onSurfaceVariant.withOpacity(0.5), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Tất cả', -1),
          const SizedBox(width: 8),
          _buildChip('Không theo dõi', 0),
          const SizedBox(width: 8),
          _buildChip('Batch/Lot', 1),
          const SizedBox(width: 8),
          _buildChip('Serial', 2),
        ],
      ),
    );
  }

  Widget _buildChip(String label, int trackingMethod) {
    bool isSelected = _selectedTrackingMethod == trackingMethod;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTrackingMethod = trackingMethod;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _primary : _surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : _onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.productVariants.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        var filteredVariants = provider.productVariants.where((v) {
          if (widget.restrictToVariantIds != null && !widget.restrictToVariantIds!.contains(v.variantId)) {
            return false;
          }
          bool matchesSearch = true;
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            matchesSearch = v.productName.toLowerCase().contains(query) ||
                v.sku.toLowerCase().contains(query);
          }
          bool matchesTracking = true;
          if (_selectedTrackingMethod != -1) {
            matchesTracking = v.trackingMethod == _selectedTrackingMethod;
          }
          return matchesSearch && matchesTracking;
        }).toList();

        if (filteredVariants.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Không có sản phẩm nào phù hợp.'),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredVariants.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final variant = filteredVariants[index];
            final isChecked = provider.selectedVariants.any((v) => v.variantId == variant.variantId);
            
            String trackingStr = 'NONE';
            if (variant.trackingMethod == 1) trackingStr = 'LOT';
            if (variant.trackingMethod == 2) trackingStr = 'SERIAL';
            if (variant.trackingMethod == 3) trackingStr = 'LOT_SERIAL';

            return _buildProductCard(
              variant: variant,
              tracking: trackingStr,
              isChecked: isChecked,
              onToggle: () => provider.toggleVariantSelection(variant),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard({
    required ProductVariant variant,
    required String tracking,
    required bool isChecked,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _surfaceContainerHighest.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: variant.imageUrl.isNotEmpty 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(variant.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.inventory_2, color: _primaryContainer),
                    )
                  )
                : Icon(Icons.inventory_2, color: _primaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.variantName.isNotEmpty ? variant.variantName : variant.productName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _onSurface),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('SKU: ${variant.sku}', style: TextStyle(fontSize: 11, color: _onSurfaceVariant)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _secondaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(variant.baseUnitSymbol, style: TextStyle(fontSize: 11, color: _onSurfaceVariant)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tracking.toUpperCase(), style: TextStyle(fontSize: 11, color: _secondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _surfaceContainerLow,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _outlineVariant.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Text('Barcode: ', style: TextStyle(fontSize: 11, color: _onSurfaceVariant.withOpacity(0.7))),
                            Text(variant.barcode, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF91081A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isChecked,
              onChanged: (val) => onToggle(),
              activeColor: _primaryContainer,
              shape: const CircleBorder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -4)),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: _onSurfaceVariant),
                  label: Text('Hủy', style: TextStyle(color: _onSurfaceVariant, fontSize: 16)),
                  style: TextButton.styleFrom(
                    backgroundColor: _surfaceContainerLow,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (provider.selectedVariants.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 sản phẩm')),
                      );
                      return;
                    }
                    if (widget.returnSelectedIds) {
                      Navigator.pop(context, provider.selectedVariants);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InventoryDetailScreen()),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: Text('Xác nhận chọn (${provider.selectedVariants.length})', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

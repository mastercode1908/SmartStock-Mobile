import 'package:flutter/material.dart';

class ChooseProductScreen extends StatefulWidget {
  const ChooseProductScreen({Key? key}) : super(key: key);

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
    return Row(
      children: [
        Expanded(
          child: Container(
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
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _outlineVariant.withOpacity(0.5)),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.tune, color: _onSurfaceVariant, size: 20),
            onPressed: () {},
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
          _buildChip('Tất cả', true),
          const SizedBox(width: 8),
          _buildChip('Kệ A1', false),
          const SizedBox(width: 8),
          _buildChip('Kệ B2', false),
          const SizedBox(width: 8),
          _buildChip('S/N Tracking', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
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
    );
  }

  Widget _buildProductList() {
    return Column(
      children: [
        _buildProductCard('Laptop Dell XPS 15', 'DEL-XPS-15', 'Kệ A1', 'S/N Tracking', 1, true),
        const SizedBox(height: 8),
        _buildProductCard('Màn hình LG 27UL850', 'LG-27UL', 'Kệ B2', 'Lot Tracking', 1, true),
        const SizedBox(height: 8),
        _buildProductCard('Bàn phím cơ Keychron K2', 'KCH-K2V2', 'Kệ C3', 'No Tracking', 0, false),
        const SizedBox(height: 8),
        _buildProductCard('Chuột Logitech MX Master 3', 'LOG-MX3', 'Kệ A2', 'S/N Tracking', 0, false),
      ],
    );
  }

  Widget _buildProductCard(String title, String sku, String shelf, String tracking, int qty, bool isChecked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurface),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('SKU: $sku', style: TextStyle(fontSize: 11, color: _onSurfaceVariant)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(shelf, style: TextStyle(fontSize: 11, color: _onSurfaceVariant)),
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
                          Text('Thực tế: ', style: TextStyle(fontSize: 11, color: _onSurfaceVariant.withOpacity(0.7))),
                          Text('$qty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF91081A))),
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
            onChanged: (val) {},
            activeColor: _primaryContainer,
            shape: const CircleBorder(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
              onPressed: () {},
              icon: const Icon(Icons.check_circle),
              label: const Text('Xác nhận chọn (2)', style: TextStyle(fontSize: 16)),
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
}

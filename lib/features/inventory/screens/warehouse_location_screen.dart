import 'package:flutter/material.dart';
import 'warehouse_map_screen.dart';

class WarehouseLocationScreen extends StatelessWidget {
  const WarehouseLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb3272e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vị trí kho',
          style: TextStyle(
            color: Color(0xffb3272e),
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2, color: Color(0xffb3272e)),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 140, // Space for fixed footer
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Search Section
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm SKU, Khu vực,...',
                              hintStyle: TextStyle(color: Colors.black38),
                              prefixIcon: Icon(Icons.search, color: Colors.black38),
                              suffixIcon: Icon(Icons.qr_code_scanner, color: Colors.black54),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.tune, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tất cả khu vực', true),
                        _buildFilterChip('Nhu cầu cao', false),
                        _buildFilterChip('Kho lạnh', false),
                        _buildFilterChip('Hàng dễ vỡ', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Breadcrumb
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.warehouse, size: 16, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Kho Alpha', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        Icon(Icons.chevron_right, size: 16, color: Colors.black54),
                        Text('Tầng 1', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        Icon(Icons.chevron_right, size: 16, color: Colors.black54),
                        Text('Khu vực A', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hierarchical Navigation Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.5,
                        children: [
                          _buildZoneCard(
                            'Dãy A-10',
                            'Điện tử',
                            Icons.category,
                            'ĐẦY 85%',
                            const Color(0xff006a67),
                            const Color(0xff00a7a3).withOpacity(0.2),
                            4,
                          ),
                          _buildZoneCard(
                            'Dãy A-11',
                            'Linh kiện',
                            Icons.category,
                            'ĐẦY 98%',
                            const Color(0xff93000a),
                            const Color(0xffffdad6),
                            3,
                            hasWarning: true,
                          ),
                          _buildZoneCard(
                            'Dãy A-12',
                            'Tủ mát',
                            Icons.ac_unit,
                            'ĐẦY 40%',
                            const Color(0xff59413f),
                            const Color(0xffd9e4e9),
                            2,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Fixed Bottom Footer
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb3272e),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Quét vị trí', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WarehouseMapScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xffb3272e),
                        side: const BorderSide(color: Color(0xffb3272e)),
                        backgroundColor: const Color(0xfff1fbff),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.map),
                      label: const Text('Xem bản đồ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffff5f5f).withOpacity(0.1) : const Color(0xffe4f0f4),
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? Border.all(color: const Color(0xffff5f5f).withOpacity(0.2)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xffff5f5f) : Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildZoneCard(
    String title,
    String subtitle,
    IconData icon,
    String capacity,
    Color capacityColor,
    Color capacityBg,
    int itemCount, {
    bool hasWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xffe4f0f4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: const Color(0xffb3272e), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: capacityBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (hasWarning) ...[
                      Icon(Icons.warning, color: capacityColor, size: 12),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      capacity,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: capacityColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 3.5,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                itemCount,
                (index) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xfff1fbff),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thùng ${(index * 5 + 1).toString().padLeft(2, '0')}-${((index + 1) * 5).toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const Icon(Icons.chevron_right, size: 14, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

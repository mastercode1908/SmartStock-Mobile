import 'package:flutter/material.dart';
import '../../scanner/screens/scan_screen.dart';
import 'product_detail_screen.dart';
// import '../scanner/screens/scan_screen.dart'; // To link scan bottom nav

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final int _selectedIndex = 1; // "Kiểm kê" is active

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Samsung 980 Pro 1TB',
      'sku': 'SSD-SAM-980P',
      'quantity': '120 cái',
      'location': 'Kệ A-12',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuD0ruiX73lMyBaULCD4ldYD9hniAje4g0jpla3hMrLpNaTvX2ZBvfxK0zOID6rRmKezeu_n7XHiyeVgoR7cAmGNCeEHHS4-o7BSBht74e49uqhR54wtCUBmtkLf0jd4MvKvO_0tMxWruGCQBkvBxwSjXw1h_2SZpsby-Q8xwCvu4fPGbIHuLsoX8UYRplt0McSG3OFfMyICTy2oPLOh49ZdJx60fzKFZFLddSQU-iNrGiu2jEn72fEnHWcx0gteC5N-AdO8Og9DfA4X',
    },
    {
      'name': 'Apple Watch Series 8',
      'sku': 'AW-S8-45MM',
      'quantity': '15 cái',
      'location': 'Tủ B-04',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAqlo53hwuAtDsg0hgxT95f7yH4x1302FC3BCyW2CYEa1lZ4yH0Fd3ODj5C2qLmEtCIyVIwlkpgv-PRRLVc_0O20ZAzlUHvhMKAVa64CP1Vp9W50XvvYD645J58OHTcGwndf6_NN9A7uhc-Rrj9j5oH-GxU_o2u41IlFpEvPht6ydtHHtX5BNtQAskHH0DXi33Lw8Kh-cRNQBfJUQJhq-HZU7Xg_WL12DDaaEyHD0zHC6UV4gV7ftD0ajkCCbAeGYQ-hTmOwOoOeynR',
      'warning': true,
    },
    {
      'name': 'Dây đồng 2mm (Cuộn)',
      'sku': 'WIR-CU-2MM',
      'quantity': '45 cuộn',
      'location': 'Kho Phụ',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDr6aNT4sWUXszitowJZ7fbKiG0P3eFBQlINMa2w6IEFHNKYGwEfx8RDsJlAicsvGafUyw6ObU0SdOgB6LkfB92-EP2odqyCDA4crw1W6msTlL9roL9QpJ7vg1DfA9kfZWxSopBjrTXhd8Coctmb90KNORtc_nlY2UWz6je4-SojChmWW86A3D1A8HJLSmtbP3fIAePSvfeV4yca_QY93UIHnbrzd0D11kRkhVpU15TrfgARgi7TAUKRN7iy-rjaPcDeQFz9BVVdvQi',
    },
    {
      'name': 'Sony WH-1000XM5',
      'sku': 'AUD-SON-XM5',
      'quantity': '32 cái',
      'location': 'Kệ C-01',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtqANgG2ufv3VcrdwlXZ51TeugVI3TFzsno9tJApzwmNsm-Athp0a8Cc-O0i6-lorDkgx2iT2s1-grfISgb7Yzy8R7cCDEAQVL4VkvTckzIUIx7skGB87jA3z4_gW3QHjLC26gQG8BZKpdODM8qqgegkNMNf2K5WMwHWd6dGwfhodSKcvxFtYewUrFZ4LrBGjjbjaMAp3OgZLzZC6FFe3QNF3ZzY-sU60BEAV2yvQ-KYDp40UhzYIhnrZxGvT4L674hdotMs61bDJM',
    },
  ];

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bộ lọc',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFilterSection('Sắp xếp theo', ['Tên', 'Số lượng', 'Vị trí'], 0),
              const SizedBox(height: 24),
              _buildFilterSection('Phương thức theo dõi', ['Số lượng', 'Lô hàng', 'Serial'], -1),
              const SizedBox(height: 24),
              _buildFilterSection('Trạng thái kho', ['Còn hàng', 'Sắp hết', 'Hết hàng'], -1),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Đặt lại', style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb02528),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Áp dụng', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(String title, List<String> options, int selectedIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(options.length, (index) {
            final isSelected = index == selectedIndex;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xffd23e3e) : const Color(0xffe8e8e8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                options[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
        title: Row(
          children: const [
            Icon(Icons.inventory_2, color: Color(0xffb02528)),
            SizedBox(width: 8),
            Text(
              'Smart Stock',
              style: TextStyle(
                color: Color(0xffb02528),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xffb02528)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm, SKU...',
                          hintStyle: TextStyle(color: Colors.black38),
                          prefixIcon: Icon(Icons.search, color: Colors.black38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showFilterModal(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip('Tất cả', isSelected: true),
                    const SizedBox(width: 8),
                    _buildChip('Điện tử'),
                    const SizedBox(width: 8),
                    _buildChip('Linh kiện'),
                    const SizedBox(width: 8),
                    _buildChip('Gia dụng'),
                    const SizedBox(width: 8),
                    _buildChip('Phụ kiện'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Product List
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _buildProductCard(product, context);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffd23e3e).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? const Color(0xffd23e3e).withOpacity(0.2) : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xffd23e3e) : Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductDetailScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['image'],
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product['sku'],
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        product['warning'] == true ? Icons.warning : Icons.inventory,
                        size: 14,
                        color: product['warning'] == true ? const Color(0xffd23e3e) : Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product['quantity'],
                        style: TextStyle(
                          fontSize: 12,
                          color: product['warning'] == true ? const Color(0xffb02528) : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xffd7e4ec),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product['location'],
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff5a666d),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LÔ HÀNG',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.more_vert, color: Color(0xffb02528), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
        left: 8,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Trang chủ', 0),
          _buildNavItem(Icons.inventory_2, 'Kiểm kê', 1),
          _buildNavItem(Icons.qr_code_scanner, 'Scan', 2, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanScreen()));
          }),
          _buildNavItem(Icons.history, 'Lịch sử', 3),
          _buildNavItem(Icons.person, 'Cá nhân', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {VoidCallback? onTap}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xffb02528),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

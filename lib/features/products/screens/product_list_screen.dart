import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import '../../scanner/screens/scan_screen.dart';
import '../../inventory/screens/inventory_list_screen.dart';
import '../../inventory/screens/inventory_history_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../home/screens/employee_dashboard_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // Styling colors matching mockups
  Color get _primary => Theme.of(context).colorScheme.primary;
  Color get _primaryContainer => Theme.of(context).colorScheme.primaryContainer;
  Color get _surface => Theme.of(context).cardColor;

  int? _tempCategoryId;
  int? _tempBrandId;
  int? _tempTrackingMethod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.clearFilters();
      provider.loadMetadata();
      provider.loadProducts(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String query) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.setSearchQuery(query.trim().isEmpty ? null : query.trim());
    provider.loadProducts(isRefresh: true);
  }

  void _applyCategoryFilter(int? categoryId) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.setFilters(
      categoryId: categoryId,
      brandId: provider.selectedBrandId,
      trackingMethod: provider.selectedTrackingMethod,
    );
    provider.loadProducts(isRefresh: true);
  }

  void _showFilterModal(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    _tempCategoryId = provider.selectedCategoryId;
    _tempBrandId = provider.selectedBrandId;
    _tempTrackingMethod = provider.selectedTrackingMethod;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bộ lọc sản phẩm',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tracking Method Filter
                    const Text(
                      'Phương thức theo dõi',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterOption(
                          'Tất cả',
                          _tempTrackingMethod == null,
                          () => setModalState(() => _tempTrackingMethod = null),
                        ),
                        _buildFilterOption(
                          'Không theo dõi (NONE)',
                          _tempTrackingMethod == 0,
                          () => setModalState(() => _tempTrackingMethod = 0),
                        ),
                        _buildFilterOption(
                          'Lô hàng (BATCH)',
                          _tempTrackingMethod == 1,
                          () => setModalState(() => _tempTrackingMethod = 1),
                        ),
                        _buildFilterOption(
                          'Số Serial (SERIAL)',
                          _tempTrackingMethod == 2,
                          () => setModalState(() => _tempTrackingMethod = 2),
                        ),
                        _buildFilterOption(
                          'Lô & Serial',
                          _tempTrackingMethod == 3,
                          () => setModalState(() => _tempTrackingMethod = 3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Category Filter Dropdown
                    const Text(
                      'Danh mục',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _tempCategoryId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      hint: const Text('Tất cả danh mục'),
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('Tất cả danh mục')),
                        ...provider.categories.map((cat) => DropdownMenuItem<int>(
                              value: cat.categoryId,
                              child: Text(cat.categoryName),
                            )),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          _tempCategoryId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Brand Filter Dropdown
                    const Text(
                      'Thương hiệu',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _tempBrandId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      hint: const Text('Tất cả thương hiệu'),
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('Tất cả thương hiệu')),
                        ...provider.brands.map((br) => DropdownMenuItem<int>(
                              value: br.brandId,
                              child: Text(br.brandName),
                            )),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          _tempBrandId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _tempCategoryId = null;
                                _tempBrandId = null;
                                _tempTrackingMethod = null;
                              });
                            },
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
                            onPressed: () {
                              provider.setFilters(
                                categoryId: _tempCategoryId,
                                brandId: _tempBrandId,
                                trackingMethod: _tempTrackingMethod,
                              );
                              provider.loadProducts(isRefresh: true);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryContainer.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _primary : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        actions: const [],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.loadProducts(isRefresh: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search and Filter Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _onSearchSubmit,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm sản phẩm, SKU...',
                              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                              prefixIcon: const Icon(Icons.search, color: Colors.black38),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.black38),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchSubmit('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                          child: Icon(
                            Icons.tune,
                            color: (provider.selectedBrandId != null ||
                                    provider.selectedTrackingMethod != null)
                                ? _primary
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Chips horizontal scroll
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.categories.length + 1,
                      itemBuilder: (context, idx) {
                        if (idx == 0) {
                          final isSelected = provider.selectedCategoryId == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildChip(
                              'Tất cả',
                              isSelected: isSelected,
                              onTap: () => _applyCategoryFilter(null),
                            ),
                          );
                        }

                        final cat = provider.categories[idx - 1];
                        final isSelected = provider.selectedCategoryId == cat.categoryId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildChip(
                            cat.categoryName,
                            isSelected: isSelected,
                            onTap: () => _applyCategoryFilter(cat.categoryId),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Product List
                Expanded(
                  child: provider.isLoading && provider.products.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : provider.products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  const Text('Không tìm thấy sản phẩm nào', style: TextStyle(color: Colors.black54)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.products.length,
                              itemBuilder: (context, index) {
                                final product = provider.products[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildParentProductCard(product),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildChip(String label, {required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _primaryContainer.withValues(alpha: 0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _primaryContainer.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? _primary : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParentProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          shape: const Border(),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          collapsedBackgroundColor: Theme.of(context).cardColor,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[100],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[100],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          title: Text(
            product.productName,
<<<<<<< HEAD
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
=======
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
>>>>>>> main
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    product.category?.categoryName ?? 'Chưa phân loại',
                    style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                  if (product.brand != null) ...[
                    const SizedBox(width: 6),
                    const Text('•', style: TextStyle(color: Colors.black26)),
                    const SizedBox(width: 6),
                    Text(
                      product.brand!.brandName,
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.scale_outlined, size: 14, color: Colors.black45),
                  const SizedBox(width: 4),
                  Text(
                    product.baseUnit != null
                        ? '${product.baseUnit!.unitName} (${product.baseUnit!.symbol})'
                        : 'ĐVT: Chưa có',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(product.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildTrackingBadge(product.trackingMethod),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${product.productVariants.length} biến thể',
                      style: TextStyle(fontSize: 11, color: _primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.expand_more, color: Colors.black45),
          children: [
            Container(color: Colors.grey[50], height: 1),
            if (product.productVariants.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sản phẩm chưa có biến thể',
                  style: TextStyle(color: Colors.black38, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: product.productVariants.length,
                separatorBuilder: (context, idx) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, idx) {
                  final variant = product.productVariants[idx];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      variant.variantName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${variant.sku}',
                          style: const TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'JetBrains Mono'),
                        ),
                        if (variant.barcode.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Barcode: ${variant.barcode}',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currencyFormat.format(variant.costPrice),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          variant.status == 1 ? 'ĐANG BÁN' : 'NGƯNG BÁN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: variant.status == 1 ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _navigateToDetails(product.productId),
                  );
                },
              ),
            Container(
              color: Colors.grey[100],
              child: ListTile(
                title: const Text(
                  'Xem chi tiết sản phẩm',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                onTap: () => _navigateToDetails(product.productId),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(int productId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
    if (result == true) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts(isRefresh: true);
    }
  }

  Widget _buildTrackingBadge(int trackingMethod) {
    String label = 'Không theo dõi';
    Color color = Colors.grey[600]!;
    Color bg = Colors.grey[100]!;

    if (trackingMethod == 1) {
      label = 'LÔ HÀNG';
      color = Colors.green[800]!;
      bg = Colors.green[100]!;
    } else if (trackingMethod == 2) {
      label = 'SERIAL';
      color = const Color(0xff006a67);
      bg = const Color(0xff00a7a3).withOpacity(0.1);
    } else if (trackingMethod == 3) {
      label = 'LÔ & SERIAL';
      color = Colors.purple[800]!;
      bg = Colors.purple[100]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    String label = 'Đang kinh doanh';
    Color color = Colors.green[800]!;
    Color bg = Colors.green[50]!;
    
    if (status == 0) {
      label = 'Nháp';
      color = Colors.orange[800]!;
      bg = Colors.orange[50]!;
    } else if (status == 2) {
      label = 'Ngừng kinh doanh';
      color = Colors.red[800]!;
      bg = Colors.red[50]!;
    } else if (status == 3) {
      label = 'Không sản xuất';
      color = Colors.grey[800]!;
      bg = Colors.grey[200]!;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      selectedItemColor: const Color(0xFF546067),
      unselectedItemColor: const Color(0xFF546067),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, a1, a2) => const InventoryListScreen(), 
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, a1, a2) => const ScanScreen(), 
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, a1, a2) => const InventoryHistoryScreen(), 
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, a1, a2) => const ProfileScreen(), 
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Kiểm kê'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'Lịch sử'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
      ],
    );
  }
}

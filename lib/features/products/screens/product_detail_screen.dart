import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../models/unit.dart';
import '../models/product_unit.dart';
import 'product_create_screen.dart';
import 'variant_create_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // Colors matching tailwind design
  final Color _primary = const Color(0xFFB3272E);
  final Color _surfaceContainer = const Color(0xFFE4F0F4);
  final Color _surfaceVariant = const Color(0xFFD9E4E9);
  final Color _primaryContainer = const Color(0xFFFF5F5F);
  final Color _onSurfaceVariant = const Color(0xFF59413F);
  final Color _tertiaryContainer = const Color(0xFF00A7A3);
  final Color _tertiaryColor = const Color(0xFF006A67);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProductDetails(widget.productId);
    });
  }

  Future<void> _deleteProductConfirm(Product product) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.productName}" và tất cả biến thể của nó không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await provider.deleteProduct(product.productId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa sản phẩm thành công!')),
        );
        Navigator.pop(context, true);
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Không thể xóa'),
            content: Text(provider.error ?? 'Đã xảy ra lỗi khi xóa sản phẩm.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng'))
            ],
          ),
        );
      }
    }
  }

  Future<void> _deleteVariantConfirm(ProductVariant variant) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa biến thể'),
        content: Text('Bạn có chắc chắn muốn xóa biến thể "${variant.variantName}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await provider.deleteVariant(variant.variantId, widget.productId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa biến thể thành công!')),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Không thể xóa'),
            content: Text(provider.error ?? 'Đã xảy ra lỗi khi xóa biến thể.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng'))
            ],
          ),
        );
      }
    }
  }

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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết Sản phẩm',
          style: TextStyle(
            color: Color(0xffb3272e),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xffb3272e)),
            onPressed: () {
              final product = Provider.of<ProductProvider>(context, listen: false).selectedProduct;
              if (product != null) _deleteProductConfirm(product);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedProduct == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = provider.selectedProduct;
          if (product == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin sản phẩm hoặc đã bị xóa.'),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 100, // Space for action bar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Hero Image & Summary
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: _surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.image, size: 48, color: Colors.grey),
                                    )
                                  : const Icon(Icons.image, size: 48, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _primaryContainer.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _primaryContainer.withOpacity(0.2)),
                                ),
                                child: Text(
                                  'MÃ SP: ${product.productId}',
                                  style: TextStyle(
                                    color: _primaryContainer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _surfaceVariant,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  product.category?.categoryName ?? 'Chưa phân loại',
                                  style: TextStyle(
                                    color: _onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.productName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff131d21),
                            ),
                          ),
                          if (product.brand != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Thương hiệu: ${product.brand!.brandName} (${product.brand!.country})',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Inventory Stats Bento Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Total Variants Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(Icons.widgets_outlined, size: 18, color: Colors.black54),
                                          SizedBox(width: 8),
                                          Text('BIẾN THỂ',
                                              style: TextStyle(
                                                  fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            product.productVariants.length.toString(),
                                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text('loại', style: TextStyle(color: Colors.black54, fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Base Unit Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(Icons.scale, size: 18, color: Colors.black54),
                                          SizedBox(width: 8),
                                          Text('ĐƠN VỊ CƠ BẢN',
                                              style: TextStyle(
                                                  fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        product.baseUnit != null
                                            ? '${product.baseUnit!.unitName} (${product.baseUnit!.symbol})'
                                            : 'Không rõ',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Status & Tracking Method
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _tertiaryContainer.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _tertiaryContainer.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: _tertiaryContainer, size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('PHƯƠNG THỨC THEO DÕI',
                                                style: TextStyle(
                                                    fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 2),
                                            Text(
                                              _getTrackingMethodLabel(product.trackingMethod),
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Text(
                                    _getStatusLabel(product.status),
                                    style: TextStyle(color: _tertiaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    if (product.description.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mô tả sản phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Text(
                                product.description,
                                style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Variants Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Danh sách biến thể', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VariantCreateScreen(
                                  productId: product.productId,
                                  baseUnit: product.baseUnit,
                                ),
                                    ),
                                  );
                                  if (result == true) {
                                    provider.loadProductDetails(widget.productId);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Thêm biến thể', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (product.productVariants.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Sản phẩm chưa có biến thể nào.\nVui lòng bấm nút Thêm biến thể phía trên.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: product.productVariants.length,
                              separatorBuilder: (context, idx) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final variant = product.productVariants[idx];
                                return VariantItemCard(
                                  variant: variant,
                                  productId: product.productId,
                                  baseUnit: product.baseUnit,
                                  onDelete: () => _deleteVariantConfirm(variant),
                                  onRefresh: () => provider.loadProductDetails(widget.productId),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed Action Bar
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
                    color: Colors.white.withOpacity(0.95),
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 32, offset: const Offset(0, -12)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductCreateScreen(product: product),
                              ),
                            );
                            if (result == true) {
                              provider.loadProductDetails(widget.productId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffdfeaef),
                            foregroundColor: _primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Sửa sản phẩm cha', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VariantCreateScreen(productId: product.productId),
                              ),
                            );
                            if (result == true) {
                              provider.loadProductDetails(widget.productId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm biến thể', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getTrackingMethodLabel(int method) {
    switch (method) {
      case 1:
        return 'Theo dõi theo Lô (BATCH)';
      case 2:
        return 'Theo dõi theo Serial (SERIAL)';
      default:
        return 'Không theo dõi (NONE)';
    }
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 0:
        return 'Nháp';
      case 2:
        return 'Ngưng hoạt động';
      case 3:
        return 'Không sản xuất';
      default:
        return 'Đang hoạt động';
    }
  }
}

class VariantItemCard extends StatefulWidget {
  final ProductVariant variant;
  final int productId;
  final Unit? baseUnit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const VariantItemCard({
    super.key,
    required this.variant,
    required this.productId,
    this.baseUnit,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<VariantItemCard> createState() => _VariantItemCardState();
}

class _VariantItemCardState extends State<VariantItemCard> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  final Color _primary = const Color(0xFFB3272E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .loadVariantUnits(widget.variant.variantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final List<ProductUnit> variantUnits = provider.getVariantUnits(widget.variant.variantId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.variant.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.variant.imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 52,
                          height: 52,
                          color: Colors.grey[100],
                          child: const Icon(Icons.widgets, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 52,
                        height: 52,
                        color: Colors.grey[100],
                        child: const Icon(Icons.widgets, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.variant.variantName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${widget.variant.sku}',
                      style: const TextStyle(fontSize: 11, color: Colors.black54, fontFamily: 'JetBrains Mono'),
                    ),
                    if (widget.variant.barcode.isNotEmpty) ...[
                      Text(
                        'Barcode: ${widget.variant.barcode}',
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Tồn tối thiểu: ${widget.variant.minimumStockLevel}',
                          style: const TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                        const Text('|', style: TextStyle(color: Colors.black26, fontSize: 10)),
                        Text(
                          'Giá: ${currencyFormat.format(widget.variant.costPrice)}',
                          style: TextStyle(fontSize: 11, color: _primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VariantCreateScreen(
                                productId: widget.productId,
                                variant: widget.variant,
                                baseUnit: widget.baseUnit,
                              ),
                            ),
                          );
                          if (result == true) {
                            widget.onRefresh();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.variant.status == 1 ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.variant.status == 1 ? 'ĐANG BÁN' : 'NGƯNG BÁN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: widget.variant.status == 1 ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Conversion Units Section
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đơn vị quy đổi:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              TextButton.icon(
                onPressed: () => _showManageUnitsBottomSheet(context, provider),
                icon: const Icon(Icons.settings, size: 14, color: Color(0xFFB3272E)),
                label: const Text(
                  'Quản lý',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB3272E), fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (variantUnits.isEmpty)
            const Text(
              'Chưa cấu hình đơn vị quy đổi',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black38),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: variantUnits.map((pu) {
                return Chip(
                  label: Text(
                    '1 ${pu.unitName} = ${pu.conversionFactor} ${widget.baseUnit?.symbol ?? widget.baseUnit?.unitName ?? ''}',
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: const Color(0xfff3f7f9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.black12),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showManageUnitsBottomSheet(BuildContext context, ProductProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final variantUnits = provider.getVariantUnits(widget.variant.variantId);
            final allUnits = provider.units;
            
            final configuredUnitIds = variantUnits.map((vu) => vu.unitId).toSet();
            final availableUnits = allUnits.where((u) {
              return u.unitId != widget.baseUnit?.unitId && !configuredUnitIds.contains(u.unitId);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quản lý Đơn vị quy đổi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    'Biến thể: ${widget.variant.variantName}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Danh sách đơn vị quy đổi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (variantUnits.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Chưa có đơn vị quy đổi nào được thiết lập.',
                          style: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: variantUnits.length,
                      itemBuilder: (ctx, index) {
                        final pu = variantUnits[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('1 ${pu.unitName} (${pu.symbol})'),
                          subtitle: Text('Hệ số quy đổi: 1 ${pu.unitName} = ${pu.conversionFactor} ${widget.baseUnit?.symbol ?? widget.baseUnit?.unitName ?? ''}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (dCtx) => AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: Text('Xóa đơn vị quy đổi ${pu.unitName}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dCtx, false),
                                      child: const Text('Hủy'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(dCtx, true),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Xóa'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final success = await provider.deleteVariantUnit(
                                  productUnitId: pu.productUnitId,
                                  variantId: widget.variant.variantId,
                                );
                                if (success) {
                                  setSheetState(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(provider.error ?? 'Lỗi khi xóa')),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  const Divider(height: 32),
                  const Text(
                    'Thêm đơn vị quy đổi mới',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (availableUnits.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Không còn đơn vị nào khả dụng để quy đổi.',
                        style: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    _AddVariantUnitForm(
                      variantId: widget.variant.variantId,
                      baseUnitSymbol: widget.baseUnit?.symbol ?? widget.baseUnit?.unitName ?? '',
                      availableUnits: availableUnits,
                      onAdd: (unitId, factor) async {
                        final success = await provider.createVariantUnit(
                          variantId: widget.variant.variantId,
                          unitId: unitId,
                          conversionFactor: factor,
                        );
                        if (success) {
                          setSheetState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error ?? 'Lỗi khi thêm')),
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AddVariantUnitForm extends StatefulWidget {
  final int variantId;
  final String baseUnitSymbol;
  final List<Unit> availableUnits;
  final Future<void> Function(int unitId, double factor) onAdd;

  const _AddVariantUnitForm({
    required this.variantId,
    required this.baseUnitSymbol,
    required this.availableUnits,
    required this.onAdd,
  });

  @override
  State<_AddVariantUnitForm> createState() => _AddVariantUnitFormState();
}

class _AddVariantUnitFormState extends State<_AddVariantUnitForm> {
  final _formKey = GlobalKey<FormState>();
  final _factorController = TextEditingController();
  int? _selectedUnitId;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _selectedUnitId,
            decoration: InputDecoration(
              labelText: 'Chọn đơn vị quy đổi',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: widget.availableUnits.map((u) {
              return DropdownMenuItem(
                value: u.unitId,
                child: Text('${u.unitName} (${u.symbol})'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedUnitId = val;
              });
            },
            validator: (val) => val == null ? 'Vui lòng chọn đơn vị quy đổi' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _factorController,
            decoration: InputDecoration(
              labelText: 'Hệ số quy đổi',
              suffixText: widget.baseUnitSymbol,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: 'Ví dụ: 10 (1 Hộp = 10 cái)',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Vui lòng nhập hệ số';
              final numVal = double.tryParse(val);
              if (numVal == null || numVal <= 0) return 'Hệ số phải lớn hơn 0';
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() {
                        _isSubmitting = true;
                      });
                      try {
                        await widget.onAdd(
                          _selectedUnitId!,
                          double.parse(_factorController.text),
                        );
                        _factorController.clear();
                        setState(() {
                          _selectedUnitId = null;
                        });
                      } finally {
                        setState(() {
                          _isSubmitting = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3272E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Thêm quy đổi'),
            ),
          ),
        ],
      ),
    );
  }
}

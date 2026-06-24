import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
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
                                Row(
                                  children: [
                                    Icon(Icons.check_circle, color: _tertiaryContainer, size: 24),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('PHƯƠNG THỨC THEO DÕI',
                                            style: TextStyle(
                                                fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _getTrackingMethodLabel(product.trackingMethod),
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
                                return _buildVariantItemCard(variant, product.productId);
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

  Widget _buildVariantItemCard(ProductVariant variant, int productId) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: variant.imageUrl.isNotEmpty
                ? Image.network(
                    variant.imageUrl,
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
                  variant.variantName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  'SKU: ${variant.sku}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54, fontFamily: 'JetBrains Mono'),
                ),
                if (variant.barcode.isNotEmpty) ...[
                  Text(
                    'Barcode: ${variant.barcode}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Tồn tối thiểu: ${variant.minimumStockLevel}',
                      style: const TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                    const SizedBox(width: 8),
                    const Text('|', style: TextStyle(color: Colors.black26, fontSize: 10)),
                    const SizedBox(width: 8),
                    Text(
                      'Giá: ${currencyFormat.format(variant.costPrice)}',
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
                            productId: productId,
                            variant: variant,
                          ),
                        ),
                      );
                      if (result == true) {
                        Provider.of<ProductProvider>(context, listen: false).loadProductDetails(productId);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _deleteVariantConfirm(variant),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: variant.status == 1 ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  variant.status == 1 ? 'ĐANG BÁN' : 'NGƯNG BÁN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: variant.status == 1 ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ],
          ),
        ],
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

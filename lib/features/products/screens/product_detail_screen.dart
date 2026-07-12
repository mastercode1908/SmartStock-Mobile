import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../models/product_variant.dart';
import '../models/unit.dart';
import '../models/product_unit.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // Colors matching tailwind design
  final Color _surfaceContainer = const Color(0xFFE4F0F4);
  final Color _surfaceVariant = const Color(0xFFD9E4E9);
  Color get _primaryContainer => Theme.of(context).colorScheme.primaryContainer;
  Color get _onSurfaceVariant => Theme.of(context).colorScheme.onSurfaceVariant;
  final Color _tertiaryContainer = const Color(0xFF00A7A3);
  final Color _tertiaryColor = const Color(0xFF006A67);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProductDetails(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        actions: const [],
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

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 24,
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
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
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (product.brand != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Thương hiệu: ${product.brand!.brandName} (${product.brand!.country})',
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.widgets_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 8),
                                          Text('BIẾN THỂ',
                                              style: TextStyle(
                                                  fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
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
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.scale, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 8),
                                          Text('ĐƠN VỊ CƠ BẢN',
                                              style: TextStyle(
                                                  fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
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
                                    color: Theme.of(context).cardColor,
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
                            children: const [
                              Text('Danh sách biến thể', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
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
      case 3:
        return 'Theo dõi theo Lô & Serial (BATCH & SERIAL)';
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

  const VariantItemCard({
    super.key,
    required this.variant,
    required this.productId,
    this.baseUnit,
  });

  @override
  State<VariantItemCard> createState() => _VariantItemCardState();
}

class _VariantItemCardState extends State<VariantItemCard> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  Color get _primary => Theme.of(context).colorScheme.primary;

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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${widget.variant.sku}',
                      style: const TextStyle(fontSize: 13, color: Colors.black87, fontFamily: 'JetBrains Mono'),
                    ),
                    if (widget.variant.barcode.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Barcode: ${widget.variant.barcode}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Tồn tối thiểu: ${widget.variant.minimumStockLevel}',
                          style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                        const Text('|', style: TextStyle(color: Colors.black26, fontSize: 12)),
                        Text(
                          'Giá: ${currencyFormat.format(widget.variant.costPrice)}',
                          style: TextStyle(fontSize: 13, color: _primary, fontWeight: FontWeight.bold),
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
                      color: widget.variant.status == 1 ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.variant.status == 1 ? 'ĐANG BÁN' : 'NGƯNG BÁN',
                      style: TextStyle(
                        fontSize: 11,
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
            children: const [
              Text(
                'Đơn vị quy đổi:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (variantUnits.isEmpty)
            const Text(
              'Chưa cấu hình đơn vị quy đổi',
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black38),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: variantUnits.map((pu) {
                return Chip(
                  label: Text(
                    '1 ${pu.unitName} = ${pu.conversionFactor} ${widget.baseUnit?.symbol ?? widget.baseUnit?.unitName ?? ''}',
                    style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
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
}

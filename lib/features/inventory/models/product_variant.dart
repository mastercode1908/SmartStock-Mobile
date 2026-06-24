class ProductVariant {
  final int variantId;
  final int productId;
  final String variantName;
  final String productName;
  final String sku;
  final String barcode;
  final String imageUrl;
  final int trackingMethod; // 0 = None, 1 = Lot, 2 = Serial
  final int baseUnitId;
  final String baseUnitSymbol;

  ProductVariant({
    required this.variantId,
    required this.productId,
    required this.variantName,
    required this.productName,
    required this.sku,
    required this.barcode,
    required this.imageUrl,
    required this.trackingMethod,
    required this.baseUnitId,
    required this.baseUnitSymbol,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      variantId: json['variantID'] ?? json['variantId'] ?? 0,
      productId: json['productID'] ?? json['productId'] ?? 0,
      variantName: json['variantName'] ?? '',
      productName: json['productName'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      trackingMethod: json['trackingMethod'] ?? 0,
      baseUnitId: json['baseUnitID'] ?? json['baseUnitId'] ?? 0,
      baseUnitSymbol: json['baseUnitSymbol'] ?? '',
    );
  }
}

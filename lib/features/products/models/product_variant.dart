class ProductVariant {
  final int variantId;
  final int productId;
  final String variantName;
  final String sku;
  final String barcode;
  final int minimumStockLevel;
  final double costPrice;
  final String imageUrl;
  final int status;

  ProductVariant({
    required this.variantId,
    required this.productId,
    required this.variantName,
    required this.sku,
    required this.barcode,
    required this.minimumStockLevel,
    required this.costPrice,
    required this.imageUrl,
    required this.status,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      variantId: json['variantID'] ?? json['variantId'] ?? 0,
      productId: json['productID'] ?? json['productId'] ?? 0,
      variantName: json['variantName'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      minimumStockLevel: json['minimumStockLevel'] ?? 0,
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      status: json['status'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variantID': variantId,
      'productID': productId,
      'variantName': variantName,
      'sku': sku,
      'barcode': barcode,
      'minimumStockLevel': minimumStockLevel,
      'costPrice': costPrice,
      'imageUrl': imageUrl,
      'status': status,
    };
  }
}

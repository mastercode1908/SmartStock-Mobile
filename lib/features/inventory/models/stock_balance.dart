class StockBalance {
  final int stockBalanceId;
  final int variantId;
  final String variantName;
  final String sku;
  final String barcode;
  final String productName;
  final int? batchId;
  final String? batchNumber;
  final DateTime? expiryDate;
  final int quantity;
  final DateTime? lastUpdated;
  final int trackingMethod; // 0 = NONE, 1 = BATCH, 2 = SERIAL

  StockBalance({
    required this.stockBalanceId,
    required this.variantId,
    required this.variantName,
    required this.sku,
    required this.barcode,
    required this.productName,
    this.batchId,
    this.batchNumber,
    this.expiryDate,
    required this.quantity,
    this.lastUpdated,
    required this.trackingMethod,
  });

  factory StockBalance.fromJson(Map<String, dynamic> json) {
    return StockBalance(
      stockBalanceId: json['stockBalanceID'] ?? json['stockBalanceId'] ?? 0,
      variantId: json['variantID'] ?? json['variantId'] ?? 0,
      variantName: json['variantName'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      productName: json['productName'] ?? '',
      batchId: json['batchID'] ?? json['batchId'],
      batchNumber: json['batchNumber'],
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate']) : null,
      quantity: json['quantity'] ?? 0,
      lastUpdated: json['lastUpdated'] != null ? DateTime.tryParse(json['lastUpdated']) : null,
      trackingMethod: json['trackingMethod'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockBalanceID': stockBalanceId,
      'variantID': variantId,
      'variantName': variantName,
      'sku': sku,
      'barcode': barcode,
      'productName': productName,
      'batchID': batchId,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'quantity': quantity,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'trackingMethod': trackingMethod,
    };
  }
}

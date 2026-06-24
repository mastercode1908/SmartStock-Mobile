class ProductUnit {
  final int productUnitId;
  final int variantId;
  final int unitId;
  final String unitName;
  final String symbol;
  final double conversionFactor;

  ProductUnit({
    required this.productUnitId,
    required this.variantId,
    required this.unitId,
    required this.unitName,
    required this.symbol,
    required this.conversionFactor,
  });

  factory ProductUnit.fromJson(Map<String, dynamic> json) {
    return ProductUnit(
      productUnitId: json['productUnitID'] ?? json['productUnitId'] ?? 0,
      variantId: json['variantID'] ?? json['variantId'] ?? 0,
      unitId: json['unitID'] ?? json['unitId'] ?? 0,
      unitName: json['unitName'] ?? '',
      symbol: json['symbol'] ?? '',
      conversionFactor: (json['conversionFactor'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productUnitID': productUnitId,
      'variantID': variantId,
      'unitID': unitId,
      'conversionFactor': conversionFactor,
    };
  }
}

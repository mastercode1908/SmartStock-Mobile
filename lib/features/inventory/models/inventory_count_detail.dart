class InventoryCountDetail {
  final int countDetailId;
  final int sessionId;
  final int variantId;
  final String? variantName;
  final String? sku;
  final String? lotNumber;
  final String? serialNumber;
  final int unitId;
  final int systemQuantity;
  final int countedQuantity;
  final int difference;
  final String status; // MATCHED, DISCREPANCY, REQUIRES_RECOUNT
  final String? notes;
  final String? locationCode;
  final String? imageUrl;

  InventoryCountDetail({
    required this.countDetailId,
    required this.sessionId,
    required this.variantId,
    this.variantName,
    this.sku,
    this.lotNumber,
    this.serialNumber,
    required this.unitId,
    required this.systemQuantity,
    required this.countedQuantity,
    required this.difference,
    required this.status,
    this.notes,
    this.locationCode,
    this.imageUrl,
  });

  factory InventoryCountDetail.fromJson(Map<String, dynamic> json) {
    int diff = json['differenceQuantity'] ?? json['difference'] ?? 0;
    String statusStr = diff == 0 ? 'MATCHED' : 'DISCREPANCY';

    String? vName;
    String? vSku;
    if (json['ProductVariant'] != null || json['productVariant'] != null) {
      final pv = json['ProductVariant'] ?? json['productVariant'];
      vName = pv['VariantName'] ?? pv['variantName'];
      vSku = pv['SKU'] ?? pv['sku'];
    }

    String? locCode;
    if (json['StorageLocation'] != null || json['storageLocation'] != null) {
      final loc = json['StorageLocation'] ?? json['storageLocation'];
      locCode = loc['LocationCode'] ?? loc['locationCode'];
    }

    return InventoryCountDetail(
      countDetailId: json['CountDetailID'] ?? json['countDetailID'] ?? json['countDetailId'] ?? 0,
      sessionId: json['SessionID'] ?? json['sessionID'] ?? json['sessionId'] ?? 0,
      variantId: json['VariantID'] ?? json['variantID'] ?? json['variantId'] ?? 0,
      variantName: vName,
      sku: vSku,
      lotNumber: json['LotNumber'] ?? json['lotNumber'],
      serialNumber: json['SerialNumber'] ?? json['serialNumber'],
      unitId: json['UnitID'] ?? json['unitID'] ?? json['unitId'] ?? json['LocationID'] ?? json['locationID'] ?? 0,
      systemQuantity: json['SystemQuantity'] ?? json['systemQuantity'] ?? 0,
      countedQuantity: json['ActualQuantity'] ?? json['actualQuantity'] ?? json['CountedQuantity'] ?? json['countedQuantity'] ?? 0,
      difference: diff,
      status: statusStr,
      notes: json['note'] ?? json['notes'],
      locationCode: locCode,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    int statusInt = 0;
    if (status == 'DISCREPANCY') statusInt = 1;
    if (status == 'REQUIRES_RECOUNT') statusInt = 2;

    return {
      'countDetailID': countDetailId,
      'sessionID': sessionId,
      'variantID': variantId,
      'batchID': null,
      'serialID': null,
      'locationID': 1, // Hardcoded for now
      'systemQuantity': systemQuantity,
      'actualQuantity': countedQuantity,
      'differenceQuantity': difference,
      'variance': 0,
      'varianceReason': '',
      'countedBy': 1, // Hardcoded for now
      'note': notes ?? '',
      'imageUrl': imageUrl ?? '',
    };
  }
}

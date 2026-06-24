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
    if (json['productVariant'] != null) {
      vName = json['productVariant']['variantName'];
      vSku = json['productVariant']['sku'];
    }

    String? locCode;
    if (json['storageLocation'] != null) {
      locCode = json['storageLocation']['locationCode'];
    }

    return InventoryCountDetail(
      countDetailId: json['countDetailID'] ?? json['countDetailId'] ?? 0,
      sessionId: json['sessionID'] ?? json['sessionId'] ?? 0,
      variantId: json['variantID'] ?? json['variantId'] ?? 0,
      variantName: vName,
      sku: vSku,
      lotNumber: json['lotNumber'],
      serialNumber: json['serialNumber'],
      unitId: json['unitID'] ?? json['unitId'] ?? json['locationID'] ?? 0,
      systemQuantity: json['systemQuantity'] ?? 0,
      countedQuantity: json['actualQuantity'] ?? json['countedQuantity'] ?? 0,
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

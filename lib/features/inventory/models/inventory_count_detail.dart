class InventoryCountDetail {
  final int countDetailId;
  final int sessionId;
  final int variantId;
  final String? lotNumber;
  final String? serialNumber;
  final int unitId;
  final int systemQuantity;
  final int countedQuantity;
  final int difference;
  final String status; // MATCHED, DISCREPANCY, REQUIRES_RECOUNT
  final String? notes;

  InventoryCountDetail({
    required this.countDetailId,
    required this.sessionId,
    required this.variantId,
    this.lotNumber,
    this.serialNumber,
    required this.unitId,
    required this.systemQuantity,
    required this.countedQuantity,
    required this.difference,
    required this.status,
    this.notes,
  });

  factory InventoryCountDetail.fromJson(Map<String, dynamic> json) {
    String statusStr = 'MATCHED';
    if (json['status'] == 1) statusStr = 'DISCREPANCY';
    if (json['status'] == 2) statusStr = 'REQUIRES_RECOUNT';

    return InventoryCountDetail(
      countDetailId: json['countDetailID'] ?? json['countDetailId'] ?? 0,
      sessionId: json['sessionID'] ?? json['sessionId'] ?? 0,
      variantId: json['variantID'] ?? json['variantId'] ?? 0,
      lotNumber: json['lotNumber'],
      serialNumber: json['serialNumber'],
      unitId: json['unitID'] ?? json['unitId'] ?? 0,
      systemQuantity: json['systemQuantity'] ?? 0,
      countedQuantity: json['countedQuantity'] ?? 0,
      difference: json['difference'] ?? 0,
      status: statusStr,
      notes: json['notes'],
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
      'imageUrl': '',
    };
  }
}

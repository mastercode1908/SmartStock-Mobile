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

  Map<String, dynamic> toJson() {
    int statusInt = 0;
    if (status == 'DISCREPANCY') statusInt = 1;
    if (status == 'REQUIRES_RECOUNT') statusInt = 2;

    return {
      'countDetailID': countDetailId,
      'sessionID': sessionId,
      'variantID': variantId,
      'lotNumber': lotNumber ?? '',
      'serialNumber': serialNumber ?? '',
      'unitID': unitId,
      'systemQuantity': systemQuantity,
      'countedQuantity': countedQuantity,
      'difference': difference,
      'status': statusInt,
      'notes': notes ?? '',
      'imageUrl': '', // Fix SQL Exception for NULL ImageUrl
    };
  }
}

class InventoryCountDetail {
  final int countDetailId;
  final int sessionId;
  final int variantId;
  final String? variantName;
  final String? productName;
  final String? sku;
  final int? batchId;
  final String? batchNumber;
  final int? serialId;
  final String? serialNumber;
  final int trackingMethod; // 0 = None, 1 = Batch, 2 = Serial, 3 = Batch & Serial
  final int unitId;
  final int systemQuantity;
  int? actualQuantity;
  final int difference;
  final String status; // MATCHED, DISCREPANCY, REQUIRES_RECOUNT
  final String? notes;
  // Storage location fields
  final int? storageLocationId;
  final String? locationCode;
  final String? zone;
  final String? rack;
  final String? shelf;
  final String? bin;
  final String? imageUrl;

  InventoryCountDetail({
    required this.countDetailId,
    required this.sessionId,
    required this.variantId,
    this.variantName,
    this.productName,
    this.sku,
    this.batchId,
    this.batchNumber,
    this.serialId,
    this.serialNumber,
    this.trackingMethod = 0,
    required this.unitId,
    required this.systemQuantity,
    this.actualQuantity,
    required this.difference,
    required this.status,
    this.notes,
    this.storageLocationId,
    this.locationCode,
    this.zone,
    this.rack,
    this.shelf,
    this.bin,
    this.imageUrl,
  });

  factory InventoryCountDetail.fromJson(Map<String, dynamic> json) {
    int diff = json['DifferenceQuantity'] ?? json['differenceQuantity'] ?? json['difference'] ?? 0;
    String statusStr = diff == 0 ? 'MATCHED' : 'DISCREPANCY';

    // VariantName / SKU / ProductName can come from nested object or flat fields
    String? vName = json['VariantName'] ?? json['variantName'];
    String? vSku = json['SKU'] ?? json['sku'];
    String? vProductName = json['ProductName'] ?? json['productName'];
    if (vName == null && (json['ProductVariant'] != null || json['productVariant'] != null)) {
      final pv = json['ProductVariant'] ?? json['productVariant'];
      vName = pv['VariantName'] ?? pv['variantName'];
      vSku = pv['SKU'] ?? pv['sku'];
    }

    // Location can come from nested object or flat fields
    String? locCode = json['LocationCode'] ?? json['locationCode'];
    String? zone = json['Zone'] ?? json['zone'];
    String? rack = json['Rack'] ?? json['rack'];
    String? shelf = json['Shelf'] ?? json['shelf'];
    String? bin = json['Bin'] ?? json['bin'];
    int? locId = json['StorageLocationID'] ?? json['storageLocationID'] ?? json['storageLocationId'];
    if (locCode == null && (json['StorageLocation'] != null || json['storageLocation'] != null)) {
      final loc = json['StorageLocation'] ?? json['storageLocation'];
      locCode = loc['LocationCode'] ?? loc['locationCode'];
      zone = loc['Zone'] ?? loc['zone'];
      rack = loc['Rack'] ?? loc['rack'];
      shelf = loc['Shelf'] ?? loc['shelf'];
      bin = loc['Bin'] ?? loc['bin'];
      locId = loc['LocationID'] ?? loc['locationID'];
    }

    return InventoryCountDetail(
      countDetailId: json['DetailID'] ?? json['detailId'] ?? json['detailID'] ?? json['CountDetailID'] ?? json['CountDetailId'] ?? json['countDetailID'] ?? json['countDetailId'] ?? 0,
      sessionId: json['SessionID'] ?? json['sessionID'] ?? json['sessionId'] ?? 0,
      variantId: json['VariantID'] ?? json['variantID'] ?? json['variantId'] ?? 0,
      variantName: vName,
      productName: vProductName,
      sku: vSku,
      batchId: json['BatchID'] ?? json['batchID'] ?? json['batchId'],
      batchNumber: json['BatchNumber'] ?? json['batchNumber'] ?? json['LotNumber'] ?? json['lotNumber'],
      serialId: json['SerialID'] ?? json['serialID'] ?? json['serialId'],
      serialNumber: json['SerialNumber'] ?? json['serialNumber'],
      trackingMethod: json['TrackingMethod'] ?? json['trackingMethod'] ?? 0,
      unitId: json['UnitID'] ?? json['unitID'] ?? json['unitId'] ?? 0,
      systemQuantity: json['SystemQuantity'] ?? json['systemQuantity'] ?? 0,
      actualQuantity: json['ActualQuantity'] ?? json['actualQuantity'],
      difference: diff,
      status: statusStr,
      notes: json['Note'] ?? json['note'] ?? json['notes'],
      storageLocationId: locId,
      locationCode: locCode,
      zone: zone,
      rack: rack,
      shelf: shelf,
      bin: bin,
      imageUrl: json['ImageUrl'] ?? json['imageUrl'],
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
      'batchID': batchId,
      'serialID': serialId,
      'locationID': storageLocationId ?? 1, // Use actual location, fallback to 1 if null
      'systemQuantity': systemQuantity,
      'actualQuantity': actualQuantity ?? 0,
      'differenceQuantity': difference,
      'variance': 0,
      'varianceReason': '',
      'countedBy': 1, // Hardcoded for now
      'note': notes ?? '',
      'imageUrl': imageUrl ?? '',
    };
  }
}

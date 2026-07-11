import '../../picking/models/picking_task.dart';

class IncidentReportModel {
  final int incidentId;
  final int reportedBy;
  final int warehouseId;
  final int? locationId;
  final int? variantId;
  final int? batchId;
  final int quantity;
  final String title;
  final String description;
  final String imageUrl;
  final String severity;
  final int status; // 0: PENDING, 1: IN_PROGRESS, 2: RESOLVED, 3: CLOSED, 4: REJECTED
  final String createdAt;
  final String updatedAt;
  final PickingUserModel? reportedByUser;
  final PickingStorageLocationModel? storageLocation;
  final PickingProductVariantModel? productVariant;
  final IncidentBatchModel? batch;

  IncidentReportModel({
    required this.incidentId,
    required this.reportedBy,
    required this.warehouseId,
    this.locationId,
    this.variantId,
    this.batchId,
    required this.quantity,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.severity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.reportedByUser,
    this.storageLocation,
    this.productVariant,
    this.batch,
  });

  factory IncidentReportModel.fromJson(Map<String, dynamic> json) {
    var reportedUserJson = json['reportedByUser'] ?? json['ReportedByUser'];
    var locationJson = json['storageLocation'] ?? json['StorageLocation'];
    var variantJson = json['productVariant'] ?? json['ProductVariant'];
    var batchJson = json['batch'] ?? json['Batch'];

    return IncidentReportModel(
      incidentId: json['incidentID'] ?? json['incidentId'] ?? json['IncidentID'] ?? 0,
      reportedBy: json['reportedBy'] ?? json['ReportedBy'] ?? 0,
      warehouseId: json['warehouseID'] ?? json['warehouseId'] ?? json['WarehouseID'] ?? 0,
      locationId: json['locationID'] ?? json['locationId'] ?? json['LocationID'],
      variantId: json['variantID'] ?? json['variantId'] ?? json['VariantID'],
      batchId: json['batchID'] ?? json['batchId'] ?? json['BatchID'],
      quantity: json['quantity'] ?? json['Quantity'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['ImageUrl'] ?? '',
      severity: json['severity'] ?? json['Severity'] ?? 'Medium',
      status: json['status'] ?? json['Status'] ?? 0,
      createdAt: json['createdAt'] ?? json['CreatedAt'] ?? '',
      updatedAt: json['updatedAt'] ?? json['UpdatedAt'] ?? '',
      reportedByUser: reportedUserJson != null ? PickingUserModel.fromJson(reportedUserJson) : null,
      storageLocation: locationJson != null ? PickingStorageLocationModel.fromJson(locationJson) : null,
      productVariant: variantJson != null ? PickingProductVariantModel.fromJson(variantJson) : null,
      batch: batchJson != null ? IncidentBatchModel.fromJson(batchJson) : null,
    );
  }
}

class IncidentBatchModel {
  final int batchId;
  final String batchNumber;

  IncidentBatchModel({
    required this.batchId,
    required this.batchNumber,
  });

  factory IncidentBatchModel.fromJson(Map<String, dynamic> json) {
    return IncidentBatchModel(
      batchId: json['batchID'] ?? json['batchId'] ?? json['BatchID'] ?? 0,
      batchNumber: json['batchNumber'] ?? json['BatchNumber'] ?? '',
    );
  }
}

class IncidentSerialModel {
  final int serialId;
  final String serialNumber;
  final int status; // 0: DRAFT, 1: AVAILABLE, 2: RESERVED, 3: SOLD, 4: DAMAGED, 5: CANCELLED

  IncidentSerialModel({
    required this.serialId,
    required this.serialNumber,
    required this.status,
  });

  factory IncidentSerialModel.fromJson(Map<String, dynamic> json) {
    return IncidentSerialModel(
      serialId: json['serialID'] ?? json['serialId'] ?? json['SerialID'] ?? 0,
      serialNumber: json['serialNumber'] ?? json['SerialNumber'] ?? '',
      status: json['status'] ?? json['Status'] ?? 0,
    );
  }
}

class IncidentReportDetailsModel {
  final IncidentReportModel report;
  final List<IncidentSerialModel> linkedSerials;

  IncidentReportDetailsModel({
    required this.report,
    required this.linkedSerials,
  });

  factory IncidentReportDetailsModel.fromJson(Map<String, dynamic> json) {
    var reportJson = json['report'] ?? json['Report'] ?? {};
    var serialsList = json['linkedSerials'] as List? ?? json['LinkedSerials'] as List? ?? [];
    
    return IncidentReportDetailsModel(
      report: IncidentReportModel.fromJson(reportJson),
      linkedSerials: serialsList.map((item) => IncidentSerialModel.fromJson(item)).toList(),
    );
  }
}

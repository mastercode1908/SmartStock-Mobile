class PickingTaskModel {
  final int taskId;
  final String taskCode;
  final int? assignedTo;
  final int status; // 0: PENDING, 1: IN_PROGRESS, 2: COMPLETED, 3: CANCELLED
  final int createdBy;
  final String createdAt;
  final String? startedAt;
  final String? completedAt;
  final PickingUserModel? assignedToUser;
  final PickingUserModel? createdByUser;
  final List<PickingDetailModel> details;

  PickingTaskModel({
    required this.taskId,
    required this.taskCode,
    this.assignedTo,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.assignedToUser,
    this.createdByUser,
    required this.details,
  });

  factory PickingTaskModel.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List? ?? json['Details'] as List? ?? [];
    List<PickingDetailModel> detailsObjs = detailsList
        .map((item) => PickingDetailModel.fromJson(item))
        .toList();

    var assignedUserJson = json['assignedToUser'] ?? json['AssignedToUser'];
    var createdUserJson = json['createdByUser'] ?? json['CreatedByUser'];

    return PickingTaskModel(
      taskId: json['taskID'] ?? json['taskID'] ?? json['TaskID'] ?? 0,
      taskCode: json['taskCode'] ?? json['TaskCode'] ?? '',
      assignedTo: json['assignedTo'] ?? json['AssignedTo'],
      status: json['status'] ?? json['Status'] ?? 0,
      createdBy: json['createdBy'] ?? json['CreatedBy'] ?? 0,
      createdAt: json['createdAt'] ?? json['CreatedAt'] ?? '',
      startedAt: json['startedAt'] ?? json['StartedAt'],
      completedAt: json['completedAt'] ?? json['CompletedAt'],
      assignedToUser: assignedUserJson != null ? PickingUserModel.fromJson(assignedUserJson) : null,
      createdByUser: createdUserJson != null ? PickingUserModel.fromJson(createdUserJson) : null,
      details: detailsObjs,
    );
  }
}

class PickingUserModel {
  final int userId;
  final String email;
  final String fullName;
  final String? avatarUrl;

  PickingUserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.avatarUrl,
  });

  factory PickingUserModel.fromJson(Map<String, dynamic> json) {
    return PickingUserModel(
      userId: json['userID'] ?? json['userId'] ?? json['UserID'] ?? 0,
      email: json['email'] ?? json['Email'] ?? '',
      fullName: json['fullName'] ?? json['FullName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['AvatarUrl'],
    );
  }
}

class PickingDetailSerialModel {
  final int pickingDetailSerialId;
  final int pickingDetailId;
  final int serialId;
  final PickingSerialModel? serial;

  PickingDetailSerialModel({
    required this.pickingDetailSerialId,
    required this.pickingDetailId,
    required this.serialId,
    this.serial,
  });

  factory PickingDetailSerialModel.fromJson(Map<String, dynamic> json) {
    var serialJson = json['serial'] ?? json['Serial'];
    return PickingDetailSerialModel(
      pickingDetailSerialId: json['pickingDetailSerialID'] ?? json['pickingDetailSerialId'] ?? json['PickingDetailSerialID'] ?? 0,
      pickingDetailId: json['pickingDetailID'] ?? json['pickingDetailId'] ?? json['PickingDetailID'] ?? 0,
      serialId: json['serialID'] ?? json['serialId'] ?? json['SerialID'] ?? 0,
      serial: serialJson != null ? PickingSerialModel.fromJson(serialJson) : null,
    );
  }
}

class PickingSerialModel {
  final int serialId;
  final int variantId;
  final String serialNumber;
  final int status;

  PickingSerialModel({
    required this.serialId,
    required this.variantId,
    required this.serialNumber,
    required this.status,
  });

  factory PickingSerialModel.fromJson(Map<String, dynamic> json) {
    return PickingSerialModel(
      serialId: json['serialID'] ?? json['serialId'] ?? json['SerialID'] ?? 0,
      variantId: json['variantID'] ?? json['variantId'] ?? json['VariantID'] ?? 0,
      serialNumber: json['serialNumber'] ?? json['SerialNumber'] ?? '',
      status: json['status'] ?? json['Status'] ?? 0,
    );
  }
}

class PickingDetailModel {
  final int pickingDetailId;
  final int taskId;
  final int issueDetailId;
  final int variantId;
  final int locationId;
  final int? batchId;
  final int expectedQuantity;
  int pickedQuantity;
  final int status; // 0: PENDING, 1: PICKED, 2: SHORT_PICKED
  final PickingProductVariantModel? productVariant;
  final PickingStorageLocationModel? storageLocation;
  final List<PickingDetailSerialModel> serials;

  PickingDetailModel({
    required this.pickingDetailId,
    required this.taskId,
    required this.issueDetailId,
    required this.variantId,
    required this.locationId,
    this.batchId,
    required this.expectedQuantity,
    required this.pickedQuantity,
    required this.status,
    this.productVariant,
    this.storageLocation,
    required this.serials,
  });

  factory PickingDetailModel.fromJson(Map<String, dynamic> json) {
    var variantJson = json['productVariant'] ?? json['ProductVariant'];
    var locationJson = json['storageLocation'] ?? json['StorageLocation'];
    var serialsList = json['serials'] as List? ?? json['Serials'] as List? ?? [];
    List<PickingDetailSerialModel> serialsObjs = serialsList
        .map((item) => PickingDetailSerialModel.fromJson(item))
        .toList();

    return PickingDetailModel(
      pickingDetailId: json['pickingDetailID'] ?? json['pickingDetailId'] ?? json['PickingDetailID'] ?? 0,
      taskId: json['taskID'] ?? json['taskId'] ?? json['TaskID'] ?? 0,
      issueDetailId: json['issueDetailID'] ?? json['issueDetailId'] ?? json['IssueDetailID'] ?? 0,
      variantId: json['variantID'] ?? json['variantId'] ?? json['VariantID'] ?? 0,
      locationId: json['locationID'] ?? json['locationId'] ?? json['LocationID'] ?? 0,
      batchId: json['batchID'] ?? json['batchId'] ?? json['BatchID'],
      expectedQuantity: json['expectedQuantity'] ?? json['ExpectedQuantity'] ?? 0,
      pickedQuantity: json['pickedQuantity'] ?? json['PickedQuantity'] ?? 0,
      status: json['status'] ?? json['Status'] ?? 0,
      productVariant: variantJson != null ? PickingProductVariantModel.fromJson(variantJson) : null,
      storageLocation: locationJson != null ? PickingStorageLocationModel.fromJson(locationJson) : null,
      serials: serialsObjs,
    );
  }
}

class PickingProductVariantModel {
  final int variantId;
  final String variantName;
  final String sku;
  final String barcode;
  final String? imageUrl;
  final String? productName;

  PickingProductVariantModel({
    required this.variantId,
    required this.variantName,
    required this.sku,
    required this.barcode,
    this.imageUrl,
    this.productName,
  });

  factory PickingProductVariantModel.fromJson(Map<String, dynamic> json) {
    var productJson = json['product'] ?? json['Product'];
    String? prodName = productJson != null ? (productJson['productName'] ?? productJson['ProductName']) : null;

    return PickingProductVariantModel(
      variantId: json['variantID'] ?? json['variantId'] ?? json['VariantID'] ?? 0,
      variantName: json['variantName'] ?? json['VariantName'] ?? '',
      sku: json['sku'] ?? json['SKU'] ?? '',
      barcode: json['barcode'] ?? json['Barcode'] ?? '',
      imageUrl: json['imageUrl'] ?? json['ImageUrl'],
      productName: prodName,
    );
  }
}

class PickingStorageLocationModel {
  final int locationId;
  final String locationCode;
  final String zone;
  final String rack;
  final String shelf;
  final String bin;

  PickingStorageLocationModel({
    required this.locationId,
    required this.locationCode,
    required this.zone,
    required this.rack,
    required this.shelf,
    required this.bin,
  });

  factory PickingStorageLocationModel.fromJson(Map<String, dynamic> json) {
    return PickingStorageLocationModel(
      locationId: json['locationID'] ?? json['locationId'] ?? json['LocationID'] ?? 0,
      locationCode: json['locationCode'] ?? json['LocationCode'] ?? '',
      zone: json['zone'] ?? json['Zone'] ?? '',
      rack: json['rack'] ?? json['Rack'] ?? '',
      shelf: json['shelf'] ?? json['Shelf'] ?? '',
      bin: json['bin'] ?? json['Bin'] ?? '',
    );
  }

  String get displayLocation => '$rack-$shelf-$bin';
}

class UnassignedIssueModel {
  final int issueId;
  final String issueCode;
  final int status;
  final int createdBy;
  final String createdAt;
  final PickingUserModel? createdByUser;

  UnassignedIssueModel({
    required this.issueId,
    required this.issueCode,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.createdByUser,
  });

  factory UnassignedIssueModel.fromJson(Map<String, dynamic> json) {
    var createdUserJson = json['createdByUser'] ?? json['CreatedByUser'];
    return UnassignedIssueModel(
      issueId: json['issueID'] ?? json['issueId'] ?? json['IssueID'] ?? 0,
      issueCode: json['issueCode'] ?? json['IssueCode'] ?? '',
      status: json['status'] ?? json['Status'] ?? 0,
      createdBy: json['createdBy'] ?? json['CreatedBy'] ?? 0,
      createdAt: json['createdAt'] ?? json['CreatedAt'] ?? '',
      createdByUser: createdUserJson != null ? PickingUserModel.fromJson(createdUserJson) : null,
    );
  }
}

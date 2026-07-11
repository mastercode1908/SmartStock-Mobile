import 'product_variant.dart';
import 'storage_location.dart';

class PickingDetail {
  final int pickingDetailId;
  final int taskId;
  final int issueDetailId;
  final int variantId;
  final int locationId;
  final int? batchId;
  final int expectedQuantity;
  int pickedQuantity;
  int status; // 0: PENDING, 1: PICKED, 2: SHORT_PICKED
  
  final ProductVariant? productVariant;
  final StorageLocation? storageLocation;

  PickingDetail({
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
  });

  factory PickingDetail.fromJson(Map<String, dynamic> json) {
    return PickingDetail(
      pickingDetailId: json['pickingDetailID'] ?? json['pickingDetailId'] ?? 0,
      taskId: json['taskID'] ?? json['taskId'] ?? 0,
      issueDetailId: json['issueDetailID'] ?? json['issueDetailId'] ?? 0,
      variantId: json['variantID'] ?? json['variantId'] ?? 0,
      locationId: json['locationID'] ?? json['locationId'] ?? 0,
      batchId: json['batchID'] ?? json['batchId'],
      expectedQuantity: json['expectedQuantity'] ?? 0,
      pickedQuantity: json['pickedQuantity'] ?? 0,
      status: json['status'] ?? 0,
      productVariant: json['productVariant'] != null
          ? ProductVariant.fromJson(json['productVariant'])
          : null,
      storageLocation: json['storageLocation'] != null
          ? StorageLocation.fromJson(json['storageLocation'])
          : null,
    );
  }
}

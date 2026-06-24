class StorageLocation {
  final int locationId;
  final String locationCode;
  final int warehouseId;

  StorageLocation({
    required this.locationId,
    required this.locationCode,
    required this.warehouseId,
  });

  factory StorageLocation.fromJson(Map<String, dynamic> json) {
    return StorageLocation(
      locationId: json['locationID'] ?? json['locationId'] ?? 0,
      locationCode: json['locationCode'] ?? '',
      warehouseId: json['warehouseID'] ?? json['warehouseId'] ?? 0,
    );
  }
}

class Warehouse {
  final int id;
  final String warehouseName;
  final String address;

  Warehouse({
    required this.id,
    required this.warehouseName,
    required this.address,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['warehouseID'] ?? json['warehouseId'] ?? 0,
      warehouseName: json['warehouseName'] ?? json['WarehouseName'] ?? '',
      address: json['address'] ?? json['Address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouseId': id,
      'warehouseName': warehouseName,
      'address': address,
    };
  }
}

import 'stock_balance.dart';

class StorageLocation {
  final int locationId;
  final int warehouseId;
  final String warehouseName;
  final String zone;
  final String rack;
  final String shelf;
  final String bin;
  final String locationCode;
  final int status;
  final List<StockBalance> stockBalances;

  StorageLocation({
    required this.locationId,
    required this.warehouseId,
    required this.warehouseName,
    required this.zone,
    required this.rack,
    required this.shelf,
    required this.bin,
    required this.locationCode,
    required this.status,
    required this.stockBalances,
  });

  factory StorageLocation.fromJson(Map<String, dynamic> json) {
    var balancesJson = json['stockBalances'] as List?;
    List<StockBalance> balances = balancesJson != null
        ? balancesJson.map((b) => StockBalance.fromJson(b)).toList()
        : [];
    return StorageLocation(
      locationId: json['locationID'] ?? json['locationId'] ?? 0,
      warehouseId: json['warehouseID'] ?? json['warehouseId'] ?? 0,
      warehouseName: json['warehouseName'] ?? '',
      zone: json['zone'] ?? '',
      rack: json['rack'] ?? '',
      shelf: json['shelf'] ?? '',
      bin: json['bin'] ?? '',
      locationCode: json['locationCode'] ?? '',
      status: json['status'] ?? 0,
      stockBalances: balances,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationID': locationId,
      'warehouseID': warehouseId,
      'warehouseName': warehouseName,
      'zone': zone,
      'rack': rack,
      'shelf': shelf,
      'bin': bin,
      'locationCode': locationCode,
      'status': status,
      'stockBalances': stockBalances.map((b) => b.toJson()).toList(),
    };
  }
}

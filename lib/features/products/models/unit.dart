class Unit {
  final int unitId;
  final String unitName;
  final String symbol;

  Unit({
    required this.unitId,
    required this.unitName,
    required this.symbol,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unitId: json['unitID'] ?? json['unitId'] ?? 0,
      unitName: json['unitName'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unitID': unitId,
      'unitName': unitName,
      'symbol': symbol,
    };
  }
}

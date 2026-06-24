class InventorySession {
  final int id; // Backend usually returns int ID
  final int warehouseId;
  final String sessionCode;
  final String countType; // FULL, PARTIAL, LOCATION, PRODUCT
  final String status; // DRAFT, IN_PROGRESS, COMPLETED, CANCELLED
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final int createdBy;
  final int? assignedTo;

  InventorySession({
    required this.id,
    required this.warehouseId,
    required this.sessionCode,
    required this.countType,
    required this.status,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.createdBy,
    this.assignedTo,
  });

  static String _parseStatus(dynamic value) {
    if (value is String) return value;
    if (value is int) {
      switch (value) {
        case 0: return 'DRAFT';
        case 1: return 'IN_PROGRESS';
        case 2: return 'COMPLETED';
        case 3: return 'CANCELLED';
        default: return 'UNKNOWN';
      }
    }
    return 'DRAFT';
  }

  static String _parseCountType(dynamic value) {
    if (value is String) return value;
    if (value is int) {
      switch (value) {
        case 0: return 'FULL';
        case 1: return 'PARTIAL';
        case 2: return 'LOCATION';
        case 3: return 'PRODUCT';
        default: return 'UNKNOWN';
      }
    }
    return 'FULL';
  }

  factory InventorySession.fromJson(Map<String, dynamic> json) {
    return InventorySession(
      id: json['sessionID'] ?? json['sessionId'] ?? 0, 
      warehouseId: json['warehouseID'] ?? json['warehouseId'] ?? 0,
      sessionCode: json['sessionCode']?.toString() ?? '',
      countType: _parseCountType(json['countType']),
      status: _parseStatus(json['status']),
      description: json['description']?.toString() ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdBy: json['createdBy'] ?? 0,
      assignedTo: json['assignedTo'],
    );
  }

  Map<String, dynamic> toJson() {
    // Map string back to int for backend
    int statusInt = 0;
    if (status == 'IN_PROGRESS') statusInt = 1;
    if (status == 'COMPLETED') statusInt = 2;
    if (status == 'CANCELLED') statusInt = 3;

    int countTypeInt = 0;
    if (countType == 'PARTIAL') countTypeInt = 1;
    if (countType == 'LOCATION') countTypeInt = 2;
    if (countType == 'PRODUCT') countTypeInt = 3;

    return {
      'sessionID': id,
      'warehouseID': warehouseId,
      'sessionCode': sessionCode,
      'countType': countTypeInt,
      'status': statusInt,
      'description': description,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate?.toUtc().toIso8601String(),
      'createdBy': createdBy,
      'assignedTo': assignedTo,
    };
  }
}

import 'inventory_count_detail.dart';

class InventorySession {
  final int id; // Backend usually returns int ID
  final int warehouseId;
  final String? warehouseName;
  final String sessionCode;
  final String countType; // FULL, PARTIAL, LOCATION, PRODUCT
  final String status; // DRAFT, PENDING, APPROVED, REJECTED, CANCELLED, POSTED
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime countDate;
  final int createdBy;
  final String? createdByName;
  final int? assignedTo;
  final String? assignedToName;
  final List<InventoryCountDetail>? details;

  InventorySession({
    required this.id,
    required this.warehouseId,
    this.warehouseName,
    required this.sessionCode,
    required this.countType,
    required this.status,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.countDate,
    required this.createdBy,
    this.createdByName,
    this.assignedTo,
    this.assignedToName,
    this.details,
  });

  static String _parseStatus(dynamic value) {
    if (value is String) return value.toUpperCase();
    if (value is int) {
      switch (value) {
        case 0: return 'DRAFT';
        case 1: return 'PENDING';
        case 2: return 'APPROVED';
        case 3: return 'REJECTED';
        case 4: return 'CANCELLED';
        case 5: return 'POSTED';
        default: return 'UNKNOWN';
      }
    }
    return 'DRAFT';
  }

  static String _parseCountType(dynamic value) {
    if (value is String) return value.toUpperCase();
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

  static DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null) return null;
    try {
      String s = dateStr.toString();
      if (s.endsWith('Z')) {
        s = s.substring(0, s.length - 1);
      }
      DateTime parsed = DateTime.parse(s);
      if (parsed.year < 2000) return null; // Ignore invalid 0001-01-01
      return parsed;
    } catch (_) {
      return null;
    }
  }

  factory InventorySession.fromJson(Map<String, dynamic> json) {
    DateTime? parsedStartDate = _parseDate(json['StartDate'] ?? json['startDate']);
    DateTime? parsedCreatedAt = _parseDate(json['CreatedAt'] ?? json['createdAt']);
    DateTime? parsedCountDate = _parseDate(json['CountDate'] ?? json['countDate']);

    return InventorySession(
      id: json['SessionID'] ?? json['sessionID'] ?? json['sessionId'] ?? 0, 
      warehouseId: json['WarehouseID'] ?? json['warehouseID'] ?? json['warehouseId'] ?? 0,
      warehouseName: json['WarehouseName'] ?? json['warehouseName'],
      sessionCode: (json['SessionCode'] ?? json['sessionCode'])?.toString() ?? '',
      countType: _parseCountType(json['CountType'] ?? json['countType']),
      status: _parseStatus(json['Status'] ?? json['status']),
      description: (json['Description'] ?? json['description'])?.toString() ?? '',
      startDate: parsedStartDate ?? parsedCreatedAt ?? parsedCountDate ?? DateTime.now(),
      endDate: _parseDate(json['EndDate'] ?? json['endDate']),
      countDate: parsedCountDate ?? parsedStartDate ?? parsedCreatedAt ?? DateTime.now(),
      createdBy: json['CreatedBy'] ?? json['createdBy'] ?? 0,
      createdByName: json['CreatedByName'] ?? json['createdByName'],
      assignedTo: json['AssignedTo'] ?? json['assignedTo'],
      assignedToName: json['AssignedToName'] ?? json['assignedToName'],
      details: (json['Details'] ?? json['details']) != null 
          ? List<InventoryCountDetail>.from(((json['Details'] ?? json['details']) as List).map((e) => InventoryCountDetail.fromJson(e as Map<String, dynamic>)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
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
      'startDate': startDate.toUtc().add(const Duration(hours: 7)).toIso8601String(),
      'endDate': endDate?.toUtc().add(const Duration(hours: 7)).toIso8601String(),
      'countDate': countDate.toUtc().add(const Duration(hours: 7)).toIso8601String(),
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'details': details?.map((d) => d.toJson()).toList() ?? [],
    };
  }
}

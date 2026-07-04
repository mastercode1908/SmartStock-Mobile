import 'picking_detail.dart';

class PickingTask {
  final int taskId;
  final String taskCode;
  final int? assignedTo;
  final int status; // 0: PENDING, 1: IN_PROGRESS, 2: COMPLETED, 3: CANCELLED
  final int createdBy;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<PickingDetail>? details;

  PickingTask({
    required this.taskId,
    required this.taskCode,
    this.assignedTo,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.details,
  });

  factory PickingTask.fromJson(Map<String, dynamic> json) {
    return PickingTask(
      taskId: json['taskID'] ?? json['taskId'] ?? 0,
      taskCode: json['taskCode'] ?? '',
      assignedTo: json['assignedTo'],
      status: json['status'] ?? 0,
      createdBy: json['createdBy'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      details: json['details'] != null
          ? (json['details'] as List)
              .map((e) => PickingDetail.fromJson(e))
              .toList()
          : null,
    );
  }
}

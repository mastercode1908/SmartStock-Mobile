import 'package:flutter/material.dart';
import '../models/picking_task.dart';
import '../services/picking_service.dart';

class PickingProvider extends ChangeNotifier {
  final PickingService _service = PickingService();

  List<PickingTaskModel> _pickingTasks = [];
  PickingTaskModel? _currentTask;
  List<UnassignedIssueModel> _unassignedIssues = [];
  List<PickingUserModel> _staffs = [];

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  bool _isLoadingAssign = false;
  double _completionProgress = 0.0;

  List<PickingTaskModel> get pickingTasks => _pickingTasks;
  PickingTaskModel? get currentTask => _currentTask;
  List<UnassignedIssueModel> get unassignedIssues => _unassignedIssues;
  List<PickingUserModel> get staffs => _staffs;

  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingAssign => _isLoadingAssign;
  double get completionProgress => _completionProgress;

  Future<void> fetchPickingTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _service.fetchPickingTasks();
      _pickingTasks = list.map((item) => PickingTaskModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching picking tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPickingTaskDetail(int id) async {
    _isLoadingDetail = true;
    _currentTask = null;
    _completionProgress = 0.0;
    notifyListeners();

    try {
      final data = await _service.fetchPickingTaskDetail(id);
      _currentTask = PickingTaskModel.fromJson(data);
      calculateProgress();
    } catch (e) {
      debugPrint('Error fetching picking task detail: $e');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void calculateProgress() {
    if (_currentTask == null || _currentTask!.details.isEmpty) {
      _completionProgress = 0.0;
      return;
    }

    int expectedSum = 0;
    int pickedSum = 0;

    for (var d in _currentTask!.details) {
      expectedSum += d.expectedQuantity;
      pickedSum += d.pickedQuantity.clamp(0, d.expectedQuantity);
    }

    _completionProgress = expectedSum > 0 ? (pickedSum / expectedSum) : 0.0;
  }

  Future<void> startTask(int id) async {
    _isLoadingDetail = true;
    notifyListeners();

    try {
      await _service.startPickingTask(id);
      await fetchPickingTaskDetail(id);
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> saveDraft(int id) async {
    if (_currentTask == null) return;
    
    _isLoadingDetail = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> draftDetails = _currentTask!.details.map((d) {
        return {
          'pickingDetailID': d.pickingDetailId,
          'pickedQuantity': d.pickedQuantity,
        };
      }).toList();

      await _service.savePickingTaskDraft(id, draftDetails);
      await fetchPickingTaskDetail(id);
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> completeTask(int id) async {
    _isLoadingDetail = true;
    notifyListeners();

    try {
      await _service.completePickingTask(id);
      await fetchPickingTaskDetail(id);
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnassignedIssues() async {
    _isLoadingAssign = true;
    notifyListeners();

    try {
      final list = await _service.fetchUnassignedIssues();
      _unassignedIssues = list.map((item) => UnassignedIssueModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching unassigned issues: $e');
    } finally {
      _isLoadingAssign = false;
      notifyListeners();
    }
  }

  Future<void> fetchStaffs() async {
    _isLoadingAssign = true;
    notifyListeners();

    try {
      final list = await _service.fetchStaffs();
      _staffs = list.map((item) => PickingUserModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching staffs: $e');
    } finally {
      _isLoadingAssign = false;
      notifyListeners();
    }
  }

  Future<void> assignTask(int issueId, int staffId) async {
    _isLoadingAssign = true;
    notifyListeners();

    try {
      await _service.assignPickingTask(issueId, staffId);
      await fetchUnassignedIssues();
      await fetchPickingTasks();
    } finally {
      _isLoadingAssign = false;
      notifyListeners();
    }
  }

  void updatePickedQty(int detailId, int val) {
    if (_currentTask == null) return;
    
    final index = _currentTask!.details.indexWhere((d) => d.pickingDetailId == detailId);
    if (index != -1) {
      _currentTask!.details[index].pickedQuantity = val;
      calculateProgress();
      notifyListeners();
    }
  }
}

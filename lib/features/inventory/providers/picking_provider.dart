import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../auth/providers/auth_provider.dart';
import '../models/picking_task.dart';
import '../models/picking_detail.dart';

class InventoryPickingProvider extends ChangeNotifier {
  final String baseUrl = 'https://10.0.2.2:7207/api';

  List<PickingTask> _tasks = [];
  bool _isLoading = false;
  String? _error;

  PickingTask? _currentTask;

  List<PickingTask> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PickingTask? get currentTask => _currentTask;

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthProvider.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/picking-tasks'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> dataList = [];
        if (data is Map && data.containsKey('value')) {
          dataList = data['value'];
        } else if (data is List) {
          dataList = data;
        }
        _tasks = dataList.map((e) => PickingTask.fromJson(e)).toList();
      } else {
        _error = 'Lỗi tải danh sách nhặt hàng: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Lỗi kết nối: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTaskDetail(int taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/picking-tasks/$taskId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          _currentTask = PickingTask.fromJson(data['data']);
        } else {
          _currentTask = PickingTask.fromJson(data);
        }
      } else {
        _error = 'Lỗi tải chi tiết: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Lỗi kết nối: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startTask(int taskId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/picking-tasks/$taskId/start'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        if (_currentTask != null) {
          _currentTask = PickingTask(
            taskId: _currentTask!.taskId,
            taskCode: _currentTask!.taskCode,
            status: 1, // IN_PROGRESS
            createdBy: _currentTask!.createdBy,
            createdAt: _currentTask!.createdAt,
            details: _currentTask!.details,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePickedQuantity(int detailId, int pickedQuantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/picking-tasks/details/$detailId/quantity'),
        headers: await _getHeaders(),
        body: json.encode(pickedQuantity),
      );

      if (response.statusCode == 200) {
        // Update local state
        if (_currentTask != null && _currentTask!.details != null) {
          final idx = _currentTask!.details!.indexWhere(
            (d) => d.pickingDetailId == detailId,
          );
          if (idx != -1) {
            final detail = _currentTask!.details![idx];
            detail.pickedQuantity = pickedQuantity;
            detail.status = (pickedQuantity == detail.expectedQuantity) ? 1 : 2;
            notifyListeners();
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> completeTask(int taskId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/picking-tasks/$taskId/complete'),
        headers: await _getHeaders(),
      );

      final data = json.decode(response.body);
      final isSuccess = response.statusCode == 200;
      final msg = data['message'] ?? data['Message'] ?? (isSuccess ? 'Hoàn tất nhiệm vụ nhặt hàng và cập nhật kho thành công.' : 'Lỗi không thể hoàn tất nhiệm vụ.');

      return {
        'success': isSuccess,
        'message': msg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối máy chủ: $e',
      };
    }
  }
}

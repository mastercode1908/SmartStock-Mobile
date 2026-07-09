import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<Map<String, dynamic>> _users = [];
  bool _isLoadingUsers = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  List<Map<String, dynamic>> get users => _users;
  bool get isLoadingUsers => _isLoadingUsers;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _service.fetchNotifications();
      _notifications = list;
      _unreadCount = _notifications.where((n) => n['isRead'] == false).length;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markRead(id);
      
      final index = _notifications.indexWhere((n) => n['notificationID'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
        _unreadCount = _notifications.where((n) => n['isRead'] == false).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllRead();
      for (var n in _notifications) {
        n['isRead'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> sendNotification({
    required String title,
    required String content,
    required String type,
    required String targetType,
    int? targetRoleId,
    List<int>? targetUserIds,
  }) async {
    await _service.sendNotification(
      title: title,
      content: content,
      type: type,
      targetType: targetType,
      targetRoleId: targetRoleId,
      targetUserIds: targetUserIds,
    );
  }

  Future<void> fetchUsers() async {
    _isLoadingUsers = true;
    notifyListeners();

    try {
      final list = await _service.fetchUsers();
      _users = list;
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }
}

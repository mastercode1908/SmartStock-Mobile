import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = await _authService.login(email, password);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(_currentUser!.toJson()));
      await prefs.setString('auth_token', _currentUser!.token);

      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('auth_token');
    notifyListeners();
  }

  Future<bool> updateUserProfile(String fullName, String phone, String avatarUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updateProfile(fullName, phone, avatarUrl);
      
      // Update local state
      if (_currentUser != null) {
        _currentUser = UserModel(
          userId: _currentUser!.userId,
          email: _currentUser!.email,
          fullName: fullName,
          phone: phone,
          avatarUrl: avatarUrl.isEmpty ? _currentUser!.avatarUrl : avatarUrl,
          roleName: _currentUser!.roleName,
          token: _currentUser!.token,
        );
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(_currentUser!.toJson()));
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadAvatar(String imagePath) async {
    try {
      _isLoading = true;
      notifyListeners();
      return await _authService.uploadAvatar(imagePath);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      if (_currentUser == null) throw Exception('Not logged in');
      
      await _authService.changePassword(_currentUser!.token, oldPassword, newPassword);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_data')) return false;

    final extractedUserData = json.decode(prefs.getString('user_data')!) as Map<String, dynamic>;
    _currentUser = UserModel.fromJson(extractedUserData);
    notifyListeners();
    return true;
  }
  
  // Helper to get token statically for Http services
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}

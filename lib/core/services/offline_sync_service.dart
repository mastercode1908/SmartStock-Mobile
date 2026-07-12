import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';
import '../../features/auth/providers/auth_provider.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isSyncing = false;
  final String _baseUrl = 'https://10.0.2.2:7207';

  factory OfflineSyncService() {
    return _instance;
  }

  OfflineSyncService._internal();

  void init() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        syncNow();
      }
    });
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }

  Future<void> savePendingRequest(String endpoint, Map<String, dynamic> payload) async {
    var uuid = const Uuid().v4();
    var now = DateTime.now().toIso8601String();
    
    await _dbHelper.insertPendingSync({
      'uuid': uuid,
      'timestamp': now,
      'endpoint': endpoint,
      'payload': jsonEncode(payload),
      'status': 0
    });
    print('Saved offline request: $uuid to $endpoint');
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingList = await _dbHelper.getPendingSyncs();
      if (pendingList.isEmpty) {
        _isSyncing = false;
        return;
      }

      print('Starting offline sync. Found ${pendingList.length} items.');

      for (var item in pendingList) {
        int id = item['id'];
        String endpoint = item['endpoint'];
        String payloadStr = item['payload'];
        Map<String, dynamic> payload = jsonDecode(payloadStr);

        bool success = false;
        
        try {
          final token = await AuthProvider.getToken();
          final user = await AuthProvider.getCurrentUserStatic();
          final headers = {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
            if (user != null) 'X-User-Id': user.userId.toString(),
          };

          final url = Uri.parse('$_baseUrl$endpoint');
          http.Response response;
          
          if (endpoint.endsWith('/submit')) {
             response = await http.post(url, headers: headers, body: jsonEncode(payload));
          } else {
             response = await http.put(url, headers: headers, body: jsonEncode(payload));
          }

          if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
            success = true;
          } else {
             print('API Error ${response.statusCode}: ${response.body}');
             // If it's a 4xx error (except 401 maybe), we might want to delete it or mark as failed so it doesn't block
             if (response.statusCode >= 400 && response.statusCode < 500) {
               // Hard fail -> remove it to avoid endless loop
               await _dbHelper.deletePendingSync(id);
             }
          }
        } catch (e) {
          print('Network error syncing item $id: $e');
        }

        if (success) {
          await _dbHelper.deletePendingSync(id);
          print('Successfully synced item: $id');
        } else {
          print('Failed to sync item: $id');
        }
      }
    } catch (e) {
      print('Error during offline sync: $e');
    } finally {
      _isSyncing = false;
    }
  }
}

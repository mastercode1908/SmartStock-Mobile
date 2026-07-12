import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../core/theme/app_colors.dart';

class PendingSyncScreen extends StatefulWidget {
  const PendingSyncScreen({super.key});

  @override
  State<PendingSyncScreen> createState() => _PendingSyncScreenState();
}

class _PendingSyncScreenState extends State<PendingSyncScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _groupedSyncs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingSyncs();
  }

  Future<void> _loadPendingSyncs() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getPendingSyncs();
    
    // Group by session ID
    Map<String, Map<String, dynamic>> groups = {};
    
    for (var item in data) {
      final payload = jsonDecode(item['payload']);
      String sessionId = (payload['session_id'] ?? payload['sessionID'] ?? 'Unknown').toString();
      
      if (!groups.containsKey(sessionId)) {
        groups[sessionId] = {
          'sessionId': sessionId,
          'sessionCode': payload['sessionCode'] ?? 'Chưa xác định',
          'timestamp': item['timestamp'],
          'productCount': 0,
          'relatedIds': <int>[],
        };
      }
      
      groups[sessionId]!['relatedIds'].add(item['id'] as int);
      
      if (item['endpoint'].toString().contains('inventory-counts') && !item['endpoint'].toString().endsWith('/submit')) {
         if (payload['details'] != null && payload['details'] is List) {
            groups[sessionId]!['productCount'] = (payload['details'] as List).length;
            groups[sessionId]!['sessionCode'] = payload['sessionCode'] ?? groups[sessionId]!['sessionCode'];
         }
      }
    }

    setState(() {
      _groupedSyncs = groups.values.toList();
      _isLoading = false;
    });
  }

  Future<void> _syncNow() async {
    await OfflineSyncService().syncNow();
    await _loadPendingSyncs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đồng bộ xong!')),
      );
    }
  }

  Future<void> _deleteGroup(List<int> ids) async {
    for (var id in ids) {
      await _dbHelper.deletePendingSync(id);
    }
    await _loadPendingSyncs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Smart Stock',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.primary),
            onPressed: _syncNow,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.wifi_off, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Dữ liệu sẽ tự động được gửi lên hệ thống khi thiết bị kết nối mạng trở lại.',
                    style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _groupedSyncs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            const Text('Không có dữ liệu chờ đồng bộ', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _groupedSyncs.length,
                        itemBuilder: (context, index) {
                          final group = _groupedSyncs[index];
                          
                          String title = 'Gửi duyệt phiếu ${group['sessionCode']}';
                          String subtitle = 'Số lượng sản phẩm đếm: ${group['productCount']}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), 
                              side: BorderSide(color: Colors.red.withValues(alpha: 0.3))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title, 
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)
                                        ),
                                      ),
                                      Text(
                                        '${group['timestamp']}'.split('T').first, 
                                        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () => _deleteGroup(group['relatedIds'] as List<int>),
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      label: const Text('Xóa', style: TextStyle(color: Colors.red, fontSize: 16)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // Go home button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text('Trở về Trang chủ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

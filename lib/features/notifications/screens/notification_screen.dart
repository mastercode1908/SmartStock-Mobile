import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'create_notification_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedTabIndex = 0; // 0 for "Tất cả", 1 for "Chưa đọc"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  String _getRelativeTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Bây giờ';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays < 7) return '${diff.inDays} ngày trước';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return 'Gần đây';
    }
  }

  void _showNotificationDetail(
    BuildContext context, {
    required String title,
    required String content,
    required String timeStr,
    required String typeLabel,
    required IconData iconData,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xffb3272e),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text(
                  'ĐÓNG',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final provider = context.watch<NotificationProvider>();
    final isLoading = provider.isLoading;
    
    // Filter notifications based on tab
    final List<Map<String, dynamic>> filteredList = _selectedTabIndex == 0
        ? provider.notifications
        : provider.notifications.where((n) => n['isRead'] == false).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb3272e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.inventory_2, color: Color(0xffb3272e)),
            SizedBox(width: 8),
            Text(
              'Smart Stock',
              style: TextStyle(
                color: Color(0xffb3272e),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xffb3272e)),
                onPressed: () {},
              ),
              if (provider.unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xffb3272e),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      provider.unreadCount > 99 ? '99+' : provider.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchNotifications(),
        color: const Color(0xffb3272e),
        child: isLoading && provider.notifications.isEmpty
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    const Text(
                      'Thông báo',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Quản lý cảnh báo và cập nhật của bạn.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    // Tabs and Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xffe4f0f4),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              _buildTabButton('Tất cả', 0),
                              _buildTabButton('Chưa đọc', 1),
                            ],
                          ),
                        ),
                        if (provider.unreadCount > 0)
                          TextButton.icon(
                            onPressed: () => provider.markAllAsRead(),
                            icon: const Icon(Icons.done_all, size: 16, color: Color(0xffb3272e)),
                            label: const Text(
                              'ĐỌC TẤT CẢ',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xffb3272e)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Notifications List
                    if (filteredList.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80.0),
                          child: Column(
                            children: [
                              Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text(
                                'Không có thông báo nào.',
                                style: TextStyle(color: Colors.grey[500], fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        itemBuilder: (context, idx) {
                          final item = filteredList[idx];
                          final id = item['notificationID'] as int;
                          final isRead = item['isRead'] as bool;
                          final type = item['type'] as String? ?? 'INFO';
                          final title = item['title'] as String? ?? '';
                          final content = item['content'] as String? ?? '';
                          final timeStr = _getRelativeTime(item['createdAt'] as String?);

                          // Style parameters based on notification type
                          IconData iconData = Icons.info_outline;
                          Color iconColor = const Color(0xff1268f3);
                          Color iconBgColor = const Color(0xffe4f0f4);
                          String typeLabel = 'Hệ thống';

                          if (type == 'WARNING') {
                            iconData = Icons.warning_amber_rounded;
                            iconColor = const Color(0xffba1a1a);
                            iconBgColor = const Color(0xffffdad6);
                            typeLabel = 'Cảnh báo';
                          } else if (type == 'TASK') {
                            iconData = Icons.assignment_outlined;
                            iconColor = const Color(0xff006a67);
                            iconBgColor = const Color(0xffe2f4f2);
                            typeLabel = 'Nhiệm vụ';
                          } else if (type == 'SYSTEM') {
                            iconData = Icons.settings_suggest_outlined;
                            iconColor = const Color(0xff586062);
                            iconBgColor = const Color(0xffdae1e3);
                            typeLabel = 'Hệ thống';
                          }

                          return GestureDetector(
                            onTap: () {
                              if (!isRead) {
                                provider.markAsRead(id);
                              }
                              _showNotificationDetail(
                                context,
                                title: title,
                                content: content,
                                timeStr: timeStr,
                                typeLabel: typeLabel,
                                iconData: iconData,
                                iconColor: iconColor,
                                iconBgColor: iconBgColor,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isRead ? const Color(0xfff8f9fa) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isRead ? Colors.grey[100]! : const Color(0xffb3272e).withOpacity(0.15),
                                  width: isRead ? 1 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isRead ? 0.02 : 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: iconBgColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(iconData, color: iconColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      title,
                                                      style: TextStyle(
                                                        fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                                        fontSize: 15,
                                                        color: isRead ? Colors.black54 : Colors.black87,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: iconBgColor,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      typeLabel.toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 9, 
                                                        fontWeight: FontWeight.bold, 
                                                        color: iconColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              timeStr,
                                              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          content,
                                          style: TextStyle(
                                            fontSize: 13, 
                                            color: isRead ? Colors.black54 : Colors.black87,
                                            fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
      floatingActionButton: user?.roleName == 'Admin'
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateNotificationScreen()),
                );
              },
              backgroundColor: const Color(0xffb3272e),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Gửi thông báo', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffb3272e) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

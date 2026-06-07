import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedTabIndex = 0; // 0 for "Tất cả", 1 for "Chưa đọc"

  @override
  Widget build(BuildContext context) {
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
        title: Row(
          children: const [
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
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xffb3272e),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
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
      body: SingleChildScrollView(
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
                Row(
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
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xffe4f0f4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(Icons.filter_list, size: 20, color: Colors.black54),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.done_all, size: 16, color: Color(0xffb3272e)),
                  label: const Text(
                    'ĐÁNH DẤU ĐÃ ĐỌC',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xffb3272e)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notifications List
            _buildNotificationItem(
              icon: Icons.warning,
              iconColor: const Color(0xffba1a1a),
              iconBgColor: const Color(0xffffdad6),
              title: 'Cảnh báo sắp hết hàng',
              tag: 'Kho hàng',
              tagColor: const Color(0xffba1a1a),
              tagBgColor: const Color(0xffffdad6).withOpacity(0.5),
              time: '10 phút trước',
              description: 'SKU-8924 (Ghế văn phòng cao cấp) dưới ngưỡng tối thiểu. Số lượng hiện tại: 4. Đề nghị nhập thêm.',
              actionText: 'XEM CHI TIẾT',
              isRead: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.assignment,
              iconColor: const Color(0xff006a67),
              iconBgColor: const Color(0xff00a7a3).withOpacity(0.2),
              title: 'Nhiệm vụ nhập hàng mới',
              tag: 'Nhiệm vụ',
              tagColor: const Color(0xff006a67),
              tagBgColor: const Color(0xff00a7a3).withOpacity(0.2),
              time: '1 giờ trước',
              description: 'Bạn đã được phân công nhập hàng lối đi 4 trước 3:00 chiều nay.',
              actionText: 'XEM NHIỆM VỤ',
              isRead: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.update,
              iconColor: const Color(0xff586062),
              iconBgColor: const Color(0xffdae1e3),
              title: 'Bảo trì hệ thống',
              tag: 'Hệ thống',
              tagColor: const Color(0xff586062),
              tagBgColor: const Color(0xffdae1e3),
              time: 'Hôm qua',
              description: 'Bảo trì theo lịch trình đã hoàn tất. Hiệu suất đồng bộ hóa được cải thiện 15%.',
              isRead: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.inventory_2,
              iconColor: const Color(0xff59413f),
              iconBgColor: const Color(0xffd9e4e9),
              title: 'Đã nhận lô hàng',
              tag: 'Kho hàng',
              tagColor: const Color(0xff59413f),
              tagBgColor: const Color(0xffd9e4e9),
              time: '2 ngày trước',
              description: 'PO-10492 đã được nhận đủ và xử lý vào kho chính.',
              isRead: true,
            ),
          ],
        ),
      ),
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

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String tag,
    required Color tagColor,
    required Color tagBgColor,
    required String time,
    required String description,
    String? actionText,
    required bool isRead,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Opacity(
        opacity: isRead ? 0.7 : 1.0,
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
              child: Icon(icon, color: iconColor, size: 20),
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: tagBgColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag.toUpperCase(),
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (actionText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      actionText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

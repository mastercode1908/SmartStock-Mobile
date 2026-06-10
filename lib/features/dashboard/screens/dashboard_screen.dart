import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9), // background
      appBar: AppBar(
        backgroundColor: const Color(0xfff9f9f9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb02528)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            Icon(Icons.inventory_2, color: Color(0xffb02528)),
            SizedBox(width: 8),
            Text(
              'Smart Stock',
              style: TextStyle(
                color: Color(0xffb02528),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xffb02528)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffe2bebb)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Chào, Nguyễn Văn A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text('Ca làm việc: Sáng - Kho A1', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xffe2bebb)),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuA2ZMo_FiXgpE1zMS7rFGZ9UQrD2_fWQ79mw0_DhVVwNxwYfc7IVZbvAQ9YNz8hdmPfY7a3mKbF6w30d0xSqA0-9R6sgXNclIu341RyY51-xKyHeikASs07E8VKcKZWd_8KXNK_PZg_uPRqBSci-ZuDzXgnL1qNgh4n80pUSLA3NjgGaceyEH4SuGV1CAfQzXXUKwq4tuJgRkgVE2W2kl2ZVdhFpt3jIaCxGque3m-P-hYMqoILs438_ZbDGn_uZXlFF9BUBnX5f8Bm',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary Cards (Bento Grid)
            Row(
              children: [
                // Large Primary Card
                Expanded(
                  child: Container(
                    height: 160,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffb02528),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          right: -16,
                          top: -16,
                          child: Opacity(
                            opacity: 0.1,
                            child: Icon(Icons.category, size: 80, color: Colors.white),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Đơn kiểm kê hôm nay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xffffb3ae))),
                            SizedBox(height: 8),
                            Text('24,560', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                            Spacer(),
                            Text('+120 hôm nay', style: TextStyle(fontSize: 12, color: Color(0xffffb3ae))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Stacked Small Cards
                Expanded(
                  child: SizedBox(
                    height: 160,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xffe2bebb)),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text('ĐÃ QUÉT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.0)),
                                    SizedBox(height: 4),
                                    Text('1,240 mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  ],
                                ),
                                const Icon(Icons.trending_up, color: Color(0xff93405f)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xffffdad6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xffba1a1a).withOpacity(0.2)),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text('LỆCH TỒN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff93000a), letterSpacing: 1.0)),
                                    SizedBox(height: 4),
                                    Text('18', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff93000a))),
                                  ],
                                ),
                                const Icon(Icons.pending_actions, color: Color(0xffba1a1a)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Access Grid
            const Text('Truy cập nhanh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickAccessButton(icon: Icons.analytics, label: 'Báo cáo', bgColor: const Color(0xffd23e3e), iconColor: Colors.white),
                _buildQuickAccessButton(icon: Icons.assignment, label: 'Nhiệm vụ', bgColor: const Color(0xffd23e3e), iconColor: Colors.white),
                _buildQuickAccessButton(icon: Icons.inventory_2, label: 'Kiểm kê', bgColor: const Color(0xffe2e2e2), iconColor: const Color(0xff5a413f), isOutline: true),
                _buildQuickAccessButton(icon: Icons.location_on, label: 'Vị trí kho', bgColor: const Color(0xffb02528), iconColor: Colors.white),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Hoạt động gần đây', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                InkWell(
                  onTap: () {},
                  child: const Text('Xem tất cả', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xffb02528))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.inventory,
              title: 'Kiểm kê - Kệ B-04',
              time: '10:45',
              subtitle: 'Người thực hiện: N.V.A',
              status: 'Hoàn thành',
              statusColor: const Color(0xfffffbff),
              statusBgColor: const Color(0xffb15878),
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              icon: Icons.inventory_2,
              title: 'Kiểm kê - Khu vực A1',
              time: '09:15',
              subtitle: 'Đang đối soát dữ liệu',
              status: 'Đang thực hiện',
              statusColor: const Color(0xff5a666d),
              statusBgColor: const Color(0xffd7e4ec),
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              icon: Icons.inventory,
              iconColor: const Color(0xff93000a),
              iconBgColor: const Color(0xffffdad6),
              title: 'Kiểm kê - Kệ A2',
              time: 'Hôm qua',
              subtitle: 'Sai lệch: -2 sản phẩm',
              subtitleColor: const Color(0xffba1a1a),
              status: 'Cần xử lý',
              statusColor: const Color(0xff93000a),
              statusBgColor: const Color(0xffffdad6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton({required IconData icon, required String label, required Color bgColor, required Color iconColor, bool isOutline = false}) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: isOutline ? Border.all(color: const Color(0xffe2bebb)) : null,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    Color iconColor = const Color(0xffb02528),
    Color iconBgColor = const Color(0xffe2e2e2),
    required String title,
    required String time,
    required String subtitle,
    Color subtitleColor = Colors.black54,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe2bebb)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
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
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54, letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(subtitle, style: TextStyle(fontSize: 14, color: subtitleColor)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 12, color: statusColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

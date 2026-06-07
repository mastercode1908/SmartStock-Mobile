import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xffb3272e)),
            onPressed: () {},
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
          children: [
            // User Profile Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[200]!),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAD7zmLWNW5ORi57UMI6NSB0K4bd4KOX92OGJsQVott_aO0oCc-7j-kWGF5TH1yVGkkyml0zAFy-BAveCO5vSVafCubOBcYoOw26B6g79A5nZobp0Q1aRKXg7YSUG8KXEqhg7_X8ZzsMHkzd_j73qiUjbHbzsDZuSchQFhv-ovBcv-YZFZvTj7OYLnRtuTtxWUcCny76i3S2hUjsKJYO3_4xqOBs-MhjhPB4n55EkMrw5WEtEGszq4ir63DVCJZIjKKAX38hvZf-PPM',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xffb3272e),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nguyễn Văn An',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      children: [
                        TextSpan(text: 'Mã NV: '),
                        TextSpan(
                          text: 'NV-8821',
                          style: TextStyle(color: Color(0xffb3272e), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.warehouse, size: 16, color: Colors.black54),
                        SizedBox(width: 4),
                        Text('Kho Chính - Tầng 1', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Sections
            _buildSection(
              title: 'TÀI KHOẢN',
              children: [
                _buildSettingsItem(Icons.manage_accounts, 'Chỉnh sửa thông tin cá nhân', hasArrow: true),
                _buildDivider(),
                _buildSettingsItem(Icons.lock_reset, 'Đổi mật khẩu', hasArrow: true),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: 'CÀI ĐẶT ỨNG DỤNG',
              children: [
                _buildSettingsItem(Icons.language, 'Ngôn ngữ', trailingText: 'Tiếng Việt', hasArrow: true),
                _buildDivider(),
                _buildSettingsItem(Icons.notifications, 'Thông báo', hasSwitch: true, switchValue: true),
                _buildDivider(),
                _buildSettingsItem(Icons.dark_mode, 'Giao diện tối', hasSwitch: true, switchValue: false),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: 'HỖ TRỢ & BẢO MẬT',
              children: [
                _buildSettingsItem(Icons.menu_book, 'Hướng dẫn sử dụng', hasArrow: true),
                _buildDivider(),
                _buildSettingsItem(Icons.shield, 'Chính sách bảo mật', hasArrow: true),
                _buildDivider(),
                _buildSettingsItem(Icons.bug_report, 'Phản hồi lỗi', hasArrow: true),
              ],
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb3272e),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    bool hasArrow = false,
    String? trailingText,
    bool hasSwitch = false,
    bool switchValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black54, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          if (hasArrow)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.chevron_right, color: Colors.black38),
            ),
          if (hasSwitch)
            Switch(
              value: switchValue,
              onChanged: (val) {},
              activeColor: const Color(0xffb3272e),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey[100]);
  }
}

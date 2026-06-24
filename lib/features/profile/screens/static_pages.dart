import 'package:flutter/material.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB3272E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hướng dẫn sử dụng', style: TextStyle(color: Color(0xFFB3272E), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('1. Cách tạo phiếu kiểm kê', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Vào mục "Kiểm kê", nhấn nút dấu + ở góc dưới bên phải. Chọn kho và bắt đầu kiểm đếm.'),
            SizedBox(height: 24),
            Text('2. Cách quét mã vạch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Trong màn hình chi tiết phiếu, nhấn nút quét mã hoặc chuyển sang tab "Scan" để sử dụng camera. Đưa mã vạch sản phẩm vào khung để tự động nhận dạng.'),
            SizedBox(height: 24),
            Text('3. Đồng bộ dữ liệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Sau khi đếm xong toàn bộ sản phẩm, nhấn "Hoàn thành & Đồng bộ" để hệ thống tính toán chênh lệch và gửi lên quản lý phê duyệt.'),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB3272E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chính sách bảo mật', style: TextStyle(color: Color(0xFFB3272E), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Chính sách bảo mật dữ liệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('SmartStock cam kết bảo vệ thông tin cá nhân và dữ liệu hàng hóa của doanh nghiệp bạn.'),
            SizedBox(height: 16),
            Text('1. Thu thập dữ liệu', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Chúng tôi chỉ thu thập các dữ liệu cần thiết phục vụ cho việc quản lý kho (hình ảnh, số lượng, lịch sử thao tác).'),
            SizedBox(height: 16),
            Text('2. Lưu trữ an toàn', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Toàn bộ dữ liệu được mã hóa và lưu trữ trên hệ thống máy chủ bảo mật tiêu chuẩn quốc tế.'),
            SizedBox(height: 16),
            Text('3. Quyền riêng tư', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Bạn hoàn toàn có quyền yêu cầu xóa hoặc xuất dữ liệu tài khoản bất kỳ lúc nào.'),
          ],
        ),
      ),
    );
  }
}

class BugReportScreen extends StatelessWidget {
  const BugReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB3272E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Phản hồi lỗi', style: TextStyle(color: Color(0xFFB3272E), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Gửi phản hồi lỗi hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Mô tả chi tiết lỗi bạn gặp phải...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cảm ơn bạn đã phản hồi!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3272E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('GỬI PHẢN HỒI', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

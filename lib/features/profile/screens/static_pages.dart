import 'package:flutter/material.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hướng dẫn sử dụng', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Cách tạo phiếu kiểm kê', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text('Vào mục "Kiểm kê", nhấn nút dấu + ở góc dưới bên phải. Chọn kho và bắt đầu kiểm đếm.', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            Text('2. Cách quét mã vạch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text('Trong màn hình chi tiết phiếu, nhấn nút quét mã hoặc chuyển sang tab "Scan" để sử dụng camera. Đưa mã vạch sản phẩm vào khung để tự động nhận dạng.', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            Text('3. Đồng bộ dữ liệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text('Sau khi đếm xong toàn bộ sản phẩm, nhấn "Hoàn thành & Đồng bộ" để hệ thống tính toán chênh lệch và gửi lên quản lý phê duyệt.', style: TextStyle(color: cs.onSurfaceVariant)),
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Chính sách bảo mật', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chính sách bảo mật dữ liệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 16),
            Text('SmartStock cam kết bảo vệ thông tin cá nhân và dữ liệu hàng hóa của doanh nghiệp bạn.', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            Text('1. Thu thập dữ liệu', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            Text('Chúng tôi chỉ thu thập các dữ liệu cần thiết phục vụ cho việc quản lý kho (hình ảnh, số lượng, lịch sử thao tác).', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            Text('2. Lưu trữ an toàn', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            Text('Toàn bộ dữ liệu được mã hóa và lưu trữ trên hệ thống máy chủ bảo mật tiêu chuẩn quốc tế.', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            Text('3. Quyền riêng tư', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            Text('Bạn hoàn toàn có quyền yêu cầu xóa hoặc xuất dữ liệu tài khoản bất kỳ lúc nào.', style: TextStyle(color: cs.onSurfaceVariant)),
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Phản hồi lỗi', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Gửi phản hồi lỗi hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
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
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
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

import 'package:flutter/material.dart';

class CreateInventoryScreen extends StatelessWidget {
  const CreateInventoryScreen({Key? key}) : super(key: key);

  // Define Colors from Tailwind Config
  final Color _primary = const Color(0xFFB3272E);
  final Color _surface = const Color(0xFFF1FBFF);
  final Color _surfaceContainerHighest = const Color(0xFFD9E4E9);
  final Color _surfaceContainerLow = const Color(0xFFEAF5FA);
  final Color _surfaceVariant = const Color(0xFFD9E4E9);
  
  final Color _onSurface = const Color(0xFF131D21);
  final Color _onSurfaceVariant = const Color(0xFF59413F);
  final Color _primaryContainer = const Color(0xFFFF5F5F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672), // max-w-2xl
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Điền thông tin chi tiết để bắt đầu quá trình kiểm kê kho mới.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _buildForm(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 64), // pb-32
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: _surfaceContainerHighest, width: 1)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _onSurfaceVariant),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Tạo phiếu kiểm kê',
        style: TextStyle(
          color: _primary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(Icons.inventory_2, color: _primary),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDropdownField('TÊN KHO', Icons.warehouse, 'Chọn kho cần kiểm kê...'),
          const SizedBox(height: 24),
          _buildTextField('VỊ TRÍ', Icons.location_on, 'VD: Kệ A-12, Khu vực 1'),
          const SizedBox(height: 24),
          _buildTextField('NGÀY KIỂM KÊ', Icons.calendar_today, '2023-10-27'),
          const SizedBox(height: 24),
          _buildReadOnlyField('NGƯỜI THỰC HIỆN', Icons.person, 'Nguyễn Văn A'),
          const SizedBox(height: 24),
          _buildTextArea('GHI CHÚ', 'Nhập ghi chú hoặc lý do kiểm kê...'),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _surfaceVariant),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _onSurfaceVariant.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: Text(hint),
            items: const [
              DropdownMenuItem(value: 'main', child: Text('Kho Chính')),
              DropdownMenuItem(value: 'parts_a', child: Text('Kho Linh Kiện A')),
              DropdownMenuItem(value: 'export_b', child: Text('Kho Xuất B')),
            ],
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _onSurfaceVariant.withOpacity(0.6)),
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryContainer, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: value),
          style: TextStyle(color: _onSurfaceVariant),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _onSurfaceVariant.withOpacity(0.6)),
            filled: true,
            fillColor: _surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _surfaceVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryContainer, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.play_arrow),
            SizedBox(width: 8),
            Text(
              'Bắt đầu kiểm kê',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

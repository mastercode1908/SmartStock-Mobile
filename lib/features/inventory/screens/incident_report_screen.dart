import 'package:flutter/material.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

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
        title: const Text(
          'Báo cáo Sự cố',
          style: TextStyle(
            color: Color(0xffb3272e),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xffff5f5f).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: Color(0xffb3272e), size: 24),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 100, // Space for footer
        ),
        child: Column(
          children: [
            // Section: Identification
            _buildSection(
              children: [
                _buildLabel('SẢN PHẨM / SKU', isRequired: true),
                const SizedBox(height: 8),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xfff1fbff),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffe1bebc)),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Nhập tên hoặc mã SKU...',
                      hintStyle: TextStyle(color: Colors.black38),
                      prefixIcon: Icon(Icons.search, color: Colors.black54),
                      suffixIcon: Icon(Icons.qr_code_scanner, color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('VỊ TRÍ HIỆN TẠI'),
                const SizedBox(height: 8),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xffe4f0f4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffe1bebc).withOpacity(0.5)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.black54, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Khu vực A • Kệ 04 • Tầng 2',
                          style: TextStyle(color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.lock, color: Colors.black38, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section: Issue Details
            _buildSection(
              children: [
                _buildLabel('LOẠI SỰ CỐ', isRequired: true),
                const SizedBox(height: 8),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xfff1fbff),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffe1bebc)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Chọn loại sự cố...', style: TextStyle(color: Colors.black54)),
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.arrow_drop_down, color: Colors.black54),
                      ),
                      items: const [
                        DropdownMenuItem(value: '1', child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Hư hỏng vật lý'))),
                        DropdownMenuItem(value: '2', child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Thiếu số lượng'))),
                        DropdownMenuItem(value: '3', child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Sai sản phẩm'))),
                      ],
                      onChanged: (val) {},
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('SỐ LƯỢNG ẢNH HƯỞNG'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: _decrementQuantity,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xfff1fbff),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffe1bebc)),
                        ),
                        child: const Icon(Icons.remove, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xfff1fbff),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffe1bebc)),
                        ),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _incrementQuantity,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xfff1fbff),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffe1bebc)),
                        ),
                        child: const Icon(Icons.add, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section: Evidence
            _buildSection(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('ĐÍNH KÈM HÌNH ẢNH'),
                    const Text('Tối đa 4 ảnh', style: TextStyle(fontSize: 12, color: Colors.black38)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Camera Button
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xfff1fbff),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xffe1bebc), width: 2, style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt, color: Colors.black54, size: 24),
                              SizedBox(height: 4),
                              Text('CHỤP ẢNH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Placeholder 1
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffd9e4e9).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xffe1bebc).withOpacity(0.3)),
                              ),
                              child: const Center(child: Icon(Icons.image, color: Colors.black26, size: 32)),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(color: Color(0xffba1a1a), shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Placeholder 2
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffe4f0f4).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xffd9e4e9)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Placeholder 3
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffe4f0f4).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xffd9e4e9)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section: Notes
            _buildSection(
              children: [
                _buildLabel('GHI CHÚ CHI TIẾT'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfff1fbff),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffe1bebc)),
                  ),
                  child: const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Mô tả chi tiết tình trạng sự cố để hỗ trợ quá trình xử lý...',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffb3272e),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 4,
            ),
            icon: const Icon(Icons.send),
            label: const Text('Gửi báo cáo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 0.5),
        ),
        if (isRequired)
          const Text('*', style: TextStyle(color: Color(0xffba1a1a), fontWeight: FontWeight.bold)),
      ],
    );
  }
}

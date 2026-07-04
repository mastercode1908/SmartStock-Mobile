import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'count_step4_screen.dart';

class CountStep3Screen extends StatefulWidget {
  const CountStep3Screen({Key? key}) : super(key: key);

  @override
  State<CountStep3Screen> createState() => _CountStep3ScreenState();
}

class _CountStep3ScreenState extends State<CountStep3Screen> {
  int _quantity = 50;

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  _buildProgressHeader(),
                  const SizedBox(height: 32),
                  _buildProductDetailsCard(),
                  const SizedBox(height: 32),
                  _buildQuantityControl(),
                  const SizedBox(height: 120), // Padding for sticky bottom area
                ],
              ),
            ),
          ),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.primary),
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
      ),
      centerTitle: true,
      title: const Text(
        'Warehouse Pro',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        const Text(
          'Bước 3/5: Nhập số lượng',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Kiểm đếm và nhập số lượng thực tế tại vị trí',
          style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.6, // 3/5
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAwEoDaXP6eOLaXhYLmu1LctAW5sBPE0mjZ0lMqgmadL3iB_Me7zlR4cO-_aPu7eOBk5IE1_13Sw_bM9Ti97UTHEMqnz-dRKOwQ8mTE6UNvCfxW1WG-kzvrOH7w3W_DzI5oo1QgMrcd6LWEktEB0GroDZZ0sdTYOsV6Eq08hy7r4LD6D0gUaeSojZ9FgVesA9JetI9_7AV72u7xYQSOBU2QXOmmlC0pC0rahj3q7d4s2WEe8pn5Mn3qpJnwsopa4AGdVVi8NmiUyy1w'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Găng tay bảo hộ cao cấp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    const SizedBox(height: 4),
                    const Text('Mã SP: SK-GL-992', style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    const Text('Vị trí: Rack A2, Kệ 04', style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Số lượng hệ thống:', style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant)),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppColors.onSurface),
                    children: [
                      TextSpan(text: '50 ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Cái', style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Column(
      children: [
        const Text('Số lượng thực tế', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQtyButton(Icons.remove, _decrement),
            const SizedBox(width: 16),
            Container(
              width: 120,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0x1AFEEBEE),
                border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 2)),
              ),
              alignment: Alignment.center,
              child: Text(
                '$_quantity',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildQtyButton(Icons.add, _increment),
          ],
        ),
      ],
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 32, color: AppColors.onSurface),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      foregroundColor: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.report, color: AppColors.primary),
                    label: const Text('Báo thiếu'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      foregroundColor: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                    label: const Text('Quét lại'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                minimumSize: const Size(double.infinity, 56),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CountStep4Screen()));
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Tiếp theo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

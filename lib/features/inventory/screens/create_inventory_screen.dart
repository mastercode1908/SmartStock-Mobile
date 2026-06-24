import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'choose_product_screen.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_session.dart';

class CreateInventoryScreen extends StatefulWidget {
  const CreateInventoryScreen({Key? key}) : super(key: key);

  @override
  State<CreateInventoryScreen> createState() => _CreateInventoryScreenState();
}

class _CreateInventoryScreenState extends State<CreateInventoryScreen> {
  // Define Colors from Tailwind Config
  final Color _primary = const Color(0xFFB3272E);
  final Color _surface = const Color(0xFFF1FBFF);
  final Color _surfaceContainerHighest = const Color(0xFFD9E4E9);
  final Color _surfaceContainerLow = const Color(0xFFEAF5FA);
  final Color _surfaceVariant = const Color(0xFFD9E4E9);
  
  final Color _onSurface = const Color(0xFF131D21);
  final Color _onSurfaceVariant = const Color(0xFF59413F);
  final Color _primaryContainer = const Color(0xFFFF5F5F);

  int? _selectedWarehouseId;
  int? _selectedLocationId;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadWarehouses();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_selectedWarehouseId == null || _selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn kho và vị trí')),
      );
      return;
    }

    final provider = context.read<InventoryProvider>();
    final newSession = InventorySession(
      id: 0, // Server will generate the ID
      warehouseId: _selectedWarehouseId!,
      sessionCode: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      countType: 'FULL',
      status: 'DRAFT', // Trạng thái nháp để hỗ trợ offline sync
      description: 'Location ID: $_selectedLocationId - ${_notesController.text}',
      startDate: DateTime.now(),
      createdBy: 1, // Mock user ID
    );

    await provider.addSession(newSession);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChooseProductScreen()),
      );
    }
  }

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
                _buildSubmitButton(context),
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
          _buildWarehouseDropdown(),
          const SizedBox(height: 24),
          _buildLocationDropdown(),
          const SizedBox(height: 24),
          _buildReadOnlyField('NGÀY KIỂM KÊ', Icons.calendar_today, DateTime.now().toString().split(' ')[0]),
          const SizedBox(height: 24),
          _buildReadOnlyField('NGƯỜI THỰC HIỆN', Icons.person, 'Nguyễn Văn A'),
          const SizedBox(height: 24),
          _buildTextArea('GHI CHÚ', 'Nhập ghi chú hoặc lý do kiểm kê...', _notesController),
        ],
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.warehouses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TÊN KHO',
              style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _surfaceVariant),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedWarehouseId,
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.warehouse, color: _onSurfaceVariant.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Chọn kho cần kiểm kê...'),
                items: provider.warehouses.map((w) {
                  return DropdownMenuItem<int>(
                    value: w.id,
                    child: Text(w.warehouseName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWarehouseId = value;
                    _selectedLocationId = null; // reset location
                  });
                },
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildLocationDropdown() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.locations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredLocations = provider.locations
            .where((l) => l.warehouseId == _selectedWarehouseId)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VỊ TRÍ',
              style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _surfaceVariant),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedLocationId,
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on, color: _onSurfaceVariant.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Chọn vị trí...'),
                items: filteredLocations.map((l) {
                  return DropdownMenuItem<int>(
                    value: l.locationId,
                    child: Text(l.locationCode),
                  );
                }).toList(),
                onChanged: _selectedWarehouseId == null ? null : (value) {
                  setState(() {
                    _selectedLocationId = value;
                  });
                },
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildTextField(String label, IconData icon, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
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

  Widget _buildTextArea(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
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

  Widget _buildSubmitButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: _submitForm,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storage_location_provider.dart';
import '../models/storage_location.dart';

class StorageLocationFormScreen extends StatefulWidget {
  final StorageLocation? location;

  const StorageLocationFormScreen({super.key, this.location});

  @override
  State<StorageLocationFormScreen> createState() => _StorageLocationFormScreenState();
}

class _StorageLocationFormScreenState extends State<StorageLocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int? _warehouseId;
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _rackController = TextEditingController();
  final TextEditingController _shelfController = TextEditingController();
  final TextEditingController _binController = TextEditingController();
  int _status = 1;

  bool get isEditMode => widget.location != null;

  @override
  void initState() {
    super.initState();
    
    // Load active warehouses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StorageLocationProvider>().loadActiveWarehouses();
    });

    if (isEditMode) {
      final loc = widget.location!;
      _warehouseId = loc.warehouseId;
      _zoneController.text = loc.zone;
      _rackController.text = loc.rack;
      _shelfController.text = loc.shelf;
      _binController.text = loc.bin;
      _status = loc.status;
    }

    _zoneController.addListener(_onFieldChanged);
    _rackController.addListener(_onFieldChanged);
    _shelfController.addListener(_onFieldChanged);
    _binController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  String _formatFieldSubmit(String val) {
    val = val.trim().toUpperCase();
    final number = int.tryParse(val);
    if (number != null && val.length == 1) {
      return '0$val';
    }
    return val;
  }

  String _formatFieldPreview(String val) {
    val = val.trim().toUpperCase();
    if (val.isEmpty) return '?';
    final number = int.tryParse(val);
    if (number != null && val.length == 1) {
      return '0$val';
    }
    return val;
  }

  String _getPreviewLocationCode() {
    final z = _formatFieldPreview(_zoneController.text);
    final r = _formatFieldPreview(_rackController.text);
    final s = _formatFieldPreview(_shelfController.text);
    final b = _formatFieldPreview(_binController.text);
    return '$z-$r-$s-$b';
  }

  @override
  void dispose() {
    _zoneController.removeListener(_onFieldChanged);
    _rackController.removeListener(_onFieldChanged);
    _shelfController.removeListener(_onFieldChanged);
    _binController.removeListener(_onFieldChanged);
    _zoneController.dispose();
    _rackController.dispose();
    _shelfController.dispose();
    _binController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_warehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn nhà kho!'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    final provider = context.read<StorageLocationProvider>();
    bool success = false;

    final z = _formatFieldSubmit(_zoneController.text);
    final r = _formatFieldSubmit(_rackController.text);
    final s = _formatFieldSubmit(_shelfController.text);
    final b = _formatFieldSubmit(_binController.text);

    if (isEditMode) {
      success = await provider.updateLocation(
        id: widget.location!.locationId,
        warehouseId: _warehouseId!,
        zone: z,
        rack: r,
        shelf: s,
        bin: b,
        status: _status,
      );
    } else {
      success = await provider.createLocation(
        warehouseId: _warehouseId!,
        zone: z,
        rack: r,
        shelf: s,
        bin: b,
        status: _status,
      );
    }

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditMode ? 'Cập nhật vị trí thành công!' : 'Thêm vị trí mới thành công!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
      Navigator.pop(context); // Close screen
      provider.loadStorageLocations(isRefresh: true); // Refresh list
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? (isEditMode ? 'Cập nhật vị trí thất bại.' : 'Thêm vị trí thất bại.')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorageLocationProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Sửa thông tin vị trí' : 'Thêm vị trí mới',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: provider.isLoading && provider.activeWarehouses.isEmpty
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary)))
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(20.0),
                children: [
                  Text(
                    'THÔNG TIN CHUNG',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Warehouse Dropdown
                  Text('Nhà kho *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<int?>(
                        value: _warehouseId,
                        hint: Text('Chọn nhà kho', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 14)),
                        isExpanded: true,
                        onChanged: (val) {
                          setState(() {
                            _warehouseId = val;
                          });
                        },
                        items: provider.activeWarehouses.map((wh) {
                          return DropdownMenuItem<int?>(
                            value: wh['warehouseID'] as int,
                            child: Text(wh['warehouseName'] as String, style: TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        validator: (value) => value == null ? 'Vui lòng chọn nhà kho' : null,
                        decoration: InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Coordinates Fields
                  Text(
                    'TỌA ĐỘ VỊ TRÍ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _zoneController,
                          label: 'Khu vực (Zone) *',
                          hint: 'Ví dụ: A, B, COLD',
                          validator: (val) => val == null || val.trim().isEmpty ? 'Nhập Zone' : null,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _rackController,
                          label: 'Dãy (Rack) *',
                          hint: 'Ví dụ: 10, 11, R1',
                          validator: (val) => val == null || val.trim().isEmpty ? 'Nhập Rack' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _shelfController,
                          label: 'Tầng (Shelf) *',
                          hint: 'Ví dụ: 1, 2, S3',
                          validator: (val) => val == null || val.trim().isEmpty ? 'Nhập Shelf' : null,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _binController,
                          label: 'Ô chứa (Bin) *',
                          hint: 'Ví dụ: 01, 02, B4',
                          validator: (val) => val == null || val.trim().isEmpty ? 'Nhập Bin' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Live Preview Code Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87)),
                              children: [
                                TextSpan(text: 'Mã vị trí dự kiến: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                TextSpan(
                                  text: _getPreviewLocationCode(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Status Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trạng thái hoạt động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Kích hoạt hoặc vô hiệu hóa vị trí', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45), fontSize: 12)),
                        ],
                      ),
                      Switch(
                        value: _status == 1,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (val) {
                          setState(() {
                            _status = val ? 1 : 0;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: provider.isLoading
                          ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          : Text(
                              isEditMode ? 'LƯU THAY ĐỔI' : 'THÊM VỊ TRÍ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 13),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

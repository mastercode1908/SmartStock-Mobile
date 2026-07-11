import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product_variant.dart';
import '../providers/incident_provider.dart';
import '../services/incident_service.dart';

class CreateIncidentScreen extends StatefulWidget {
  const CreateIncidentScreen({super.key});

  @override
  State<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final _service = IncidentService();
  final _picker = ImagePicker();

  ProductVariant? _selectedProduct;
  List<Map<String, dynamic>> _productLocations = [];
  Map<String, dynamic>? _selectedLocationBalance;

  // Selected details
  String? _selectedLocationText;
  int? _selectedLocationId;
  int? _selectedBatchId;
  String? _selectedBatchNumber;
  List<String> _availableSerials = [];
  final List<String> _selectedSerials = [];

  // Incident Type
  String? _selectedType;
  final List<String> _typesList = [];

  // Fields
  int _quantity = 1;
  String _severity = 'Medium';
  final _notesController = TextEditingController();

  // Image Upload
  String _uploadedImageUrl = '';
  bool _isUploadingImage = false;
  File? _localImageFile;

  bool _isLoadingLocations = false;
  bool _isLoadingSerials = false;

  bool _hasSerials() {
    if (_selectedProduct == null) return false;
    final tm = _selectedProduct!.trackingMethod;
    return tm == 2 || tm == 3;
  }

  bool _hasBatch() {
    if (_selectedProduct == null) return false;
    final tm = _selectedProduct!.trackingMethod;
    return tm == 1 || tm == 3;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadProductVariants();
      _loadIncidentTypes();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadIncidentTypes() async {
    final provider = context.read<IncidentProvider>();
    await provider.fetchIncidentTypes();
    setState(() {
      _typesList.clear();
      _typesList.addAll(provider.incidentTypes);
      if (_typesList.isNotEmpty && _selectedType == null) {
        _selectedType = _typesList.first;
      }
    });
  }

  Future<void> _onProductSelected(ProductVariant product) async {
    setState(() {
      _selectedProduct = product;
      _productLocations = [];
      _selectedLocationBalance = null;
      _selectedLocationText = null;
      _selectedLocationId = null;
      _selectedBatchId = null;
      _selectedBatchNumber = null;
      _availableSerials = [];
      _selectedSerials.clear();
      _quantity = 1;
      _isLoadingLocations = true;
    });

    try {
      final locs = await _service.fetchProductLocations(product.variantId);
      setState(() {
        _productLocations = locs;
        if (locs.isNotEmpty) {
          // Auto select first location
          _onLocationSelected(locs.first);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải vị trí lưu trữ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoadingLocations = false;
      });
    }
  }

  Future<void> _onLocationSelected(Map<String, dynamic> balance) async {
    setState(() {
      _selectedLocationBalance = balance;
      _selectedLocationId = balance['locationID'] ?? balance['LocationID'];
      _selectedLocationText = balance['locationName'] ?? balance['LocationName'] ?? 'Không rõ';
      _selectedBatchId = balance['batchID'] ?? balance['BatchID'];
      _selectedBatchNumber = balance['batchNumber'] ?? balance['BatchNumber'];
      _availableSerials = [];
      _selectedSerials.clear();
      _quantity = 1;
    });

    if (_hasSerials()) { // Serial tracked
      _loadAvailableSerials();
    }
  }

  Future<void> _loadAvailableSerials() async {
    if (_selectedProduct == null || _selectedLocationId == null) return;
    setState(() {
      _isLoadingSerials = true;
    });

    try {
      final serials = await _service.fetchAvailableSerials(
        _selectedProduct!.variantId,
        _selectedLocationId!,
      );
      setState(() {
        _availableSerials = serials;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải mã serial: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoadingSerials = false;
      });
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile == null) return;

    setState(() {
      _localImageFile = File(pickedFile.path);
      _isUploadingImage = true;
    });

    try {
      final url = await _service.uploadImage(pickedFile.path);
      setState(() {
        _uploadedImageUrl = url;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tải hình ảnh lên Cloudinary!'), backgroundColor: Color(0xff006a67)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh lên: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _showAddCustomTypeDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm loại sự cố mới', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập tên loại sự cố...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              final newType = textController.text.trim();
              if (newType.isNotEmpty) {
                setState(() {
                  if (!_typesList.contains(newType)) {
                    _typesList.add(newType);
                  }
                  _selectedType = newType;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('THÊM', style: TextStyle(color: Color(0xffb3272e), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showProductSearchBottomSheet() {
    final variants = context.read<InventoryProvider>().productVariants;
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = variants.where((v) {
              final query = searchQuery.toLowerCase();
              return v.variantName.toLowerCase().contains(query) ||
                  v.sku.toLowerCase().contains(query) ||
                  v.barcode.toLowerCase().contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Chọn Sản Phẩm Gặp Sự Cố', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên, SKU hoặc Barcode...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('Không tìm thấy sản phẩm nào.', style: TextStyle(color: Colors.black54)))
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final p = filtered[index];
                              return ListTile(
                                leading: Image.network(
                                  p.imageUrl.isNotEmpty == true
                                      ? p.imageUrl
                                      : 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=100',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(width: 40, height: 40, color: Colors.grey[200]),
                                ),
                                title: Text(p.variantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text('SKU: ${p.sku}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                onTap: () {
                                  _onProductSelected(p);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSerialsSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chọn mã Serial bị ảnh hưởng (${_selectedSerials.length} đã chọn)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _availableSerials.isEmpty
                        ? const Center(child: Text('Không có mã serial nào khả dụng.', style: TextStyle(color: Colors.black54)))
                        : ListView.separated(
                            itemCount: _availableSerials.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final serial = _availableSerials[index];
                              final isChecked = _selectedSerials.contains(serial);

                              return CheckboxListTile(
                                value: isChecked,
                                activeColor: const Color(0xffb3272e),
                                title: Text(serial, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                onChanged: (bool? val) {
                                  setModalState(() {
                                    if (val == true) {
                                      _selectedSerials.add(serial);
                                    } else {
                                      _selectedSerials.remove(serial);
                                    }
                                    // Sync quantity to serial length
                                    setState(() {
                                      _quantity = _selectedSerials.length;
                                    });
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb3272e),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('XÁC NHẬN', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport() async {
    if (_selectedProduct == null) {
      _showError('Vui lòng chọn sản phẩm.');
      return;
    }
    if (_selectedLocationId == null) {
      _showError('Vui lòng chọn vị trí lưu trữ.');
      return;
    }
    if (_selectedType == null || _selectedType!.isEmpty) {
      _showError('Vui lòng chọn loại sự cố.');
      return;
    }
    if (_quantity <= 0) {
      _showError('Số lượng sản phẩm ảnh hưởng phải lớn hơn 0.');
      return;
    }
    
    // Validate serials if product tracked by serials
    if (_hasSerials() && _selectedSerials.isEmpty) {
      _showError('Vui lòng chọn ít nhất một mã serial bị hỏng.');
      return;
    }

    final body = {
      'warehouseID': 1, // Default main warehouse
      'locationID': _selectedLocationId,
      'variantID': _selectedProduct!.variantId,
      'batchID': _selectedBatchId,
      'quantity': _quantity,
      'title': _selectedType,
      'description': _notesController.text.trim(),
      'imageUrl': _uploadedImageUrl,
      'severity': _severity,
      'serialNumbers': _selectedSerials,
    };

    try {
      final provider = context.read<IncidentProvider>();
      await provider.createIncident(body);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Báo cáo sự cố đã được gửi, đang chờ phê duyệt!'), backgroundColor: Color(0xff006a67)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi báo cáo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final isSubmitting = provider.isSubmitting;

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
          'Khai Báo Sự Cố Mới',
          style: TextStyle(
            color: Color(0xffb3272e),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))),
                  SizedBox(height: 16),
                  Text('Đang gửi báo cáo sự cố...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Product Selection
                  _buildSectionCard(
                    title: 'THÔNG TIN SẢN PHẨM & VỊ TRÍ',
                    children: [
                      _buildLabel('SẢN PHẨM / BIẾN THỂ', isRequired: true),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _showProductSearchBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xfff1fbff),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xffe1bebc)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedProduct != null
                                      ? _selectedProduct!.variantName
                                      : 'Bấm chọn sản phẩm...',
                                  style: TextStyle(
                                    fontWeight: _selectedProduct != null ? FontWeight.bold : FontWeight.normal,
                                    color: _selectedProduct != null ? Colors.black87 : Colors.black38,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location Selector Dropdown (Dynamic)
                      if (_selectedProduct != null) ...[
                        _buildLabel('VỊ TRÍ LƯU TRỮ TRONG KHO', isRequired: true),
                        const SizedBox(height: 8),
                        _isLoadingLocations
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))),
                                ),
                              )
                            : _productLocations.isEmpty
                                ? const Text(
                                    'Sản phẩm này chưa được xếp vị trí lưu trữ nào trong kho.',
                                    style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff1fbff),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xffe1bebc)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Map<String, dynamic>>(
                                        isExpanded: true,
                                        value: _selectedLocationBalance,
                                        items: _productLocations.map((loc) {
                                          final name = loc['locationName'] ?? loc['LocationName'] ?? 'KĐX';
                                          final qty = loc['quantity'] ?? loc['Quantity'] ?? 0;
                                          final batchNo = loc['batchNumber'] ?? loc['BatchNumber'] ?? '';
                                          final batchText = batchNo.isNotEmpty ? ' | Lô: $batchNo' : '';

                                          return DropdownMenuItem<Map<String, dynamic>>(
                                            value: loc,
                                            child: Text('$name (Tồn: $qty$batchText)'),
                                          );
                                        }).toList(),
                                        onChanged: (Map<String, dynamic>? val) {
                                          if (val != null) {
                                            _onLocationSelected(val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 2: Details & Specific elements
                  if (_selectedProduct != null && _selectedLocationId != null) ...[
                    _buildSectionCard(
                      title: 'CHI TIẾT SỰ CỐ',
                      children: [
                        // Batch Number if applicable
                        if (_hasBatch() && _selectedBatchNumber != null) ...[
                          _buildLabel('LÔ HÀNG BỊ ẢNH HƯỞNG'),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedBatchNumber!,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Serial Selector if applicable
                        if (_hasSerials()) ...[
                          _buildLabel('CHỌN MÃ SERIAL GẶP SỰ CỐ', isRequired: true),
                          const SizedBox(height: 8),
                          _isLoadingSerials
                              ? const Center(child: CircularProgressIndicator())
                              : InkWell(
                                  onTap: _showSerialsSelectorBottomSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff1fbff),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xffe1bebc)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedSerials.isEmpty
                                              ? 'Chọn mã serial...'
                                              : '${_selectedSerials.length} serial đã chọn',
                                          style: TextStyle(
                                            fontWeight: _selectedSerials.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                                            color: _selectedSerials.isNotEmpty ? Colors.black87 : Colors.black38,
                                          ),
                                        ),
                                        const Icon(Icons.qr_code, color: Colors.black54),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 16),
                        ],

                        // Incident Type Dropdown & Custom Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('LOẠI SỰ CỐ', isRequired: true),
                            TextButton.icon(
                              onPressed: _showAddCustomTypeDialog,
                              icon: const Icon(Icons.add, size: 16, color: Color(0xffb3272e)),
                              label: const Text('Thêm loại mới', style: TextStyle(color: Color(0xffb3272e), fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xfff1fbff),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xffe1bebc)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedType,
                              hint: const Text('Chọn loại sự cố...'),
                              items: _typesList.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (String? val) {
                                setState(() {
                                  _selectedType = val;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quantity selector (locked if serial-tracked)
                        _buildLabel('SỐ LƯỢNG SẢN PHẨM BỊ HỎNG/MẤT'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 28, color: Color(0xffb3272e)),
                              onPressed: _hasSerials()
                                  ? null
                                  : () {
                                      if (_quantity > 1) {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 28, color: Color(0xff10b981)),
                              onPressed: _hasSerials()
                                  ? null
                                  : () {
                                      setState(() {
                                        _quantity++;
                                      });
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Severity selection
                        _buildLabel('MỨC ĐỘ NGHIÊM TRỌNG'),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Low', 'Medium', 'High'].map((level) {
                            final isSelected = _severity == level;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  label: Text(level),
                                  selected: isSelected,
                                  selectedColor: const Color(0xffb3272e),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _severity = level;
                                      });
                                    }
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Evidence Image Upload
                    _buildSectionCard(
                      title: 'ẢNH CHỤP BẰNG CHỨNG THỰC TẾ',
                      children: [
                        _buildLabel('HÌNH ẢNH MINH HỌA SỰ CỐ'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickAndUploadImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('CHỤP ẢNH'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xfff1fbff),
                                  foregroundColor: const Color(0xffb3272e),
                                  elevation: 0,
                                  side: const BorderSide(color: Color(0xffe1bebc)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickAndUploadImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('THƯ VIỆN'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xfff1fbff),
                                  foregroundColor: const Color(0xffb3272e),
                                  elevation: 0,
                                  side: const BorderSide(color: Color(0xffe1bebc)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isUploadingImage)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))),
                            ),
                          )
                        else if (_uploadedImageUrl.isNotEmpty)
                          Center(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _uploadedImageUrl,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _uploadedImageUrl = '';
                                        _localImageFile = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 4: Notes
                    _buildSectionCard(
                      title: 'GHI CHÚ CHI TIẾT',
                      children: [
                        _buildLabel('MÔ TẢ SỰ CỐ'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Mô tả chi tiết để hỗ trợ phê duyệt trừ kho...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffb3272e),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 2,
                        ),
                        child: const Text('GỬI BÁO CÁO SỰ CỐ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xffb3272e), letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        if (isRequired)
          const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_variant.dart';
import '../providers/product_provider.dart';

class VariantCreateScreen extends StatefulWidget {
  final int productId;
  final ProductVariant? variant; // If not null, we are in Edit mode

  const VariantCreateScreen({
    super.key,
    required this.productId,
    this.variant,
  });

  @override
  State<VariantCreateScreen> createState() => _VariantCreateScreenState();
}

class _VariantCreateScreenState extends State<VariantCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _minStockController;
  late TextEditingController _costPriceController;
  late TextEditingController _imageUrlController;

  int _selectedStatus = 1; // default to ACTIVE (1)

  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  // Colors
  final Color _primary = const Color(0xFFB02528);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.variant?.variantName ?? '');
    _skuController = TextEditingController(text: widget.variant?.sku ?? '');
    _barcodeController = TextEditingController(text: widget.variant?.barcode ?? '');
    _minStockController = TextEditingController(text: widget.variant?.minimumStockLevel.toString() ?? '0');
    _costPriceController = TextEditingController(text: widget.variant?.costPrice.toString() ?? '0');
    _imageUrlController = TextEditingController(text: widget.variant?.imageUrl ?? '');
    _selectedStatus = widget.variant?.status ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _minStockController.dispose();
    _costPriceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      final provider = Provider.of<ProductProvider>(context, listen: false);
      final uploadedUrl = await provider.uploadImage(pickedFile.path);

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() {
          _imageUrlController.text = uploadedUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tải ảnh biến thể thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Tải ảnh lên thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi upload: $e')),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final variantName = _nameController.text.trim();
    final sku = _skuController.text.trim();
    final barcode = _barcodeController.text.trim();
    final minStock = int.tryParse(_minStockController.text) ?? 0;
    final costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
    final imageUrl = _imageUrlController.text.trim();

    bool success;
    if (widget.variant == null) {
      success = await provider.createVariant(
        productId: widget.productId,
        variantName: variantName,
        sku: sku,
        barcode: barcode,
        minimumStockLevel: minStock,
        costPrice: costPrice,
        imageUrl: imageUrl,
        status: _selectedStatus,
      );
    } else {
      success = await provider.updateVariant(
        variantId: widget.variant!.variantId,
        productId: widget.productId,
        variantName: variantName,
        sku: sku,
        barcode: barcode,
        minimumStockLevel: minStock,
        costPrice: costPrice,
        imageUrl: imageUrl,
        status: _selectedStatus,
      );
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.variant == null ? 'Thêm biến thể thành công!' : 'Cập nhật biến thể thành công!')),
      );
      Navigator.pop(context, true);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Lỗi thực hiện'),
          content: Text(provider.error ?? 'Đã xảy ra lỗi, vui lòng thử lại.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.variant != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Chỉnh sửa biến thể' : 'Thêm biến thể sản phẩm',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Variant Name
                  const Text(
                    'Tên biến thể *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên biến thể (ví dụ: Màu đỏ, Size L,...)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tên biến thể là bắt buộc';
                      }
                      if (value.trim().length > 200) {
                        return 'Tên biến thể tối đa 200 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // SKU
                  const Text(
                    'Mã SKU *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _skuController,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã SKU định danh duy nhất',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mã SKU là bắt buộc';
                      }
                      if (value.trim().length > 100) {
                        return 'Mã SKU tối đa 100 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Barcode
                  const Text(
                    'Mã vạch (Barcode)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã vạch sản phẩm (nếu có)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value != null && value.trim().length > 100) {
                        return 'Mã vạch tối đa 100 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cost Price & Minimum Stock Level in a row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giá mua (VNĐ)',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _costPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return null;
                                final numValue = double.tryParse(value);
                                if (numValue == null || numValue < 0) {
                                  return 'Giá mua không được âm';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tồn tối thiểu',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _minStockController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return null;
                                final numValue = int.tryParse(value);
                                if (numValue == null || numValue < 0) {
                                  return 'Mức tồn không được âm';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Image URL and picker
                  const Text(
                    'Hình ảnh biến thể',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            hintText: 'Đường dẫn ảnh biến thể',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isUploadingImage 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.upload_file),
                        label: const Text('Tải lên'),
                      ),
                    ],
                  ),
                  if (_imageUrlController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imageUrlController.text,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Status
                  const Text(
                    'Trạng thái biến thể *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Đang hoạt động (ACTIVE)')),
                      DropdownMenuItem(value: 0, child: Text('Ngưng hoạt động (INACTIVE)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEdit ? 'Lưu thay đổi' : 'Thêm biến thể',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

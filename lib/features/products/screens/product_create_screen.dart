import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductCreateScreen extends StatefulWidget {
  final Product? product; // If not null, we are in Edit mode

  const ProductCreateScreen({super.key, this.product});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;

  int? _selectedCategoryId;
  int? _selectedBrandId;
  int? _selectedBaseUnitId;
  int _selectedTrackingMethod = 0; // default to NONE
  int _selectedStatus = 1; // default to ACTIVE

  bool _isUploadingImage = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Styling colors
  final Color _primary = const Color(0xFFB02528);
  final Color _surface = const Color(0xFFF9F9F9);
  final Color _outlineVariant = const Color(0xFFE2BEBB);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.productName ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');

    _selectedCategoryId = widget.product?.categoryId;
    _selectedBrandId = widget.product?.brandId;
    _selectedBaseUnitId = widget.product?.baseUnitId;
    _selectedTrackingMethod = widget.product?.trackingMethod ?? 0;
    _selectedStatus = widget.product?.status ?? 1;

    // Load categories, brands, units on open if they are not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (provider.categories.isEmpty || provider.brands.isEmpty || provider.units.isEmpty) {
        provider.loadMetadata();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile == null) return;

      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploadingImage = true;
      });

      final provider = Provider.of<ProductProvider>(context, listen: false);
      final uploadedUrl = await provider.uploadImage(pickedFile.path);

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() {
          _imageUrlController.text = uploadedUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tải ảnh lên thành công!')),
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

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    if (_selectedBaseUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đơn vị tính cơ bản')),
      );
      return;
    }

    final provider = Provider.of<ProductProvider>(context, listen: false);
    bool success;

    if (widget.product == null) {
      // Create mode
      success = await provider.createProduct(
        productName: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        brandId: _selectedBrandId,
        baseUnitId: _selectedBaseUnitId!,
        trackingMethod: _selectedTrackingMethod,
        imageUrl: _imageUrlController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    } else {
      // Edit mode
      success = await provider.updateProduct(
        id: widget.product!.productId,
        productName: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        brandId: _selectedBrandId,
        baseUnitId: _selectedBaseUnitId!,
        trackingMethod: _selectedTrackingMethod,
        imageUrl: _imageUrlController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
      );
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.product == null ? 'Tạo sản phẩm thành công!' : 'Cập nhật sản phẩm thành công!')),
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
    final isEdit = widget.product != null;

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
          isEdit ? 'Chỉnh sửa Sản phẩm' : 'Tạo sản phẩm cha',
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
          if (provider.isMetadataLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  const Text(
                    'Tên sản phẩm *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên sản phẩm',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tên sản phẩm là bắt buộc';
                      }
                      if (value.trim().length < 3 || value.trim().length > 200) {
                        return 'Tên sản phẩm phải từ 3 đến 200 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category ID selection
                  const Text(
                    'Danh mục *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    hint: const Text('Chọn danh mục'),
                    items: provider.categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.categoryId,
                        child: Text(cat.categoryName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Brand selection
                  const Text(
                    'Thương hiệu',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedBrandId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    hint: const Text('Chọn thương hiệu (Mặc định: Brand 1)'),
                    items: provider.brands.map((br) {
                      return DropdownMenuItem<int>(
                        value: br.brandId,
                        child: Text(br.brandName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBrandId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Base Unit selection
                  const Text(
                    'Đơn vị tính cơ bản *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedBaseUnitId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    hint: const Text('Chọn đơn vị tính cơ bản'),
                    items: provider.units.map((unit) {
                      return DropdownMenuItem<int>(
                        value: unit.unitId,
                        child: Text('${unit.unitName} (${unit.symbol})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBaseUnitId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tracking Method selection
                  const Text(
                    'Phương thức theo dõi *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedTrackingMethod,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Không theo dõi (NONE)')),
                      DropdownMenuItem(value: 1, child: Text('Theo dõi theo Lô (BATCH)')),
                      DropdownMenuItem(value: 2, child: Text('Theo dõi theo Serial (SERIAL)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedTrackingMethod = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Image Selection & Upload
                  const Text(
                    'Hình ảnh sản phẩm',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            hintText: 'Đường dẫn ảnh hoặc tải lên',
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

                  // Description
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập mô tả sản phẩm',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status selection if editing
                  if (isEdit) ...[
                    const Text(
                      'Trạng thái hoạt động *',
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
                        DropdownMenuItem(value: 0, child: Text('Nháp (DRAFT)')),
                        DropdownMenuItem(value: 1, child: Text('Đang hoạt động (ACTIVE)')),
                        DropdownMenuItem(value: 2, child: Text('Ngưng hoạt động (INACTIVE)')),
                        DropdownMenuItem(value: 3, child: Text('Không sản xuất (DISCONTINUED)')),
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
                  ] else ...[
                    const SizedBox(height: 16),
                  ],

                  // Submit Button
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
                              isEdit ? 'Lưu thay đổi' : 'Tạo sản phẩm',
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

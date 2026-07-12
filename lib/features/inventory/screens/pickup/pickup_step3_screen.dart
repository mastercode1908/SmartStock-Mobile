import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/picking_detail.dart';
import '../../providers/picking_provider.dart';

class PickUpStep3Screen extends StatefulWidget {
  final PickingDetail detail;
  const PickUpStep3Screen({Key? key, required this.detail}) : super(key: key);

  @override
  State<PickUpStep3Screen> createState() => _PickUpStep3ScreenState();
}

class _PickUpStep3ScreenState extends State<PickUpStep3Screen> {
  late int _quantity;
  late final int _maxQuantity;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.detail.expectedQuantity;
    _maxQuantity = widget.detail.expectedQuantity;
  }

  void _increment() {
    if (_quantity < _maxQuantity) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  Future<void> _submitPicking() async {
    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<InventoryPickingProvider>();
    final success = await provider.updatePickedQuantity(
      widget.detail.pickingDetailId,
      _quantity,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật số lượng nhặt: $_quantity/$_maxQuantity'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop Step 3 and Step 2 to return to Step 1 (Route List)
        Navigator.pop(context); // Pop step 3
        Navigator.pop(context); // Pop step 2
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật số lượng thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  _buildProgressHeader(),
                  SizedBox(height: 32),
                  _buildProductDetailsCard(),
                  SizedBox(height: 32),
                  _buildPickingControl(),
                  SizedBox(height: 120), // Padding for sticky bottom area
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'Smart Stock',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        Text(
          'Bước 3/5: Nhập số lượng',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Kiểm đếm và nhập số lượng thực tế tại vị trí',
          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
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
    final productName = widget.detail.productVariant?.variantName ?? "Sản phẩm N/A";
    final sku = widget.detail.productVariant?.sku ?? "SKU N/A";
    final locationCode = widget.detail.storageLocation?.locationCode ?? "Vị trí N/A";
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
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
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.image_outlined, color: Colors.grey, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    SizedBox(height: 4),
                    Text('Mã SP: $sku', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    SizedBox(height: 2),
                    Text('Vị trí: $locationCode', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    if (widget.detail.serials != null && widget.detail.serials!.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Serials: ', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                          ...widget.detail.serials!.map((s) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            ),
                            child: Text(
                              s.serialNumber ?? 'N/A',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          )).toList(),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Số lượng yêu cầu:', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    children: [
                      TextSpan(text: '$_maxQuantity ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Cái', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

  Widget _buildPickingControl() {
    return Column(
      children: [
        Text('Số lượng thực tế', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQtyButton(Icons.remove, _decrement),
            SizedBox(width: 16),
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0x1AFEEBEE),
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 2)),
              ),
              alignment: Alignment.center,
              child: Text(
                '$_quantity',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: _quantity >= _maxQuantity ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(width: 16),
            _buildQtyButton(Icons.add, _increment),
          ],
        ),
      ],
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: _isSubmitting ? null : onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
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
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _isSubmitting ? null : () {
                      setState(() {
                        _quantity = 0;
                      });
                    },
                    icon: Icon(Icons.report, color: AppColors.primary),
                    label: Text('Báo thiếu (0)'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _isSubmitting ? null : () {
                      Navigator.pop(context); // Go back to step 2 to scan again
                    },
                    icon: Icon(Icons.qr_code_scanner, color: AppColors.primary),
                    label: Text('Quét lại'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                minimumSize: const Size(double.infinity, 56),
              ),
              onPressed: _isSubmitting ? null : _submitPicking,
              child: _isSubmitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.surface, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Xác nhận nhặt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.check),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/inventory_count_detail.dart';
import '../../providers/inventory_provider.dart';
import 'count_step4_screen.dart';

class CountStep3Screen extends StatefulWidget {
  final InventoryCountDetail detail;

  const CountStep3Screen({Key? key, required this.detail}) : super(key: key);

  @override
  State<CountStep3Screen> createState() => _CountStep3ScreenState();
}

class _CountStep3ScreenState extends State<CountStep3Screen> {
  int _quantity = 0;
  int _systemQty = 0;

  @override
  void initState() {
    super.initState();
    _systemQty = widget.detail.systemQuantity;
    _quantity = widget.detail.actualQuantity ?? _systemQty;
  }

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

  void _saveAndProceed() {
    context.read<InventoryProvider>().updateActualQuantity(
      widget.detail.countDetailId, 
      _quantity,
      fallbackDetail: widget.detail,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã lưu số lượng!'), backgroundColor: AppColors.primary),
    );
    Navigator.pop(context); // Go back to Scanner
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
                  _buildQuantityControl(),
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
        icon: Icon(Icons.arrow_back, color: AppColors.primary),
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
    final hasImage = widget.detail.imageUrl != null && widget.detail.imageUrl!.isNotEmpty;
    
    String trackingText = 'NONE';
    if (widget.detail.trackingMethod == 1) trackingText = 'BATCH';
    else if (widget.detail.trackingMethod == 2) trackingText = 'SERIAL';
    else if (widget.detail.trackingMethod == 3) trackingText = 'BATCH & SERIAL';

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
                  image: hasImage ? DecorationImage(
                    image: NetworkImage(widget.detail.imageUrl!),
                    fit: BoxFit.cover,
                  ) : null,
                ),
                child: !hasImage ? Icon(Icons.inventory_2, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (widget.detail.variantName != null && widget.detail.variantName!.isNotEmpty) ? widget.detail.variantName! : (widget.detail.productName ?? 'Unknown'), 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)
                    ),
                    SizedBox(height: 4),
                    Text('SKU: ${widget.detail.sku ?? ""}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    SizedBox(height: 2),
                    Text('Tracking: $trackingText', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    if ((widget.detail.trackingMethod == 1 || widget.detail.trackingMethod == 3) && widget.detail.batchNumber != null && widget.detail.batchNumber!.isNotEmpty)
                      Text('Lô: ${widget.detail.batchNumber}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    if ((widget.detail.trackingMethod == 2 || widget.detail.trackingMethod == 3) && widget.detail.serialNumber != null && widget.detail.serialNumber!.isNotEmpty)
                      Text('Serial: ${widget.detail.serialNumber}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                Text('Số lượng hệ thống:', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    children: [
                      TextSpan(text: '$_systemQty ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      TextSpan(text: '', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                  color: Theme.of(context).colorScheme.onSurface,
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
      onTap: onPressed,
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

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                minimumSize: const Size(double.infinity, 56),
              ),
              onPressed: () {
                _saveAndProceed();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lưu & Tiếp tục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

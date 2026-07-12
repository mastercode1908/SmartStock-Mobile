import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/picking_provider.dart';
import '../../models/picking_task.dart';

class PickUpReadOnlyScreen extends StatefulWidget {
  final PickingTask task;
  const PickUpReadOnlyScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<PickUpReadOnlyScreen> createState() => _PickUpReadOnlyScreenState();
}

class _PickUpReadOnlyScreenState extends State<PickUpReadOnlyScreen> {
  PickingTask? _fullTask;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final provider = context.read<InventoryPickingProvider>();
      await provider.fetchTaskDetail(widget.task.taskId);
      if (mounted) {
        setState(() {
          _fullTask = provider.currentTask;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Smart Stock',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Text('Lỗi: $_error', style: TextStyle(color: Colors.red)))
              : _buildContent(context, _fullTask ?? widget.task),
    );
  }

  Widget _buildContent(BuildContext context, PickingTask task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thông tin chung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Divider(),
                  SizedBox(height: 8),
                  _buildInfoRow('Mã phiếu', task.taskCode),
                  _buildInfoRow('Trạng thái', 'Hoàn thành', color: Colors.green),
                  _buildInfoRow('Số sản phẩm', '${task.details?.length ?? 0} SKU'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('Danh sách sản phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 8),
          if (task.details == null || task.details!.isEmpty)
            Text('Không có sản phẩm nào')
          else
            ...task.details!.map((d) {
              String name = d.productVariant?.variantName ?? d.productVariant?.productName ?? 'Sản phẩm không tên';
              if (name.isEmpty) name = 'Sản phẩm không tên';
              
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: ListTile(
                  title: Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Số lượng nhặt: ${d.pickedQuantity} / ${d.expectedQuantity}'),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}

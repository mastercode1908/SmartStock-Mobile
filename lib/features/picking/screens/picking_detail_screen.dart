import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/picking_provider.dart';
import '../models/picking_task.dart';

class PickingDetailScreen extends StatefulWidget {
  final int taskId;

  const PickingDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<PickingDetailScreen> createState() => _PickingDetailScreenState();
}

class _PickingDetailScreenState extends State<PickingDetailScreen> {
  String _userRole = 'Staff';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _userRole = user?.roleName ?? 'Staff';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PickingProvider>().fetchPickingTaskDetail(widget.taskId);
    });
  }

  String _getTaskStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ thực hiện';
      case 1:
        return 'Đang nhặt hàng';
      case 2:
        return 'Hoàn thành';
      case 3:
        return 'Đã hủy';
      default:
        return 'Không rõ';
    }
  }

  Color _getTaskStatusColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xfff59e0b);
      case 1:
        return const Color(0xff3b82f6);
      case 2:
        return const Color(0xff10b981);
      case 3:
        return const Color(0xffef4444);
      default:
        return Colors.grey;
    }
  }

  Color _getTaskStatusBgColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xfffef3c7);
      case 1:
        return const Color(0xffdbeafe);
      case 2:
        return const Color(0xffd1fae5);
      case 3:
        return const Color(0xfffee2e2);
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PickingProvider>();
    final task = provider.currentTask;
    final isLoading = provider.isLoadingDetail;

    if (isLoading && task == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))),
        ),
      );
    }

    if (task == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(
          child: Text('Không thể tải chi tiết nhiệm vụ.'),
        ),
      );
    }

    final isPickable = task.status == 1 && _userRole == 'Staff';
    final completedItemsCount = task.details.where((d) => d.pickedQuantity >= d.expectedQuantity).length;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffb3272e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          task.taskCode,
          style: const TextStyle(
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Task Header Card
                  _buildHeaderCard(task),
                  const SizedBox(height: 16),

                  // Start Task Panel (If PENDING & Staff)
                  if (task.status == 0 && _userRole == 'Staff')
                    _buildStartTaskPanel(provider, task.taskId),

                  // List Card header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Danh sách sản phẩm cần nhặt',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text(
                        '$completedItemsCount / ${task.details.length} đã xong',
                        style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Items List
                  if (task.details.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: const Center(
                        child: Text('Nhiệm vụ này không có sản phẩm nào.', style: TextStyle(color: Colors.black54)),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: task.details.length,
                      itemBuilder: (context, index) {
                        final detail = task.details[index];
                        return _buildPickingDetailItem(provider, detail, isPickable);
                      },
                    ),
                  const SizedBox(height: 80), // bottom spacing
                ],
              ),
            ),
          ),

          // Bottom Action Panel
          if (task.status == 1 && _userRole == 'Staff')
            _buildPickingFooter(provider, task.taskId)
          else if (task.status == 2)
            _buildCompletedFooter(task),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(PickingTaskModel task) {
    final assignedName = task.assignedToUser?.fullName ?? 'Chưa phân công';
    final creatorName = task.createdByUser?.fullName ?? 'Hệ thống';
    final createdDateStr = task.createdAt.isNotEmpty
        ? DateTime.parse(task.createdAt).toLocal().toString().substring(0, 16)
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.taskCode,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTaskStatusBgColor(task.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getTaskStatusText(task.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getTaskStatusColor(task.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildMetaRow(Icons.person_outline, 'Giao cho:', assignedName),
          const SizedBox(height: 8),
          _buildMetaRow(Icons.create_outlined, 'Người giao:', creatorName),
          const SizedBox(height: 8),
          _buildMetaRow(Icons.calendar_today_outlined, 'Ngày giao:', createdDateStr),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildStartTaskPanel(PickingProvider provider, int taskId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xfffffbeb), // soft yellow
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xfffde68a)),
      ),
      child: Column(
        children: [
          const Icon(Icons.directions_run_outlined, size: 48, color: Color(0xffd97706)),
          const SizedBox(height: 12),
          const Text(
            'Bắt đầu nhặt hàng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff92400e)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hệ thống đã tự động sắp xếp lộ trình tối ưu qua các kệ. Bấm nút dưới để bắt đầu lấy hàng.',
            style: TextStyle(fontSize: 13, color: Color(0xffb45309)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _startTask(provider, taskId),
            icon: const Icon(Icons.play_arrow),
            label: const Text('NHẬN & BẮT ĐẦU NHẶT HÀNG', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffb3272e),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickingDetailItem(PickingProvider provider, PickingDetailModel detail, bool isPickable) {
    final location = detail.storageLocation;
    final variant = detail.productVariant;

    final locationText = location != null ? '${location.rack}-${location.shelf}-${location.bin}' : 'KĐX';
    final zone = location?.zone ?? '';

    final variantName = variant?.variantName ?? '';
    final productName = variant?.productName ?? '';
    String displayName = productName.isNotEmpty ? productName : 'Sản phẩm';
    if (variantName.isNotEmpty && variantName != productName) {
      if (variantName.toLowerCase().contains(productName.toLowerCase())) {
        displayName = variantName;
      } else {
        displayName = '$productName ($variantName)';
      }
    } else if (variantName.isNotEmpty) {
      displayName = variantName;
    }
    final sku = variant?.sku ?? 'N/A';
    final barcode = variant?.barcode ?? 'N/A';
    final image = variant?.imageUrl?.isNotEmpty == true
        ? variant!.imageUrl!
        : 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=100';

    final isFullyPicked = detail.pickedQuantity >= detail.expectedQuantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFullyPicked ? const Color(0xff10b981).withOpacity(0.3) : Colors.grey[200]!,
          width: isFullyPicked ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isFullyPicked ? const Color(0xff10b981) : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox if pickable
              if (isPickable)
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Checkbox(
                    value: isFullyPicked,
                    activeColor: const Color(0xff10b981),
                    onChanged: (bool? val) {
                      if (val == true) {
                        provider.updatePickedQty(detail.pickingDetailId, detail.expectedQuantity);
                      } else {
                        provider.updatePickedQty(detail.pickingDetailId, 0);
                      }
                    },
                  ),
                ),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info & Qty
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location path
                    Row(
                      children: [
                        if (zone.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xffb3272e).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              zone,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffb3272e),
                              ),
                            ),
                          ),
                        Text(
                          locationText,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: $sku | Barcode: $barcode',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    if (detail.serials.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              'Serials: ',
                              style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: detail.serials.map((s) {
                                final num = s.serial?.serialNumber ?? '';
                                if (num.isEmpty) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffb3272e).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xffb3272e).withOpacity(0.15)),
                                  ),
                                  child: Text(
                                    num,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffb3272e),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Expected vs Picked Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Yêu cầu: ${detail.expectedQuantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        ),
                        if (isPickable)
                          // Qty adjustment Counter
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 22, color: Color(0xffb3272e)),
                                onPressed: () {
                                  if (detail.pickedQuantity > 0) {
                                    provider.updatePickedQty(detail.pickingDetailId, detail.pickedQuantity - 1);
                                  }
                                },
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 32),
                                alignment: Alignment.center,
                                child: Text(
                                  detail.pickedQuantity.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 22, color: Color(0xff10b981)),
                                onPressed: () {
                                  if (detail.pickedQuantity < detail.expectedQuantity * 2) {
                                    provider.updatePickedQty(detail.pickingDetailId, detail.pickedQuantity + 1);
                                  }
                                },
                              ),
                            ],
                          )
                        else
                          // Read-only picked count
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isFullyPicked ? const Color(0xffd1fae5) : const Color(0xfffee2e2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Đã nhặt: ${detail.pickedQuantity} / ${detail.expectedQuantity}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isFullyPicked ? const Color(0xff065f46) : const Color(0xff991b1b),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickingFooter(PickingProvider provider, int taskId) {
    final progressVal = provider.completionProgress;
    final progressPercent = (progressVal * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$progressPercent% HOÀN THÀNH',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xffb3272e)),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressVal,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(Color(0xffb3272e)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => _saveDraft(provider, taskId),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xffb3272e)),
                foregroundColor: const Color(0xffb3272e),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              child: const Text('LƯU NHÁP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _completeTask(provider, taskId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffb3272e),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              child: const Text('HOÀN THÀNH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedFooter(PickingTaskModel task) {
    final completedDateStr = task.completedAt != null
        ? DateTime.parse(task.completedAt!).toLocal().toString().substring(0, 16)
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffd1fae5),
        border: Border(top: BorderSide(color: const Color(0xffa7f3d0))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Color(0xff065f46)),
            const SizedBox(width: 8),
            Text(
              'Nhiệm vụ đã hoàn thành lúc: $completedDateStr',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff065f46), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startTask(PickingProvider provider, int taskId) async {
    try {
      await provider.startTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã bắt đầu nhặt hàng!'), backgroundColor: Color(0xff006a67)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveDraft(PickingProvider provider, int taskId) async {
    try {
      await provider.saveDraft(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu nháp tiến độ thành công!'), backgroundColor: Color(0xff006a67)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu nháp: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeTask(PickingProvider provider, int taskId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn tất nhặt hàng?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hành động này sẽ cập nhật số lượng tồn kho thực tế và đóng nhiệm vụ này. Bạn chắc chắn chứ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('HỦY', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('HOÀN TẤT', style: TextStyle(color: Color(0xffb3272e), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await provider.completeTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nhiệm vụ nhặt hàng đã hoàn tất!'), backgroundColor: Color(0xff006a67)),
        );
        Navigator.pop(context); // Go back to list on completion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi hoàn tất: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

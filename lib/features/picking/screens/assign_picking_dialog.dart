import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/picking_provider.dart';

class AssignPickingDialog extends StatefulWidget {
  final int issueId;
  final String issueCode;

  const AssignPickingDialog({
    super.key,
    required this.issueId,
    required this.issueCode,
  });

  @override
  State<AssignPickingDialog> createState() => _AssignPickingDialogState();
}

class _AssignPickingDialogState extends State<AssignPickingDialog> {
  String _searchQuery = '';
  bool _isAssigning = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PickingProvider>();
    final staffs = provider.staffs;

    final filteredStaffs = staffs.where((s) {
      final name = s.fullName.toLowerCase();
      final email = s.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân công nhặt hàng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Mã phiếu: ${widget.issueCode}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Input
            TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Staff List
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: _isAssigning
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))),
                      ),
                    )
                  : filteredStaffs.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('Không tìm thấy nhân viên nào.', style: TextStyle(color: Colors.black54)),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredStaffs.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final staff = filteredStaffs[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  staff.avatarUrl?.isNotEmpty == true
                                      ? staff.avatarUrl!
                                      : 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                                ),
                              ),
                              title: Text(staff.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(staff.email, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                              trailing: const Icon(Icons.chevron_right, size: 18),
                              onTap: () => _assignToStaff(staff.userId, staff.fullName),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isAssigning ? null : () => Navigator.pop(context),
          child: const Text('HỦY BỎ', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Future<void> _assignToStaff(int staffId, String staffName) async {
    setState(() {
      _isAssigning = true;
    });

    try {
      final provider = context.read<PickingProvider>();
      await provider.assignTask(widget.issueId, staffId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã phân công nhặt hàng cho $staffName thành công!'),
            backgroundColor: const Color(0xff006a67),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phân công thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }
}

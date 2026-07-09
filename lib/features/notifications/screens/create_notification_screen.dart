import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class CreateNotificationScreen extends StatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  State<CreateNotificationScreen> createState() => _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedType = 'INFO'; // INFO, WARNING, TASK, SYSTEM
  String _selectedTargetType = 'ALL'; // ALL, ROLE, SPECIFIC
  int? _selectedRoleId = 2; // Default to Staff (RoleID = 2)
  final List<int> _selectedUserIds = [];
  
  String _userSearchQuery = '';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTargetType == 'SPECIFIC' && _selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một người nhận'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final provider = context.read<NotificationProvider>();
      await provider.sendNotification(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        targetType: _selectedTargetType,
        targetRoleId: _selectedTargetType == 'ROLE' ? _selectedRoleId : null,
        targetUserIds: _selectedTargetType == 'SPECIFIC' ? _selectedUserIds : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gửi thông báo thành công!'),
            backgroundColor: Color(0xff006a67),
          ),
        );
        provider.fetchNotifications(); // Reload list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi thông báo thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final users = provider.users;
    final isLoadingUsers = provider.isLoadingUsers;

    // Filter users list based on search query
    final filteredUsers = users.where((u) {
      final fullName = (u['fullName'] as String? ?? '').toLowerCase();
      final email = (u['email'] as String? ?? '').toLowerCase();
      final query = _userSearchQuery.toLowerCase();
      return fullName.contains(query) || email.contains(query);
    }).toList();

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
          'Tạo Thông báo',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              const Text(
                'Tiêu đề thông báo *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                decoration: InputDecoration(
                  hintText: 'Nhập tiêu đề...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffb3272e), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Content Field
              const Text(
                'Nội dung thông báo *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập nội dung' : null,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung thông báo...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffb3272e), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),

              // Type Dropdown
              const Text(
                'Loại thông báo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'INFO', child: Text('Thông tin chung (INFO)')),
                  DropdownMenuItem(value: 'WARNING', child: Text('Cảnh báo (WARNING)')),
                  DropdownMenuItem(value: 'TASK', child: Text('Nhiệm vụ (TASK)')),
                  DropdownMenuItem(value: 'SYSTEM', child: Text('Hệ thống (SYSTEM)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Target Recipient Segmented Button
              const Text(
                'Đối tượng nhận',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildTargetRadioButton('Gửi tất cả', 'ALL')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTargetRadioButton('Theo vai trò', 'ROLE')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTargetRadioButton('Gửi riêng lẻ', 'SPECIFIC')),
                ],
              ),
              const SizedBox(height: 16),

              // Conditional Options: ROLE
              if (_selectedTargetType == 'ROLE') ...[
                const Text(
                  'Chọn vai trò nhận *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedRoleId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('Nhân viên kho (Staff)')),
                    DropdownMenuItem(value: 3, child: Text('Quản lý kho (Manager)')),
                    DropdownMenuItem(value: 1, child: Text('Quản trị viên (Admin)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRoleId = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Conditional Options: SPECIFIC
              if (_selectedTargetType == 'SPECIFIC') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Danh sách người nhận *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    Text(
                      'Đã chọn: ${_selectedUserIds.length} người',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffb3272e), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Search field inside specific list
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _userSearchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên hoặc email...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                if (isLoadingUsers)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xffb3272e))),
                    ),
                  )
                else if (filteredUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text('Không tìm thấy người dùng nào phù hợp', style: TextStyle(color: Colors.black54)),
                    ),
                  )
                else
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[350]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredUsers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
                      itemBuilder: (context, index) {
                        final u = filteredUsers[index];
                        final id = u['userID'] as int;
                        final name = u['fullName'] as String? ?? 'Chưa đặt tên';
                        final email = u['email'] as String? ?? '';
                        final roleName = u['roleName'] as String? ?? 'Staff';
                        final avatar = u['avatarUrl'] as String? ?? '';
                        final isChecked = _selectedUserIds.contains(id);

                        return CheckboxListTile(
                          value: isChecked,
                          activeColor: const Color(0xffb3272e),
                          onChanged: (bool? val) {
                            setState(() {
                              if (val == true) {
                                _selectedUserIds.add(id);
                              } else {
                                _selectedUserIds.remove(id);
                              }
                            });
                          },
                          secondary: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                              avatar.isNotEmpty ? avatar : 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                            ),
                          ),
                          title: Text(
                            name, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  email, 
                                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: roleName == 'Admin' 
                                      ? const Color(0xffffdad6)
                                      : roleName == 'Manager'
                                          ? const Color(0xffe2f4f2)
                                          : const Color(0xffe9ecef),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  roleName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8, 
                                    fontWeight: FontWeight.bold, 
                                    color: roleName == 'Admin'
                                        ? const Color(0xffba1a1a)
                                        : roleName == 'Manager'
                                            ? const Color(0xff006a67)
                                            : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSending ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xffb3272e)),
                        foregroundColor: const Color(0xffb3272e),
                      ),
                      child: const Text('HỦY BỎ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xffb3272e),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('GỬI THÔNG BÁO', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetRadioButton(String label, String value) {
    final isSelected = _selectedTargetType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTargetType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xfffef3f2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xffb3272e) : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xffb3272e) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

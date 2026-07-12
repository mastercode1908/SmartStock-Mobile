import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../main_tab_screen.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/employee_dashboard_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Colors from the HTML design
  final Color _primaryColor = const Color(0xFFB02528);
  final Color _backgroundColor = const Color(0xFFF9F9F9);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _onSurfaceColor = const Color(0xFF1A1C1C);
  final Color _onSurfaceVariantColor = const Color(0xFF5A413F);
  final Color _outlineColor = const Color(0xFF8E706E);
  final Color _outlineVariantColor = const Color(0xFFE2BEBB);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email, password);

    if (!mounted) return;

    if (success) {
      final roleName = authProvider.currentUser?.roleName;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => roleName == 'Staff'
              ? const MainTabScreen()
              : const DashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Đăng nhập thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: _outlineVariantColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Smart Stock',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hệ thống quản lý kho vận chuyên nghiệp',
                      style: TextStyle(
                        fontSize: 16,
                        color: _onSurfaceVariantColor,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Email field
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Nhập email',
                    prefixIcon: Icon(Icons.person_outline, color: _outlineColor),
                    filled: true,
                    fillColor: _backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _outlineVariantColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                  ),
                  style: TextStyle(color: _onSurfaceColor, fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Password field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mật khẩu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _onSurfaceColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          fontSize: 14,
                          color: _primaryColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Nhập mật khẩu',
                    prefixIcon: Icon(Icons.lock_outline, color: _outlineColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: _outlineColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: _backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _outlineVariantColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                  ),
                  style: TextStyle(color: _onSurfaceColor, fontSize: 16),
                ),
                const SizedBox(height: 24),

                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: auth.isLoading 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đăng nhập',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.login, size: 20),
                            ],
                          ),
                    );
                  }
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: _outlineVariantColor.withOpacity(0.5))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'hoặc đăng nhập bằng',
                        style: TextStyle(color: _onSurfaceVariantColor, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: _outlineVariantColor.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _onSurfaceColor,
                    side: BorderSide(color: _outlineVariantColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata, size: 24, color: Colors.blue),
                  ),
                  label: const Text(
                    'Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: '20446891708-5gkike9c82loe50enjm886ooourcb1tn.apps.googleusercontent.com',
        serverClientId: '20446891708-oj06b6u35dasbrvngbu2ma8pev8pu618.apps.googleusercontent.com',
      );
      
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email'],
      );
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('Không lấy được ID Token từ Google OAuth.');
      }
      
      _performGoogleLoginWithToken(idToken);
    } catch (e) {
      _showGoogleMockSelectionSheet(e.toString());
    }
  }

  void _showGoogleMockSelectionSheet(String errorMsg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'Google OAuth Fallback',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Khởi chạy Google OAuth thực tế không thành công:\n$errorMsg\n\nBạn có muốn chuyển sang chế độ Mô phỏng Google Login để tiếp tục kiểm thử?',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildGoogleAccountItem(
                  email: 'admin@smartstock.com',
                  name: 'System Admin (Pre-configured)',
                ),
                _buildGoogleAccountItem(
                  email: 'manager@smartstock.com',
                  name: 'Warehouse Manager (Pre-configured)',
                ),
                _buildGoogleAccountItem(
                  email: 'staff@smartstock.com',
                  name: 'Warehouse Staff (Pre-configured)',
                ),
                const Divider(height: 24),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xfff1f3f5),
                    child: Icon(Icons.add, color: Colors.black54),
                  ),
                  title: const Text(
                    'Đăng nhập bằng một email Google khác',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showCustomEmailInputDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleAccountItem({required String email, required String name}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _primaryColor.withOpacity(0.1),
        child: Text(
          name[0],
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(email),
      onTap: () {
        Navigator.pop(context);
        _performGoogleLoginWithToken("mock-oauth-token-$email");
      },
    );
  }

  void _showCustomEmailInputDialog() {
    final TextEditingController emailInputController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Nhập Email Google'),
          content: TextField(
            controller: emailInputController,
            decoration: const InputDecoration(
              hintText: 'vi_du@gmail.com',
              labelText: 'Email',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailInputController.text.trim();
                if (email.isNotEmpty && email.contains('@')) {
                  Navigator.pop(context);
                  _performGoogleLoginWithToken("mock-oauth-token-$email");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập email hợp lệ')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
              child: const Text('Tiếp tục'),
            ),
          ],
        );
      },
    );
  }

  void _performGoogleLoginWithToken(String idToken) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithGoogle(idToken);

    if (!mounted) return;

    if (success) {
      final roleName = authProvider.currentUser?.roleName;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => roleName == 'Staff'
              ? const MainTabScreen()
              : const DashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Đăng nhập Google thất bại')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main_tab_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../home/screens/employee_dashboard_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
    _checkAuth();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    // Add a delay for the splash screen feel (3 seconds like the HTML)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    final isAuth = await authProvider.tryAutoLogin();

    if (mounted) {
      if (isAuth) {
        final roleName = authProvider.currentUser?.roleName;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => roleName == 'Staff'
                ? const MainTabScreen()
                : const DashboardScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Subtle background gradient at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height / 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFFB02528).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD23E3E), // primary-container
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD23E3E)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.white, // on-primary-container
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // App Title
                  const Text(
                    'Smart Stock',
                    style: TextStyle(
                      color: Color(0xFF1A1C1C), // on-background
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // App Subtitle
                  const Text(
                    'Hệ thống quản lý kho thông minh',
                    style: TextStyle(
                      color: Color(0xFF5A413F), // on-surface-variant
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Loading Indicator
                  Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: const LinearProgressIndicator(
                            backgroundColor: Color(0xFFE2E2E2), // surface-variant
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB02528)), // primary
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đang tải dữ liệu...',
                        style: TextStyle(
                          color: const Color(0xFF5A413F).withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

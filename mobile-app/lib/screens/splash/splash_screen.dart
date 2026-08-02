import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/routes/app_routes.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    final session = await AuthService.restoreSession();
    if (session['token'] != null && session['token']!.isNotEmpty) {
      final role = session['role'];
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else if (role == 'vendor') {
        Navigator.pushReplacementNamed(context, AppRoutes.vendorDashboard);
      } else if (role == 'qc') {
        Navigator.pushReplacementNamed(context, AppRoutes.qcDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam, size: 100, color: Colors.white).animate().fade().scale(),
              const SizedBox(height: 20),
              const Text('ElevateIQ Video Platform',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ).animate().fade().slideY(),
            ],
          ),
        ),
      ),
    );
  }
}

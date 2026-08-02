import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/signup/candidate_signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/recording/video_recording_screen.dart';
import 'screens/upload/video_upload_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/mobile_admin_dashboard_screen.dart';
import 'screens/vendor/mobile_vendor_dashboard_screen.dart';
import 'screens/qc/mobile_qc_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElevateIQ Platform',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.root,
      routes: {
        AppRoutes.root: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.candidateSignup: (context) => const CandidateSignupScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.record: (context) => const VideoRecordingScreen(),
        AppRoutes.upload: (context) => const VideoUploadScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.adminDashboard: (context) => const MobileAdminDashboardScreen(),
        AppRoutes.vendorDashboard: (context) => const MobileVendorDashboardScreen(),
        AppRoutes.qcDashboard: (context) => const MobileQcDashboardScreen(),
      },
    );
  }
}

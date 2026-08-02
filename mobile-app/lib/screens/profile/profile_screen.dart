import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/auth_service.dart';
import '../../config/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text('JD', style: TextStyle(fontSize: 32, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.verified, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Candidate ID: CAND-001', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Vendor ID: VEND-123', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: 'CAND-001|VEND-123',
                    version: QrVersions.auto,
                    size: 150.0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

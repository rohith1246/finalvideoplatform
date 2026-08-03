import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    try {
      final data = await AuthService.login(_emailCtrl.text, _passCtrl.text);
      final role = (data['role'] ?? '').toString().toLowerCase();
      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else if (role == 'vendor') {
        Navigator.pushReplacementNamed(context, AppRoutes.vendorDashboard);
      } else if (role == 'qc' || role == 'qc_team') {
        Navigator.pushReplacementNamed(context, AppRoutes.qcDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ElevateIQ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
              const Text('Video Platform', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 30),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Quick Test Login:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Admin'),
                    onPressed: () {
                      _emailCtrl.text = 'admin@gmail.com';
                      _passCtrl.text = 'admin123';
                    },
                  ),
                  ActionChip(
                    label: const Text('Vendor'),
                    onPressed: () {
                      _emailCtrl.text = 'vendor@gmail.com';
                      _passCtrl.text = 'vendor123';
                    },
                  ),
                  ActionChip(
                    label: const Text('Candidate'),
                    onPressed: () {
                      _emailCtrl.text = 'candidate@gmail.com';
                      _passCtrl.text = 'candidate123';
                    },
                  ),
                  ActionChip(
                    label: const Text('QC Team'),
                    onPressed: () {
                      _emailCtrl.text = 'qcteam@gmail.com';
                      _passCtrl.text = 'qcteam123';
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.candidateSignup),
                child: const Text('New Candidate? Register Here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

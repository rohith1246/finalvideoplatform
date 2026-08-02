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
      final role = data['role'];
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else if (role == 'vendor') {
        Navigator.pushReplacementNamed(context, AppRoutes.vendorDashboard);
      } else if (role == 'qc') {
        Navigator.pushReplacementNamed(context, AppRoutes.qcDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
    setState(() => _loading = false);
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
              const SizedBox(height: 40),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
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
                  onPressed: _loading ? null : _login,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login'),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: ['Admin', 'Vendor', 'Candidate', 'QC'].map((role) {
                  return ActionChip(
                    label: Text(role),
                    onPressed: () {
                      _emailCtrl.text = '${role.toLowerCase()}@example.com';
                      _passCtrl.text = 'password123';
                    },
                  );
                }).toList(),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.candidateSignup),
                child: const Text('New Candidate? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

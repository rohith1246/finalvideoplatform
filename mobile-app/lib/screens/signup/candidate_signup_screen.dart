import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class CandidateSignupScreen extends StatefulWidget {
  const CandidateSignupScreen({super.key});
  @override
  State<CandidateSignupScreen> createState() => _CandidateSignupScreenState();
}

class _CandidateSignupScreenState extends State<CandidateSignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  void _signup() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signup(_emailCtrl.text, _passCtrl.text, _nameCtrl.text, _vendorCtrl.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signup successful. Please login.')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: ${e.toString()}')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidate Sign Up')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 16),
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 16),
          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 16),
          TextField(controller: _vendorCtrl, decoration: const InputDecoration(labelText: 'Vendor Code')),
          const SizedBox(height: 16),
          TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 16),
          TextField(controller: _confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _signup,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}

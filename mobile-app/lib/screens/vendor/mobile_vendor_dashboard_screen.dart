import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../config/routes/app_routes.dart';

class MobileVendorDashboardScreen extends StatefulWidget {
  const MobileVendorDashboardScreen({super.key});

  @override
  State<MobileVendorDashboardScreen> createState() => _MobileVendorDashboardScreenState();
}

class _MobileVendorDashboardScreenState extends State<MobileVendorDashboardScreen> {
  String _vendorCode = 'VEND-000';
  int _candidateCount = 0;
  int _videoCount = 0;
  double _approvedHours = 0.0;
  double _totalEarnings = 0.0;
  List<dynamic> _candidates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendorData();
  }

  Future<void> _fetchVendorData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    setState(() => _isLoading = true);

    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await http.get(Uri.parse('${ApiConstants.apiBase}/vendors/dashboard-stats'), headers: headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body)['data'] ?? {};
        setState(() {
          _vendorCode = body['vendor_code'] ?? 'VEND-001';
          _candidateCount = body['candidate_count'] ?? 0;
          _videoCount = body['video_count'] ?? 0;
          _approvedHours = (body['approved_hours'] ?? 0.0).toDouble();
          _totalEarnings = (body['total_earnings'] ?? 0.0).toDouble();
        });
      }

      final candRes = await http.get(Uri.parse('${ApiConstants.apiBase}/candidates'), headers: headers);
      if (candRes.statusCode == 200) {
        final body = jsonDecode(candRes.body);
        setState(() {
          _candidates = body['data'] as List? ?? [];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      }
    }
  }

  void _showAddCandidateModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Register Candidate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Initial Password', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                try {
                  await AuthService.signup(emailCtrl.text, passCtrl.text, nameCtrl.text, _vendorCode);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _fetchVendorData();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.blue.shade700),
              child: const Text('Add Candidate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchVendorData),
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.pushNamed(context, AppRoutes.profile)),
          IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), tooltip: 'Sign Out', onPressed: _handleLogout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchVendorData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text('Your Vendor Registration Code', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(_vendorCode, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.blue.shade700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _metricCard('Candidates', '$_candidateCount', Colors.blue),
                      _metricCard('Videos', '$_videoCount', Colors.orange),
                      _metricCard('Approved Hrs', '${_approvedHours.toStringAsFixed(1)}', Colors.green),
                      _metricCard('Earnings ₹', '₹${_totalEarnings.toInt()}', Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Registered Candidates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () => _showAddCandidateModal(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_candidates.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text('No candidates registered under your vendor code yet.')),
                      ),
                    )
                  else
                    ..._candidates.map((c) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(Icons.person, color: Colors.blue),
                            ),
                            title: Text(c['full_name'] ?? 'Candidate', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${c['email'] ?? ''} • ${c['phone'] ?? 'No phone'}'),
                            trailing: const Chip(
                              label: Text('Active', style: TextStyle(fontSize: 11, color: Colors.white)),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _metricCard(String title, String val, Color c) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: c.withOpacity(0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: c)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

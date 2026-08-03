import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../config/routes/app_routes.dart';

class MobileAdminDashboardScreen extends StatefulWidget {
  const MobileAdminDashboardScreen({super.key});

  @override
  State<MobileAdminDashboardScreen> createState() => _MobileAdminDashboardScreenState();
}

class _MobileAdminDashboardScreenState extends State<MobileAdminDashboardScreen> {
  Map<String, dynamic> _stats = {
    'total_vendors': 0,
    'total_candidates': 0,
    'total_videos': 0,
    'pending_qc': 0,
  };
  List<dynamic> _vendors = [];
  List<dynamic> _qcQueue = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    setState(() => _isLoading = true);

    try {
      final headers = {'Authorization': 'Bearer $token'};
      
      // Fetch Stats
      final statsRes = await http.get(Uri.parse('${ApiConstants.apiBase}/admins/dashboard-stats'), headers: headers);
      if (statsRes.statusCode == 200) {
        final body = jsonDecode(statsRes.body);
        _stats = body['data'] ?? _stats;
      }

      // Fetch Vendors
      final vendorsRes = await http.get(Uri.parse('${ApiConstants.apiBase}/vendors'), headers: headers);
      if (vendorsRes.statusCode == 200) {
        final body = jsonDecode(vendorsRes.body);
        _vendors = body['data'] as List? ?? [];
      }

      // Fetch Pending QC Videos
      final videosRes = await http.get(Uri.parse('${ApiConstants.apiBase}/videos?status=pending'), headers: headers);
      if (videosRes.statusCode == 200) {
        final body = jsonDecode(videosRes.body);
        _qcQueue = body['data'] as List? ?? [];
      }
    } catch (e) {
      // Handle error silently or show snackbar
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _dispatchQC() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.apiBase}/admins/videos/dispatch-qc'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QC Tasks Dispatched Successfully!')));
        }
        _fetchAdminData();
      }
    } catch (_) {}
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out from Admin?'),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAdminData),
            IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), tooltip: 'Sign Out', onPressed: _handleLogout),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Vendors'),
              Tab(text: 'QC Queue'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildOverview(),
                  _buildVendorList(),
                  _buildQCQueue(),
                ],
              ),
      ),
    );
  }

  Widget _buildOverview() {
    return RefreshIndicator(
      onRefresh: _fetchAdminData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _metricCard('Vendors', '${_stats['total_vendors'] ?? _vendors.length}', Colors.blue),
              _metricCard('Candidates', '${_stats['total_candidates'] ?? 0}', Colors.green),
              _metricCard('Videos', '${_stats['total_videos'] ?? 0}', Colors.orange),
              _metricCard('Pending QC', '${_stats['pending_qc'] ?? _qcQueue.length}', Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _dispatchQC,
            icon: const Icon(Icons.send_rounded, color: Colors.white),
            label: const Text('Dispatch QC Tasks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: Colors.blue),
                    title: const Text('View Profile Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                ],
              ),
            ),
          )
        ],
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
          Text(val, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: c)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildVendorList() {
    if (_vendors.isEmpty) {
      return const Center(child: Text('No vendors registered yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _vendors.length,
      itemBuilder: (context, index) {
        final v = _vendors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.store, color: Colors.blue),
            ),
            title: Text(v['company_name'] ?? 'Vendor Company', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Code: ${v['vendor_code'] ?? 'N/A'} • ${v['email'] ?? ''}'),
            trailing: const Chip(label: Text('Active', style: TextStyle(fontSize: 11)), backgroundColor: Colors.greenAccent),
          ),
        );
      },
    );
  }

  Widget _buildQCQueue() {
    if (_qcQueue.isEmpty) {
      return const Center(child: Text('No pending videos in QC queue.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _qcQueue.length,
      itemBuilder: (context, index) {
        final item = _qcQueue[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.video_file, color: Colors.orange),
            title: Text(item['title'] ?? 'Video #${item['id']}'),
            subtitle: Text('Candidate ID: ${item['candidate_id'] ?? 'Unknown'}'),
            trailing: ElevatedButton(
              onPressed: _dispatchQC,
              child: const Text('Assign QC'),
            ),
          ),
        );
      },
    );
  }
}

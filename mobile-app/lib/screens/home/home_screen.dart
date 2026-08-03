import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../config/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Candidate';
  List<dynamic> _videos = [];
  bool _isLoading = true;
  int _approvedCount = 0;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? 'Candidate';
    final token = prefs.getString('token') ?? '';

    setState(() {
      _userName = name;
      _isLoading = true;
    });

    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.apiBase}/videos'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List? ?? [];
        int app = 0;
        int pend = 0;
        for (var v in list) {
          final st = v['status'] ?? 'pending';
          if (st.toString().contains('approved')) {
            app++;
          } else {
            pend++;
          }
        }
        setState(() {
          _videos = list;
          _approvedCount = app;
          _pendingCount = pend;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
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

  Color _getStatusColor(String status) {
    if (status.contains('approved')) return Colors.green;
    if (status.contains('rejected')) return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $_userName!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Collection Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetric('Total Videos', '${_videos.length}'),
                        _buildMetric('Approved', '$_approvedCount'),
                        _buildMetric('Pending', '$_pendingCount'),
                      ],
                    ),
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
                _buildActionCard(context, 'Record Video', Icons.videocam, AppRoutes.record, Colors.blue),
                _buildActionCard(context, 'Upload Video', Icons.cloud_upload, AppRoutes.upload, Colors.green),
                _buildActionCard(context, 'My Profile', Icons.person, AppRoutes.profile, Colors.purple),
                _buildActionCard(context, 'Settings', Icons.settings, null, Colors.orange),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Submissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_videos.length} items', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
            else if (_videos.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.video_library_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('No videos submitted yet', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.record),
                        icon: const Icon(Icons.videocam),
                        label: const Text('Record First Video'),
                      )
                    ],
                  ),
                ),
              )
            else
              ..._videos.map((v) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.video_file, color: Colors.blue),
                      ),
                      title: Text(v['title'] ?? 'Video Submission', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${v['environment_tag'] ?? 'General'} • ${v['duration_seconds'] ?? 0}s'),
                      trailing: Chip(
                        label: Text((v['status'] ?? 'pending').toString().toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        backgroundColor: _getStatusColor(v['status'] ?? 'pending'),
                      ),
                    ),
                  )),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Record'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_upload), label: 'Uploads'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, AppRoutes.record);
          if (index == 2) Navigator.pushNamed(context, AppRoutes.upload);
          if (index == 3) Navigator.pushNamed(context, AppRoutes.profile);
        },
      ),
    );
  }

  Widget _buildMetric(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, String? route, Color color) {
    return InkWell(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../config/routes/app_routes.dart';

class MobileQcDashboardScreen extends StatefulWidget {
  const MobileQcDashboardScreen({super.key});
  @override
  State<MobileQcDashboardScreen> createState() => _MobileQcDashboardScreenState();
}

class _MobileQcDashboardScreenState extends State<MobileQcDashboardScreen> {
  double _audio = 5;
  double _lighting = 5;
  double _framing = 5;
  double _env = 5;
  List<dynamic> _tickets = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchQCTickets();
  }

  Future<void> _fetchQCTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    setState(() => _isLoading = true);

    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.apiBase}/qc/tickets/assigned'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _tickets = body['data'] as List? ?? [];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitQC(bool approved) async {
    if (_tickets.isEmpty) return;

    final currentTicket = _tickets[_currentIndex];
    final videoId = currentTicket['id'];
    String rejectionReason = '';

    if (!approved) {
      final reason = await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Rejection Reason', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...['Poor Audio Quality', 'Low Lighting / Dark Video', 'Bad Framing / Out of Focus', 'Invalid Environment'].map(
                (reasonText) => ListTile(
                  title: Text(reasonText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(ctx, reasonText),
                ),
              ),
            ],
          ),
        ),
      );

      if (reason == null) return;
      rejectionReason = reason;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final overall = (_audio + _lighting + _framing + _env) / 4.0;

    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.apiBase}/qc/reviews'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'video_id': videoId,
          'audio_rating': _audio.toInt(),
          'lighting_rating': _lighting.toInt(),
          'framing_rating': _framing.toInt(),
          'environment_rating': _env.toInt(),
          'overall_score': overall,
          'status': approved ? 'qc_approved' : 'qc_rejected',
          'rejection_reason': rejectionReason,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(approved ? 'Video Approved!' : 'Video Rejected: $rejectionReason')),
          );
        }
        _fetchQCTickets();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting QC: $e')));
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out from QC Dashboard?'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('QC Team Review'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchQCTickets),
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.pushNamed(context, AppRoutes.profile)),
          IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), tooltip: 'Sign Out', onPressed: _handleLogout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
                        const SizedBox(height: 16),
                        const Text('All Caught Up!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('No pending assigned videos in your QC queue.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(onPressed: _fetchQCTickets, icon: const Icon(Icons.refresh), label: const Text('Check for New Tickets'))
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Assigned Queue (${_tickets.length} left)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Chip(label: Text('Ticket ${_currentIndex + 1}/${_tickets.length}')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
                                onPressed: () {},
                              ),
                              Text(
                                _tickets[_currentIndex]['title'] ?? 'Video #${_tickets[_currentIndex]['id']}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Quality Ratings (0-10)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildSlider('Audio Quality', _audio, (v) => setState(() => _audio = v)),
                    _buildSlider('Lighting', _lighting, (v) => setState(() => _lighting = v)),
                    _buildSlider('Framing & Focus', _framing, (v) => setState(() => _framing = v)),
                    _buildSlider('Environment Tag', _env, (v) => setState(() => _env = v)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _submitQC(false),
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text('Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _submitQC(true),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
    );
  }

  Widget _buildSlider(String label, double val, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
          child: Text('$label: ${val.toInt()}/10', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Slider(
          value: val,
          min: 0,
          max: 10,
          divisions: 10,
          label: val.toInt().toString(),
          activeColor: Colors.blue.shade700,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

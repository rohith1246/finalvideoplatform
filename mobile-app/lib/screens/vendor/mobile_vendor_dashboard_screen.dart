import 'package:flutter/material.dart';

class MobileVendorDashboardScreen extends StatelessWidget {
  const MobileVendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Your Vendor Code', style: TextStyle(color: Colors.grey)),
                  Text('VEND-789', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
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
              _metricCard('Candidates', '42'),
              _metricCard('Videos', '156'),
              _metricCard('Approved Hrs', '34.5'),
              _metricCard('Earnings ₹', '45,000'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Candidates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => _showAddCandidateModal(context),
                child: const Text('+ Add'),
              )
            ],
          ),
          ...List.generate(3, (index) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Candidate ${index + 1}'),
            trailing: const Chip(label: Text('Active'), backgroundColor: Colors.greenAccent),
          )),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String val) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAddCandidateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Candidate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text('Send Invite'),
            )
          ],
        ),
      ),
    );
  }
}

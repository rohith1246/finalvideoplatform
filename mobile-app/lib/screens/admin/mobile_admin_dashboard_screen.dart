import 'package:flutter/material.dart';

class MobileAdminDashboardScreen extends StatelessWidget {
  const MobileAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Vendors'),
              Tab(text: 'QC Queue'),
            ],
          ),
        ),
        body: TabBarView(
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _metricCard('Vendors', '12', Colors.blue),
            _metricCard('Candidates', '450', Colors.green),
            _metricCard('Videos', '890', Colors.orange),
            _metricCard('Pending QC', '34', Colors.red),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {}, child: const Text('Dispatch QC Tasks')),
        const SizedBox(height: 20),
        const Card(
          child: SizedBox(
            height: 200,
            child: Center(child: Text('7-Day Trend Chart (Canvas)')), // Simplification for canvas
          ),
        )
      ],
    );
  }

  Widget _metricCard(String title, String val, Color c) {
    return Card(
      color: c.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: c)),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildVendorList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.store)),
          title: Text('Vendor ${index + 1}'),
          subtitle: const Text('Active Candidates: 45'),
        );
      },
    );
  }

  Widget _buildQCQueue() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.video_file),
          title: Text('Video_Task_${index + 1}.mp4'),
          trailing: ElevatedButton(onPressed: () {}, child: const Text('Assign')),
        );
      },
    );
  }
}

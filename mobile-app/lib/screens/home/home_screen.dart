import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
        actions: [
          IconButton(
            icon: const Badge(child: Icon(Icons.notifications)),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today\'s Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric('Videos', '3'),
                      _buildMetric('Hours', '1.5'),
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
              _buildActionCard(context, 'Record Video', Icons.videocam, AppRoutes.record),
              _buildActionCard(context, 'Guidelines', Icons.library_books, null),
              _buildActionCard(context, 'Env Tags', Icons.tag, null),
              _buildActionCard(context, 'Settings', Icons.settings, null),
            ],
          ),
          const SizedBox(height: 20),
          const Text('My Uploads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.video_file),
            title: const Text('Indoor_Session_1.mp4'),
            trailing: Chip(label: const Text('Approved'), backgroundColor: Colors.green.shade100),
          ),
          ListTile(
            leading: const Icon(Icons.video_file),
            title: const Text('Outdoor_Session_2.mp4'),
            trailing: Chip(label: const Text('Pending'), backgroundColor: Colors.orange.shade100),
          ),
        ],
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
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, String? route) {
    return InkWell(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

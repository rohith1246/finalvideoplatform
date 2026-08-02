import 'package:flutter/material.dart';

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

  void _submitQC(bool approved) {
    if (!approved) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rejection Reason', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                items: ['Poor Audio', 'Poor Lighting', 'Bad Framing', 'Invalid Env'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) {},
                decoration: const InputDecoration(labelText: 'Select Reason'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size.fromHeight(50)),
                child: const Text('Confirm Reject'),
              )
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video Approved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QC Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Assigned Video', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            color: Colors.black,
            child: SizedBox(
              height: 200,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Rate Parameters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildSlider('Audio Quality', _audio, (v) => setState(() => _audio = v)),
          _buildSlider('Lighting', _lighting, (v) => setState(() => _lighting = v)),
          _buildSlider('Framing', _framing, (v) => setState(() => _framing = v)),
          _buildSlider('Environment', _env, (v) => setState(() => _env = v)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _submitQC(false),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _submitQC(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Approve'),
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
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: Text('$label: ${val.toInt()}/10', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Slider(
          value: val,
          min: 0,
          max: 10,
          divisions: 10,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

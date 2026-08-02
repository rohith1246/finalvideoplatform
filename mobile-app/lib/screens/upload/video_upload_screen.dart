import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key});
  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  File? _selectedFile;
  double _progress = 0;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;
    setState(() {
      _isUploading = true;
      _progress = 0;
    });
    // Dummy upload simulation
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _progress = i / 100);
    }
    setState(() => _isUploading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload Complete!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedFile != null) ...[
              const Icon(Icons.video_file, size: 80, color: Colors.blue),
              const SizedBox(height: 10),
              Text(_selectedFile!.path.split('/').last, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
            ],
            if (_isUploading) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 10),
              Text('${(_progress * 100).toInt()}% Uploaded'),
              const SizedBox(height: 20),
            ],
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: const Icon(Icons.folder),
              label: const Text('Select File'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selectedFile == null || _isUploading ? null : _upload,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Start Upload'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

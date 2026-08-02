import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';

class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({super.key});
  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  int _secondsRemaining = 1800; // 30 mins
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras.first, ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _stopRecording();
      }
    });
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _secondsRemaining = 1800;
      });
      _startTimer();
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final file = await _controller!.stopVideoRecording();
    setState(() => _isRecording = false);
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Recording Saved'),
          content: Text('File: ${file.name}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Save Draft')),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Go to upload
              },
              child: const Text('Upload Now'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Chip(label: Text('Indoor'), backgroundColor: Colors.white70),
                const SizedBox(width: 10),
                const Chip(label: Text('Daylight'), backgroundColor: Colors.white70),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _toggleRecording,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _isRecording ? Colors.red : Colors.white,
                  child: Icon(_isRecording ? Icons.stop : Icons.videocam, color: _isRecording ? Colors.white : Colors.red, size: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

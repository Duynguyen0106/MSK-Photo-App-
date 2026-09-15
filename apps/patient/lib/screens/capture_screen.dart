import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../widgets/disclaimer_banner.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final service = CameraCaptureService();
      await service.initialize();
      if (service.cameras.isEmpty) {
        setState(() {
          _error = 'No camera found';
          _initializing = false;
        });
        return;
      }
      final controller = await service.createController();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Camera unavailable';
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final file = await _controller!.takePicture();
    if (!mounted) return;
    final provider = context.read<CheckInProvider>();
    provider.setUsedManualFallback(false);
    provider.addPhotoPath(file.path);
    Navigator.pushNamed(context, AppRoutes.analyzing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a photo')),
      body: Column(
        children: [
          const DisclaimerBanner(),
          Expanded(child: _buildPreview()),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _controller != null ? _capture : null,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture photo'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.captureFallback,
                      ),
                  child: const Text('Use manual entry instead'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 48),
              const SizedBox(height: 12),
              Text(_error ?? 'Camera not available'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.captureFallback,
                ),
                child: const Text('Continue without photo'),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CameraPreview(_controller!),
      ),
    );
  }
}

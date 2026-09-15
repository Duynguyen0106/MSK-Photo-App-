import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/assessment_provider.dart';
import '../widgets/health_disclaimer.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({
    super.key,
    required this.onPhotoCaptured,
    required this.onManualFallback,
  });

  final VoidCallback onPhotoCaptured;
  final VoidCallback onManualFallback;

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
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
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
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    final provider = context.read<AssessmentProvider>();
    await provider.processPhoto(
      imageBytes: bytes,
      width: _controller!.value.previewSize?.width.toInt() ?? 640,
      height: _controller!.value.previewSize?.height.toInt() ?? 480,
    );
    if (!mounted) return;
    widget.onPhotoCaptured();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Take a photo')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const HealthDisclaimer(),
                  const SizedBox(height: 8),
                  Text(
                    DisclaimerService.photoDisclaimer,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildPreview(theme),
            ),
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
                    onPressed: widget.onManualFallback,
                    child: const Text('Enter details manually instead'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
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
              Icon(Icons.no_photography, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text(_error ?? 'Camera not available'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: widget.onManualFallback,
                child: const Text('Continue without photo'),
              ),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CameraPreview(_controller!),
    );
  }
}

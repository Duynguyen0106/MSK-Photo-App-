import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:msk_core/msk_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../services/analytics_service.dart';
import '../services/camera_input_image.dart';
import '../services/pose_alignment_checker.dart';
import '../widgets/disclaimer_banner.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  static const _alignHoldDuration = Duration(seconds: 2);
  static const _frameInterval = Duration(milliseconds: 500);

  CameraController? _controller;
  late final PoseDetector _detector;
  final _alignmentChecker = PoseAlignmentChecker();

  bool _initializing = true;
  bool _permissionDenied = false;
  bool _streamActive = false;
  bool _isProcessingFrame = false;
  bool _isCapturing = false;
  String? _error;
  String? _capturedPath;

  CapturePrompt _prompt = CapturePrompt.stepBack;
  DateTime? _alignedSince;
  DateTime _lastProcessedAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.accurate,
        mode: PoseDetectionMode.single,
      ),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (!status.isGranted) {
      AnalyticsService.instance.logEvent('photo_permission_denied');
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _initializing = false;
      });
      return;
    }

    try {
      final service = CameraCaptureService();
      await service.initialize();
      if (service.cameras.isEmpty) {
        throw StateError('No camera found');
      }

      final frontCamera = service.cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => service.cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      await _startStream();

      setState(() {
        _initializing = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Camera unavailable';
        _initializing = false;
      });
    }
  }

  Future<void> _startStream() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (_streamActive) return;

    await controller.startImageStream(_onCameraImage);
    _streamActive = true;
  }

  Future<void> _stopStream() async {
    final controller = _controller;
    if (controller == null || !_streamActive) return;

    try {
      await controller.stopImageStream();
    } catch (_) {
      // Stream may already be stopped.
    }
    _streamActive = false;
  }

  void _onCameraImage(CameraImage image) {
    if (_capturedPath != null || _isCapturing) return;

    final now = DateTime.now();
    if (_isProcessingFrame ||
        now.difference(_lastProcessedAt) < _frameInterval) {
      return;
    }

    _lastProcessedAt = now;
    _isProcessingFrame = true;
    unawaited(_processFrame(image));
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      final controller = _controller;
      if (controller == null) return;

      final input = inputImageFromCameraImage(image, controller);
      if (input == null) return;

      final poses = await _detector.processImage(input);
      if (!mounted || _capturedPath != null) return;

      final status = poses.isEmpty
          ? const PoseAlignmentStatus(
              prompt: CapturePrompt.stepBack,
              isAligned: false,
            )
          : _alignmentChecker.evaluate(
              poses.first,
              imageWidth: image.width.toDouble(),
              imageHeight: image.height.toDouble(),
            );

      _applyAlignment(status);
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _applyAlignment(PoseAlignmentStatus status) {
    if (_capturedPath != null || _isCapturing) return;

    setState(() => _prompt = status.prompt);

    if (status.isAligned) {
      _alignedSince ??= DateTime.now();
      final held = DateTime.now().difference(_alignedSince!);
      if (held >= _alignHoldDuration) {
        unawaited(_capturePhoto());
      }
    } else {
      _alignedSince = null;
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || _isCapturing || _capturedPath != null) return;

    _isCapturing = true;
    try {
      await _stopStream();
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedPath = file.path;
        _alignedSince = null;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not capture photo. Try again.')),
        );
        await _startStream();
      }
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> _retake() async {
    if (_capturedPath != null) {
      try {
        await File(_capturedPath!).delete();
      } catch (_) {
        // Ignore missing temp file.
      }
    }

    setState(() {
      _capturedPath = null;
      _prompt = CapturePrompt.stepBack;
      _alignedSince = null;
    });
    await _startStream();
  }

  Future<void> _usePhoto() async {
    if (_capturedPath == null) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final fileName = 'checkin_front_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${docsDir.path}/$fileName';
    await File(_capturedPath!).copy(savedPath);

    if (!mounted) return;

    final provider = context.read<CheckInProvider>();
    provider.setUsedManualFallback(false);
    provider.addPhotoPath(savedPath);

    AnalyticsService.instance.logEvent('photo_captured');
    Navigator.pushReplacementNamed(context, AppRoutes.analyzing);
  }

  void _goToFallback() {
    Navigator.pushReplacementNamed(context, AppRoutes.captureFallback);
  }

  @override
  void dispose() {
    unawaited(_stopStream());
    _controller?.dispose();
    unawaited(_detector.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return _PermissionDeniedView(onContinue: _goToFallback);
    }

    if (_capturedPath != null) {
      return _ReviewView(
        imagePath: _capturedPath!,
        onRetake: _retake,
        onUse: _usePhoto,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Front photo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const DisclaimerBanner(),
          Expanded(child: _buildLivePreview()),
          _PromptSequence(active: _prompt),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: _goToFallback,
                  child: const Text('Skip photo'),
                ),
                const SizedBox(width: 24),
                FloatingActionButton.large(
                  onPressed: _controller != null && !_isCapturing
                      ? _capturePhoto
                      : null,
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreview() {
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
              const Icon(Icons.no_photography_outlined, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Camera not available',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _goToFallback,
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_controller!),
            Center(
              child: Image.asset(
                'assets/silhouette_front.png',
                fit: BoxFit.contain,
                color: Colors.white.withValues(alpha: 0.55),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            if (_prompt == CapturePrompt.holdStill && _alignedSince != null)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: _HoldProgress(
                  startedAt: _alignedSince!,
                  duration: _alignHoldDuration,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PromptSequence extends StatelessWidget {
  const _PromptSequence({required this.active});

  final CapturePrompt active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = [
      (CapturePrompt.stepBack, 'Step back'),
      (CapturePrompt.standStraight, 'Stand straight'),
      (CapturePrompt.holdStill, 'Hold still'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Text(
                '→',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            Text(
              steps[i].$2,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight:
                    steps[i].$1 == active ? FontWeight.w700 : FontWeight.w400,
                color: steps[i].$1 == active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HoldProgress extends StatefulWidget {
  const _HoldProgress({
    required this.startedAt,
    required this.duration,
  });

  final DateTime startedAt;
  final Duration duration;

  @override
  State<_HoldProgress> createState() => _HoldProgressState();
}

class _HoldProgressState extends State<_HoldProgress> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = DateTime.now().difference(widget.startedAt).inMilliseconds /
        widget.duration.inMilliseconds;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 4,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _ReviewView extends StatelessWidget {
  const _ReviewView({
    required this.imagePath,
    required this.onRetake,
    required this.onUse,
  });

  final String imagePath;
  final VoidCallback onRetake;
  final Future<void> Function() onUse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review photo')),
      body: Column(
        children: [
          const DisclaimerBanner(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () => onUse(),
                  child: const Text('Use this'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: onRetake,
                  child: const Text('Retake'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Camera access needed')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DisclaimerBanner(padding: EdgeInsets.zero),
            const Spacer(),
            Icon(
              Icons.no_photography_outlined,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'We need camera access for your posture photo.',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Photos stay on your device. You can still complete your '
              'check-in by entering details manually.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton(
              onPressed: onContinue,
              child: const Text('Continue without photo'),
            ),
          ],
        ),
      ),
    );
  }
}

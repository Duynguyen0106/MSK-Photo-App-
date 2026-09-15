import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/clinician_provider.dart';
import '../widgets/clinical_disclaimer.dart';

class AssessmentCaptureScreen extends StatefulWidget {
  const AssessmentCaptureScreen({super.key, required this.patientId});

  final String patientId;

  @override
  State<AssessmentCaptureScreen> createState() => _AssessmentCaptureScreenState();
}

class _AssessmentCaptureScreenState extends State<AssessmentCaptureScreen> {
  CameraController? _controller;
  bool _initializing = true;

  double _painLevel = 5;
  String _side = 'left';
  int _durationDays = 14;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final service = CameraCaptureService();
      await service.initialize();
      if (service.cameras.isNotEmpty) {
        _controller = await service.createController();
      }
    } catch (_) {}
    setState(() => _initializing = false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureAndSave() async {
    final provider = context.read<ClinicianProvider>();
    final report = SymptomReport(
      reportedAt: DateTime.now(),
      painLevel: _painLevel.round(),
      affectedSide: _side,
      durationDays: _durationDays,
      notes: _notesController.text.trim(),
      usedPhotoCapture: _controller != null,
    );

    PoseObservation? observation;
    if (_controller != null && _controller!.value.isInitialized) {
      final file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      observation = await provider.analyzePose(
        imageBytes: bytes,
        width: _controller!.value.previewSize?.width.toInt() ?? 640,
        height: _controller!.value.previewSize?.height.toInt() ?? 480,
        report: report,
      );
    }

    await provider.recordAssessment(
      patientId: widget.patientId,
      report: report,
      observation: observation,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('New Assessment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ClinicalDisclaimer(),
          const SizedBox(height: 12),
          if (_initializing)
            const Center(child: CircularProgressIndicator())
          else if (_controller != null)
            SizedBox(
              height: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CameraPreview(_controller!),
              ),
            )
          else
            Container(
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Camera unavailable — symptom data only'),
            ),
          const SizedBox(height: 16),
          Text('Reported pain (0–10)', style: theme.textTheme.titleSmall),
          Slider(
            value: _painLevel,
            min: 0,
            max: 10,
            divisions: 10,
            label: _painLevel.round().toString(),
            onChanged: (v) => setState(() => _painLevel = v),
          ),
          Text('Affected side', style: theme.textTheme.titleSmall),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'left', label: Text('L')),
              ButtonSegment(value: 'right', label: Text('R')),
              ButtonSegment(value: 'both', label: Text('Bilateral')),
            ],
            selected: {_side},
            onSelectionChanged: (s) => setState(() => _side = s.first),
          ),
          const SizedBox(height: 8),
          Text('Duration (days)', style: theme.textTheme.titleSmall),
          Row(
            children: [
              IconButton(
                onPressed: _durationDays > 1 ? () => setState(() => _durationDays--) : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_durationDays'),
              IconButton(
                onPressed: () => setState(() => _durationDays++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Clinical notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _captureAndSave,
            child: const Text('Record assessment'),
          ),
        ],
      ),
    );
  }
}

import 'package:camera/camera.dart';

/// Camera enumeration and lifecycle — on-device only.
class CameraCaptureService {
  List<CameraDescription> _cameras = [];

  List<CameraDescription> get cameras => _cameras;

  Future<void> initialize() async {
    _cameras = await availableCameras();
  }

  Future<CameraController> createController({
    CameraLensDirection direction = CameraLensDirection.back,
    ResolutionPreset preset = ResolutionPreset.medium,
  }) async {
    if (_cameras.isEmpty) {
      await initialize();
    }
    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _cameras.first,
    );
    final controller = CameraController(camera, preset, enableAudio: false);
    await controller.initialize();
    return controller;
  }
}

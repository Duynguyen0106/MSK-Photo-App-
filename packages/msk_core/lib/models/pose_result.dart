import 'dart:ui' show Offset;

import 'body_part.dart';

/// A single pose landmark from on-device detection.
class Landmark {
  const Landmark({
    required this.x,
    required this.y,
    required this.z,
    required this.likelihood,
  });

  final double x;
  final double y;
  final double z;
  final double likelihood;

  Map<String, dynamic> toMap() => {
        'x': x,
        'y': y,
        'z': z,
        'likelihood': likelihood,
      };

  factory Landmark.fromMap(Map<String, dynamic> map) => Landmark(
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        z: (map['z'] as num).toDouble(),
        likelihood: (map['likelihood'] as num).toDouble(),
      );
}

/// Result of on-device pose analysis for one image.
class PoseResult {
  const PoseResult({
    required this.imagePath,
    required this.landmarks,
    required this.measurements,
    required this.confidence,
    required this.landmarkPixels,
    required this.success,
    this.errorMessage,
  });

  final String imagePath;
  final List<Landmark> landmarks;
  final Map<String, double?> measurements;
  final Map<String, double> confidence;
  final Map<BodyPart, Offset> landmarkPixels;
  final bool success;
  final String? errorMessage;

  Map<String, dynamic> toMap() => {
        'imagePath': imagePath,
        'landmarks': landmarks.map((l) => l.toMap()).toList(),
        'measurements': measurements.map(
          (key, value) => MapEntry(key, value),
        ),
        'confidence': confidence,
        'landmarkPixels': landmarkPixels.map(
          (part, offset) => MapEntry(
            part.name,
            {'x': offset.dx, 'y': offset.dy},
          ),
        ),
        'success': success,
        'errorMessage': errorMessage,
      };

  /// Failed analysis — no person detected or processing error.
  factory PoseResult.failure(String imagePath, String errorMessage) =>
      PoseResult(
        imagePath: imagePath,
        landmarks: const [],
        measurements: const {},
        confidence: const {},
        landmarkPixels: const {},
        success: false,
        errorMessage: errorMessage,
      );

  factory PoseResult.fromMap(Map<String, dynamic> map) => PoseResult(
        imagePath: map['imagePath'] as String,
        landmarks: (map['landmarks'] as List<dynamic>)
            .map((e) => Landmark.fromMap(e as Map<String, dynamic>))
            .toList(),
        measurements: (map['measurements'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            value == null ? null : (value as num).toDouble(),
          ),
        ),
        confidence: (map['confidence'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
        landmarkPixels:
            (map['landmarkPixels'] as Map<String, dynamic>).map(
          (key, value) {
            final coords = value as Map<String, dynamic>;
            return MapEntry(
              bodyPartFromName(key),
              Offset(
                (coords['x'] as num).toDouble(),
                (coords['y'] as num).toDouble(),
              ),
            );
          },
        ),
        success: map['success'] as bool,
        errorMessage: map['errorMessage'] as String?,
      );
}

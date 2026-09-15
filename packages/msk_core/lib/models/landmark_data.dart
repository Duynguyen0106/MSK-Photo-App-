/// A single pose landmark with confidence.
class LandmarkPoint {
  const LandmarkPoint({
    required this.name,
    required this.x,
    required this.y,
    required this.confidence,
  });

  final String name;
  final double x;
  final double y;
  final double confidence;

  Map<String, dynamic> toJson() => {
        'name': name,
        'x': x,
        'y': y,
        'confidence': confidence,
      };

  factory LandmarkPoint.fromJson(Map<String, dynamic> json) => LandmarkPoint(
        name: json['name'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        confidence: (json['confidence'] as num).toDouble(),
      );
}

/// Angular measurement between three landmarks.
class AngleMeasurement {
  const AngleMeasurement({
    required this.label,
    required this.degrees,
    required this.confidence,
    required this.landmarksUsed,
  });

  final String label;
  final double degrees;
  final double confidence;
  final List<String> landmarksUsed;

  Map<String, dynamic> toJson() => {
        'label': label,
        'degrees': degrees,
        'confidence': confidence,
        'landmarksUsed': landmarksUsed,
      };

  factory AngleMeasurement.fromJson(Map<String, dynamic> json) =>
      AngleMeasurement(
        label: json['label'] as String,
        degrees: (json['degrees'] as num).toDouble(),
        confidence: (json['confidence'] as num).toDouble(),
        landmarksUsed: (json['landmarksUsed'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      );
}

/// Left/right delta for a paired measurement.
class LrDelta {
  const LrDelta({
    required this.metric,
    required this.leftValue,
    required this.rightValue,
    required this.delta,
    required this.unit,
  });

  final String metric;
  final double leftValue;
  final double rightValue;
  final double delta;
  final String unit;

  Map<String, dynamic> toJson() => {
        'metric': metric,
        'leftValue': leftValue,
        'rightValue': rightValue,
        'delta': delta,
        'unit': unit,
      };

  factory LrDelta.fromJson(Map<String, dynamic> json) => LrDelta(
        metric: json['metric'] as String,
        leftValue: (json['leftValue'] as num).toDouble(),
        rightValue: (json['rightValue'] as num).toDouble(),
        delta: (json['delta'] as num).toDouble(),
        unit: json['unit'] as String,
      );
}

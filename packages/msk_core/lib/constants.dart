/// Shared constants for MSK Suite — disclaimers, self-care tips, reference bands.
class MskConstants {
  // ---------------------------------------------------------------------------
  // Disclaimers (both apps)
  // ---------------------------------------------------------------------------

  static const String disclaimerShort =
      'This app does not diagnose, treat, or cure any condition.';

  static const String disclaimerFull =
      'This app does not diagnose, treat, or cure any condition. '
      'All findings are observations based on what you reported and what we recorded. '
      'They are not medical advice. Contact a qualified healthcare provider for medical concerns.';

  static const String disclaimerPhoto =
      'Photos are processed on your device only. '
      'They are never uploaded without your explicit consent.';

  static const String disclaimerClinician =
      'This is a measurement and documentation tool only. '
      'It does not provide treatment recommendations or diagnostic suggestions. '
      'All values are recorded observations, not clinical decisions.';

  static const String disclaimerUrgentCare =
      'Based on what you reported, we recommend seeking urgent medical care. '
      'This app cannot assess emergencies. If you feel unsafe, call emergency services now.';

  // ---------------------------------------------------------------------------
  // Self-care tips per region (patient app only)
  // ---------------------------------------------------------------------------

  static const Map<String, List<String>> selfCareTipsByRegion = {
    'shoulder': [
      'Take breaks from reaching overhead if that makes discomfort worse.',
      'Use gentle arm swings to keep the shoulder moving comfortably.',
    ],
    'neck': [
      'Take short breaks from looking down at screens.',
      'Roll your shoulders slowly if it feels comfortable to do so.',
    ],
    'lowerBack': [
      'Stand up and walk briefly after sitting for a long time.',
      'Avoid staying in one bent position for too long.',
    ],
    'upperBack': [
      'Sit with support behind you when you can.',
      'Stretch your arms forward gently if it feels okay.',
    ],
    'knee': [
      'Go up and down stairs at a pace that feels comfortable.',
      'Use a chair arm for support when standing if you need it.',
    ],
    'hip': [
      'Shift your weight when standing for a while.',
      'Take short walks to ease stiffness when you get up.',
    ],
    'elbow': [
      'Pause gripping activities that you reported make it feel worse.',
      'Straighten and bend your arm gently through the day.',
    ],
    'wrist': [
      'Take breaks from typing or writing when you can.',
      'Shake your hands out gently between tasks.',
    ],
    'ankle': [
      'Wear supportive shoes on uneven ground.',
      'Circle your ankles slowly when you first stand up.',
    ],
    'head': [
      'Rest in a quiet, dim space if light or noise bothers you.',
      'Drink water and take breaks from screen time.',
    ],
    'chest': [
      'Take slow breaths and pause if deep breaths feel uncomfortable.',
      'Avoid twisting quickly if you reported that makes it worse.',
    ],
    'abdomen': [
      'Eat smaller meals if large meals feel uncomfortable.',
      'Avoid bending deeply at the waist if that feels worse.',
    ],
  };

  // ---------------------------------------------------------------------------
  // Reference ranges for clinician documentation (observation bands only)
  // ---------------------------------------------------------------------------

  static const Map<String, ReferenceRange> referenceRanges = {
    'shoulderHeightDiffCm': ReferenceRange(
      label: 'Shoulder height difference',
      low: 0,
      high: 2,
      unit: 'cm',
    ),
    'pelvicTiltDeg': ReferenceRange(
      label: 'Pelvic tilt',
      low: -5,
      high: 5,
      unit: 'deg',
    ),
    'kneeAlignmentLeftDeg': ReferenceRange(
      label: 'Left knee angle',
      low: 170,
      high: 180,
      unit: 'deg',
    ),
    'kneeAlignmentRightDeg': ReferenceRange(
      label: 'Right knee angle',
      low: 170,
      high: 180,
      unit: 'deg',
    ),
    'headLateralOffsetCm': ReferenceRange(
      label: 'Head lateral offset',
      low: 0,
      high: 3,
      unit: 'cm',
    ),
    'forwardHeadAngleDeg': ReferenceRange(
      label: 'Forward head angle',
      low: 40,
      high: 55,
      unit: 'deg',
    ),
    'thoracicKyphosisProxyDeg': ReferenceRange(
      label: 'Thoracic angle proxy',
      low: 0,
      high: 15,
      unit: 'deg',
    ),
  };
}

/// Typical reference band for a recorded measurement (clinician documentation).
class ReferenceRange {
  const ReferenceRange({
    required this.label,
    required this.low,
    required this.high,
    required this.unit,
  });

  final String label;
  final double low;
  final double high;

  /// Display unit: `deg`, `cm`, etc.
  final String unit;

  /// Whether [value] falls within this documented band.
  bool contains(double value) => value >= low && value <= high;

  String get bandLabel => '$low-$high $unit';
}

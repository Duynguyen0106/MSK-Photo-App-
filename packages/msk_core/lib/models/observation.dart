/// A recorded observation — framed as what was reported or measured.
class Observation {
  const Observation({
    required this.region,
    required this.text,
    this.value,
    required this.confidence,
  });

  final String region;
  final String text;
  final double? value;
  final double confidence;

  Map<String, dynamic> toMap() => {
        'region': region,
        'text': text,
        'value': value,
        'confidence': confidence,
      };

  factory Observation.fromMap(Map<String, dynamic> map) => Observation(
        region: map['region'] as String,
        text: map['text'] as String,
        value: map['value'] == null ? null : (map['value'] as num).toDouble(),
        confidence: (map['confidence'] as num).toDouble(),
      );
}

/// Self-reported symptoms — framed as what the user reported.
class SymptomReport {
  const SymptomReport({
    required this.reportedAt,
    required this.painLevel,
    required this.affectedSide,
    required this.durationDays,
    required this.notes,
    required this.usedPhotoCapture,
  });

  final DateTime reportedAt;
  final int painLevel; // 0–10
  final String affectedSide; // 'left', 'right', 'both', 'unsure'
  final int durationDays;
  final String notes;
  final bool usedPhotoCapture;

  Map<String, dynamic> toJson() => {
        'reportedAt': reportedAt.toIso8601String(),
        'painLevel': painLevel,
        'affectedSide': affectedSide,
        'durationDays': durationDays,
        'notes': notes,
        'usedPhotoCapture': usedPhotoCapture,
      };

  factory SymptomReport.fromJson(Map<String, dynamic> json) => SymptomReport(
        reportedAt: DateTime.parse(json['reportedAt'] as String),
        painLevel: json['painLevel'] as int,
        affectedSide: json['affectedSide'] as String,
        durationDays: json['durationDays'] as int,
        notes: json['notes'] as String? ?? '',
        usedPhotoCapture: json['usedPhotoCapture'] as bool? ?? false,
      );
}

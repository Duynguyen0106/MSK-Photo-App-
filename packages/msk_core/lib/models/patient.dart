/// Clinician roster patient — stored on-device only.
class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String notes;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
        id: map['id'] as String,
        name: map['name'] as String,
        notes: map['notes'] as String? ?? '',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

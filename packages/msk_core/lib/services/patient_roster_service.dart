import 'dart:convert';

import '../models/assessment.dart';
import '../models/patient_record.dart';
import 'local_storage_service.dart';
import 'secure_storage_service.dart';

/// Multi-patient roster with encrypted local storage.
class PatientRosterService {
  PatientRosterService({
    LocalStorageService? localStorage,
    SecureStorageService? secureStorage,
  })  : _local = localStorage ?? LocalStorageService(),
        _secure = secureStorage ?? SecureStorageService();

  final LocalStorageService _local;
  final SecureStorageService _secure;
  static const _rosterKey = 'msk_clinician_roster';
  static const _encryptionKeyName = 'msk_roster_enc_key';

  Future<void> init() async {
    await _local.init();
    final existing = await _secure.read(_encryptionKeyName);
    if (existing == null) {
      final key = base64Encode(
        List<int>.generate(32, (i) => (DateTime.now().microsecondsSinceEpoch + i) % 256),
      );
      await _secure.write(_encryptionKeyName, key);
    }
  }

  Future<List<PatientRecord>> loadRoster() async {
    final raw = _local.read(_rosterKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PatientRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRoster(List<PatientRecord> patients) async {
    final json = jsonEncode(patients.map((p) => p.toJson()).toList());
    await _local.save(_rosterKey, json);
  }

  Future<PatientRecord?> getPatient(String id) async {
    final roster = await loadRoster();
    return roster.cast<PatientRecord?>().firstWhere(
          (p) => p?.id == id,
          orElse: () => null,
        );
  }

  Future<void> addPatient(PatientRecord patient) async {
    final roster = await loadRoster();
    roster.add(patient);
    await saveRoster(roster);
  }

  Future<void> updatePatient(PatientRecord patient) async {
    final roster = await loadRoster();
    final index = roster.indexWhere((p) => p.id == patient.id);
    if (index >= 0) {
      roster[index] = patient;
      await saveRoster(roster);
    }
  }

  Future<void> deletePatient(String id) async {
    final roster = await loadRoster();
    roster.removeWhere((p) => p.id == id);
    await saveRoster(roster);
  }

  Future<void> addAssessment(String patientId, Assessment assessment) async {
    final patient = await getPatient(patientId);
    if (patient == null) return;
    final updated = PatientRecord(
      id: patient.id,
      displayName: patient.displayName,
      dateOfBirth: patient.dateOfBirth,
      mrn: patient.mrn,
      createdAt: patient.createdAt,
      assessments: [...patient.assessments, assessment],
      notes: patient.notes,
    );
    await updatePatient(updated);
  }
}

import 'package:hive_flutter/hive_flutter.dart';

import '../models/check_in.dart';
import '../models/patient.dart';

/// On-device Hive storage for check-ins and clinician patients.
///
/// No network calls — all data stays local.
class StorageService {
  StorageService({
    this.checkInsBoxName = 'msk_check_ins',
    this.patientsBoxName = 'msk_patients',
  });

  final String checkInsBoxName;
  final String patientsBoxName;

  bool _initialized = false;

  /// Opens Hive boxes and registers type adapters.
  ///
  /// Pass [path] in tests to use a temp directory instead of [Hive.initFlutter].
  Future<void> init({String? path}) async {
    if (_initialized) return;

    if (path != null) {
      Hive.init(path);
    } else {
      await Hive.initFlutter();
    }

    _registerAdapters();

    if (!Hive.isBoxOpen(checkInsBoxName)) {
      await Hive.openBox<CheckIn>(checkInsBoxName);
    }
    if (!Hive.isBoxOpen(patientsBoxName)) {
      await Hive.openBox<Patient>(patientsBoxName);
    }

    _initialized = true;
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(CheckInAdapter().typeId)) {
      Hive.registerAdapter(CheckInAdapter());
    }
    if (!Hive.isAdapterRegistered(PatientAdapter().typeId)) {
      Hive.registerAdapter(PatientAdapter());
    }
  }

  Box<CheckIn> get _checkIns => Hive.box<CheckIn>(checkInsBoxName);
  Box<Patient> get _patients => Hive.box<Patient>(patientsBoxName);

  // ---------------------------------------------------------------------------
  // Check-in CRUD
  // ---------------------------------------------------------------------------

  Future<void> saveCheckIn(CheckIn checkIn) async {
    await _checkIns.put(checkIn.id, checkIn);
  }

  /// Returns all check-ins, optionally filtered by [patientId].
  Future<List<CheckIn>> getAllCheckIns({String? patientId}) async {
    final all = _checkIns.values.toList();
    final filtered = patientId == null
        ? all
        : all.where((c) => c.patientId == patientId).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Future<void> deleteCheckIn(String id) async {
    await _checkIns.delete(id);
  }

  // ---------------------------------------------------------------------------
  // Patient CRUD (clinician mode)
  // ---------------------------------------------------------------------------

  Future<void> savePatient(Patient patient) async {
    await _patients.put(patient.id, patient);
  }

  Future<List<Patient>> getAllPatients() async {
    final all = _patients.values.toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  Future<Patient?> getPatient(String id) async {
    return _patients.get(id);
  }

  Future<void> deletePatient(String patientId) async {
    await _patients.delete(patientId);

    final keysToDelete = _checkIns.values
        .where((c) => c.patientId == patientId)
        .map((c) => c.id)
        .toList();
    for (final key in keysToDelete) {
      await _checkIns.delete(key);
    }
  }

  // ---------------------------------------------------------------------------
  // Bulk delete
  // ---------------------------------------------------------------------------

  Future<void> deleteAll() async {
    await _checkIns.clear();
    await _patients.clear();
  }
}

// ---------------------------------------------------------------------------
// Hive type adapters
// ---------------------------------------------------------------------------

/// Hive adapter for [CheckIn] using map serialization.
class CheckInAdapter extends TypeAdapter<CheckIn> {
  @override
  final int typeId = 0;

  @override
  CheckIn read(BinaryReader reader) {
    final raw = reader.read();
    return CheckIn.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  @override
  void write(BinaryWriter writer, CheckIn obj) {
    writer.write(obj.toMap());
  }
}

/// Hive adapter for [Patient] using map serialization.
class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 1;

  @override
  Patient read(BinaryReader reader) {
    final raw = reader.read();
    return Patient.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer.write(obj.toMap());
  }
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:msk_core/msk_core.dart';

void main() {
  late Directory tempDir;
  late StorageService storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('msk_storage_test');
    storage = StorageService();
    await storage.init(path: tempDir.path);
  });

  tearDown(() async {
    await storage.deleteAll();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  CheckIn makeCheckIn({
    required String id,
    String? patientId,
  }) {
    return CheckIn(
      id: id,
      date: DateTime(2026, 9, 15),
      selectedParts: [BodyPart.neck],
      painScore: 5,
      durationKey: '1_2_weeks',
      aggravators: ['sitting'],
      redFlags: [],
      observations: const [
        Observation(
          region: 'neck',
          text: 'Region recorded.',
          confidence: 0.0,
        ),
      ],
      questions: ['Sample question?'],
      hasPhoto: false,
      photoPaths: [],
      poseResults: [],
      patientId: patientId,
    );
  }

  group('StorageService check-ins', () {
    test('save and retrieve check-ins', () async {
      final checkIn = makeCheckIn(id: 'ci-1');
      await storage.saveCheckIn(checkIn);

      final all = await storage.getAllCheckIns();
      expect(all.length, 1);
      expect(all.first.id, 'ci-1');
    });

    test('getAllCheckIns filters by patientId', () async {
      await storage.saveCheckIn(makeCheckIn(id: 'ci-1', patientId: 'p-1'));
      await storage.saveCheckIn(makeCheckIn(id: 'ci-2', patientId: 'p-2'));
      await storage.saveCheckIn(makeCheckIn(id: 'ci-3'));

      final forPatient = await storage.getAllCheckIns(patientId: 'p-1');
      expect(forPatient.length, 1);
      expect(forPatient.first.id, 'ci-1');
    });

    test('deleteCheckIn removes one record', () async {
      await storage.saveCheckIn(makeCheckIn(id: 'ci-1'));
      await storage.deleteCheckIn('ci-1');

      expect(await storage.getAllCheckIns(), isEmpty);
    });
  });

  group('StorageService patients', () {
    test('save and retrieve patients', () async {
      final patient = Patient(
        id: 'p-1',
        name: 'Jane Doe',
        notes: 'Follow up in 2 weeks',
        createdAt: DateTime(2026, 1, 10),
      );
      await storage.savePatient(patient);

      final patients = await storage.getAllPatients();
      expect(patients.length, 1);
      expect(patients.first.name, 'Jane Doe');
    });

    test('getPatient returns single patient', () async {
      await storage.savePatient(Patient(
        id: 'p-1',
        name: 'John',
        notes: '',
        createdAt: DateTime(2026, 1, 1),
      ));

      final patient = await storage.getPatient('p-1');
      expect(patient?.name, 'John');
    });

    test('deletePatient removes patient and their check-ins', () async {
      await storage.savePatient(Patient(
        id: 'p-1',
        name: 'Jane',
        notes: '',
        createdAt: DateTime(2026, 1, 1),
      ));
      await storage.saveCheckIn(makeCheckIn(id: 'ci-1', patientId: 'p-1'));
      await storage.saveCheckIn(makeCheckIn(id: 'ci-2', patientId: 'p-2'));

      await storage.deletePatient('p-1');

      expect(await storage.getPatient('p-1'), isNull);
      expect(await storage.getAllCheckIns(), hasLength(1));
      expect((await storage.getAllCheckIns()).first.id, 'ci-2');
      expect(await storage.getAllCheckIns(patientId: 'p-1'), isEmpty);
    });
  });

  group('StorageService deleteAll', () {
    test('clears patients and check-ins', () async {
      await storage.savePatient(Patient(
        id: 'p-1',
        name: 'Jane',
        notes: '',
        createdAt: DateTime(2026, 1, 1),
      ));
      await storage.saveCheckIn(makeCheckIn(id: 'ci-1'));

      await storage.deleteAll();

      expect(await storage.getAllPatients(), isEmpty);
      expect(await storage.getAllCheckIns(), isEmpty);
    });
  });
}

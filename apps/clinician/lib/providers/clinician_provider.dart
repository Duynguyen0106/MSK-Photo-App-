import 'package:flutter/foundation.dart';
import 'package:msk_core/msk_core.dart';

/// Clinician app state — roster and active assessment.
class ClinicianProvider extends ChangeNotifier {
  final PatientRosterService _rosterService = PatientRosterService();
  final PoseAnalysisService _poseService = PoseAnalysisService();
  final PdfExportService _pdfService = PdfExportService();
  final CsvExportService _csvService = CsvExportService();

  List<PatientRecord> patients = [];
  PatientRecord? selectedPatient;
  bool isLoading = true;

  Future<void> init() async {
    await _rosterService.init();
    patients = await _rosterService.loadRoster();
    isLoading = false;
    notifyListeners();
  }

  void selectPatient(PatientRecord patient) {
    selectedPatient = patient;
    notifyListeners();
  }

  Future<void> addPatient({
    required String name,
    required String mrn,
    required DateTime dob,
  }) async {
    final patient = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: name,
      dateOfBirth: dob,
      mrn: mrn,
      createdAt: DateTime.now(),
      assessments: [],
    );
    await _rosterService.addPatient(patient);
    patients = await _rosterService.loadRoster();
    notifyListeners();
  }

  Future<void> deletePatient(String id) async {
    await _rosterService.deletePatient(id);
    patients = await _rosterService.loadRoster();
    if (selectedPatient?.id == id) selectedPatient = null;
    notifyListeners();
  }

  Future<Assessment> recordAssessment({
    required String patientId,
    required SymptomReport report,
    PoseObservation? observation,
  }) async {
    final assessment = Assessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      createdAt: DateTime.now(),
      symptomReport: report,
      poseObservation: observation,
      photoConsentGiven: false,
      notes: '',
    );
    await _rosterService.addAssessment(patientId, assessment);
    patients = await _rosterService.loadRoster();
    selectedPatient = patients.firstWhere((p) => p.id == patientId);
    notifyListeners();
    return assessment;
  }

  Future<PoseObservation> analyzePose({
    required List<int> imageBytes,
    required int width,
    required int height,
    required SymptomReport report,
  }) {
    return _poseService.analyzeImage(
      imageBytes: Uint8List.fromList(imageBytes),
      width: width,
      height: height,
      report: report,
    );
  }

  Future<void> exportPdf(PatientRecord patient, Assessment assessment) =>
      _pdfService.printAssessment(patient, assessment);

  String exportCsv(PatientRecord patient) => _csvService.exportAssessments(patient);

  @override
  void dispose() {
    _poseService.dispose();
    super.dispose();
  }
}

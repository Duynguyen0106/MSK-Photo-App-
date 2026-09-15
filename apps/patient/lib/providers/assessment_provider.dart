import 'package:flutter/foundation.dart';
import 'package:msk_core/msk_core.dart';

/// Holds assessment state across the patient flow.
class AssessmentProvider extends ChangeNotifier {
  final RedFlagService _redFlagService = RedFlagService();
  final PoseAnalysisService _poseService = PoseAnalysisService();
  final PhotoConsentService _consentService = PhotoConsentService();

  Set<RedFlagSymptom> redFlags = {};
  RedFlagResult? redFlagResult;
  SymptomReport? symptomReport;
  PoseObservation? observation;
  bool photoConsentGiven = false;
  bool isProcessing = false;

  void setRedFlags(Set<RedFlagSymptom> flags) {
    redFlags = flags;
    redFlagResult = _redFlagService.evaluate(flags);
    notifyListeners();
  }

  void setSymptomReport(SymptomReport report) {
    symptomReport = report;
    notifyListeners();
  }

  Future<void> grantPhotoConsent() async {
    photoConsentGiven = true;
    await _consentService.grantUploadConsent();
    notifyListeners();
  }

  Future<PoseObservation> processManual() async {
    if (symptomReport == null) {
      throw StateError('No symptom report');
    }
    isProcessing = true;
    notifyListeners();
    final result = _poseService.buildManualObservation(symptomReport!);
    observation = result;
    isProcessing = false;
    notifyListeners();
    return result;
  }

  Future<PoseObservation> processPhoto({
    required List<int> imageBytes,
    required int width,
    required int height,
  }) async {
    if (symptomReport == null) {
      throw StateError('No symptom report');
    }
    isProcessing = true;
    notifyListeners();
    final result = await _poseService.analyzeImage(
      imageBytes: Uint8List.fromList(imageBytes),
      width: width,
      height: height,
      report: symptomReport!.copyWithUsedPhotoCapture(true),
    );
    observation = result;
    isProcessing = false;
    notifyListeners();
    return result;
  }

  void reset() {
    redFlags = {};
    redFlagResult = null;
    symptomReport = null;
    observation = null;
    photoConsentGiven = false;
    isProcessing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _poseService.dispose();
    super.dispose();
  }
}

extension _SymptomReportCopy on SymptomReport {
  SymptomReport copyWithUsedPhotoCapture(bool used) => SymptomReport(
        reportedAt: reportedAt,
        painLevel: painLevel,
        affectedSide: affectedSide,
        durationDays: durationDays,
        notes: notes,
        usedPhotoCapture: used,
      );
}

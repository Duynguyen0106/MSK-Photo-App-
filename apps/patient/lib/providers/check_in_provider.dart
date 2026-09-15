import 'package:flutter/foundation.dart';
import 'package:msk_core/msk_core.dart';

/// In-progress check-in state for the patient flow.
class CheckInProvider extends ChangeNotifier {
  final RedFlagEngine _redFlagEngine = RedFlagEngine();
  final ObservationService _observationService = ObservationService();
  final QuestionService _questionService = QuestionService();

  List<BodyPart> selectedParts = [];
  int painScore = 0;
  String durationKey = 'less_than_week';
  final List<String> aggravators = [];
  final Set<RedFlag> redFlags = {};
  List<String> questions = [];
  List<Observation> observations = [];
  bool hasPhoto = false;
  final List<String> photoPaths = [];
  final Map<String, PoseResult> poseResults = {};
  bool usedManualFallback = false;
  bool isAnalyzing = false;
  CheckIn? completedCheckIn;

  bool get shouldEscalate => _redFlagEngine.shouldEscalate(redFlags);

  String get escalationMessage => _redFlagEngine.escalationMessage();

  // ---------------------------------------------------------------------------
  // Mutators
  // ---------------------------------------------------------------------------

  void setSelectedParts(List<BodyPart> parts) {
    selectedParts = List.of(parts);
    notifyListeners();
  }

  void togglePart(BodyPart part) {
    if (selectedParts.contains(part)) {
      selectedParts.remove(part);
    } else {
      selectedParts.add(part);
    }
    notifyListeners();
  }

  void removePart(BodyPart part) {
    selectedParts.remove(part);
    notifyListeners();
  }

  void setPainScore(int score) {
    painScore = score.clamp(0, 10);
    notifyListeners();
  }

  void setDurationKey(String key) {
    durationKey = key;
    notifyListeners();
  }

  void setAggravators(List<String> values) {
    aggravators
      ..clear()
      ..addAll(values);
    notifyListeners();
  }

  void toggleRedFlag(RedFlag flag) {
    if (redFlags.contains(flag)) {
      redFlags.remove(flag);
    } else {
      redFlags.add(flag);
    }
    notifyListeners();
  }

  void setRedFlags(Set<RedFlag> flags) {
    redFlags
      ..clear()
      ..addAll(flags);
    notifyListeners();
  }

  void addPhotoPath(String path) {
    hasPhoto = true;
    if (!photoPaths.contains(path)) {
      photoPaths.add(path);
    }
    notifyListeners();
  }

  void setPoseResult(String view, PoseResult result) {
    poseResults[view] = result;
    notifyListeners();
  }

  void setUsedManualFallback(bool value) {
    usedManualFallback = value;
    notifyListeners();
  }

  void setAnalyzing(bool value) {
    isAnalyzing = value;
    notifyListeners();
  }

  /// Build follow-up questions from selected body parts.
  void refreshQuestions() {
    questions = _questionService.build(selectedParts);
    notifyListeners();
  }

  /// Generate observations from pose results and reported data.
  void refreshObservations() {
    observations = _observationService.build(
      parts: selectedParts,
      results: poseResults,
      painScore: painScore.toDouble(),
      durationKey: durationKey,
    );
    notifyListeners();
  }

  /// Finalize and return a [CheckIn] from current state.
  CheckIn finalizeCheckIn() {
    refreshObservations();
    if (questions.isEmpty) refreshQuestions();

    final checkIn = CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      selectedParts: List.of(selectedParts),
      painScore: painScore,
      durationKey: durationKey,
      aggravators: List.of(aggravators),
      redFlags: redFlags.map((f) => f.name).toList(),
      observations: List.of(observations),
      questions: List.of(questions),
      hasPhoto: hasPhoto,
      photoPaths: List.of(photoPaths),
      poseResults: poseResults.values.toList(),
    );
    completedCheckIn = checkIn;
    notifyListeners();
    return checkIn;
  }

  /// Reset for a new check-in session.
  void reset() {
    selectedParts = [];
    painScore = 0;
    durationKey = 'less_than_week';
    aggravators.clear();
    redFlags.clear();
    questions = [];
    observations = [];
    hasPhoto = false;
    photoPaths.clear();
    poseResults.clear();
    usedManualFallback = false;
    isAnalyzing = false;
    completedCheckIn = null;
    notifyListeners();
  }
}

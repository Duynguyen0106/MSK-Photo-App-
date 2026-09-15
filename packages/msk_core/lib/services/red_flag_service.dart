import '../models/red_flag.dart';
import 'disclaimer_service.dart';

/// Evaluates self-reported symptoms for red-flag patterns.
class RedFlagService {
  RedFlagResult evaluate(Set<RedFlagSymptom> reported) {
    final hasRedFlags = reported.isNotEmpty;
    return RedFlagResult(
      hasRedFlags: hasRedFlags,
      reportedSymptoms: reported.toList(),
      urgentCareMessage: hasRedFlags
          ? DisclaimerService.urgentCareMessage
          : '',
    );
  }
}

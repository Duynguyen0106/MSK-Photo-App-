import 'package:flutter/foundation.dart';

/// Lightweight analytics logger for patient app events.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  void logEvent(String name, [Map<String, Object?>? parameters]) {
    if (kDebugMode) {
      final suffix =
          parameters == null || parameters.isEmpty ? '' : ' $parameters';
      debugPrint('[Analytics] $name$suffix');
    }
  }
}

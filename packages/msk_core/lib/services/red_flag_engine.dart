import 'disclaimer_service.dart';

/// Red-flag symptoms that trigger urgent-care escalation — never a diagnosis.
enum RedFlag {
  bladderBowel,
  progressiveWeakness,
  severeUnrelentingPain,
  unexplainedWeightLoss,
  majorTrauma,
}

/// UI-ready red-flag item with id, label, and description.
class RedFlagItem {
  const RedFlagItem({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;
}

/// Evaluates reported red flags and supplies shared escalation messaging.
class RedFlagEngine {
  /// True when any red flag is present.
  bool shouldEscalate(Set<RedFlag> flags) => flags.isNotEmpty;

  /// Shared urgent-care message for patient and clinician apps.
  String escalationMessage() => DisclaimerService.urgentCareMessage;

  /// All red-flag items for UI checklists.
  List<RedFlagItem> items() => [
        RedFlagItem(
          id: RedFlag.bladderBowel.name,
          label: 'Bladder or bowel changes',
          description:
              'You reported new trouble controlling your bladder or bowels.',
        ),
        RedFlagItem(
          id: RedFlag.progressiveWeakness.name,
          label: 'Getting weaker',
          description:
              'You reported weakness that is getting worse over time.',
        ),
        RedFlagItem(
          id: RedFlag.severeUnrelentingPain.name,
          label: 'Severe ongoing pain',
          description:
              'You reported severe pain that does not ease with rest.',
        ),
        RedFlagItem(
          id: RedFlag.unexplainedWeightLoss.name,
          label: 'Unplanned weight loss',
          description:
              'You reported losing weight without trying to.',
        ),
        RedFlagItem(
          id: RedFlag.majorTrauma.name,
          label: 'Recent major trauma',
          description:
              'You reported a recent serious accident, fall, or injury.',
        ),
      ];
}

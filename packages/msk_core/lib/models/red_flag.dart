/// Symptoms that trigger urgent-care messaging — never a diagnosis.
enum RedFlagSymptom {
  suddenSeverePain('Sudden severe pain'),
  numbnessOrTingling('Numbness or tingling'),
  lossOfBladderControl('Loss of bladder or bowel control'),
  feverWithPain('Fever with pain'),
  traumaInjury('Recent trauma or injury'),
  progressiveWeakness('Progressive weakness');

  const RedFlagSymptom(this.label);
  final String label;
}

class RedFlagResult {
  const RedFlagResult({
    required this.hasRedFlags,
    required this.reportedSymptoms,
    required this.urgentCareMessage,
  });

  final bool hasRedFlags;
  final List<RedFlagSymptom> reportedSymptoms;
  final String urgentCareMessage;
}

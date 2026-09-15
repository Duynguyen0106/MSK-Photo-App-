import '../models/body_part.dart';

/// Builds plain-language follow-up questions from selected body regions.
class QuestionService {
  static const _alwaysAppend = [
    'What is the most likely cause of my pain, and what should I do next?',
    'Are there any warning signs I should watch for?',
  ];

  /// Region-keyed question templates (1–2 questions each, plain language).
  static const Map<String, List<String>> _templates = {
    'shoulder': [
      'Does raising your arm make the discomfort worse?',
      'Do you notice stiffness when moving your shoulder?',
    ],
    'neck': [
      'Does turning your head make the discomfort worse?',
      'Do you feel tightness at the base of your neck?',
    ],
    'lowerBack': [
      'Does bending forward change how your lower back feels?',
      'Do you notice more discomfort after sitting for a while?',
    ],
    'upperBack': [
      'Does sitting for long periods make your upper back feel worse?',
      'Do you notice tightness between your shoulders?',
    ],
    'knee': [
      'Does going up or down stairs change how your knee feels?',
      'Do you notice more discomfort when standing up from a chair?',
    ],
    'hip': [
      'Does standing on one leg change how your hip feels?',
      'Do you notice stiffness in your hip when you first get up?',
    ],
    'elbow': [
      'Does gripping or lifting make your elbow feel worse?',
      'Do you notice discomfort when straightening your arm?',
    ],
    'wrist': [
      'Does typing or writing make your wrist feel worse?',
      'Do you notice discomfort when bending your wrist?',
    ],
    'ankle': [
      'Does walking on uneven ground change how your ankle feels?',
      'Do you notice stiffness when you first stand up?',
    ],
    'head': [
      'Do you notice pressure or tension around your head?',
      'Does bright light or noise make it feel worse?',
    ],
    'chest': [
      'Does taking a deep breath change how your chest feels?',
      'Do you notice tightness when you twist your torso?',
    ],
    'abdomen': [
      'Does eating change how your abdomen feels?',
      'Do you notice more discomfort when bending at the waist?',
    ],
  };

  /// Build a deduplicated list of questions for the selected [parts].
  List<String> build(List<BodyPart> parts) {
    final seen = <String>{};
    final questions = <String>[];

    void add(String question) {
      if (seen.add(question)) {
        questions.add(question);
      }
    }

    final regions = <String>{};
    for (final part in parts) {
      regions.add(_questionRegionFor(part));
    }

    for (final region in regions) {
      final template = _templates[region];
      if (template != null) {
        for (final question in template) {
          add(question);
        }
      }
    }

    for (final question in _alwaysAppend) {
      add(question);
    }

    return questions;
  }

  /// Maps a [BodyPart] to a question-template region key.
  static String _questionRegionFor(BodyPart part) {
    switch (part) {
      case BodyPart.head:
        return 'head';
      case BodyPart.neck:
        return 'neck';
      case BodyPart.leftShoulder:
      case BodyPart.rightShoulder:
        return 'shoulder';
      case BodyPart.chest:
        return 'chest';
      case BodyPart.upperBack:
        return 'upperBack';
      case BodyPart.lowerBack:
        return 'lowerBack';
      case BodyPart.abdomen:
        return 'abdomen';
      case BodyPart.leftElbow:
      case BodyPart.rightElbow:
        return 'elbow';
      case BodyPart.leftWrist:
      case BodyPart.rightWrist:
        return 'wrist';
      case BodyPart.leftHip:
      case BodyPart.rightHip:
        return 'hip';
      case BodyPart.leftKnee:
      case BodyPart.rightKnee:
        return 'knee';
      case BodyPart.leftAnkle:
      case BodyPart.rightAnkle:
        return 'ankle';
    }
  }
}

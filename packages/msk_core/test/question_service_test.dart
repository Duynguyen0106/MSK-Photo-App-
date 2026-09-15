import 'package:flutter_test/flutter_test.dart';
import 'package:msk_core/msk_core.dart';

void main() {
  final service = QuestionService();

  const alwaysAppend = [
    'What is the most likely cause of my pain, and what should I do next?',
    'Are there any warning signs I should watch for?',
  ];

  group('QuestionService', () {
    test('returns region questions plus always-append questions', () {
      final questions = service.build([BodyPart.neck]);

      expect(questions.length, greaterThanOrEqualTo(3));
      expect(questions, contains(alwaysAppend[0]));
      expect(questions, contains(alwaysAppend[1]));
      expect(
        questions.first,
        'Does turning your head make the discomfort worse?',
      );
    });

    test('deduplicates when multiple parts share a region', () {
      final questions = service.build([
        BodyPart.leftShoulder,
        BodyPart.rightShoulder,
      ]);

      final shoulderQuestions = questions.where(
        (q) => q.contains('shoulder') || q.contains('arm'),
      );
      expect(shoulderQuestions.length, 2);
      expect(questions.toSet().length, questions.length);
    });

    test('covers all template regions when all parts selected', () {
      final questions = service.build(BodyPart.values);

      expect(questions.toSet().length, questions.length);
      expect(questions, contains(alwaysAppend[0]));
      expect(questions, contains(alwaysAppend[1]));

      // 12 regions × up to 2 questions + 2 appended = at most 26
      expect(questions.length, lessThanOrEqualTo(26));
      expect(questions.length, greaterThanOrEqualTo(14));
    });

    test('always-append questions are last', () {
      final questions = service.build([BodyPart.leftKnee]);

      expect(questions[questions.length - 2], alwaysAppend[0]);
      expect(questions.last, alwaysAppend[1]);
    });

    test('empty parts still returns always-append questions', () {
      final questions = service.build([]);

      expect(questions, alwaysAppend);
    });
  });
}

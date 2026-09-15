import 'package:flutter_test/flutter_test.dart';
import 'package:msk_core/msk_core.dart';

void main() {
  final engine = RedFlagEngine();

  group('RedFlagEngine', () {
    test('shouldEscalate is false when no flags', () {
      expect(engine.shouldEscalate({}), isFalse);
    });

    test('shouldEscalate is true when any flag is set', () {
      expect(
        engine.shouldEscalate({RedFlag.majorTrauma}),
        isTrue,
      );
    });

    test('escalationMessage matches shared urgent-care text', () {
      expect(
        engine.escalationMessage(),
        DisclaimerService.urgentCareMessage,
      );
    });

    test('items returns all five red flags with id, label, description', () {
      final items = engine.items();

      expect(items.length, RedFlag.values.length);
      for (final flag in RedFlag.values) {
        final item = items.firstWhere((i) => i.id == flag.name);
        expect(item.label, isNotEmpty);
        expect(item.description, isNotEmpty);
      }
    });

    test('item descriptions use reported framing, not diagnostic language', () {
      final forbidden = ['diagnosis', 'you have', 'indicates', 'condition'];
      for (final item in engine.items()) {
        final lower = '${item.label} ${item.description}'.toLowerCase();
        for (final word in forbidden) {
          expect(lower.contains(word), isFalse, reason: item.id);
        }
      }
    });
  });
}

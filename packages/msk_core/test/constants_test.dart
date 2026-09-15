import 'package:flutter_test/flutter_test.dart';
import 'package:msk_core/msk_core.dart';

void main() {
  group('MskConstants', () {
    test('disclaimers are non-empty', () {
      expect(MskConstants.disclaimerFull, isNotEmpty);
      expect(MskConstants.disclaimerClinician, isNotEmpty);
      expect(DisclaimerService.fullDisclaimer, MskConstants.disclaimerFull);
    });

    test('self-care tips cover all question regions', () {
      const regions = [
        'shoulder',
        'neck',
        'lowerBack',
        'upperBack',
        'knee',
        'hip',
        'elbow',
        'wrist',
        'ankle',
        'head',
        'chest',
        'abdomen',
      ];
      for (final region in regions) {
        expect(
          MskConstants.selfCareTipsByRegion[region],
          isNotNull,
          reason: region,
        );
        expect(MskConstants.selfCareTipsByRegion[region]!, isNotEmpty);
      }
    });

    test('reference ranges include key angle measurements', () {
      expect(MskConstants.referenceRanges['pelvicTiltDeg'], isNotNull);
      expect(MskConstants.referenceRanges['kneeAlignmentLeftDeg'], isNotNull);
      expect(
        MskConstants.referenceRanges['forwardHeadAngleDeg']!.contains(48),
        isTrue,
      );
    });
  });
}

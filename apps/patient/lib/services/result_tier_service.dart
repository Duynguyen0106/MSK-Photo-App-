import 'package:msk_core/msk_core.dart';

enum ResultTier { green, amber, red }

/// Determines which result card to show — observations only, not a diagnosis.
class ResultTierService {
  ResultTier tierFor(CheckIn checkIn) {
    if (checkIn.redFlags.isNotEmpty || checkIn.painScore >= 8) {
      return ResultTier.red;
    }
    if (checkIn.painScore >= 4 ||
        checkIn.durationKey == 'weeks' ||
        checkIn.durationKey == 'months') {
      return ResultTier.amber;
    }
    return ResultTier.green;
  }

  /// Up to two self-care tips from [MskConstants] for the selected regions.
  List<String> selfCareTips(List<BodyPart> parts, {int limit = 2}) {
    final tips = <String>[];
    final regions = parts.map(regionFor).toSet();

    for (final region in regions) {
      for (final key in _tipKeysForRegion(region)) {
        final regionTips = MskConstants.selfCareTipsByRegion[key];
        if (regionTips == null) continue;
        for (final tip in regionTips) {
          if (!tips.contains(tip)) {
            tips.add(tip);
            if (tips.length >= limit) return tips;
          }
        }
      }
    }

    return tips;
  }

  List<String> _tipKeysForRegion(String region) {
    switch (region) {
      case 'back':
        return const ['lowerBack', 'upperBack'];
      default:
        return [region];
    }
  }
}

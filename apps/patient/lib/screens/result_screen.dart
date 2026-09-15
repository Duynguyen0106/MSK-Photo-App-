import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../widgets/disclaimer_banner.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final checkIn = provider.completedCheckIn;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('What we recorded')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 16),
          if (checkIn != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your report', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Pain: ${checkIn.painScore} out of 10'),
                    Text(
                      'Areas: ${checkIn.selectedParts.map(labelFor).join(', ')}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Observations', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...checkIn.observations.map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(o.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SelfCareSection(parts: checkIn.selectedParts),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              provider.reset();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (r) => false,
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _SelfCareSection extends StatelessWidget {
  const _SelfCareSection({required this.parts});

  final List<BodyPart> parts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final regions = parts.map(regionFor).toSet();
    final tips = <String>{};
    for (final region in regions) {
      final regionTips = MskConstants.selfCareTipsByRegion[region];
      if (regionTips != null) tips.addAll(regionTips);
    }

    if (tips.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Self-care tips', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $t'),
                )),
          ],
        ),
      ),
    );
  }
}

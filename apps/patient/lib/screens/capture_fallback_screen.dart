import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../widgets/disclaimer_banner.dart';

class CaptureFallbackScreen extends StatelessWidget {
  const CaptureFallbackScreen({super.key});

  static const _durationOptions = [
    ('less_than_week', 'Less than 1 week'),
    ('1_2_weeks', '1-2 weeks'),
    ('3_7_days', '3-7 days'),
    ('more_than_month', 'More than 1 month'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manual entry')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 16),
          Text(
            'Tell us how long this has been going on.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durationOptions.map((entry) {
              return FilterChip(
                label: Text(entry.$2),
                selected: provider.durationKey == entry.$1,
                onSelected: (_) => provider.setDurationKey(entry.$1),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('What makes it worse?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Sitting', 'Standing', 'Walking', 'Lifting', 'Sleep']
                .map((label) {
              final key = label.toLowerCase();
              final selected = provider.aggravators.contains(key);
              return FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: (on) {
                  final next = List<String>.from(provider.aggravators);
                  if (on) {
                    next.add(key);
                  } else {
                    next.remove(key);
                  }
                  provider.setAggravators(next);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              provider.setUsedManualFallback(true);
              Navigator.pushNamed(context, AppRoutes.analyzing);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

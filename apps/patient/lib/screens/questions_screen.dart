import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../widgets/disclaimer_banner.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  static const _durationOptions = [
    ('days', 'Days'),
    ('weeks', 'Weeks'),
    ('months', 'Months'),
  ];

  final _redFlagEngine = RedFlagEngine();
  bool _safetyExpanded = false;

  void _continue(BuildContext context) {
    final provider = context.read<CheckInProvider>();
    provider.refreshQuestions();

    final route = provider.shouldEscalate
        ? AppRoutes.redFlag
        : AppRoutes.whyPhoto;
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tell us more')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 24),
          Text('How much does it hurt?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${provider.painScore}',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Slider(
            value: provider.painScore.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (v) => provider.setPainScore(v.round()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('No pain', style: theme.textTheme.bodySmall),
                Text('Worst imaginable', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('How long has this been going on?',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: _durationOptions.map((option) {
              final selected = provider.durationKey == option.$1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: option.$1 != 'months' ? 8 : 0,
                  ),
                  child: FilterChip(
                    label: Text(option.$2),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => provider.setDurationKey(option.$1),
                    labelStyle: TextStyle(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Material(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _safetyExpanded = !_safetyExpanded),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.health_and_safety_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Safety check',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Icon(
                          _safetyExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                      ],
                    ),
                    if (!_safetyExpanded) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Tap to review warning signs',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (_safetyExpanded) ...[
                      const SizedBox(height: 12),
                      ..._redFlagEngine.items().map((item) {
                        final flag = RedFlag.values.firstWhere(
                          (f) => f.name == item.id,
                        );
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.label),
                          subtitle: Text(item.description),
                          value: provider.redFlags.contains(flag),
                          onChanged: (_) => provider.toggleRedFlag(flag),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => _continue(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

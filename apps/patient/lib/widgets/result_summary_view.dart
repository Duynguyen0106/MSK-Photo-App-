import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';

import '../services/result_tier_service.dart';

/// Tiered result card summary — plain language only, no measurements.
class ResultSummaryView extends StatelessWidget {
  const ResultSummaryView({super.key, required this.checkIn});

  final CheckIn checkIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierService = ResultTierService();
    final tier = tierService.tierFor(checkIn);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultTierCard(tier: tier, checkIn: checkIn, tierService: tierService),
        if (checkIn.hasPhoto) ...[
          const SizedBox(height: 16),
          Text(
            'Because you took a photo, we checked your shoulder and head '
            'alignment. Without it, this report would be half as useful.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class ResultTierCard extends StatelessWidget {
  const ResultTierCard({
    super.key,
    required this.tier,
    required this.checkIn,
    required this.tierService,
  });

  final ResultTier tier;
  final CheckIn checkIn;
  final ResultTierService tierService;

  @override
  Widget build(BuildContext context) {
    switch (tier) {
      case ResultTier.green:
        final tips = tierService.selfCareTips(checkIn.selectedParts);
        return GreenResultCard(
          tips: tips.isNotEmpty
              ? tips
              : MskConstants.selfCareTipsByRegion['lowerBack']!
                  .take(2)
                  .toList(),
        );
      case ResultTier.amber:
        return const AmberResultCard();
      case ResultTier.red:
        return const RedResultCard();
    }
  }
}

class GreenResultCard extends StatelessWidget {
  const GreenResultCard({super.key, required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredResultCard(
      backgroundColor: Colors.green.shade50,
      borderColor: Colors.green.shade300,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green.shade700,
      children: [
        Text(
          'Sounds manageable at home.',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.green.shade900,
          ),
        ),
        const SizedBox(height: 12),
        ...tips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: Colors.green.shade800)),
                Expanded(
                  child: Text(
                    tip,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Check again in a week.',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
      ],
    );
  }
}

class AmberResultCard extends StatelessWidget {
  const AmberResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredResultCard(
      backgroundColor: Colors.amber.shade50,
      borderColor: Colors.amber.shade300,
      icon: Icons.info_outline,
      iconColor: Colors.amber.shade900,
      children: [
        Text(
          'Worth seeing a physio.',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.amber.shade900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Symptoms that linger often improve faster with guided movement '
          'and a hands-on assessment.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.amber.shade900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Save report for your appointment.',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.amber.shade900,
          ),
        ),
      ],
    );
  }
}

class RedResultCard extends StatelessWidget {
  const RedResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredResultCard(
      backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      borderColor: theme.colorScheme.error,
      icon: Icons.warning_amber_rounded,
      iconColor: theme.colorScheme.error,
      children: [
        Text(
          'Please see someone today.',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          MskConstants.disclaimerUrgentCare,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class ColoredResultCard extends StatelessWidget {
  const ColoredResultCard({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

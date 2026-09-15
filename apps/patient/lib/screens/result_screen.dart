import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../services/result_tier_service.dart';
import '../widgets/disclaimer_banner.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _tierService = ResultTierService();
  bool _exporting = false;

  Future<void> _exportPdf(CheckIn checkIn) async {
    setState(() => _exporting = true);
    try {
      final pdf = await PdfService().buildPatientPdf(checkIn);
      await Printing.sharePdf(
        bytes: pdf,
        filename: 'msk-checkin-${checkIn.id}.pdf',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _saveAndFinish() {
    final provider = context.read<CheckInProvider>();
    provider.reset();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final checkIn = provider.completedCheckIn;
    final theme = Theme.of(context);

    if (checkIn == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your summary')),
        body: const Center(child: Text('No check-in to show.')),
      );
    }

    final tier = _tierService.tierFor(checkIn);

    return Scaffold(
      appBar: AppBar(title: const Text('Your summary')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 20),
          _TierCard(tier: tier, checkIn: checkIn, tierService: _tierService),
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
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saveAndFinish,
            child: const Text('Save & finish'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _exporting ? null : () => _exportPdf(checkIn),
            child: _exporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Export PDF'),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
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
        return _GreenCard(
          tips: tips.isNotEmpty
              ? tips
              : MskConstants.selfCareTipsByRegion['lowerBack']!
                  .take(2)
                  .toList(),
        );
      case ResultTier.amber:
        return const _AmberCard();
      case ResultTier.red:
        return const _RedCard();
    }
  }
}

class _GreenCard extends StatelessWidget {
  const _GreenCard({required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ColoredResultCard(
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

class _AmberCard extends StatelessWidget {
  const _AmberCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ColoredResultCard(
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

class _RedCard extends StatelessWidget {
  const _RedCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ColoredResultCard(
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

class _ColoredResultCard extends StatelessWidget {
  const _ColoredResultCard({
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

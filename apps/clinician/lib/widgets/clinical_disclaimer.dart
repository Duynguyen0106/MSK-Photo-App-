import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';

class ClinicalDisclaimer extends StatelessWidget {
  const ClinicalDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.medical_information_outlined,
              size: 16, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              DisclaimerService.clinicianDisclaimer,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

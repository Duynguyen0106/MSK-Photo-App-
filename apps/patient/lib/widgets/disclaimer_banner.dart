import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';

/// Reusable amber disclaimer banner — exact text from [MskConstants].
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({
    super.key,
    this.compact = false,
    this.padding = const EdgeInsets.all(16),
  });

  /// When true, shows [MskConstants.disclaimerShort]; otherwise full disclaimer.
  final bool compact;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = compact
        ? MskConstants.disclaimerShort
        : MskConstants.disclaimerFull;

    return Padding(
      padding: padding,
      child: Material(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: Colors.amber.shade900,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade900,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

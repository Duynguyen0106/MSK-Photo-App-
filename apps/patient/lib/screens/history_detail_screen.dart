import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:printing/printing.dart';

import '../widgets/disclaimer_banner.dart';
import '../widgets/result_summary_view.dart';

/// Read-only view of a past check-in result.
class HistoryDetailScreen extends StatefulWidget {
  const HistoryDetailScreen({super.key, required this.checkIn});

  final CheckIn checkIn;

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final pdf = await PdfService().buildPatientPdf(widget.checkIn);
      await Printing.sharePdf(
        bytes: pdf,
        filename: 'msk-checkin-${widget.checkIn.id}.pdf',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = widget.checkIn.date.toLocal();
    final dateLabel =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text('Check-in · $dateLabel')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 20),
          Text(
            'Pain ${widget.checkIn.painScore} out of 10',
            style: theme.textTheme.titleMedium,
          ),
          if (widget.checkIn.selectedParts.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.checkIn.selectedParts.map(labelFor).join(', '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),
          ResultSummaryView(checkIn: widget.checkIn),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: _exporting ? null : _exportPdf,
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

import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/result_summary_view.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
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

    if (checkIn == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your summary')),
        body: const Center(child: Text('No check-in to show.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your summary')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 20),
          ResultSummaryView(checkIn: checkIn),
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

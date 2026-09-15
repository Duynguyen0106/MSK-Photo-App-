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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckInProvider>().refreshQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final engine = RedFlagEngine();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('A few questions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 16),
          Text(
            'Check any warning signs you are experiencing.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...engine.items().map((item) {
            final flag = RedFlag.values.firstWhere((f) => f.name == item.id);
            return CheckboxListTile(
              title: Text(item.label),
              subtitle: Text(item.description),
              value: provider.redFlags.contains(flag),
              onChanged: (_) => provider.toggleRedFlag(flag),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
          if (provider.shouldEscalate) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(provider.escalationMessage),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('Follow-up questions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...provider.questions.map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $q', style: theme.textTheme.bodyMedium),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.whyPhoto),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

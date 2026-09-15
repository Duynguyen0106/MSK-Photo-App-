import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/clinician_provider.dart';
import '../widgets/clinical_disclaimer.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicianProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Roster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPatientScreen()),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: ClinicalDisclaimer(),
                ),
                Expanded(
                  child: provider.patients.isEmpty
                      ? Center(
                          child: Text(
                            'No patients yet. Tap + to add.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.patients.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final patient = provider.patients[index];
                            return _PatientCard(patient: patient);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final PatientRecord patient;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(patient.displayName.isNotEmpty
              ? patient.displayName[0].toUpperCase()
              : '?'),
        ),
        title: Text(patient.displayName),
        subtitle: Text(
          'MRN: ${patient.mrn} · ${patient.assessments.length} assessment(s)',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.read<ClinicianProvider>().selectPatient(patient);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailScreen(patientId: patient.id),
            ),
          );
        },
        onLongPress: () => _confirmDelete(context),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove patient?'),
        content: Text('Remove ${patient.displayName} from local roster?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<ClinicianProvider>().deletePatient(patient.id);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/clinician_provider.dart';
import '../widgets/clinical_disclaimer.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _nameController = TextEditingController();
  final _mrnController = TextEditingController();
  DateTime _dob = DateTime(1990, 1, 1);

  @override
  void dispose() {
    _nameController.dispose();
    _mrnController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _mrnController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and MRN are required')),
      );
      return;
    }
    await context.read<ClinicianProvider>().addPatient(
          name: _nameController.text.trim(),
          mrn: _mrnController.text.trim(),
          dob: _dob,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ClinicalDisclaimer(),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mrnController,
            decoration: const InputDecoration(
              labelText: 'MRN',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Date of birth'),
            subtitle: Text(
              '${_dob.year}-${_dob.month.toString().padLeft(2, '0')}-${_dob.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dob,
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _dob = picked);
            },
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save patient')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/clinician_provider.dart';
import 'screens/roster_screen.dart';

void main() {
  runApp(const ClinicianApp());
}

class ClinicianApp extends StatelessWidget {
  const ClinicianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClinicianProvider()..init(),
      child: MaterialApp(
        title: 'MSK Clinician',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          visualDensity: VisualDensity.compact,
        ),
        home: const RosterScreen(),
      ),
    );
  }
}

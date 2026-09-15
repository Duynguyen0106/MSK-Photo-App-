import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/assessment_provider.dart';
import 'screens/capture_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/results_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/symptom_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const PatientApp());
}

class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssessmentProvider(),
      child: MaterialApp(
        title: 'MSK Check-In',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const PatientFlow(),
      ),
    );
  }
}

/// Main flow — exactly 6 screens.
enum _FlowStep { welcome, symptoms, capture, processing, results, summary }

class PatientFlow extends StatefulWidget {
  const PatientFlow({super.key});

  @override
  State<PatientFlow> createState() => _PatientFlowState();
}

class _PatientFlowState extends State<PatientFlow> {
  _FlowStep _step = _FlowStep.welcome;
  bool _manualFallback = false;

  void _goTo(_FlowStep step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _FlowStep.welcome:
        return WelcomeScreen(onStart: () => _goTo(_FlowStep.symptoms));
      case _FlowStep.symptoms:
        return SymptomScreen(onContinue: () => _goTo(_FlowStep.capture));
      case _FlowStep.capture:
        return CaptureScreen(
          onPhotoCaptured: () {
            _manualFallback = false;
            _goTo(_FlowStep.processing);
          },
          onManualFallback: () {
            _manualFallback = true;
            _goTo(_FlowStep.processing);
          },
        );
      case _FlowStep.processing:
        return ProcessingScreen(
          runManual: _manualFallback,
          onComplete: () => _goTo(_FlowStep.results),
        );
      case _FlowStep.results:
        return ResultsScreen(onContinue: () => _goTo(_FlowStep.summary));
      case _FlowStep.summary:
        return SummaryScreen(
          onDone: () {
            context.read<AssessmentProvider>().reset();
            _manualFallback = false;
            _goTo(_FlowStep.welcome);
          },
        );
    }
  }
}

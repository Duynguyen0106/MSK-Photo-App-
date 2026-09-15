import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/check_in_provider.dart';
import 'routes.dart';
import 'screens/analyzing_screen.dart';
import 'screens/capture_fallback_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pain_map_screen.dart';
import 'screens/questions_screen.dart';
import 'screens/red_flag_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/why_photo_screen.dart';
import 'theme.dart';

void main() {
  runApp(const PatientApp());
}

class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckInProvider(),
      child: MaterialApp(
        title: 'MSK Check-In',
        debugShowCheckedModeBanner: false,
        theme: PatientTheme.light(),
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.painMap: (_) => const PainMapScreen(),
          AppRoutes.questions: (_) => const QuestionsScreen(),
          AppRoutes.redFlag: (_) => const RedFlagScreen(),
          AppRoutes.whyPhoto: (_) => const WhyPhotoScreen(),
          AppRoutes.capture: (_) => const CaptureScreen(),
          AppRoutes.captureFallback: (_) => const CaptureFallbackScreen(),
          AppRoutes.analyzing: (_) => const AnalyzingScreen(),
          AppRoutes.result: (_) => const ResultScreen(),
          AppRoutes.history: (_) => const HistoryScreen(),
          AppRoutes.settings: (_) => const SettingsScreen(),
        },
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msk_core/msk_core.dart';
import 'package:patient/providers/check_in_provider.dart';
import 'package:patient/screens/history_screen.dart';
import 'package:patient/screens/home_screen.dart';
import 'package:patient/screens/questions_screen.dart';
import 'package:patient/screens/result_screen.dart';
import 'package:patient/screens/settings_screen.dart';
import 'package:patient/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outputDir = '/opt/cursor/artifacts/screenshots';

  Future<void> capture(WidgetTester tester, String name) async {
    await tester.runAsync(() async {
      final boundary = tester.firstRenderObject(find.byType(RepaintBoundary))
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$outputDir/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  Widget app(Widget child) {
    return ChangeNotifierProvider(
      create: (_) => CheckInProvider(),
      child: MaterialApp(
        theme: PatientTheme.light(),
        home: RepaintBoundary(child: child),
      ),
    );
  }

  CheckIn sampleCheckIn({int painScore = 2}) {
    return CheckIn(
      id: 'demo',
      date: DateTime(2026, 9, 15),
      selectedParts: [BodyPart.leftShoulder, BodyPart.neck],
      painScore: painScore,
      durationKey: 'days',
      aggravators: ['sitting'],
      redFlags: [],
      observations: [],
      questions: [],
      hasPhoto: true,
      photoPaths: [],
      poseResults: [],
    );
  }

  setUpAll(() async {
    await Directory(outputDir).create(recursive: true);
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized().window
      ..physicalSizeTestValue = const Size(390, 844)
      ..devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().window
      .clearPhysicalSizeTestValue();
    TestWidgetsFlutterBinding.ensureInitialized().window
      .clearDevicePixelRatioTestValue();
  });

  testWidgets('screenshot home', (tester) async {
    await tester.pumpWidget(app(HomeScreen(initialCheckIns: <CheckIn>[])));
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, 'screenshot_home');
  });

  testWidgets('screenshot questions', (tester) async {
    await tester.pumpWidget(app(const QuestionsScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, 'screenshot_questions');
  });

  testWidgets('screenshot result', (tester) async {
    final provider = CheckInProvider();
    provider.completedCheckIn = sampleCheckIn(painScore: 5);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: PatientTheme.light(),
          home: const RepaintBoundary(child: ResultScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, 'screenshot_result');
  });

  testWidgets('screenshot history', (tester) async {
    await tester.pumpWidget(
      app(
        HistoryScreen(
          initialCheckIns: [
            sampleCheckIn(),
            sampleCheckIn(painScore: 6).copyWith(
              id: 'older',
              date: DateTime(2026, 9, 8),
              selectedParts: [BodyPart.lowerBack],
              hasPhoto: false,
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, 'screenshot_history');
  });

  testWidgets('screenshot settings', (tester) async {
    await tester.pumpWidget(app(const SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    await capture(tester, 'screenshot_settings');
  });
}

extension on CheckIn {
  CheckIn copyWith({
    String? id,
    DateTime? date,
    List<BodyPart>? selectedParts,
    int? painScore,
    bool? hasPhoto,
  }) {
    return CheckIn(
      id: id ?? this.id,
      date: date ?? this.date,
      selectedParts: selectedParts ?? this.selectedParts,
      painScore: painScore ?? this.painScore,
      durationKey: durationKey,
      aggravators: aggravators,
      redFlags: redFlags,
      observations: observations,
      questions: questions,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      photoPaths: photoPaths,
      poseResults: poseResults,
    );
  }
}

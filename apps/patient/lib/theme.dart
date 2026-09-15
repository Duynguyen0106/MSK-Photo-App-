import 'package:flutter/material.dart';

/// Patient app Material 3 theme — readable, approachable styling.
class PatientTheme {
  static const Color seedColor = Color(0xFF2563EB);

  static const double cardRadius = 18;
  static const double inputRadius = 14;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
    final base = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    );

    final textTheme = _textTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(inputRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(inputRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(height: 1.25),
      displayMedium: base.displayMedium?.copyWith(height: 1.25),
      displaySmall: base.displaySmall?.copyWith(height: 1.3),
      headlineLarge: base.headlineLarge?.copyWith(height: 1.3),
      headlineMedium: base.headlineMedium?.copyWith(height: 1.35),
      headlineSmall: base.headlineSmall?.copyWith(height: 1.35),
      titleLarge: base.titleLarge?.copyWith(height: 1.4),
      titleMedium: base.titleMedium?.copyWith(height: 1.45),
      titleSmall: base.titleSmall?.copyWith(height: 1.45),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.55),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.55),
      bodySmall: base.bodySmall?.copyWith(height: 1.5),
      labelLarge: base.labelLarge?.copyWith(height: 1.45),
      labelMedium: base.labelMedium?.copyWith(height: 1.45),
      labelSmall: base.labelSmall?.copyWith(height: 1.4),
    );
  }
}

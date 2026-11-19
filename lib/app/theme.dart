import 'package:flutter/material.dart';

class AurumColors {
  static const background = Color(0xFF05060D);
  static const surface = Color(0xFF0B1020);
  static const gold = Color(0xFFE8B84A);
  static const goldLight = Color(0xFFFFF0B8);
  static const goldDark = Color(0xFF9A6A1C);
  static const text = Color(0xFFEEF1F8);
  static const secondary = Color(0xFF9AA3B8);
}

ThemeData buildTheme() {
  const colorScheme = ColorScheme.dark(
    primary: AurumColors.gold,
    onPrimary: AurumColors.background,
    secondary: AurumColors.goldLight,
    surface: AurumColors.surface,
    onSurface: AurumColors.text,
    error: Color(0xFFFF8A80),
  );

  final display = TextStyle(
    fontFamily: 'AurumDisplay',
    color: AurumColors.text,
    fontVariations: const <FontVariation>[FontVariation.weight(500)],
  );
  final body = TextStyle(
    fontFamily: 'AurumDisplay',
    color: AurumColors.text,
    fontSize: 17,
    height: 1.5,
    fontVariations: const <FontVariation>[FontVariation.weight(400)],
  );
  final mono = TextStyle(
    fontFamily: 'AurumMono',
    color: AurumColors.text,
    fontVariations: const <FontVariation>[FontVariation.weight(400)],
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AurumColors.background,
    canvasColor: AurumColors.background,
    splashFactory: InkSparkle.splashFactory,
    textTheme: TextTheme(
      displayLarge: display.copyWith(fontSize: 64, height: 1.05),
      displayMedium: display.copyWith(fontSize: 48, height: 1.08),
      displaySmall: display.copyWith(fontSize: 34, height: 1.15),
      headlineMedium: display.copyWith(fontSize: 28, height: 1.2),
      headlineSmall: display.copyWith(fontSize: 22, height: 1.25),
      titleMedium: display.copyWith(fontSize: 18),
      bodyLarge: body,
      bodyMedium: body.copyWith(fontSize: 15),
      bodySmall: body.copyWith(fontSize: 13, color: AurumColors.secondary),
      labelSmall: mono.copyWith(fontSize: 11, letterSpacing: 1.8),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AurumColors.background,
      foregroundColor: AurumColors.text,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AurumColors.surface,
      indicatorColor: AurumColors.gold.withValues(alpha: 0.18),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AurumColors.gold);
        }
        return const IconThemeData(color: AurumColors.secondary);
      }),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontFamily: 'AurumMono',
          fontSize: 10,
          letterSpacing: 1,
          color: AurumColors.secondary,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x1FE8B84A),
      thickness: 1,
    ),
  );
}

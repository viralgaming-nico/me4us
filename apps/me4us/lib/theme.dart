import 'package:flutter/material.dart';

/// Art tokens from CLAUDE.md. Text on pastel uses plum (>= 4.5:1).
class Me4UsColors {
  static const cream = Color(0xFFFFF8F4);
  static const blush = Color(0xFFF9BFCF);
  static const peach = Color(0xFFFFD3BE);
  static const butter = Color(0xFFFFF1C2);
  static const mint = Color(0xFFCDEBDD);
  static const lavender = Color(0xFFD9CCF5);
  static const dusk = Color(0xFFC79BC4);
  static const plum = Color(0xFF5B4B6B);
  static const accent = Color(0xFFD9648A); // the "4" in the wordmark
}

ThemeData buildTheme() {
  const plum = Me4UsColors.plum;
  final scheme = ColorScheme.fromSeed(
    seedColor: Me4UsColors.blush,
    brightness: Brightness.light,
  ).copyWith(
    primary: plum,
    onPrimary: Me4UsColors.cream,
    primaryContainer: Me4UsColors.blush,
    onPrimaryContainer: plum,
    surface: Me4UsColors.cream,
    onSurface: plum,
    secondaryContainer: Me4UsColors.lavender,
    onSecondaryContainer: plum,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Me4UsColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: Me4UsColors.cream,
      foregroundColor: plum,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Me4UsColors.blush,
        foregroundColor: plum,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: plum,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: Me4UsColors.dusk),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Me4UsColors.dusk),
      ),
    ),
  );
}

/// Lowercase wordmark: me4us, with the 4 in the accent colour.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontSize: size, fontWeight: FontWeight.w800, color: Me4UsColors.plum);
    return Text.rich(
      TextSpan(style: base, children: [
        const TextSpan(text: 'me'),
        TextSpan(text: '4', style: base.copyWith(color: Me4UsColors.accent)),
        const TextSpan(text: 'us'),
      ]),
      semanticsLabel: 'me4us',
    );
  }
}

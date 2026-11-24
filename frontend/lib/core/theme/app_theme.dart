import 'package:flutter/material.dart';

/// Identidad visual compartida de PIUTTEC II.
///
/// Las pantallas que usen Material 3 heredan estos colores, incluidos botones,
/// cuadros de diálogo, indicadores, controles de formulario y navegación.
/// Los colores semánticos (errores, faltas, advertencias) se respetan.
class AppTheme {
  static const brand = Color(0xFF087C49);
  static const brandBright = Color(0xFF0FA958);
  static const brandSoft = Color(0xFF8BE4B3);
  static const brandDark = Color(0xFF064A33);

  static final light = _makeTheme(Brightness.light);
  static final dark = _makeTheme(Brightness.dark);

  static ThemeData _makeTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: brandBright,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? brandSoft : brand,
      onPrimary: isDark ? brandDark : Colors.white,
      primaryContainer:
          isDark ? const Color(0xFF124B38) : const Color(0xFFD9F9E7),
      onPrimaryContainer:
          isDark ? const Color(0xFFD9F9E7) : brandDark,
      secondary: isDark ? const Color(0xFF7FD9B0) : const Color(0xFF087856),
      outline: isDark ? const Color(0xFF587467) : const Color(0xFF8CA99A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF11161F) : const Color(0xFFF6FBF8),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              isDark ? const Color(0xFF33453D) : const Color(0xFFC7D7CD),
          disabledForegroundColor:
              isDark ? const Color(0xFFAEBEB4) : const Color(0xFF63776A),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? brandSoft : brand,
          side: BorderSide(color: isDark ? brandSoft : brand),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? brandSoft : brand,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? brandSoft : brand, width: 2),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? brandSoft : brand,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brand,
        foregroundColor: Colors.white,
      ),
    );
  }
}

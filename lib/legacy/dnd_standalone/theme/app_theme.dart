import 'package:flutter/material.dart';

/// Tema oscuro con estética RPG (taberna/pergamino) sin alterar la lógica de negocio.
final class AppTheme {
  AppTheme._();

  // Paleta base (oscura, cálida)
  static const Color _bg = Color(0xFF0F0C08); // fondo
  static const Color _surface = Color(0xFF19130E); // tarjetas / paneles
  static const Color _surface2 = Color(0xFF211A13); // elevación suave
  static const Color _ink = Color(0xFFECE1CC); // texto principal (pergamino)
  static const Color _muted = Color(0xFFBFAF92); // texto secundario
  static const Color _gold = Color(0xFFC9A34A); // primario
  static const Color _bronze = Color(0xFF8B6B2E); // secundario
  static const Color _danger = Color(0xFFB44B4B);
  static const Color _info = Color(0xFF5B84C6);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _gold,
        secondary: _bronze,
        surface: _surface,
        error: _danger,
        onPrimary: Colors.black,
        onSecondary: _ink,
        onSurface: _ink,
        onError: Colors.black,
      ),
    );

    final textTheme = base.textTheme.apply(
      bodyColor: _ink,
      displayColor: _ink,
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: _bg,

      // AppBar transparente (estilo juego)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _ink,
      ),

      // Tarjetas con borde dorado sutil
      // Flutter version compatibility: ThemeData expects CardThemeData (not CardTheme widget).
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: _gold.withValues(alpha: 0.22), width: 1),
        ),
      ),

      dividerTheme: DividerThemeData(
        thickness: 1,
        space: 16,
        color: _ink.withValues(alpha: 0.10),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: _gold.withValues(alpha: 0.95),
        textColor: _ink,
        subtitleTextStyle: const TextStyle(color: _muted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),

      // Inputs más “panel”
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: _gold.withValues(alpha: 0.18), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: _gold.withValues(alpha: 0.55), width: 2),
        ),
      ),

      // Botones con estilo “metal”
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: _gold.withValues(alpha: 0.35)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _gold,
        foregroundColor: Colors.black,
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: _surface2,
        selectedColor: _gold.withValues(alpha: 0.20),
        disabledColor: _surface2,
        side: BorderSide(color: _gold.withValues(alpha: 0.22)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),

      // Flutter version compatibility: ThemeData expects DialogThemeData (not DialogTheme widget).
      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: _gold.withValues(alpha: 0.22), width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: _ink,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
        contentTextStyle: const TextStyle(
          color: _muted,
          height: 1.25,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surface2,
        contentTextStyle: const TextStyle(color: _ink),
        actionTextColor: _gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      iconTheme: IconThemeData(color: _ink.withValues(alpha: 0.95)),
      colorScheme: base.colorScheme.copyWith(
        tertiary: _info,
        primaryContainer: _gold.withValues(alpha: 0.20),
        secondaryContainer: _bronze.withValues(alpha: 0.20),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Paleta "cantina RPG" (alto contraste sobre madera)
  static const _ink =
      Color(0xFF1B140E); // tinta muy oscura (solo sobre pergamino)
  static const _parchment = Color(0xFFF7E7C9);
  static const _parchmentDeep = Color(0xFFEAD3A7);
  static const _wood = Color(0xFF2B1E16);
  static const _woodDeep = Color(0xFF120B06);
  static const _amber = Color(0xFFD79A2B);
  static const _ale = Color(0xFFB76E1A);
  static const _burgundy = Color(0xFF6E2B2B);
  static const _gold = Color(0xFFE0C07A);

  static const List<Shadow> _textShadow = <Shadow>[
    Shadow(
      blurRadius: 10,
      color: Color(0xB3000000),
      offset: Offset(0, 1),
    ),
  ];

  static TextTheme _textTheme({required Brightness brightness}) {
    // En "claro" (pergamino) usamos tinta oscura; en "oscuro" (madera) usamos pergamino.
    final bool isDark = brightness == Brightness.dark;

    final onBg = isDark ? _parchment : _ink;
    final onBgMuted =
        (isDark ? _parchment : _ink).withValues(alpha: isDark ? 0.88 : 0.80);
    final onBgFaint =
        (isDark ? _parchment : _ink).withValues(alpha: isDark ? 0.78 : 0.70);

    final base = GoogleFonts.crimsonTextTextTheme();
    final deco = GoogleFonts.cinzelDecorativeTextTheme();

    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(
        color: onBg,
        height: 1.26,
        shadows: isDark ? _textShadow : null,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: onBgMuted,
        height: 1.23,
        shadows: isDark ? _textShadow : null,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: onBgFaint,
        shadows: isDark ? _textShadow : null,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: onBg,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
        shadows: isDark ? _textShadow : null,
      ),
      titleLarge: deco.titleLarge?.copyWith(
        color: isDark ? _gold : _burgundy,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.35,
        shadows: isDark ? _textShadow : null,
      ),
      titleMedium: deco.titleMedium?.copyWith(
        color: isDark ? _gold : _burgundy,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.25,
        shadows: isDark ? _textShadow : null,
      ),
      headlineSmall: deco.headlineSmall?.copyWith(
        color: isDark ? _gold : _burgundy,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.45,
        shadows: isDark ? _textShadow : null,
      ),
    );
  }

  /// Tema claro: pergamino (taberna iluminada).
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor:
        Colors.transparent, // el fondo real lo aporta TavernChrome
    colorScheme: ColorScheme.fromSeed(
      seedColor: _amber,
      brightness: Brightness.light,
    ).copyWith(
      primary: _amber,
      secondary: _burgundy,
      tertiary: _ale,
      surface: _parchmentDeep,
      onPrimary: _ink,
      onSecondary: _parchment,
      onSurface: _ink,
    ),
    textTheme: _textTheme(brightness: Brightness.light),
    appBarTheme: AppBarTheme(
      backgroundColor: _parchment.withValues(alpha: 0.90),
      foregroundColor: _ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cinzelDecorative(
        color: _burgundy,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.45,
        fontSize: 20,
      ),
    ),
    iconTheme: const IconThemeData(color: _burgundy),
    dividerTheme: DividerThemeData(color: _ink.withValues(alpha: 0.12)),
    cardTheme: CardThemeData(
      color: _parchment.withValues(alpha: 0.92),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.20),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: _ink.withValues(alpha: 0.10), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _burgundy,
      textColor: _ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _parchmentDeep.withValues(alpha: 0.92),
      hintStyle: TextStyle(color: _ink.withValues(alpha: 0.55)),
      labelStyle: TextStyle(color: _ink.withValues(alpha: 0.75)),
      prefixIconColor: _burgundy,
      suffixIconColor: _burgundy,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _ink.withValues(alpha: 0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _ink.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _amber, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _amber,
        foregroundColor: _ink,
        textStyle:
            const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink,
        side: BorderSide(color: _burgundy.withValues(alpha: 0.70), width: 1.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _amber,
      foregroundColor: _ink,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _ink.withValues(alpha: 0.94),
      contentTextStyle: TextStyle(
          color: _parchment.withValues(alpha: 0.95),
          fontWeight: FontWeight.w700),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _parchment.withValues(alpha: 0.90),
      indicatorColor: _amber.withValues(alpha: 0.22),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.15),
      ),
      iconTheme: WidgetStateProperty.all(const IconThemeData(color: _burgundy)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _parchment.withValues(alpha: 0.96),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _ink.withValues(alpha: 0.12)),
      ),
      titleTextStyle: GoogleFonts.cinzelDecorative(
        color: _burgundy,
        fontWeight: FontWeight.w900,
        fontSize: 18,
      ),
      contentTextStyle: GoogleFonts.crimsonText(
        color: _ink.withValues(alpha: 0.92),
        fontSize: 16,
      ),
    ),
  );

  /// Tema oscuro: madera (taberna nocturna).
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _amber,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _amber,
      secondary: _burgundy,
      tertiary: _ale,
      surface: _wood,
      onPrimary: _woodDeep,
      onSecondary: _parchment,
      onSurface: _parchment,
    ),
    textTheme: _textTheme(brightness: Brightness.dark),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xD9120B06),
      foregroundColor: _parchment,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: _gold,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.45,
        fontSize: 20,
        shadows: _textShadow,
      ),
    ),
    iconTheme: const IconThemeData(color: _gold),
    dividerTheme: DividerThemeData(color: _gold.withValues(alpha: 0.14)),
    cardTheme: CardThemeData(
      color: _wood.withValues(alpha: 0.92),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: _gold.withValues(alpha: 0.18), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _amber,
      textColor: _parchment,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _woodDeep.withValues(alpha: 0.75),
      hintStyle: TextStyle(
          color: _parchment.withValues(alpha: 0.62), shadows: _textShadow),
      labelStyle: TextStyle(
          color: _parchment.withValues(alpha: 0.82), shadows: _textShadow),
      prefixIconColor: _amber,
      suffixIconColor: _amber,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _gold.withValues(alpha: 0.22)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _gold.withValues(alpha: 0.20)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _amber, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _amber,
        foregroundColor: _woodDeep,
        textStyle:
            const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _parchment,
        side: BorderSide(color: _gold.withValues(alpha: 0.70), width: 1.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _amber,
      foregroundColor: _woodDeep,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _woodDeep.withValues(alpha: 0.98),
      contentTextStyle:
          const TextStyle(color: _parchment, fontWeight: FontWeight.w700),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _woodDeep.withValues(alpha: 0.94),
      indicatorColor: _amber.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.15),
      ),
      iconTheme: WidgetStateProperty.all(const IconThemeData(color: _gold)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _wood.withValues(alpha: 0.96),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _gold.withValues(alpha: 0.18)),
      ),
      titleTextStyle: GoogleFonts.cinzelDecorative(
        color: _gold,
        fontWeight: FontWeight.w900,
        fontSize: 18,
        shadows: _textShadow,
      ),
      contentTextStyle: GoogleFonts.crimsonText(
        color: _parchment.withValues(alpha: 0.92),
        fontSize: 16,
        shadows: _textShadow,
      ),
    ),
  );
}

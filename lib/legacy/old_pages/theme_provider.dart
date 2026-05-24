// lib/provider/theme_provider.dart

import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  bool _isDarkMode = true; // Por defecto, empieza en modo oscuro

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Avisa a todos los widgets que están escuchando que el tema ha cambiado
  }
}

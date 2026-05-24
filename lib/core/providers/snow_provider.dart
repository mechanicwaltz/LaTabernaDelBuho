// lib/provider/snow_provider.dart

import 'package:flutter/material.dart';

class SnowProvider with ChangeNotifier {
  bool _isSnowing = false;
  bool get isSnowing => _isSnowing;

  void toggleSnow() {
    _isSnowing = !_isSnowing;
    notifyListeners(); // Avisa a los widgets que escuchan que el estado ha cambiado.
  }

  // Método para forzar un estado específico (útil para el logout)
  void setSnow(bool value) {
    if (_isSnowing != value) {
      _isSnowing = value;
      notifyListeners();
    }
  }
}

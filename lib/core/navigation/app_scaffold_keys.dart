import 'package:flutter/material.dart';

/// Clave global del Scaffold raíz (HomePage) para poder abrir el menú (Drawer)
/// desde pantallas internas (p.ej. Juego/DND) que usan su propio Scaffold.
class AppScaffoldKeys {
  static final GlobalKey<ScaffoldState> homeScaffoldKey =
      GlobalKey<ScaffoldState>();
}

import 'package:flutter/material.dart';

/// Paleta "dark RPG" para dados: tonos gema apagados que encajan con un tema oscuro.
///
/// Nota: esto es puramente estético. No afecta a la lógica de tiradas.
final class RpgDicePalette {
  // Tonos pensados para que se vean bien sobre fondos oscuros sin parecer neón.
  static const d4 = Color(0xFF2F7A5B); // esmeralda oscuro
  static const d6 = Color(0xFF2C6D85); // azul petróleo
  static const d8 = Color(0xFF5B3B8A); // amatista
  static const d10 = Color(0xFF7D2E55); // vino
  static const d12 = Color(0xFF8A4A2A); // cobre
  static const d20 = Color(0xFF8A6A2F); // ámbar / latón

  static Color forDie(int die) {
    switch (die) {
      case 4:
        return d4;
      case 6:
        return d6;
      case 8:
        return d8;
      case 10:
        return d10;
      case 12:
        return d12;
      case 20:
        return d20;
      default:
        return const Color(0xFF3A3A3A);
    }
  }
}

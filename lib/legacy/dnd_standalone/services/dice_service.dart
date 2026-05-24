import 'dart:math';

class DiceService {
  static final _random = Random();

  /// Lanza un dado de N caras
  static int rollDie(int sides) {
    return _random.nextInt(sides) + 1;
  }

  /// Lanza un dado de 20 caras con ventaja/desventaja
  static int rollD20({bool advantage = false, bool disadvantage = false}) {
    int first = rollDie(20);
    int second = rollDie(20);

    if (advantage && !disadvantage) return max(first, second);
    if (disadvantage && !advantage) return min(first, second);
    return first; // Tirada normal
  }

  /// Lanza cualquier dado N veces, con ventaja/desventaja
  static int rollDice(int sides, int count, bool advantage, bool disadvantage) {
    int total = 0;
    for (int i = 0; i < count; i++) {
      int roll = sides == 20
          ? rollD20(advantage: advantage, disadvantage: disadvantage)
          : rollDie(sides);
      total += roll;
    }
    return total;
  }
}

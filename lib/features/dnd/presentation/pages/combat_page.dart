import 'dart:math';
import 'package:flutter/material.dart';
import 'package:appantibloqueo/features/dnd/presentation/widgets/rpg_scaffold.dart';
import 'package:appantibloqueo/features/dnd/domain/character.dart';
import 'package:appantibloqueo/features/dnd/presentation/theme/rpg_dice_palette.dart';
import 'package:appantibloqueo/features/dnd/presentation/widgets/polygon_die.dart';
import 'package:appantibloqueo/features/dnd/presentation/widgets/thrown_polygon_die.dart';

enum RollMode { normal, advantage, disadvantage }

class CombatPage extends StatefulWidget {
  final Character character;
  const CombatPage({required this.character, super.key});

  @override
  State<CombatPage> createState() => _CombatPageState();
}

class _CombatPageState extends State<CombatPage> {
  ThemeData get _theme => Theme.of(context);
  ColorScheme get _cs => _theme.colorScheme;
  bool get _isDark => _theme.brightness == Brightness.dark;

  late int currentHP;
  List<String> log = [];
  List<Map<String, dynamic>> lastRollDetails = [];
  int lastRollTotal = 0;

  int get _computedLastRollTotal {
    int total = 0;
    for (final d in lastRollDetails) {
      final rolls = (d['rolls'] as List<int>);
      for (final r in rolls) {
        total += r;
      }
    }
    return total;
  }

  int _rollNonce = 0;

  static const int maxSelectedDice = 6;
  String? _diceLimitError;

  int _totalSelectedDice() => diceCounts.values.fold(0, (a, b) => a + b);
  RollMode diceRollMode = RollMode.normal;

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    currentHP = widget.character.hp;
  }

  int _modifier(String stat) =>
      (((widget.character.attributes[stat] ?? 10) - 10) / 2).floor();

  void adjustHP(int delta) {
    setState(
        () => currentHP = (currentHP + delta).clamp(0, widget.character.hp));
  }

  void addLog(String entry) {
    setState(() {
      log.insert(0, entry);
      if (log.length > 10) log.removeLast();
    });
  }

  int rollDie(int sides) => random.nextInt(sides) + 1;

  int rollD20WithMode(RollMode mode) {
    int roll1 = rollDie(20);
    int roll2 = rollDie(20);
    if (mode == RollMode.advantage) {
      return max(roll1, roll2);
    } else if (mode == RollMode.disadvantage) {
      return min(roll1, roll2);
    } else {
      return roll1;
    }
  }

  // Ataque normal: 1d20 + mod fuerza, con o sin ventaja/desventaja según diceRollMode
  void rollAttack() {
    int roll = rollD20WithMode(diceRollMode);
    int total = roll + _modifier('FUE');
    addLog(
        '🎯 Ataque (d20 + mod FUE) [$describeRoll(diceRollMode)]: $roll + ${_modifier('FUE')} = $total');
  }

  String describeRoll(RollMode mode) {
    switch (mode) {
      case RollMode.advantage:
        return 'Ventaja';
      case RollMode.disadvantage:
        return 'Desventaja';
      case RollMode.normal:
        return 'Normal';
    }
  }

  // Datos para el panel de tirada múltiple de dados
  final Map<int, int> diceCounts = {
    4: 0,
    6: 0,
    8: 0,
    10: 0,
    12: 0,
    20: 0,
  };

  void rollAllDice() {
    final totalDice = _totalSelectedDice();
    if (totalDice <= 0) {
      setState(() => _diceLimitError = 'Selecciona al menos 1 dado.');
      return;
    }
    if (totalDice > maxSelectedDice) {
      setState(() => _diceLimitError = 'Máximo $maxSelectedDice dados.');
      return;
    }
    setState(() => _diceLimitError = null);

    List<Map<String, dynamic>> resultsDetails = [];
    int total = 0;

    diceCounts.forEach((type, count) {
      if (count <= 0) return;

      List<int> rolls = [];
      for (int i = 0; i < count; i++) {
        int roll;
        if (type == 20) {
          roll = rollD20WithMode(diceRollMode);
        } else {
          roll = rollDie(type);
        }
        rolls.add(roll);
        total += roll;
      }
      resultsDetails.add({'type': type, 'rolls': rolls});
    });

    if (total > 0) {
      setState(() {
        _rollNonce++;
        lastRollDetails = resultsDetails;
        lastRollTotal = _computedLastRollTotal;
      });

      String detailStr = resultsDetails.map((d) {
        final type = d['type'];
        final rolls = (d['rolls'] as List<int>).join(', ');
        return '${(d['rolls'] as List<int>).length}d$type: [$rolls]';
      }).join(' + ');

      addLog('🎲 $detailStr → $_computedLastRollTotal');
    }
  }

  Color colorForDice(int type) => RpgDicePalette.forDie(type);

  Widget buildDiceWidget(int number, int type, {required int index}) {
    return ThrownPolygonDie(
      die: type,
      value: number,
      size: 78,
      color: colorForDice(type),
      rollNonce: _rollNonce,
      // Semilla para que cada dado tenga un movimiento distinto en cada tirada.
      seed: (type * 1000) ^ (index * 17) ^ (_rollNonce * 101),
    );
  }

  Widget buildDiceSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: diceCounts.keys.map((type) {
        final c = colorForDice(type);
        final count = diceCounts[type]!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: _isDark ? 0.18 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withValues(alpha: 0.35), width: 1),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 6),
                color: Colors.black.withValues(alpha: _isDark ? 0.25 : 0.12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PolygonDie(
                die: type,
                value: type,
                size: 42,
                color: c,
                rotation: 0.10,
              ),
              const SizedBox(width: 10),
              _MiniIconButton(
                icon: Icons.remove,
                onTap: () {
                  setState(() {
                    if (diceCounts[type]! > 0) {
                      diceCounts[type] = diceCounts[type]! - 1;
                    }
                    if (_totalSelectedDice() < maxSelectedDice) {
                      _diceLimitError = null;
                    }
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '$count',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              _MiniIconButton(
                icon: Icons.add,
                onTap: () {
                  setState(() {
                    if (_totalSelectedDice() >= maxSelectedDice) {
                      _diceLimitError = 'Máximo $maxSelectedDice dados.';
                      return;
                    }
                    _diceLimitError = null;
                    diceCounts[type] = diceCounts[type]! + 1;
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildRollModeSelector() {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Normal'),
          selected: diceRollMode == RollMode.normal,
          onSelected: (_) => setState(() => diceRollMode = RollMode.normal),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Ventaja'),
          selected: diceRollMode == RollMode.advantage,
          onSelected: (_) => setState(() => diceRollMode = RollMode.advantage),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Desventaja'),
          selected: diceRollMode == RollMode.disadvantage,
          onSelected: (_) =>
              setState(() => diceRollMode = RollMode.disadvantage),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RpgScaffold(
      title: '${widget.character.name} - Combate',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HP: $currentHP / ${widget.character.hp}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () => adjustHP(1),
                    icon: const Icon(Icons.add, color: Colors.green)),
                IconButton(
                    onPressed: () => adjustHP(-1),
                    icon: const Icon(Icons.remove, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 10),
            buildDiceSelector(),
            const SizedBox(height: 12),
            buildRollModeSelector(),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Dados seleccionados: ${_totalSelectedDice()}/$maxSelectedDice',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _cs.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
            if (_diceLimitError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _diceLimitError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.casino),
                label: const Text('Tirar dados'),
                onPressed: rollAllDice,
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sports_martial_arts),
                label: const Text('Ataque normal'),
                onPressed: rollAttack,
              ),
            ),
            const SizedBox(height: 14),
            if (lastRollDetails.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: _isDark ? 0.18 : 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: _cs.onSurface
                          .withValues(alpha: _isDark ? 0.08 : 0.18)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: lastRollDetails.expand((d) {
                          final type = d['type'] as int;
                          final rolls = d['rolls'] as List<int>;
                          return rolls
                              .asMap()
                              .entries
                              .map((e) =>
                                  buildDiceWidget(e.value, type, index: e.key))
                              .toList();
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            color: _cs.onSurface
                                .withValues(alpha: _isDark ? 0.70 : 0.90),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$_computedLastRollTotal',
                          style: const TextStyle(
                              fontSize: 42, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Registro:',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => setState(() => log.clear()),
                  child: const Text('🧹 Limpiar historial'),
                ),
              ],
            ),
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: log.map((e) => Text(e)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.06
                    : 0.90,
              ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.10
                      : 0.22,
                ),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

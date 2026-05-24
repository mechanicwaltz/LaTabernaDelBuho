import 'package:flutter/material.dart';

typedef DiceCallback = void Function(int type, int count, bool advantage);

class DiceSelector extends StatefulWidget {
  final DiceCallback onRoll;
  const DiceSelector({required this.onRoll, super.key});

  @override
  State<DiceSelector> createState() => _DiceSelectorState();
}

class _DiceSelectorState extends State<DiceSelector> {
  int count = 1;
  int type = 6;
  bool advantage = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: cs.onSurface,
      fontWeight: FontWeight.w700,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Cantidad:', style: labelStyle),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => count++),
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => count = count > 1 ? count - 1 : 1),
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                Text('Dado:', style: labelStyle),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: type,
                  items: const [4, 6, 8, 10, 12, 20]
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text('d$d'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ventaja:', style: labelStyle),
                Switch(
                  value: advantage,
                  onChanged: (v) => setState(() => advantage = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => widget.onRoll(type, count, advantage),
              child: const Text('Tirar el dado'),
            ),
          ],
        ),
      ),
    );
  }
}

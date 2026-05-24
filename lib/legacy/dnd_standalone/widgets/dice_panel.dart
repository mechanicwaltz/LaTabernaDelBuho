import 'package:flutter/material.dart';
import 'package:appantibloqueo/legacy/dnd_standalone/widgets/animated_dice_roll.dart';

typedef DiceCallback = void Function(int type, int count, bool advantage);

class DicePanel extends StatefulWidget {
  final DiceCallback onRoll;
  final int? lastType;
  final int? lastCount;
  final int? lastResult;

  const DicePanel({
    required this.onRoll,
    this.lastType,
    this.lastCount,
    this.lastResult,
    super.key,
  });

  @override
  State<DicePanel> createState() => _DicePanelState();
}

class _DicePanelState extends State<DicePanel> {
  int _rollNonce = 0;

  int selectedType = 6;
  int count = 1;
  bool advantage = false;

  final Map<int, Color> diceColors = {
    4: Colors.green,
    6: Colors.lightGreen,
    8: Colors.purple,
    10: Colors.pink,
    12: Colors.red,
    20: Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.lastResult != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDiceRoll(
                sides: widget.lastType!,
                count: widget.lastCount!,
                result: widget.lastResult!,
                rollNonce: _rollNonce,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('${widget.lastResult}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 28)),
                ],
              ),
            ],
          ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          children: diceColors.keys.map((type) {
            final isSelected = selectedType == type;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: diceColors[type],
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              onPressed: () => setState(() => selectedType = type),
              child: Text('d$type',
                  style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white)),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Cantidad:', style: TextStyle(color: Colors.white)),
            IconButton(
                onPressed: () => setState(() => count++),
                icon: const Icon(Icons.add, color: Colors.white)),
            Text('$count', style: const TextStyle(color: Colors.white)),
            IconButton(
                onPressed: () =>
                    setState(() => count = count > 1 ? count - 1 : 1),
                icon: const Icon(Icons.remove, color: Colors.white)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ventaja:', style: TextStyle(color: Colors.white)),
            Switch(
                value: advantage,
                onChanged: (v) => setState(() => advantage = v)),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () {
            setState(() => _rollNonce++);
            widget.onRoll(selectedType, count, advantage);
          },
          child: const Text('Tirar el dado'),
        ),
      ],
    );
  }
}

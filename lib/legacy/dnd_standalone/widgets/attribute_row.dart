import 'package:flutter/material.dart';

class AttributeRow extends StatelessWidget {
  final String keyName;
  final int value;
  final bool mainStat;
  final VoidCallback onIncrement;

  const AttributeRow({
    required this.keyName,
    required this.value,
    required this.mainStat,
    required this.onIncrement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('$keyName: $value ${mainStat ? '⭐' : ''}')),
        IconButton(onPressed: onIncrement, icon: const Icon(Icons.add))
      ],
    );
  }
}

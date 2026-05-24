import 'package:flutter/material.dart';

class SpellCard extends StatelessWidget {
  final String spellName;
  final String description;

  const SpellCard(
      {required this.spellName, required this.description, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(spellName),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => showDialog(
            context: context,
            useRootNavigator: false,
            builder: (dialogContext) => AlertDialog(
              title: Text(spellName),
              content: Text(description),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cerrar'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

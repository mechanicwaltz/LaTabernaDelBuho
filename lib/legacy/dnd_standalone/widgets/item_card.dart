import 'package:flutter/material.dart';

class SpellCard extends StatelessWidget {
  final String spellName;
  final String description;
  final VoidCallback onTap;

  const SpellCard({
    super.key,
    required this.spellName,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(spellName),
        subtitle: Text(description),
        trailing: const Icon(Icons.edit),
        onTap: onTap,
      ),
    );
  }
}

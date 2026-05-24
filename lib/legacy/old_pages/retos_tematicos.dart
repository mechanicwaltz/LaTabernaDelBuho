import 'package:flutter/material.dart';
import 'dart:math';

class RetosTematicosPage extends StatefulWidget {
  const RetosTematicosPage({super.key});

  @override
  State<RetosTematicosPage> createState() => _RetosTematicosPageState();
}

class _RetosTematicosPageState extends State<RetosTematicosPage> {
  final List<String> temas = <String>[
    'Miedo',
    'Terror',
    'Fantasía',
    'Detectivesco',
    'Romántico',
    'Aventura'
  ];

  final TextEditingController _controller = TextEditingController();
  late String temaActual;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nuevoReto();
  }

  void _nuevoReto() {
    final random = Random();
    setState(() {
      temaActual = temas[random.nextInt(temas.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: Text(
                temaActual,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: Icon(Icons.refresh,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: _nuevoReto,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Escribe tu historia aquí...',
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

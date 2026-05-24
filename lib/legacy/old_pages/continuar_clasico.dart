import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContinuarClasico extends StatefulWidget {
  const ContinuarClasico({super.key});

  @override
  State<ContinuarClasico> createState() => _ContinuarClasicoState();
}

class _ContinuarClasicoState extends State<ContinuarClasico> {
  String _contenido = '';
  String _autor = '';
  bool _cargando = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cargarCita() async {
    setState(() {
      _cargando = true;
      _contenido = '';
      _autor = '';
      _controller.clear();
    });

    String contenido = 'Error al cargar la cita';
    String autor = '';

    try {
      final response = await http.get(Uri.parse('https://gutendex.com/books'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = (data is Map && data['results'] is List)
            ? (data['results'] as List)
            : const <dynamic>[];

        if (results.isNotEmpty && results.first is Map) {
          final libro = results.first as Map;
          contenido = (libro['title'] ?? 'Sin título').toString();

          autor = 'Autor desconocido';
          final authors = libro['authors'];
          if (authors is List && authors.isNotEmpty && authors.first is Map) {
            final a = authors.first as Map;
            autor = (a['name'] ?? 'Autor desconocido').toString();
          }
        } else {
          contenido = 'No se encontraron libros';
          autor = '';
        }
      }
    } catch (e) {
      contenido = 'Error al cargar la cita: $e';
      autor = '';
    } finally {
      if (mounted) {
        setState(() {
          _contenido = contenido;
          _autor = autor;
          _cargando = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarCita();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obras Clásicas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _contenido,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _autor,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Continúa escribiendo:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu continuación aquí...',
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: FilledButton.icon(
                      onPressed: _cargarCita,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Siguiente obra'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

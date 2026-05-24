import 'package:flutter/material.dart';

import 'package:appantibloqueo/features/notes/domain/app_note.dart';
import 'package:appantibloqueo/core/errors/firebase_error_mapper.dart';
import 'package:appantibloqueo/features/notes/data/note_repository.dart';

class NotasRapidasPage extends StatefulWidget {
  const NotasRapidasPage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<NotasRapidasPage> createState() => _NotasRapidasPageState();
}

class _NotasRapidasPageState extends State<NotasRapidasPage> {
  final NoteRepository _noteRepository = NoteRepository();

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'Personaje':
        return Icons.person;
      case 'Lugar':
        return Icons.location_on;
      case 'Nota':
      default:
        return Icons.note;
    }
  }

  String _formatFechaHora(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _fechaCreacionTexto(AppNote nota) {
    final timestamp = nota.createdAt ?? nota.updatedAt;
    if (timestamp == null) return '';
    return _formatFechaHora(timestamp.toDate());
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }

  Future<void> _nuevaNota(String tipo) async {
    final tituloController = TextEditingController();
    final contenidoController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Nueva $tipo'),
          content: SizedBox(
            height: 300,
            child: Column(
              children: <Widget>[
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: contenidoController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Escribe aquí tu $tipo...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final contenido = contenidoController.text.trim();
                if (contenido.isEmpty) return;
                try {
                  await _noteRepository.addNote(
                    uid: widget.userId,
                    tipo: tipo,
                    titulo: tituloController.text.trim().isEmpty
                        ? '(Sin título)'
                        : tituloController.text.trim(),
                    contenido: contenido,
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                } catch (e) {
                  _showMessage(FirebaseErrorMapper.fromObject(e),
                      isError: true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _menuNuevaNota() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Nota normal'),
              onTap: () {
                Navigator.pop(context);
                _nuevaNota('Nota');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nuevo personaje'),
              onTap: () {
                Navigator.pop(context);
                _nuevaNota('Personaje');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Nuevo lugar'),
              onTap: () {
                Navigator.pop(context);
                _nuevaNota('Lugar');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editarNota(AppNote nota) async {
    final tituloController = TextEditingController(text: nota.titulo);
    final contenidoController = TextEditingController(text: nota.contenido);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(0, 2),
                    child: Text(
                      'NOTA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withValues(alpha: 0.35),
                              ) ??
                          TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context)
                                .colorScheme
                                .shadow
                                .withValues(alpha: 0.35),
                          ),
                    ),
                  ),
                  Text(
                    'NOTA',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ) ??
                        const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Guardar',
                  icon: Icon(Icons.save,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    try {
                      await _noteRepository.updateNote(
                        uid: widget.userId,
                        noteId: nota.id,
                        titulo: tituloController.text.trim(),
                        contenido: contenidoController.text,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    } catch (e) {
                      _showMessage(FirebaseErrorMapper.fromObject(e),
                          isError: true);
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Borrar',
                  icon: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Borrar nota'),
                        content:
                            const Text('¿Seguro que quieres borrar esta nota?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Borrar'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    try {
                      await _noteRepository.deleteNote(
                          uid: widget.userId, noteId: nota.id);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    } catch (e) {
                      _showMessage(FirebaseErrorMapper.fromObject(e),
                          isError: true);
                    }
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: contenidoController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu ${nota.tipo}...',
                        filled: true,
                        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: null,
      body: StreamBuilder<List<AppNote>>(
        stream: _noteRepository.watchNotes(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notas = snapshot.data ?? const <AppNote>[];
          if (notas.isEmpty) {
            return Center(
              child: Text(
                'No hay notas todavía.\nPulsa "+" para crear una.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notas.length,
            itemBuilder: (context, index) {
              final nota = notas[index];
              final fechaTexto = _fechaCreacionTexto(nota);
              return GestureDetector(
                onTap: () => _editarNota(nota),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              _iconoPorTipo(nota.tipo),
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                nota.titulo.isNotEmpty
                                    ? nota.titulo
                                    : '(Sin título)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (fechaTexto.isNotEmpty)
                              Text(
                                fechaTexto,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: isDark ? 0.62 : 0.68),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nota.contenido,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: isDark ? 0.78 : 0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _menuNuevaNota,
        child: const Icon(Icons.add),
      ),
    );
  }
}

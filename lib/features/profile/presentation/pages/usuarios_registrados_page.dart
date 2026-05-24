import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:appantibloqueo/core/providers/audio_provider.dart';
import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/features/profile/data/admin_repository.dart';
import 'package:appantibloqueo/features/profile/domain/app_user.dart';
import 'package:appantibloqueo/core/errors/firebase_error_mapper.dart';
import 'package:appantibloqueo/features/profile/data/user_repository.dart';

class UsuariosRegistradosPage extends StatefulWidget {
  const UsuariosRegistradosPage({super.key});

  @override
  State<UsuariosRegistradosPage> createState() =>
      _UsuariosRegistradosPageState();
}

class _UsuariosRegistradosPageState extends State<UsuariosRegistradosPage> {
  final UserRepository _userRepository = UserRepository();
  final AdminRepository _adminRepository = AdminRepository();

  ImageProvider<Object>? _resolveProfileImage(String? rawValue) {
    final value = (rawValue ?? '').trim();
    if (value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }

    if (value.startsWith('data:image')) {
      final commaIndex = value.indexOf(',');
      if (commaIndex == -1 || commaIndex >= value.length - 1) return null;
      final base64Data = value.substring(commaIndex + 1);
      try {
        return MemoryImage(base64Decode(base64Data));
      } catch (_) {
        return null;
      }
    }

    try {
      return MemoryImage(base64Decode(value));
    } catch (_) {
      return null;
    }
  }

  Future<void> _editarUsuario(AppUser user) async {
    final nombreCtrl = TextEditingController(text: user.nombre);
    final apellidosCtrl = TextEditingController(text: user.apellidos);
    final usuarioCtrl = TextEditingController(text: user.usuario);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: apellidosCtrl,
                decoration: const InputDecoration(labelText: 'Apellidos'),
              ),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Correo (no editable)',
                  hintText: user.correo,
                ),
              ),
              TextField(
                controller: usuarioCtrl,
                decoration: const InputDecoration(labelText: 'Usuario'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _userRepository.updateUserByAdmin(
                  uid: user.uid,
                  nombre: nombreCtrl.text.trim(),
                  apellidos: apellidosCtrl.text.trim(),
                  usuario: usuarioCtrl.text.trim(),
                );
                if (!mounted) return;
                Navigator.pop(this.context);
                _showMessage('Usuario actualizado con éxito');
              } on UsernameTakenException {
                _showMessage('El nombre de usuario ya existe.', isError: true);
              } catch (e) {
                _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActivo(AppUser user) async {
    final next = !user.isActive;
    final actionText = next ? 'reactivar' : 'dar de baja';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(next ? 'Reactivar Usuario' : 'Dar de baja'),
        content: Text('¿Seguro que deseas $actionText a ${user.usuario}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await _userRepository.setUserActive(uid: user.uid, isActive: next);
      _showMessage(next ? 'Usuario reactivado' : 'Usuario dado de baja');
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    }
  }

  Future<void> _eliminarUsuario(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar de base de datos'),
        content: Text(
          '¿Seguro que deseas eliminar a ${user.usuario} de Firestore? Esta acción no borra su cuenta de Authentication.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await _userRepository.deleteUserProfileByAdmin(uid: user.uid);
      _showMessage('Usuario eliminado de la base de datos');
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Usuarios Registrados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          Consumer<AudioProvider>(
            builder: (context, audioProvider, _) {
              if (audioProvider.currentUrl == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: audioProvider.isPlaying
                    ? 'Pausar: ${audioProvider.currentSongName}'
                    : 'Reanudar: ${audioProvider.currentSongName}',
                icon: Icon(
                  audioProvider.isPlaying
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                ),
                onPressed: audioProvider.globalTogglePlayPause,
              );
            },
          ),
          Consumer<SnowProvider>(
            builder: (context, snowProvider, _) {
              return IconButton(
                tooltip:
                    snowProvider.isSnowing ? 'Quitar nieve' : 'Activar nieve',
                icon: Icon(
                  Icons.ac_unit,
                  color: snowProvider.isSnowing ? Colors.lightBlueAccent : null,
                ),
                onPressed: () => context.read<SnowProvider>().toggleSnow(),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: _userRepository.watchAllUsers(),
        builder: (context, usersSnapshot) {
          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final usuarios = usersSnapshot.data ?? const <AppUser>[];
          return StreamBuilder<Set<String>>(
            stream: _adminRepository.watchEnabledAdminEmails(),
            builder: (context, adminsSnapshot) {
              if (adminsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final adminEmails = adminsSnapshot.data ?? const <String>{};
              final usuariosNormales = usuarios
                  .where(
                    (u) => !adminEmails.contains(u.correo.trim().toLowerCase()),
                  )
                  .toList(growable: false);

              if (usuariosNormales.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay usuarios normales registrados todavía.',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: usuariosNormales.length,
                itemBuilder: (context, index) {
                  final user = usuariosNormales[index];
                  final photoProvider =
                      _resolveProfileImage(user.fotoPerfilUrl);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.92),
                        backgroundImage: photoProvider,
                        child: photoProvider == null
                            ? Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 30,
                              )
                            : null,
                      ),
                      title: Text(
                        '${user.nombre} ${user.apellidos}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Correo: ${user.correo}'),
                          Text('Usuario: ${user.usuario}'),
                          Text(
                            user.isActive
                                ? 'Estado: Activo'
                                : 'Estado: Inactivo',
                            style: TextStyle(
                              color:
                                  user.isActive ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 4,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            onPressed: () => _editarUsuario(user),
                          ),
                          IconButton(
                            icon: Icon(
                              user.isActive
                                  ? Icons.person_off
                                  : Icons.verified_user,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => _toggleActivo(user),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                            ),
                            onPressed: () => _eliminarUsuario(user),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

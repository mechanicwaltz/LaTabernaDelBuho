import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:appantibloqueo/core/providers/audio_provider.dart';
import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/features/profile/domain/app_user.dart';
import 'package:appantibloqueo/features/auth/data/auth_service.dart';
import 'package:appantibloqueo/core/errors/firebase_error_mapper.dart';
import 'package:appantibloqueo/features/profile/data/profile_image_service.dart';
import 'package:appantibloqueo/features/profile/data/user_repository.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({
    super.key,
    required this.uid,
    required this.isAdmin,
    required this.onLogout,
  });

  final String uid;
  final bool isAdmin;
  final Future<void> Function() onLogout;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();
  final ProfileImageService _profileImageService = const ProfileImageService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _deletePassController = TextEditingController();

  AppUser? _usuarioData;
  bool _loading = true;
  bool _saving = false;
  String? _pendingPhotoUrl;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _userController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    _deletePassController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuario() async {
    setState(() => _loading = true);
    try {
      final user = await _userRepository.getUser(widget.uid);
      if (user == null) {
        _usuarioData = null;
      } else {
        _usuarioData = user;
        _pendingPhotoUrl = null;
        _nombreController.text = user.nombre;
        _apellidosController.text = user.apellidos;
        _correoController.text = user.correo;
        _userController.text = user.usuario;
      }
    } catch (_) {
      _usuarioData = null;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cambiarFotoPerfil() async {
    if (_usuarioData == null) return;
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _saving = true);
    try {
      final file = File(picked.path);
      final url = await _profileImageService.uploadProfileImage(
          uid: widget.uid, file: file);
      if (!mounted) return;
      setState(() => _pendingPhotoUrl = url);
      _showMessage('Foto seleccionada. Pulsa "Guardar cambios" para aplicarla.');
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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

  Future<void> _guardarCambios() async {
    if (_usuarioData == null) return;

    final nombre = _nombreController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final usuario = _userController.text.trim();

    if (nombre.isEmpty || usuario.isEmpty) {
      _showMessage('Nombre y usuario son obligatorios', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await _userRepository.updateOwnProfile(
        uid: widget.uid,
        nombre: nombre,
        apellidos: apellidos,
        usuario: usuario,
      );

      final pendingPhoto = _pendingPhotoUrl;
      if (pendingPhoto != null && pendingPhoto != _usuarioData!.fotoPerfilUrl) {
        await _userRepository.updateProfilePhotoUrl(
          uid: widget.uid,
          downloadUrl: pendingPhoto,
        );
      }

      if (_newPassController.text.isNotEmpty ||
          _confirmPassController.text.isNotEmpty) {
        if (_newPassController.text != _confirmPassController.text) {
          _showMessage('Las contraseñas no coinciden', isError: true);
          return;
        }
        final email =
            FirebaseAuth.instance.currentUser?.email ?? _correoController.text;
        await _authService.sendPasswordResetEmail(email.trim());
        _showMessage('Te enviamos un correo para cambiar la contraseña');
      }

      _newPassController.clear();
      _confirmPassController.clear();
      await _cargarUsuario();
      _showMessage('Perfil actualizado con éxito');
    } on UsernameTakenException {
      _showMessage('El nombre de usuario ya existe', isError: true);
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmarEliminarCuenta() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _deletePassController.clear();

    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar cuenta'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text(
                'Para borrar tu cuenta, confirma tu contraseña. Esta acción no se puede deshacer.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deletePassController,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => Navigator.of(dialogContext)
                    .pop(_deletePassController.text.trim()),
                decoration:
                    const InputDecoration(labelText: 'Contraseña actual'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(_deletePassController.text.trim()),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (!mounted || password == null) return;
    final normalizedPassword = password.trim();
    if (normalizedPassword.isEmpty) {
      _showMessage('Introduce tu contraseña para borrar la cuenta.',
          isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      final email = (authUser?.email ?? '').trim().toLowerCase();
      if (authUser == null || email.isEmpty) {
        _showMessage('No hay una sesión activa válida.', isError: true);
        return;
      }

      await _authService.reauthenticateWithEmailPassword(
        email: email,
        password: normalizedPassword,
      );

      await _userRepository.deleteOwnAccountData(uid: widget.uid);
      await _authService.deleteCurrentUser();
      await widget.onLogout();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showMessage(
          'Por seguridad, vuelve a iniciar sesión y reintenta borrar la cuenta.',
          isError: true,
        );
        return;
      }
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_usuarioData == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró información del usuario')),
      );
    }

    final photoUrl = _pendingPhotoUrl ?? _usuarioData!.fotoPerfilUrl;
    final photoProvider = _resolveProfileImage(photoUrl);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saving ? null : _guardarCambios,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: _saving ? null : _cambiarFotoPerfil,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.92),
                    backgroundImage: photoProvider,
                    child: photoProvider == null
                        ? Icon(
                            Icons.person,
                            size: 70,
                            color: Theme.of(context).colorScheme.secondary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Toca la foto para cambiarla',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 25),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _apellidosController,
                          decoration: const InputDecoration(
                            labelText: 'Apellidos',
                            prefixIcon: Icon(Icons.badge),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _correoController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Correo (no editable)',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _userController,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: Icon(Icons.account_circle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Cambio de contraseña',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _newPassController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Nueva contraseña',
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPassController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar contraseña',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Por seguridad se enviará un correo de restablecimiento.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _guardarCambios,
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar cambios'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _confirmarEliminarCuenta,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Borrar cuenta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_saving)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x55000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

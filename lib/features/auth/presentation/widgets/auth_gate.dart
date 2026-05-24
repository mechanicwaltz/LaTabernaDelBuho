import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:appantibloqueo/app/presentation/pages/home_page.dart';
import 'package:appantibloqueo/core/errors/firebase_error_mapper.dart';
import 'package:appantibloqueo/core/notifications/notification_service.dart';
import 'package:appantibloqueo/core/providers/audio_provider.dart';
import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/features/auth/data/auth_service.dart';
import 'package:appantibloqueo/features/auth/presentation/pages/login_page.dart';
import 'package:appantibloqueo/features/profile/data/admin_repository.dart';
import 'package:appantibloqueo/features/profile/data/user_repository.dart'
    show UserRepository, UsernameTakenException;
import 'package:appantibloqueo/features/profile/domain/app_user.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();
  final AdminRepository _adminRepository = AdminRepository();
  bool _finalizingProfile = false;
  bool _syncingNotifications = false;
  String? _notificationsUid;

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
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = authSnapshot.data;
        if (user == null) {
          _notificationsUid = null;
          return LoginPage(
            onToggleTheme: widget.onToggleTheme,
            isDark: widget.isDark,
          );
        }

        if (!user.emailVerified) {
          return _EmailVerificationPage(
            email: user.email ?? '',
            onRefresh: _reloadAndFinalizeVerifiedUser,
            onResend: () => _authService.sendEmailVerification(),
            onSignOut: _signOut,
            isLoading: _finalizingProfile,
          );
        }

        return StreamBuilder<AppUser?>(
          stream: _userRepository.watchUser(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final appUser = userSnapshot.data;
            if (appUser == null) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Tu correo está verificado, pero falta completar el registro en Firestore.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _finalizingProfile
                              ? null
                              : _reloadAndFinalizeVerifiedUser,
                          child: Text(_finalizingProfile
                              ? 'Completando registro...'
                              : 'Completar registro'),
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: _signOut,
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (!appUser.isActive) {
              return _InactiveUserPage(
                email: appUser.correo,
                onSignOut: _signOut,
              );
            }

            _syncNotificationsForUser(user.uid);

            return StreamBuilder<bool>(
              stream: _adminRepository.watchIsAdminEmail(user.email),
              builder: (context, adminSnapshot) {
                final isAdmin = adminSnapshot.data ?? false;
                return HomePage(
                  appUser: appUser,
                  isAdmin: isAdmin,
                  isDark: widget.isDark,
                  onToggleTheme: widget.onToggleTheme,
                  onLogout: _signOut,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _reloadAndFinalizeVerifiedUser() async {
    if (_finalizingProfile) return;
    setState(() => _finalizingProfile = true);
    try {
      await _authService.reloadCurrentUser();
      final user = _authService.currentUser;
      if (user == null) return;

      if (!user.emailVerified) {
        _showMessage('Tu correo todavía no aparece como verificado.',
            isError: true);
        return;
      }

      await _authService.refreshIdToken();

      final existingProfile = await _userRepository.getUser(user.uid);
      if (existingProfile != null) {
        _showMessage('Correo verificado correctamente.');
        return;
      }

      final pendingData = _authService.getPendingRegistrationData(user);
      if (pendingData == null) {
        _showMessage(
          'No se encontraron datos de registro pendientes para completar el perfil.',
          isError: true,
        );
        return;
      }

      try {
        await _userRepository.createUserProfileAndReserveUsername(
          uid: user.uid,
          nombre: pendingData.nombre,
          apellidos: pendingData.apellidos,
          correo: (user.email ?? '').trim().toLowerCase(),
          usuario: pendingData.usuario,
        );
      } on UsernameTakenException {
        _showMessage(
          'Tu nombre de usuario ya fue usado por otra cuenta. Cierra sesión y regístrate con otro nombre.',
          isError: true,
        );
        return;
      }

      await _authService.clearPendingRegistrationData();
      _showMessage('Cuenta verificada y perfil creado correctamente.');
      if (mounted) setState(() {});
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    } finally {
      if (mounted) setState(() => _finalizingProfile = false);
    }
  }

  Future<void> _signOut() async {
    context.read<SnowProvider>().setSnow(false);
    await context.read<AudioProvider>().stop();
    await NotificationService.instance.detachCurrentUser();
    _notificationsUid = null;
    final user = _authService.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await _authService.clearPendingRegistrationData();
        await _authService.deleteCurrentUser();
      } catch (_) {
        // Si no se puede borrar (p.ej. sesión no reciente), cerramos sesión igualmente.
      }
    }
    await _authService.signOut();
  }

  void _syncNotificationsForUser(String uid) {
    if (_notificationsUid == uid || _syncingNotifications) return;
    _syncingNotifications = true;
    unawaited(_syncNotificationsForUserAsync(uid));
  }

  Future<void> _syncNotificationsForUserAsync(String uid) async {
    try {
      await NotificationService.instance.syncForUser(uid);
      await NotificationService.instance.subscribeToDefaultTopics();
      _notificationsUid = uid;
    } catch (e) {
      debugPrint('No se pudo configurar notificaciones para $uid: $e');
    } finally {
      _syncingNotifications = false;
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmailVerificationPage extends StatelessWidget {
  const _EmailVerificationPage({
    required this.email,
    required this.onRefresh,
    required this.onResend,
    required this.onSignOut,
    required this.isLoading,
  });

  final String email;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onResend;
  final Future<void> Function() onSignOut;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.mark_email_read_outlined, size: 58),
              const SizedBox(height: 12),
              Text(
                'Debes verificar tu correo antes de entrar.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  if (isLoading) return;
                  await onResend();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Correo de verificación reenviado')),
                  );
                },
                child: const Text('Reenviar verificación'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: isLoading ? null : onRefresh,
                child: Text(
                    isLoading ? 'Comprobando...' : 'Ya verifiqué mi correo'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onSignOut,
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InactiveUserPage extends StatelessWidget {
  const _InactiveUserPage({
    required this.email,
    required this.onSignOut,
  });

  final String email;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.block_outlined, size: 58),
              const SizedBox(height: 12),
              Text(
                'Cuenta inhabilitada. Solo podrás entrar cuando el administrador la habilite otra vez.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: onSignOut,
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

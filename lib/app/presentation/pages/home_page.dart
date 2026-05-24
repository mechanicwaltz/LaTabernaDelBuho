import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:appantibloqueo/app/bootstrap_seed_service.dart';
import 'package:appantibloqueo/core/errors/firebase_error_mapper.dart';
import 'package:appantibloqueo/core/navigation/app_scaffold_keys.dart';
import 'package:appantibloqueo/core/notifications/app_notification_target.dart';
import 'package:appantibloqueo/core/notifications/notification_service.dart';
import 'package:appantibloqueo/core/providers/audio_provider.dart';
import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/features/dnd/presentation/pages/antibloqueo_page.dart';
import 'package:appantibloqueo/features/notifications/presentation/pages/admin_broadcast_page.dart';
import 'package:appantibloqueo/features/news/presentation/pages/para_ti_page.dart';
import 'package:appantibloqueo/features/notes/presentation/pages/notas_rapidas_page.dart';
import 'package:appantibloqueo/features/playlist/presentation/pages/playlist_page.dart';
import 'package:appantibloqueo/features/profile/domain/app_user.dart';
import 'package:appantibloqueo/features/profile/data/user_repository.dart';
import 'package:appantibloqueo/features/profile/presentation/pages/perfil_page.dart';
import 'package:appantibloqueo/features/profile/presentation/pages/usuarios_registrados_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.appUser,
    required this.isAdmin,
    required this.isDark,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final AppUser appUser;
  final bool isAdmin;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final Future<void> Function() onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final BootstrapSeedService _bootstrapSeedService = BootstrapSeedService();
  final UserRepository _userRepository = UserRepository();
  StreamSubscription<AppNotificationTarget>? _notificationTargetSub;
  BannerAd? banner;
  int _currentIndex = 0;
  bool _bootstrapAttempted = false;
  bool _bootstrapping = false;

  static const List<String> _titles = <String>[
    'Notas Rápidas',
    'DyD',
    'Playlist de Rol',
    'Noticias',
  ];

  // --- FUNCIONES AUXILIARES ---
  Future<void> _runBootstrapIfNeeded() async {
    if (!widget.isAdmin || _bootstrapping || _bootstrapAttempted) return;
    _bootstrapping = true;
    _bootstrapAttempted = true;
    try {
      final seeded = await _bootstrapSeedService.ensureSeededIfAdmin(
          isAdmin: widget.isAdmin);
      if (!mounted || !seeded) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos iniciales cargados en Firestore')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(FirebaseErrorMapper.fromObject(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      _bootstrapping = false;
    }
  }

  void _listenNotificationNavigation() {
    _notificationTargetSub =
        NotificationService.instance.openTargetStream.listen(_openTarget);

    final pending = NotificationService.instance.consumePendingTarget();
    if (pending == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openTarget(pending);
    });
  }

  void _openTarget(AppNotificationTarget target) {
    final targetIndex = target.homeTabIndex;
    if (_currentIndex != targetIndex) {
      setState(() => _currentIndex = targetIndex);
    }

    final scaffoldState = AppScaffoldKeys.homeScaffoldKey.currentState;
    if (scaffoldState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Widget _shadowAppBarTitle(BuildContext context, String text) {
    final baseStyle = Theme.of(context).textTheme.titleLarge ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w800);
    final style =
    baseStyle.copyWith(fontFamily: 'Cinzel', fontWeight: FontWeight.w800);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Transform.translate(
          offset: const Offset(0, 2),
          child: Text(
            text.toUpperCase(),
            style: style.copyWith(
              color:
              Theme.of(context).colorScheme.shadow.withValues(alpha: 0.35),
            ),
          ),
        ),
        Text(text.toUpperCase(), style: style),
      ],
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    final List<Widget> actions = <Widget>[
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
    ];

    // Agrega iconos de favoritos según la pestaña
    if (_currentIndex == 2 || _currentIndex == 3) {
      actions.add(
        IconButton(
          tooltip: 'Mostrar solo favoritos',
          icon: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _currentIndex == 2
                    ? PlaylistPage(
                  userId: widget.appUser.uid,
                  isAdmin: widget.isAdmin,
                  soloFavoritos: true,
                )
                    : ParaTiPage(
                  userId: widget.appUser.uid,
                  isAdmin: widget.isAdmin,
                  soloFavoritos: true,
                ),
              ),
            );
          },
        ),
      );
    }

    actions.add(
      Consumer<SnowProvider>(
        builder: (context, snowProvider, _) {
          return IconButton(
            tooltip: snowProvider.isSnowing ? 'Quitar nieve' : 'Activar nieve',
            icon: Icon(
              Icons.ac_unit,
              color: snowProvider.isSnowing ? Colors.lightBlueAccent : null,
            ),
            onPressed: () => context.read<SnowProvider>().toggleSnow(),
          );
        },
      ),
    );

    return actions;
  }

  List<Widget> _buildPages() {
    return <Widget>[
      NotasRapidasPage(userId: widget.appUser.uid),
      AntiBloqueoPage(ownerUid: widget.appUser.uid),
      PlaylistPage(
        userId: widget.appUser.uid,
        isAdmin: widget.isAdmin,
        soloFavoritos: false,
      ),
      ParaTiPage(
        userId: widget.appUser.uid,
        isAdmin: widget.isAdmin,
        soloFavoritos: false,
      ),
    ];
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

  // --- INITSTATE ---
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _runBootstrapIfNeeded();
    _listenNotificationNavigation();

    // Banner de prueba
    banner = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // tu banner real
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('Banner cargado'),
        onAdFailedToLoad: (ad, error) {
          print('Error al cargar banner: $error');
          ad.dispose();
        },
      ),
    );
    banner!.load();
  }

  @override
  void dispose() {
    _notificationTargetSub?.cancel();
    banner?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- BUILD ---
  @override
  Widget build(BuildContext context) {
    final isJuego = _currentIndex == 1;

    return Scaffold(
      key: AppScaffoldKeys.homeScaffoldKey,
      appBar: AppBar(
        title: _shadowAppBarTitle(
          context,
          isJuego ? 'Dungeons & Dragons' : _titles[_currentIndex],
        ),
        centerTitle: true,
        actions: _buildAppBarActions(context),
        leadingWidth: 64,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menú',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Padding(
              padding: const EdgeInsets.all(2),
              child: Image.asset(
                'assets/icon/logo.png',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            StreamBuilder<AppUser?>(
              stream: _userRepository.watchUser(widget.appUser.uid),
              initialData: widget.appUser,
              builder: (context, snapshot) {
                final currentUser = snapshot.data ?? widget.appUser;
                final photoProvider =
                _resolveProfileImage(currentUser.fotoPerfilUrl);
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
                  color: Theme.of(context).colorScheme.primary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.92),
                        backgroundImage: photoProvider,
                        child: photoProvider == null
                            ? Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 50,
                        )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${currentUser.nombre} ${currentUser.apellidos}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      Text(
                        widget.isAdmin ? 'Administrador' : currentUser.correo,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PerfilPage(
                      uid: widget.appUser.uid,
                      isAdmin: widget.isAdmin,
                      onLogout: widget.onLogout,
                    ),
                  ),
                );
              },
            ),
            if (widget.isAdmin)
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Usuarios Registrados'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsuariosRegistradosPage(),
                    ),
                  );
                },
              ),
            if (widget.isAdmin)
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Enviar Aviso'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminBroadcastPage(
                        adminUser: widget.appUser,
                      ),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: Text(widget.isDark ? 'Modo claro' : 'Modo oscuro'),
              onTap: () {
                Navigator.pop(context);
                widget.onToggleTheme();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                Navigator.pop(context);
                await widget.onLogout();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _buildPages(),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (banner != null)
            SizedBox(
              height: 50,
              child: AdWidget(ad: banner!),
            ),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.note_outlined),
                selectedIcon: Icon(Icons.note),
                label: 'Notas',
              ),
              NavigationDestination(
                icon: Icon(Icons.casino_outlined),
                selectedIcon: Icon(Icons.casino),
                label: 'DyD',
              ),
              NavigationDestination(
                icon: Icon(Icons.music_note_outlined),
                selectedIcon: Icon(Icons.music_note),
                label: 'Playlist',
              ),
              NavigationDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article),
                label: 'Noticias',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
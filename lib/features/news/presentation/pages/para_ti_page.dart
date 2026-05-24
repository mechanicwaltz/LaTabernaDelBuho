import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:appantibloqueo/core/providers/audio_provider.dart';
import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/core/errors/firebase_error_mapper.dart';
import 'package:appantibloqueo/features/news/data/news_repository.dart';
import 'package:appantibloqueo/features/news/data/rss_news_service.dart';
import 'package:appantibloqueo/features/news/domain/news_item.dart';

class ParaTiPage extends StatefulWidget {
  const ParaTiPage({
    super.key,
    required this.userId,
    required this.isAdmin,
    this.soloFavoritos = false,
  });

  final String userId;
  final bool isAdmin;
  final bool soloFavoritos;

  @override
  State<ParaTiPage> createState() => _ParaTiPageState();
}

class _ParaTiPageState extends State<ParaTiPage> {
  final NewsRepository _newsRepository = NewsRepository();
  final RssNewsService _rssNewsService = RssNewsService();
  late final ScrollController _scrollController;
  late Stream<List<NewsItem>> _newsStream;
  late Stream<Set<String>> _favoriteNewsStream;
  bool _mostrarFlechaArriba = false;

  // LISTADO DE BANNERS IN-FEED
  final List<BannerAd> _banners = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _newsStream = _newsRepository.watchNews();
    _favoriteNewsStream = _newsRepository.watchFavoriteNewsIds(widget.userId);
  }

  @override
  void didUpdateWidget(covariant ParaTiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _favoriteNewsStream = _newsRepository.watchFavoriteNewsIds(widget.userId);
    }
  }

  @override
  void dispose() {
    for (final banner in _banners) {
      banner.dispose();
    }
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    const threshold = 180.0;
    final shouldShow = _scrollController.offset > threshold;
    if (shouldShow != _mostrarFlechaArriba) {
      setState(() => _mostrarFlechaArriba = shouldShow);
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

  Future<void> _toggleFavorito(NewsItem noticia) async {
    try {
      await _newsRepository.toggleFavorite(
          uid: widget.userId, newsId: noticia.id);
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    }
  }

  Future<void> _abrirUrl(String url) async {
    final clean = url.trim();
    if (clean.isEmpty) return;
    final uri = Uri.parse(clean);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('No se pudo abrir el enlace', isError: true);
    }
  }

  Future<void> _showNewsEditor({NewsItem? initial}) async {
    final tituloCtrl = TextEditingController(text: initial?.titulo ?? '');
    final descripcionCtrl =
    TextEditingController(text: initial?.descripcion ?? '');
    final imagenCtrl = TextEditingController(text: initial?.imagenUrl ?? '');
    final linkCtrl = TextEditingController(text: initial?.link ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(initial == null ? 'Nueva noticia' : 'Editar noticia'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextField(
                controller: imagenCtrl,
                decoration: const InputDecoration(labelText: 'Imagen URL'),
              ),
              TextField(
                controller: linkCtrl,
                decoration: const InputDecoration(labelText: 'Link'),
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
              final titulo = tituloCtrl.text.trim();
              final descripcion = descripcionCtrl.text.trim();
              if (titulo.isEmpty || descripcion.isEmpty) {
                _showMessage('Título y descripción son obligatorios',
                    isError: true);
                return;
              }
              try {
                if (initial == null) {
                  await _newsRepository.addNews(
                    titulo: titulo,
                    descripcion: descripcion,
                    imagenUrl: imagenCtrl.text.trim(),
                    link: linkCtrl.text.trim(),
                  );
                } else {
                  await _newsRepository.updateNews(
                    id: initial.id,
                    titulo: titulo,
                    descripcion: descripcion,
                    imagenUrl: imagenCtrl.text.trim(),
                    link: linkCtrl.text.trim(),
                  );
                }
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
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

  Future<void> _importLatestNews({bool showInfoMessages = true}) async {
    try {
      final fetched = await _rssNewsService.fetchLatest(maxItems: 40);
      if (fetched.isEmpty) {
        if (showInfoMessages) {
          _showMessage('No se pudieron obtener noticias online');
        }
        return;
      }

      final existingLinks = await _newsRepository.fetchExistingLinks();
      final candidates = fetched
          .where(
            (item) =>
        item.link.trim().isNotEmpty &&
            !existingLinks.contains(item.link.trim()),
      )
          .toList(growable: false);

      const batchSize = 5;
      final toImport = candidates.take(batchSize).toList(growable: false);

      if (toImport.isEmpty) {
        if (showInfoMessages) {
          _showMessage('No hay noticias nuevas para importar');
        }
        return;
      }

      for (final item in toImport) {
        await _newsRepository.addNews(
          titulo: item.titulo,
          descripcion: item.descripcion,
          imagenUrl: item.imagenUrl,
          link: item.link,
        );
      }

      if (showInfoMessages) {
        _showMessage(
          'Importadas ${toImport.length} noticias nuevas (${candidates.length - toImport.length} pendientes)',
        );
      }
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    }
  }

  Future<void> _handlePullToRefresh() async {
    try {
      if (widget.isAdmin && !widget.soloFavoritos) {
        await _importLatestNews(showInfoMessages: false);
      }
      await _newsRepository.refreshNewsFromServer();
      await _newsRepository.refreshFavoriteNewsFromServer(uid: widget.userId);
      _showMessage('Noticias actualizadas');
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    }
  }

  Future<void> _deleteNews(NewsItem news) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar noticia'),
        content: Text('¿Eliminar "${news.titulo}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _newsRepository.deleteNews(news.id);
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    }
  }

  BannerAd _createBanner() {
    final banner = BannerAd(
      size: AdSize.mediumRectangle,
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint('Banner in-feed cargado'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Error banner in-feed: ${error.message}');
          ad.dispose();
        },
      ),
    );
    banner.load();
    _banners.add(banner);
    return banner;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: widget.soloFavoritos
          ? AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver a noticias',
        ),
        title: const Text('Favoritos'),
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
                tooltip: snowProvider.isSnowing
                    ? 'Quitar nieve'
                    : 'Activar nieve',
                icon: Icon(
                  Icons.ac_unit,
                  color: snowProvider.isSnowing
                      ? Colors.lightBlueAccent
                      : null,
                ),
                onPressed: () =>
                    context.read<SnowProvider>().toggleSnow(),
              );
            },
          ),
        ],
      )
          : (widget.isAdmin
          ? AppBar(
        title: const Text('Noticias'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Recargar noticias online',
            icon: const Icon(Icons.download),
            onPressed: _importLatestNews,
          ),
          IconButton(
            tooltip: 'Añadir noticia',
            icon: const Icon(Icons.add),
            onPressed: () => _showNewsEditor(),
          ),
        ],
      )
          : null),
      body: StreamBuilder<List<NewsItem>>(
        stream: _newsStream,
        builder: (context, newsSnapshot) {
          if (newsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final news = newsSnapshot.data ?? const <NewsItem>[];
          return StreamBuilder<Set<String>>(
            stream: _favoriteNewsStream,
            builder: (context, favSnapshot) {
              if (favSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final favIds = favSnapshot.data ?? <String>{};
              final visibles = widget.soloFavoritos
                  ? news.where((n) => favIds.contains(n.id)).toList()
                  : news;

              if (visibles.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _handlePullToRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: Center(
                          child: Text(
                            widget.soloFavoritos
                                ? 'No tienes noticias en favoritos.'
                                : 'No hay noticias disponibles.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _handlePullToRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: visibles.length + (visibles.length ~/ 5),
                  itemBuilder: (context, index) {
                    if ((index + 1) % 6 == 0) {
                      final banner = _createBanner();
                      return SizedBox(
                        width: banner.size.width.toDouble(),
                        height: banner.size.height.toDouble(),
                        child: AdWidget(ad: banner),
                      );
                    }

                    final noticiaIndex = index - (index ~/ 6);
                    final noticia = visibles[noticiaIndex];
                    final fav = favIds.contains(noticia.id);

                    return _NoticiaCard(
                      titulo: noticia.titulo,
                      descripcion: noticia.descripcion,
                      imagenUrl: noticia.imagenUrl,
                      isDark: isDark,
                      isFavorite: fav,
                      isAdmin: widget.isAdmin,
                      onFavoriteToggle: () => _toggleFavorito(noticia),
                      onTap: () => _abrirUrl(noticia.link),
                      onEdit: widget.isAdmin
                          ? () => _showNewsEditor(initial: noticia)
                          : null,
                      onDelete:
                      widget.isAdmin ? () => _deleteNews(noticia) : null,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        ),
        child: _mostrarFlechaArriba
            ? FloatingActionButton.small(
          key: const ValueKey('news_scroll_to_top'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          tooltip: 'Volver arriba',
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
            );
          },
          child: const Icon(Icons.keyboard_arrow_up),
        )
            : const SizedBox.shrink(key: ValueKey('news_no_scroll_to_top')),
      ),
    );
  }
}

class _NoticiaCard extends StatelessWidget {
  const _NoticiaCard({
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
    required this.isDark,
    required this.isFavorite,
    required this.isAdmin,
    required this.onFavoriteToggle,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final String titulo;
  final String descripcion;
  final String imagenUrl;
  final bool isDark;
  final bool isFavorite;
  final bool isAdmin;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final esLocal = !imagenUrl.startsWith('http');

    return Card(
      color: isDark ? Colors.grey[850] : Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: esLocal
                  ? Image.asset(
                imagenUrl.isEmpty
                    ? 'assets/images/fondo_taberna.png'
                    : imagenUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.network(
                imagenUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/fondo_taberna.png',
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: isFavorite
                            ? 'Quitar de favoritos'
                            : 'Guardar en favoritos',
                        onPressed: onFavoriteToggle,
                        splashRadius: 22,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.78),
                        ),
                      ),
                      if (isAdmin)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') onEdit?.call();
                            if (value == 'delete') onDelete?.call();
                          },
                          itemBuilder: (_) => const <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descripcion,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: isDark ? 0.78 : 0.82),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
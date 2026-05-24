import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'package:appantibloqueo/features/playlist/domain/song_item.dart';
import 'package:appantibloqueo/features/playlist/presentation/pages/player_page.dart';
import 'package:appantibloqueo/core/providers/audio_provider.dart';
import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/core/errors/firebase_error_mapper.dart';
import 'package:appantibloqueo/features/playlist/data/playlist_repository.dart';
import 'package:appantibloqueo/features/playlist/data/song_repository.dart';
import 'package:appantibloqueo/features/playlist/presentation/widgets/tavern_song_card.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({
    super.key,
    required this.userId,
    required this.isAdmin,
    this.soloFavoritos = false,
  });

  final String userId;
  final bool isAdmin;
  final bool soloFavoritos;

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final SongRepository _songRepository = SongRepository();
  final PlaylistRepository _playlistRepository = PlaylistRepository();
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;
  late Stream<List<SongItem>> _songsStream;
  late Stream<Set<String>> _favoriteIdsStream;
  bool _mostrarFlechaArriba = false;

  static const Map<String, String> _diacritics = <String, String>{
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'ã': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'ñ': 'n',
    'ç': 'c',
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _songsStream = _songRepository.watchSongs();
    _favoriteIdsStream =
        _playlistRepository.watchFavoriteSongIds(widget.userId);
  }

  @override
  void didUpdateWidget(covariant PlaylistPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _favoriteIdsStream =
          _playlistRepository.watchFavoriteSongIds(widget.userId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  String _normalizeText(String input) {
    var s = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_diacritics[ch] ?? ch);
    }
    s = buffer.toString();
    s = s.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  List<String> _tokensFromQuery(String query) {
    final q = _normalizeText(query);
    if (q.isEmpty) return const <String>[];
    return q
        .split(' ')
        .where((t) => t.trim().isNotEmpty)
        .toList(growable: false);
  }

  bool _matchesSong(SongItem song, List<String> tokens) {
    if (tokens.isEmpty) return true;
    final titulo = _normalizeText(song.titulo);
    final artista = _normalizeText(song.artista);
    final tags = song.tags.map(_normalizeText).toList(growable: false);
    for (final token in tokens) {
      final hit = titulo.contains(token) ||
          artista.contains(token) ||
          tags.any((tag) => tag.contains(token));
      if (!hit) return false;
    }
    return true;
  }

  List<SongItem> _filterSongs(List<SongItem> songs, Set<String> favIds) {
    final tokens = _tokensFromQuery(_searchController.text);
    final base = songs.where((song) => _matchesSong(song, tokens));
    final filtered = widget.soloFavoritos
        ? base.where((song) => favIds.contains(song.id)).toList(growable: false)
        : base.toList(growable: false);
    return filtered;
  }

  List<Map<String, dynamic>> _toAudioMap(List<SongItem> songs) {
    return songs
        .map((s) => <String, dynamic>{
              'id': s.id,
              'titulo': s.titulo,
              'artista': s.artista,
              'coverUrl': s.coverUrl,
              'audioUrl': s.audioUrl,
              'tags': s.tags,
            })
        .toList(growable: false);
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

  Future<void> _toggleFavorito(SongItem song) async {
    try {
      await _playlistRepository.toggleFavorite(
          uid: widget.userId, songId: song.id);
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    }
  }

  Future<void> _showSongEditor({SongItem? initial}) async {
    final tituloCtrl = TextEditingController(text: initial?.titulo ?? '');
    final artistaCtrl = TextEditingController(text: initial?.artista ?? '');
    final coverCtrl = TextEditingController(text: initial?.coverUrl ?? '');
    final audioCtrl = TextEditingController(text: initial?.audioUrl ?? '');
    final tagsCtrl = TextEditingController(
        text: (initial?.tags ?? const <String>[]).join(', '));

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(initial == null ? 'Nueva canción' : 'Editar canción'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: artistaCtrl,
                decoration: const InputDecoration(labelText: 'Artista'),
              ),
              TextField(
                controller: coverCtrl,
                decoration: const InputDecoration(labelText: 'Cover URL'),
              ),
              TextField(
                controller: audioCtrl,
                decoration: const InputDecoration(labelText: 'Audio URL'),
              ),
              TextField(
                controller: tagsCtrl,
                decoration:
                    const InputDecoration(labelText: 'Tags (coma separadas)'),
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
              final artista = artistaCtrl.text.trim();
              final audioUrl = audioCtrl.text.trim();
              if (titulo.isEmpty || artista.isEmpty || audioUrl.isEmpty) {
                _showMessage('Título, artista y audio URL son obligatorios',
                    isError: true);
                return;
              }
              final tags = tagsCtrl.text
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .toList(growable: false);

              try {
                if (initial == null) {
                  await _songRepository.addSong(
                    titulo: titulo,
                    artista: artista,
                    coverUrl: coverCtrl.text.trim(),
                    audioUrl: audioUrl,
                    tags: tags,
                  );
                } else {
                  await _songRepository.updateSong(
                    songId: initial.id,
                    titulo: titulo,
                    artista: artista,
                    coverUrl: coverCtrl.text.trim(),
                    audioUrl: audioUrl,
                    tags: tags,
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

  Future<void> _confirmDeleteSong(SongItem song) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text('¿Eliminar "${song.titulo}" del catálogo?'),
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

    if (confirm != true) return;
    try {
      await _songRepository.deleteSong(song.id);
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    }
  }

  Future<void> _importSongsFromAsset() async {
    try {
      final raw = await rootBundle.loadString('assets/musica.json');
      final decoded = json.decode(raw);
      if (decoded is! List) return;

      for (final item in decoded) {
        if (item is! Map) continue;
        final tags = (item['tags'] is List)
            ? (item['tags'] as List)
                .map((t) => t.toString())
                .where((t) => t.isNotEmpty)
                .toList()
            : const <String>[];
        await _songRepository.upsertByAudioUrl(
          titulo: (item['titulo'] ?? '').toString(),
          artista: (item['artista'] ?? '').toString(),
          coverUrl: (item['coverUrl'] ?? '').toString(),
          audioUrl: (item['audioUrl'] ?? '').toString(),
          tags: tags,
        );
      }
      _showMessage('Catálogo importado desde assets/musica.json');
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    }
  }

  void _play(AudioProvider provider, List<SongItem> songs, int index) {
    final playlist = _toAudioMap(songs);
    final song = playlist[index];
    final audioUrl = (song['audioUrl'] ?? '').toString();
    if (audioUrl.isEmpty) return;

    if (provider.currentUrl == audioUrl) {
      provider.globalTogglePlayPause();
    } else {
      provider.setPlaylist(playlist, initialIndex: index);
    }
  }

  void _openPlayer(
    BuildContext context,
    AudioProvider provider,
    List<SongItem> songs,
    int index,
  ) {
    final playlist = _toAudioMap(songs);
    final song = playlist[index];
    final audioUrl = (song['audioUrl'] ?? '').toString();
    if (audioUrl.isEmpty) return;

    if (provider.currentUrl != audioUrl) {
      provider.setPlaylist(playlist, initialIndex: index);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerPage(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    return Scaffold(
      appBar: widget.soloFavoritos
          ? AppBar(
              title: const Text('Favoritos'),
              actions: <Widget>[
                Consumer<AudioProvider>(
                  builder: (context, provider, _) {
                    if (provider.currentUrl == null) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      tooltip: provider.isPlaying
                          ? 'Pausar: ${provider.currentSongName}'
                          : 'Reanudar: ${provider.currentSongName}',
                      icon: Icon(
                        provider.isPlaying
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                      ),
                      onPressed: provider.globalTogglePlayPause,
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
                  title: const Text('Playlist'),
                  actions: <Widget>[
                    IconButton(
                      tooltip: 'Importar catálogo desde assets',
                      icon: const Icon(Icons.download),
                      onPressed: _importSongsFromAsset,
                    ),
                    IconButton(
                      tooltip: 'Añadir canción',
                      icon: const Icon(Icons.add),
                      onPressed: () => _showSongEditor(),
                    ),
                  ],
                )
              : null),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _mostrarFlechaArriba
            ? FloatingActionButton.small(
                key: const ValueKey('up'),
                onPressed: () => _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                ),
                child: const Icon(Icons.keyboard_arrow_up),
              )
            : const SizedBox(key: ValueKey('down')),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por título, artista o tags...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<SongItem>>(
              stream: _songsStream,
              builder: (context, songsSnapshot) {
                if (songsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allSongs = songsSnapshot.data ?? const <SongItem>[];
                return StreamBuilder<Set<String>>(
                  stream: _favoriteIdsStream,
                  builder: (context, favSnapshot) {
                    if (favSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final favIds = favSnapshot.data ?? <String>{};
                    final filtered = _filterSongs(allSongs, favIds);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          widget.soloFavoritos
                              ? 'No tienes canciones en favoritos.'
                              : 'No hay resultados para esa búsqueda.',
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final song = filtered[index];
                        final isFav = favIds.contains(song.id);
                        final isPlaying = audioProvider.isPlaying &&
                            audioProvider.currentUrl == song.audioUrl;

                        return TavernSongCard(
                          title: song.titulo,
                          subtitle: song.artista,
                          coverUrl: song.coverUrl,
                          isPlaying: isPlaying,
                          isFavorite: isFav,
                          onFavoriteToggle: () => _toggleFavorito(song),
                          onTap: () => _play(audioProvider, filtered, index),
                          onDoubleTap: () => _openPlayer(
                              context, audioProvider, filtered, index),
                          onLongPress: widget.isAdmin
                              ? () async {
                                  await showModalBottomSheet<void>(
                                    context: context,
                                    builder: (ctx) => SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            leading: const Icon(Icons.edit),
                                            title: const Text('Editar canción'),
                                            onTap: () async {
                                              Navigator.pop(ctx);
                                              await _showSongEditor(
                                                  initial: song);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete),
                                            title:
                                                const Text('Eliminar canción'),
                                            onTap: () async {
                                              Navigator.pop(ctx);
                                              await _confirmDeleteSong(song);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

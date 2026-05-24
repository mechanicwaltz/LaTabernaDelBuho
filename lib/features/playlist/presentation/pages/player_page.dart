import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:appantibloqueo/core/providers/audio_provider.dart';
import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/core/errors/firebase_error_mapper.dart';
import 'package:appantibloqueo/features/playlist/data/playlist_repository.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key, required this.userId});

  final String userId;

  Widget _shadowAppBarTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final baseStyle = theme.textTheme.titleLarge ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w800);

    final style = baseStyle.copyWith(
      fontFamily: 'Cinzel',
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: scheme.onSurface,
    );

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Transform.translate(
          offset: const Offset(0, 2),
          child: Text(
            text.toUpperCase(),
            style: style.copyWith(color: scheme.shadow.withValues(alpha: 0.35)),
          ),
        ),
        Text(text.toUpperCase(), style: style),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final playlistRepository = PlaylistRepository();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final coverUrl = audioProvider.currentCoverUrl;
    final songName = audioProvider.currentSongName;
    final artistName = audioProvider.currentArtistName;
    final isPlaying = audioProvider.isPlaying;
    final currentSongId = audioProvider.currentSongId;

    final List<Color> bgGradient = isDark
        ? <Color>[scheme.surface, scheme.surface.withValues(alpha: 0.84)]
        : <Color>[
            scheme.primaryContainer.withValues(alpha: 0.55),
            scheme.surface
          ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _shadowAppBarTitle(context, 'Reproductor'),
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            tooltip: 'Cerrar reproductor',
            onPressed: () => Navigator.of(context).pop(),
            icon: SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                'assets/icon/logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          StreamBuilder<Set<String>>(
            stream: playlistRepository.watchFavoriteSongIds(userId),
            builder: (context, snapshot) {
              final favIds = snapshot.data ?? <String>{};
              final songId = currentSongId;
              final canFavorite = songId != null && songId.isNotEmpty;
              final isFav = canFavorite ? favIds.contains(songId) : false;
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? scheme.primary : scheme.onSurface,
                  size: 28,
                ),
                onPressed: !canFavorite
                    ? null
                    : () async {
                        final favoriteSongId = songId;
                        try {
                          await playlistRepository.toggleFavorite(
                            uid: userId,
                            songId: favoriteSongId,
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(FirebaseErrorMapper.fromObject(e)),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                      },
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
                  color: snowProvider.isSnowing
                      ? Colors.lightBlueAccent
                      : scheme.onSurface,
                ),
                onPressed: () => context.read<SnowProvider>().toggleSnow(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                coverUrl.isNotEmpty
                    ? coverUrl
                    : 'https://via.placeholder.com/512',
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.width * 0.75,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: MediaQuery.of(context).size.width * 0.75,
                  color: scheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.music_note,
                    size: 100,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              songName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artistName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.78),
              ),
            ),
            const Spacer(),
            StreamBuilder<Duration?>(
              stream: audioProvider.audioPlayer.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: audioProvider.audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    var position = snapshot.data ?? Duration.zero;
                    if (position > duration) position = duration;
                    final maxMs = duration.inMilliseconds.toDouble();
                    final valueMs = position.inMilliseconds
                        .toDouble()
                        .clamp(0.0, maxMs == 0 ? 0.0 : maxMs);
                    return SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: scheme.primary,
                        inactiveTrackColor:
                            scheme.onSurface.withValues(alpha: 0.22),
                        thumbColor: scheme.primary,
                        overlayColor: scheme.primary.withValues(alpha: 0.18),
                      ),
                      child: Slider(
                        value: valueMs,
                        onChanged: (value) {
                          audioProvider.audioPlayer.seek(
                            Duration(milliseconds: value.round()),
                          );
                        },
                        min: 0.0,
                        max: maxMs == 0 ? 1.0 : maxMs,
                      ),
                    );
                  },
                );
              },
            ),
            IconTheme(
              data: IconThemeData(color: scheme.onSurface),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 40),
                    onPressed: audioProvider.audioPlayer.hasPrevious
                        ? audioProvider.audioPlayer.seekToPrevious
                        : null,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 70,
                      color: scheme.primary,
                    ),
                    onPressed: audioProvider.globalTogglePlayPause,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 40),
                    onPressed: audioProvider.audioPlayer.hasNext
                        ? audioProvider.audioPlayer.seekToNext
                        : null,
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

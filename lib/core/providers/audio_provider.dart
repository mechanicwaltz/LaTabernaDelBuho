import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, dynamic>> _currentPlaylist = <Map<String, dynamic>>[];
  int _currentIndex = 0;

  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _audioPlayer.playing;

  String get currentSongName => _currentPlaylist.isNotEmpty
      ? (_currentPlaylist[_currentIndex]['titulo'] ?? 'Desconocido').toString()
      : '';
  String get currentArtistName => _currentPlaylist.isNotEmpty
      ? (_currentPlaylist[_currentIndex]['artista'] ?? 'Desconocido').toString()
      : '';
  String get currentCoverUrl => _currentPlaylist.isNotEmpty
      ? (_currentPlaylist[_currentIndex]['coverUrl'] ?? '').toString()
      : '';
  String? get currentUrl => _currentPlaylist.isNotEmpty
      ? (_currentPlaylist[_currentIndex]['audioUrl'] ?? '').toString()
      : null;
  String? get currentSongId => _currentPlaylist.isNotEmpty
      ? (_currentPlaylist[_currentIndex]['id'] ?? '').toString()
      : null;

  AudioProvider() {
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        _currentIndex = index;
        notifyListeners();
      }
    });
    _audioPlayer.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  Future<void> setPlaylist(List<Map<String, dynamic>> playlist,
      {int initialIndex = 0}) async {
    final withAudio = playlist.where((song) {
      final url = (song['audioUrl'] ?? '').toString().trim();
      return url.isNotEmpty;
    }).toList(growable: false);

    if (withAudio.isEmpty) return;
    _currentPlaylist = withAudio;
    _currentIndex = initialIndex.clamp(0, withAudio.length - 1);

    final audioSources = withAudio.map((song) {
      return AudioSource.uri(Uri.parse((song['audioUrl'] ?? '').toString()));
    }).toList(growable: false);

    try {
      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        initialIndex: _currentIndex,
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error al establecer la playlist: $e');
    }
  }

  Future<void> pause() async => _audioPlayer.pause();

  Future<void> resume() async => _audioPlayer.play();

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentPlaylist = <Map<String, dynamic>>[];
    _currentIndex = 0;
    notifyListeners();
  }

  void globalTogglePlayPause() {
    if (isPlaying) {
      pause();
    } else if (_currentPlaylist.isNotEmpty) {
      resume();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

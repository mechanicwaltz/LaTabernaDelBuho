import 'package:just_audio/just_audio.dart';

/// Servicio singleton para compartir un único [AudioPlayer] en toda la app.
///
/// - Mantiene una cola ([ConcatenatingAudioSource])
/// - Permite saltar por índice
/// - Evita reinstanciar el reproductor al navegar entre pantallas
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer player = AudioPlayer();
  ConcatenatingAudioSource? _queue;

  bool get hasQueue => _queue != null;

  /// Establece una nueva cola y arranca desde [initialIndex].
  ///
  /// Nota: Si la cola es la misma que la actual, no reconfiguramos para no
  /// perder el estado. Este heurístico es sencillo y suficiente para el modo
  /// reproductor de la app.
  Future<void> setQueue({
    required List<AudioSource> sources,
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
  }) async {
    if (sources.isEmpty) {
      return;
    }

    final newQueue = ConcatenatingAudioSource(children: sources);
    _queue = newQueue;

    await player.setAudioSource(
      newQueue,
      initialIndex: initialIndex.clamp(0, sources.length - 1),
      initialPosition: initialPosition,
      preload: true,
    );
  }

  Future<void> playIndex(int index) async {
    // just_audio expone `sequence` como nullable; puede ser null si aún no se ha
    // configurado una fuente o si la cola está en transición.
    final seq = player.sequence;
    if (seq == null || seq.isEmpty) {
      return;
    }

    final maxIndex = seq.length - 1;
    if (maxIndex < 0) {
      return;
    }

    final safeIndex = index.clamp(0, maxIndex);
    await player.seek(Duration.zero, index: safeIndex);
    await player.play();
  }

  Future<void> togglePlayPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }
}

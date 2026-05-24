import 'package:flutter/material.dart';

/// Barra de progreso para audio (posición/duración) con soporte de "scrub".
///
/// Diseñada para funcionar sin dependencias adicionales (sin rxdart).
class SeekBar extends StatefulWidget {
  final Duration position;
  final Duration buffered;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const SeekBar({
    super.key,
    required this.position,
    required this.buffered,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  static String _fmt(Duration d) {
    final totalSeconds = d.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double _toMs(Duration d) => d.inMilliseconds.toDouble();

  @override
  Widget build(BuildContext context) {
    final durationMs = _toMs(widget.duration);
    // `clamp` devuelve `num`; normalizamos a `double` para evitar errores de tipo.
    final positionMs = _toMs(widget.position).clamp(0.0, durationMs).toDouble();
    final bufferedMs = _toMs(widget.buffered).clamp(0.0, durationMs).toDouble();

    final sliderValue = (_dragValue ?? positionMs).toDouble();

    return Column(
      children: [
        // Buffered bar (fina) + slider principal encima
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Barra de buffered (sutil)
            SizedBox(
              height: 24,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final frac =
                      durationMs <= 0 ? 0.0 : (bufferedMs / durationMs);
                  return Container(
                    height: 4,
                    width: w,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: w * frac.clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Slider(
              min: 0.0,
              max: durationMs <= 0 ? 1.0 : durationMs,
              value: durationMs <= 0
                  ? 0.0
                  : sliderValue.clamp(0.0, durationMs).toDouble(),
              onChanged: durationMs <= 0
                  ? null
                  : (v) => setState(() => _dragValue = v),
              onChangeEnd: durationMs <= 0
                  ? null
                  : (v) {
                      setState(() => _dragValue = null);
                      widget.onSeek(Duration(milliseconds: v.round()));
                    },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fmt(widget.position),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              Text(
                _fmt(widget.duration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

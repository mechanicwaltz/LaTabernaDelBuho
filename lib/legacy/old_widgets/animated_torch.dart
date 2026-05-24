import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Antorcha animada (sin dependencias externas).
/// Usa un único PNG y separa base + llama mediante recorte.
/// La llama se anima con una leve oscilación + flicker de escala/opacidad.
class AnimatedTorch extends StatefulWidget {
  final double width;
  final double height;

  /// Porción superior de la imagen que se considera "llama".
  /// Ej.: 0.38 => el 38% superior se animará como fuego.
  final double flameTopFraction;

  const AnimatedTorch({
    super.key,
    this.width = 34,
    this.height = 70,
    this.flameTopFraction = 0.40,
  });

  @override
  State<AnimatedTorch> createState() => _AnimatedTorchState();
}

class _AnimatedTorchState extends State<AnimatedTorch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const assetPath = 'assets/images/torch.png';
    final flameFrac = widget.flameTopFraction.clamp(0.2, 0.7);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // Oscilaciones con distintas frecuencias para que el patrón no sea mecánico.
          final wiggle = math.sin(2 * math.pi * t);
          final wiggle2 = math.sin(2 * math.pi * (t * 1.7 + 0.15));
          final wiggle3 = math.sin(2 * math.pi * (t * 2.3 + 0.33));

          final flameDy = -1.0 + (wiggle * 1.2); // px
          final flameScale = 1.0 + (wiggle2 * 0.04);
          final flameRot = (wiggle3 * 0.03); // rad
          final flameOpacity = (0.90 + (wiggle2 * 0.08)).clamp(0.75, 1.0);

          final baseCut = (flameFrac + 0.06).clamp(0.25, 0.85).toDouble();

          Widget torchImage({Alignment alignment = Alignment.center}) {
            return OverflowBox(
              alignment: alignment,
              minWidth: widget.width,
              maxWidth: widget.width,
              minHeight: widget.height,
              maxHeight: widget.height,
              child: Image.asset(
                assetPath,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.contain,
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Base estática (sin la zona de fuego).
              ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: (1.0 - baseCut),
                  child: torchImage(alignment: Alignment.bottomCenter),
                ),
              ),

              // Llama (zona superior) con animación.
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: flameFrac,
                  child: Transform.translate(
                    offset: Offset(0, flameDy),
                    child: Transform.rotate(
                      angle: flameRot,
                      child: Transform.scale(
                        scale: flameScale,
                        child: Opacity(
                          opacity: flameOpacity,
                          child: torchImage(alignment: Alignment.topCenter),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

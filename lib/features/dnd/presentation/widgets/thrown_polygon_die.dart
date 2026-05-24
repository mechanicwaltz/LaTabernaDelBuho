import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:appantibloqueo/features/dnd/presentation/widgets/polygon_die.dart';

/// Animación de "tirada" para un dado poligonal (estética taberna).
///
/// - Hace un pequeño desplazamiento + rebote + rotación.
/// - Mientras rueda, muestra valores "intermedios" (simula rodar) y al final fija el resultado.
class ThrownPolygonDie extends StatefulWidget {
  final int die;
  final int value;
  final double size;
  final Color color;

  /// Incrementa este valor para forzar una nueva tirada/animación aunque el valor final sea el mismo.
  final int rollNonce;

  /// Semilla opcional para variar la animación entre dados.
  final int seed;

  final Duration duration;

  const ThrownPolygonDie({
    super.key,
    required this.die,
    required this.value,
    required this.size,
    required this.color,
    required this.rollNonce,
    required this.seed,
    this.duration = const Duration(milliseconds: 750),
  });

  @override
  State<ThrownPolygonDie> createState() => _ThrownPolygonDieState();
}

class _ThrownPolygonDieState extends State<ThrownPolygonDie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rot;
  late Animation<double> _scale;
  late Animation<Offset> _offset;

  // Para limitar actualizaciones de la cara durante el “rodado”.
  int _lastFaceTickMs = 0;

  // Valor visual mientras "rueda".
  int _rollingValue = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _configureAnimations();
    _start();
  }

  @override
  void didUpdateWidget(covariant ThrownPolygonDie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rollNonce != widget.rollNonce ||
        oldWidget.die != widget.die ||
        oldWidget.value != widget.value ||
        oldWidget.seed != widget.seed) {
      _configureAnimations();
      _start();
    }
  }

  void _configureAnimations() {
    final rnd = math.Random(widget.seed ^ (widget.rollNonce * 1000003));

    // --- Animación más “física” ---
    // Dispersión mayor (simula lanzamiento) + caída + rebote amortiguado.
    final dx = (40 + rnd.nextDouble() * 70) * (rnd.nextBool() ? 1 : -1);
    final dyUp = -(35 + rnd.nextDouble() * 55);
    final dyDown = (14 + rnd.nextDouble() * 22);

    // rotación (más vueltas) + sentido aleatorio
    final dir = rnd.nextBool() ? 1.0 : -1.0;
    final turns = 3.0 + rnd.nextDouble() * 3.0;
    final endRot = dir * 2 * math.pi * turns;

    _rot = Tween<double>(begin: 0, end: endRot).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // “Squash & stretch” + pequeño impacto al caer.
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.08), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.95), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.03), weight: 20),
      TweenSequenceItem(
        tween: Tween(begin: 1.03, end: 1.00)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    // Movimiento en 3 fases:
    // 1) Impulso: desde centro a (dx, dyUp)
    // 2) Caída: hacia suelo (dx*0.35, dyDown)
    // 3) Rebote/amortiguación: vuelve a (0,0) con elastic.
    _offset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: Offset(dx, dyUp))
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(dx, dyUp), end: Offset(dx * 0.35, dyDown))
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(dx * 0.35, dyDown), end: Offset.zero)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    // Actualiza valores "rodando" durante la animación.
    _controller.removeListener(_tickRollingValue);
    _controller.addListener(_tickRollingValue);
  }

  void _tickRollingValue() {
    // Mientras está rodando, cambia el número a un ritmo fijo (evita setState excesivo).
    if (!_controller.isAnimating) return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - _lastFaceTickMs < 55) return; // ~18 fps de “caras”
    _lastFaceTickMs = nowMs;

    final t = (_controller.value * 10000).floor();
    final rnd = math.Random(widget.seed ^ t ^ (widget.rollNonce * 2654435761));
    final v = rnd.nextInt(widget.die) + 1;
    if (v != _rollingValue) {
      setState(() => _rollingValue = v);
    }
  }

  void _start() {
    _controller
      ..stop()
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.value.clamp(1, widget.die);

    // Wobble amortiguado (más “físico”) además de la rotación principal.
    final rnd = math.Random(widget.seed);
    final wobbleAmp = 0.18 + rnd.nextDouble() * 0.14;
    final wobbleFreq = 10.0 + rnd.nextDouble() * 6.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        final wobble = math.sin(t * math.pi * wobbleFreq) * wobbleAmp * (1 - t);
        return Transform.translate(
          offset: _offset.value,
          child: Transform.rotate(
            angle: _rot.value + wobble,
            child: Transform.scale(
              scale: _scale.value,
              child: PolygonDie(
                die: widget.die,
                value: displayValue,
                size: widget.size,
                color: widget.color,
                // un poco de rotación estética adicional
                rotation: 0.10,
              ),
            ),
          ),
        );
      },
    );
  }
}

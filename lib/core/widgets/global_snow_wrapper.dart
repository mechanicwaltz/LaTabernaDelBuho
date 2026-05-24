// lib/widgets/global_snow_wrapper.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Importación necesaria para Consumer
import 'package:appantibloqueo/core/providers/snow_provider.dart';

class GlobalSnowWrapper extends StatelessWidget {
  final Widget
      child; // La página que se mostrará (ej: LoginPage, HomePage, etc.)

  const GlobalSnowWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. El contenido principal de la app siempre está visible y es interactuable
        Positioned.fill(child: child),

        // 2. La nieve se superpone SIEMPRE, pero solo si el provider lo indica
        Positioned.fill(
          child: Consumer<SnowProvider>(
            builder: (context, snowProvider, _) {
              // Si isSnowing es true, muestra el widget, si no, un contenedor vacío.
              return snowProvider.isSnowing
                  ? const SnowWidget()
                  : const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

// --- WIDGET DE NIEVE ---
class SnowWidget extends StatefulWidget {
  const SnowWidget({super.key});

  @override
  State<SnowWidget> createState() => _SnowWidgetState();
}

class _SnowWidgetState extends State<SnowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Snowflake> _snowflakes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _snowflakes = List.generate(200, (index) => _Snowflake(Random()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Importante: para que la nieve no bloquee los clics en los widgets de debajo
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          for (var snowflake in _snowflakes) {
            snowflake.fall();
          }
          return CustomPaint(
            size: Size.infinite,
            painter: _SnowPainter(_snowflakes),
          );
        },
      ),
    );
  }
}

class _SnowPainter extends CustomPainter {
  final List<_Snowflake> snowflakes;
  _SnowPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    for (var snowflake in snowflakes) {
      canvas.drawCircle(
          Offset(snowflake.x * size.width, snowflake.y * size.height),
          snowflake.radius,
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Snowflake {
  final Random _random;
  double x, y, radius, velocity;

  _Snowflake(this._random)
      : x = _random.nextDouble(),
        y = _random.nextDouble(),
        radius = _random.nextDouble() * 2 + 1,
        velocity = _random.nextDouble() * 0.005 + 0.002;

  void fall() {
    y += velocity;
    if (y > 1.2) {
      y = -0.1;
      x = _random.nextDouble();
    }
  }
}

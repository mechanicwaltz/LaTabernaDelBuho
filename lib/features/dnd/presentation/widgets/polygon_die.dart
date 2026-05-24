import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Dado poligonal con estética "gema" pensado para modo oscuro.
///
/// Importante: este widget es puramente visual. No implementa lógica de tirada.
class PolygonDie extends StatelessWidget {
  /// Tipo de dado (4, 6, 8, 10, 12, 20).
  final int die;

  /// Valor a mostrar (resultado o etiqueta).
  final int value;

  /// Tamaño en píxeles.
  final double size;

  /// Color base.
  final Color color;

  /// Rotación estética (radianes).
  final double rotation;

  const PolygonDie({
    super.key,
    required this.die,
    required this.value,
    required this.size,
    required this.color,
    this.rotation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final shapeSides = _shapeSidesForDie(die);

    // Tamaño de fuente proporcional para que en tamaños pequeños (selector) no desborde.
    final fontSize = math.max(12.0, size * 0.36);

    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.4,
          height: 1.0,
          shadows: [
            Shadow(
              blurRadius: 10,
              offset: const Offset(0, 2),
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ],
        ) ??
        TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _DiePainter(
              sides: shapeSides,
              color: color,
              rotation: rotation,
            ),
            size: Size.square(size),
          ),
          Text('$value', style: textStyle),
        ],
      ),
    );
  }

  int _shapeSidesForDie(int die) {
    // Identidad visual por dado (solo estética).
    switch (die) {
      case 4:
        return 3; // triángulo (d4 estilizado)
      case 6:
        return 4; // cuadrado
      case 8:
        return 8;
      case 10:
        return 10;
      case 12:
        return 12;
      case 20:
        return 20;
      default:
        return 6;
    }
  }
}

class _DiePainter extends CustomPainter {
  final int sides;
  final Color color;
  final double rotation;

  _DiePainter({
    required this.sides,
    required this.color,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = (math.min(size.width, size.height) / 2) * 0.92;

    final path = _polygonPath(center, r, sides, rotation);

    // Sombra proyectada (profesional; da volumen inmediatamente).
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.75), 12, true);

    // Base: gradiente "gema" integrado en dark.
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _tint(color, 0.22),
          color,
          _shade(color, 0.28),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, base);

    // Borde facetado sutil.
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.10);
    canvas.drawPath(path, border);

    // Brillo interior (volumen).
    final inner = _polygonPath(
      center.translate(-r * 0.04, -r * 0.06),
      r * 0.78,
      sides,
      rotation,
    );

    final highlight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.55),
        radius: 1.1,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawPath(inner, highlight);
  }

  Path _polygonPath(Offset c, double radius, int sides, double rot) {
    final p = Path();
    final n = math.max(3, sides);
    for (int i = 0; i < n; i++) {
      final a = (2 * math.pi * i / n) + rot - math.pi / 2;
      final x = c.dx + radius * math.cos(a);
      final y = c.dy + radius * math.sin(a);
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
    return p..close();
  }

  Color _tint(Color c, double t) => Color.lerp(c, Colors.white, t)!;
  Color _shade(Color c, double t) => Color.lerp(c, Colors.black, t)!;

  @override
  bool shouldRepaint(covariant _DiePainter oldDelegate) {
    return oldDelegate.sides != sides ||
        oldDelegate.color != color ||
        oldDelegate.rotation != rotation;
  }
}

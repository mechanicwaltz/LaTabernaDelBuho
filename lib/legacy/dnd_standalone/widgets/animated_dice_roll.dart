import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedDiceRoll extends StatefulWidget {
  final int sides;
  final int count;
  final int result;
  final int rollNonce;

  const AnimatedDiceRoll({
    required this.sides,
    required this.count,
    required this.result,
    this.rollNonce = 0,
    super.key,
  });

  @override
  State<AnimatedDiceRoll> createState() => _AnimatedDiceRollState();
}

class _AnimatedDiceRollState extends State<AnimatedDiceRoll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedDiceRoll oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambia la tirada (resultado) o el tipo de dado, reinicia animación.
    if (oldWidget.result != widget.result ||
        oldWidget.sides != widget.sides ||
        oldWidget.count != widget.count ||
        oldWidget.rollNonce != widget.rollNonce) {
      _controller
        ..stop()
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _diceColor {
    switch (widget.sides) {
      case 4:
        return Colors.green;
      case 6:
        return Colors.lightGreen;
      case 8:
        return Colors.purple;
      case 10:
        return Colors.pink;
      case 12:
        return Colors.red;
      case 20:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.count > 1 ? 'x${widget.count}' : null;

    return Center(
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (_, __) {
          return Transform.rotate(
            angle: _rotation.value,
            child: CustomPaint(
              painter: _DicePainter(
                sides: widget.sides,
                fillColor: _diceColor,
              ),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${widget.result}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (label != null)
                      Positioned(
                        bottom: 10,
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DicePainter extends CustomPainter {
  final int sides;
  final Color fillColor;

  const _DicePainter({
    required this.sides,
    required this.fillColor,
  });

  Path _polygonPath(int sides, double radius) {
    final path = Path();
    final angle = 2 * pi / sides;

    for (int i = 0; i < sides; i++) {
      final x = radius * cos(i * angle - pi / 2);
      final y = radius * sin(i * angle - pi / 2);
      if (i == 0) {
        path.moveTo(x + radius, y + radius);
      } else {
        path.lineTo(x + radius, y + radius);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;

    final path = _polygonPath(sides, radius);

    // Relleno
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Borde para definición (mejor UX visual)
    final strokePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _DicePainter oldDelegate) {
    return oldDelegate.sides != sides || oldDelegate.fillColor != fillColor;
  }
}

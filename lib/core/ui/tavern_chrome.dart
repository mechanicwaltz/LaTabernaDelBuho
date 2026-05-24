import 'package:flutter/material.dart';

/// Capa visual global estilo "cantina RPG":
/// - Fondo de madera
/// - Luz cálida tipo antorcha (dos focos superiores)
/// - Viñeteado suave para oscurecer bordes
/// Nota: No toca navegación ni lógica; solo envuelve el árbol de widgets.
class TavernChrome extends StatelessWidget {
  final Widget child;

  const TavernChrome({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            isDark
                ? 'assets/images/tavern_wood_dark.png'
                : 'assets/images/tavern_parchment.png',
            fit: BoxFit.cover,
          ),
        ),

        // En claro (pergamino) mantenemos una estética "taberna" más luminosa;
        // en oscuro (madera) intensificamos la profundidad con viñeteado.

        // Luz tipo antorcha: foco superior izquierdo
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.9, -1.0),
                  radius: 1.1,
                  colors: [
                    Color(0x66FFB74D), // ámbar cálido
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Luz tipo antorcha: foco superior derecho
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.9, -1.0),
                  radius: 1.1,
                  colors: [
                    Color(0x55FF8A65), // naranja/rojo suave
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Viñeteado para profundidad (más intenso en oscuro)
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.15,
                  colors: [
                    Colors.transparent,
                    (isDark
                        ? const Color(0xCC000000)
                        : const Color(0x66000000)),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Contenido de la app
        child,
      ],
    );
  }
}

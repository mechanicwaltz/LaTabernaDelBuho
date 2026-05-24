import 'package:flutter/material.dart';

/// Scaffold con fondo y “atmósfera” RPG aplicable a todas las páginas
/// sin modificar la lógica del contenido.
class RpgScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final double? leadingWidth;
  final bool centerTitle;
  final bool useShadowTitle;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const RpgScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.leadingWidth,
    this.centerTitle = true,
    this.useShadowTitle = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  Widget _shadowTitle(BuildContext context, String text) {
    final baseStyle = Theme.of(context).textTheme.titleLarge ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w800);

    final style = baseStyle.copyWith(fontWeight: FontWeight.w800);

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 2),
          child: Text(
            text.toUpperCase(),
            style: style.copyWith(
              color:
                  Theme.of(context).colorScheme.shadow.withValues(alpha: 0.35),
            ),
          ),
        ),
        Text(
          text.toUpperCase(),
          style: style,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: leading,
        leadingWidth: leadingWidth,
        centerTitle: centerTitle,
        title: title == null
            ? null
            : (useShadowTitle ? _shadowTitle(context, title!) : Text(title!)),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo base (gradiente cálido oscuro)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.surface,
                  cs.surface.withValues(alpha: 0.92),
                  cs.surface.withValues(alpha: 0.98),
                ],
              ),
            ),
          ),

          // Ruido suave para dar textura (no depende de assets externos con copyright)
          _NoiseOverlay(opacity: isDark ? 0.06 : 0.03),

          // Viñeteado sutil para look “cinemático”
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.10,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: isDark ? 0.38 : 0.12),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoiseOverlay extends StatelessWidget {
  final double opacity;

  const _NoiseOverlay({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          'assets/textures/noise.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
      ),
    );
  }
}

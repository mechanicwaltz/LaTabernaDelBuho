import 'package:flutter/material.dart';

class TavernSongCard extends StatelessWidget {
  const TavernSongCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    required this.isFavorite,
    required this.isPlaying,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onDoubleTap,
    this.onLongPress,
    this.extraTrailing,
  });

  final String title;
  final String subtitle;
  final String coverUrl;
  final bool isFavorite;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Widget? extraTrailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Opacity(
                  opacity: isDark ? 0.14 : 0.10,
                  child: Image.asset(
                    isDark
                        ? 'assets/images/tavern_wood_dark.png'
                        : 'assets/images/tavern_parchment.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        theme.cardColor.withValues(alpha: 0.98),
                        theme.cardColor.withValues(alpha: 0.90),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: <Widget>[
                    _Cover(
                      coverUrl: coverUrl,
                      isPlaying: isPlaying,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: isFavorite
                          ? 'Quitar de favoritos'
                          : 'Guardar en favoritos',
                      splashRadius: 22,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.78),
                      ),
                      onPressed: onFavoriteToggle,
                    ),
                    if (extraTrailing != null) extraTrailing!,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.coverUrl, required this.isPlaying});

  final String coverUrl;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cleaned = coverUrl.trim();
    final isHttp =
        cleaned.startsWith('http://') || cleaned.startsWith('https://');

    final Widget image = isHttp
        ? Image.network(
            cleaned,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/cover_generic_tavern.png',
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            'assets/images/cover_generic_tavern.png',
            fit: BoxFit.cover,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.secondary
                .withValues(alpha: isDark ? 0.22 : 0.18),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            image,
            if (isPlaying)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withValues(alpha: 0.5),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 32,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

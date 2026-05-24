import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class RssNewsEntry {
  const RssNewsEntry({
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
    required this.link,
  });

  final String titulo;
  final String descripcion;
  final String imagenUrl;
  final String link;
}

class RssNewsService {
  RssNewsService({
    http.Client? client,
    List<String>? feedUrls,
  })  : _client = client ?? http.Client(),
        _feedUrls = feedUrls ?? _defaultFeedUrls;

  static const List<String> _defaultFeedUrls = <String>[
    'https://news.google.com/rss/search?q=dungeons+and+dragons&hl=es-419&gl=ES&ceid=ES:es',
    'https://news.google.com/rss/search?q=baldur%27s+gate+3&hl=es-419&gl=ES&ceid=ES:es',
    'https://news.google.com/rss/search?q=pathfinder+rpg&hl=es-419&gl=ES&ceid=ES:es',
    'https://news.google.com/rss/search?q=juegos+de+rol+de+mesa&hl=es-419&gl=ES&ceid=ES:es',
  ];

  final http.Client _client;
  final List<String> _feedUrls;

  Future<List<RssNewsEntry>> fetchLatest({int maxItems = 30}) async {
    final List<RssNewsEntry> all = <RssNewsEntry>[];

    for (final url in _feedUrls) {
      try {
        final response =
            await _client.get(Uri.parse(url), headers: const <String, String>{
          'User-Agent': 'Mozilla/5.0 (Flutter App) RSS',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        }).timeout(const Duration(seconds: 20));

        if (response.statusCode != 200) {
          continue;
        }

        final parsed = _parseFeed(response.body);
        all.addAll(parsed);
      } catch (_) {
        // Si un feed falla, seguimos con los demas.
      }
    }

    final Map<String, RssNewsEntry> dedupByLink = <String, RssNewsEntry>{};
    for (final entry in all) {
      final link = entry.link.trim();
      if (link.isEmpty) continue;
      dedupByLink.putIfAbsent(link, () => entry);
    }

    final result = dedupByLink.values.take(maxItems).toList(growable: false);
    return result;
  }

  List<RssNewsEntry> _parseFeed(String rawXml) {
    final document = XmlDocument.parse(rawXml);
    final List<RssNewsEntry> entries = <RssNewsEntry>[];

    final rssItems = document.findAllElements('item');
    for (final item in rssItems) {
      final title = _cleanText(_elementText(item, 'title'));
      final link = _cleanText(_elementText(item, 'link'));
      final descriptionRaw = _firstNonEmpty(
        <String>[
          _elementText(item, 'description'),
          _elementText(item, 'content:encoded'),
          _elementText(item, 'summary'),
        ],
      );
      final description = _cleanDescription(descriptionRaw);
      final image = _extractImageUrl(item, descriptionRaw);

      if (title.isEmpty || link.isEmpty) continue;
      entries.add(
        RssNewsEntry(
          titulo: title,
          descripcion:
              description.isEmpty ? 'Sin descripcion disponible.' : description,
          imagenUrl: image,
          link: link,
        ),
      );
    }

    final atomEntries = document.findAllElements('entry');
    for (final entry in atomEntries) {
      final title = _cleanText(_elementText(entry, 'title'));
      final link = _atomLink(entry);
      final descriptionRaw = _firstNonEmpty(
        <String>[
          _elementText(entry, 'summary'),
          _elementText(entry, 'content'),
        ],
      );
      final description = _cleanDescription(descriptionRaw);
      final image = _extractImageUrl(entry, descriptionRaw);

      if (title.isEmpty || link.isEmpty) continue;
      entries.add(
        RssNewsEntry(
          titulo: title,
          descripcion:
              description.isEmpty ? 'Sin descripcion disponible.' : description,
          imagenUrl: image,
          link: link,
        ),
      );
    }

    return entries;
  }

  String _elementText(XmlElement parent, String tag) {
    final found = parent.findElements(tag);
    if (found.isEmpty) return '';
    return found.first.innerText;
  }

  String _atomLink(XmlElement entry) {
    final links = entry.findElements('link');
    if (links.isEmpty) return '';

    for (final element in links) {
      final rel = (element.getAttribute('rel') ?? '').trim();
      final href = (element.getAttribute('href') ?? '').trim();
      if (href.isEmpty) continue;
      if (rel.isEmpty || rel == 'alternate') return href;
    }
    return (links.first.getAttribute('href') ?? '').trim();
  }

  String _extractImageUrl(XmlElement parent, String descriptionRaw) {
    final mediaContent = parent.findElements('media:content');
    for (final element in mediaContent) {
      final url = (element.getAttribute('url') ?? '').trim();
      if (_isImageUrl(url)) return url;
    }

    final mediaThumbnail = parent.findElements('media:thumbnail');
    for (final element in mediaThumbnail) {
      final url = (element.getAttribute('url') ?? '').trim();
      if (_isImageUrl(url)) return url;
    }

    final enclosures = parent.findElements('enclosure');
    for (final element in enclosures) {
      final url = (element.getAttribute('url') ?? '').trim();
      final type = (element.getAttribute('type') ?? '').toLowerCase();
      if (_isImageUrl(url) || type.startsWith('image/')) return url;
    }

    final imgRegex = RegExp(
      '<img[^>]+src=["\\\']([^"\\\']+)["\\\']',
      caseSensitive: false,
    );
    final match = imgRegex.firstMatch(descriptionRaw);
    if (match != null) {
      final url = (match.group(1) ?? '').trim();
      if (_isImageUrl(url)) return url;
    }

    return '';
  }

  String _cleanDescription(String input) {
    final noTags = input.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final normalized = _cleanText(noTags);
    if (normalized.length <= 260) return normalized;
    return '${normalized.substring(0, 257)}...';
  }

  String _cleanText(String input) {
    final decoded = input
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  bool _isImageUrl(String url) {
    final normalized = url.toLowerCase();
    return normalized.startsWith('http://') ||
        normalized.startsWith('https://') ||
        normalized.startsWith('content://');
  }
}

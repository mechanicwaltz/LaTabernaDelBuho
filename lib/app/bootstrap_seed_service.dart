import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:appantibloqueo/features/news/data/news_repository.dart';
import 'package:appantibloqueo/features/playlist/data/song_repository.dart';

class BootstrapSeedService {
  BootstrapSeedService({
    FirebaseFirestore? firestore,
    SongRepository? songRepository,
    NewsRepository? newsRepository,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _songRepository =
            songRepository ?? SongRepository(firestore: firestore),
        _newsRepository =
            newsRepository ?? NewsRepository(firestore: firestore);

  final FirebaseFirestore _db;
  final SongRepository _songRepository;
  final NewsRepository _newsRepository;

  DocumentReference<Map<String, dynamic>> get _metaRef =>
      _db.collection('app_meta').doc('bootstrap');
  CollectionReference<Map<String, dynamic>> get _dndRacesRef =>
      _db.collection('dnd_races');

  static const Map<String, String> _raceLocalAssets = <String, String>{
    'draconido': 'assets/images/dnd_races/race_draconido.png',
    'drow': 'assets/images/dnd_races/race_drow.png',
    'elfo': 'assets/images/dnd_races/race_elfo.png',
    'enano': 'assets/images/dnd_races/race_enano.png',
    'githyanki': 'assets/images/dnd_races/race_githyanki.png',
    'gnomo': 'assets/images/dnd_races/race_gnomo.png',
    'humano': 'assets/images/dnd_races/race_humano.png',
    'mediano': 'assets/images/dnd_races/race_mediano.png',
    'semielfo': 'assets/images/dnd_races/race_semielfo.png',
    'semiorco': 'assets/images/dnd_races/race_semiorco.png',
    'tiefling': 'assets/images/dnd_races/race_tiefling.png',
  };

  Future<bool> ensureSeededIfAdmin({required bool isAdmin}) async {
    if (!isAdmin) return false;

    final metaSnap = await _metaRef.get();
    final data = metaSnap.data() ?? const <String, dynamic>{};
    final songsSeeded = data['songsSeeded'] == true;
    final newsSeeded = data['newsSeeded'] == true;
    final hasDndRaceDocs = await _hasDndRacesData();
    final dndRacesSeeded = (data['dndRacesSeeded'] == true) && hasDndRaceDocs;
    var dndRacesSeededNow = dndRacesSeeded;
    var didSeedAnyData = false;

    if (!songsSeeded) {
      await _seedSongsFromAsset();
      didSeedAnyData = true;
    }
    if (!newsSeeded) {
      await _seedNewsFromAsset();
      didSeedAnyData = true;
    }
    if (!dndRacesSeeded) {
      try {
        await _seedDndRacesFromAssets();
        dndRacesSeededNow = true;
        didSeedAnyData = true;
      } on FirebaseException catch (e) {
        dndRacesSeededNow = false;
        debugPrint(
          'Bootstrap DnD races skipped (${e.code}): ${e.message ?? 'sin detalle'}',
        );
      }
    }

    final shouldUpdateMeta =
        (!songsSeeded || !newsSeeded) || (dndRacesSeededNow != dndRacesSeeded);
    if (shouldUpdateMeta) {
      await _metaRef.set(<String, dynamic>{
        'songsSeeded': songsSeeded || didSeedAnyData,
        'newsSeeded': newsSeeded || didSeedAnyData,
        'dndRacesSeeded': dndRacesSeededNow,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return didSeedAnyData;
  }

  Future<bool> _hasDndRacesData() async {
    final snapshot = await _dndRacesRef.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> _seedSongsFromAsset() async {
    final raw = await rootBundle.loadString('assets/musica.json');
    final decoded = json.decode(raw);
    if (decoded is! List) return;

    for (final item in decoded) {
      if (item is! Map) continue;
      final tags = (item['tags'] is List)
          ? (item['tags'] as List)
              .map((t) => t.toString().trim())
              .where((t) => t.isNotEmpty)
              .toList(growable: false)
          : const <String>[];

      await _songRepository.upsertByAudioUrl(
        titulo: (item['titulo'] ?? '').toString(),
        artista: (item['artista'] ?? '').toString(),
        coverUrl: (item['coverUrl'] ?? '').toString(),
        audioUrl: (item['audioUrl'] ?? '').toString(),
        tags: tags,
      );
    }
  }

  Future<void> _seedNewsFromAsset() async {
    final raw = await rootBundle.loadString('assets/noticias.json');
    final decoded = json.decode(raw);
    if (decoded is! List) return;

    for (final item in decoded) {
      if (item is! Map) continue;
      await _newsRepository.upsertByLink(
        titulo: (item['titulo'] ?? '').toString(),
        descripcion: (item['descripcion'] ?? '').toString(),
        imagenUrl: (item['imagenUrl'] ?? '').toString(),
        link: (item['link'] ?? '').toString(),
      );
    }
  }

  Future<void> _seedDndRacesFromAssets() async {
    for (final entry in _raceLocalAssets.entries) {
      final raceKey = entry.key;
      final localAssetPath = entry.value;
      await _dndRacesRef.doc(raceKey).set(<String, dynamic>{
        'key': raceKey,
        // Spark-friendly: usamos asset local o URL externa, sin Storage.
        'imageUrl': localAssetPath,
        'source': 'asset',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}

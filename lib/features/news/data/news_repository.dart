import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:appantibloqueo/features/news/domain/news_item.dart';

class NewsRepository {
  NewsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _news => _db.collection('news');

  CollectionReference<Map<String, dynamic>> _favoriteNewsRef(String uid) {
    return _db.collection('users').doc(uid).collection('news_favorites');
  }

  Stream<List<NewsItem>> watchNews() {
    return _news.orderBy('updatedAt', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map(NewsItem.fromDoc).toList(growable: false));
  }

  Future<void> refreshNewsFromServer({int limit = 80}) async {
    await _news
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .get(const GetOptions(source: Source.server));
  }

  Stream<Set<String>> watchFavoriteNewsIds(String uid) {
    return _favoriteNewsRef(uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => (doc.data()['newsId'] ?? doc.id).toString())
          .where((id) => id.isNotEmpty)
          .toSet();
    });
  }

  Future<void> refreshFavoriteNewsFromServer({
    required String uid,
    int limit = 300,
  }) async {
    await _favoriteNewsRef(uid)
        .limit(limit)
        .get(const GetOptions(source: Source.server));
  }

  Future<void> addNews({
    required String titulo,
    required String descripcion,
    required String imagenUrl,
    required String link,
  }) {
    return _news.add(<String, dynamic>{
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'imagenUrl': imagenUrl.trim(),
      'link': link.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNews({
    required String id,
    required String titulo,
    required String descripcion,
    required String imagenUrl,
    required String link,
  }) {
    return _news.doc(id).update(<String, dynamic>{
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'imagenUrl': imagenUrl.trim(),
      'link': link.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNews(String id) => _news.doc(id).delete();

  Future<Set<String>> fetchExistingLinks() async {
    final snapshot = await _news.get();
    return snapshot.docs
        .map((doc) => (doc.data()['link'] ?? '').toString().trim())
        .where((link) => link.isNotEmpty)
        .toSet();
  }

  Future<void> upsertByLink({
    required String titulo,
    required String descripcion,
    required String imagenUrl,
    required String link,
  }) async {
    final normalizedLink = link.trim();
    if (normalizedLink.isEmpty) return;

    final existing =
        await _news.where('link', isEqualTo: normalizedLink).limit(1).get();
    if (existing.docs.isEmpty) {
      await addNews(
        titulo: titulo,
        descripcion: descripcion,
        imagenUrl: imagenUrl,
        link: normalizedLink,
      );
      return;
    }

    await updateNews(
      id: existing.docs.first.id,
      titulo: titulo,
      descripcion: descripcion,
      imagenUrl: imagenUrl,
      link: normalizedLink,
    );
  }

  Future<void> toggleFavorite({
    required String uid,
    required String newsId,
  }) async {
    final ref = _favoriteNewsRef(uid).doc(newsId);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set(<String, dynamic>{
        'newsId': newsId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

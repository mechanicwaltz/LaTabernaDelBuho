import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:appantibloqueo/core/notifications/app_notification_target.dart';
import 'package:appantibloqueo/features/notifications/data/admin_broadcast_repository.dart';
import 'package:appantibloqueo/features/notifications/domain/admin_broadcast.dart';
import 'package:appantibloqueo/features/profile/data/user_repository.dart';
import 'package:appantibloqueo/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'taberna_alerts_channel_v2';
  static const String _channelName = 'Alertas de Taberna';
  static const String _channelDescription =
      'Avisos de noticias y playlist de Taberna del Buho';
  static const List<String> _defaultTopics = <String>['noticias', 'playlist'];
  static const String _prefsUnreadCountKey = 'notification_unread_count';
  static const String _prefsHandledBroadcastIdsPrefix =
      'notification_handled_admin_broadcast_ids';
  static const int _maxHandledBroadcastIds = 500;
  static const String _payloadKindAdminBroadcast = 'admin_broadcast';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final UserRepository _userRepository = UserRepository();
  final AdminBroadcastRepository _broadcastRepository =
      AdminBroadcastRepository();

  final StreamController<AppNotificationTarget> _openTargetController =
      StreamController<AppNotificationTarget>.broadcast();

  Stream<AppNotificationTarget> get openTargetStream =>
      _openTargetController.stream;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _broadcastsSubscription;
  final Map<String, Timer> _inAppBroadcastTimers = <String, Timer>{};

  AppNotificationTarget? _pendingTarget;
  String? _currentUid;
  String? _currentToken;
  final Set<String> _handledBroadcastIds = <String>{};
  bool _topicsSubscribed = false;
  bool _initialized = false;
  bool _initializing = false;
  bool _timezonesInitialized = false;
  int _unreadCount = 0;

  Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;

    try {
      await _initializeLocalNotifications();
      _initializeTimeZones();
      await _restoreUnreadCount();
      await _configureForegroundPresentation();
      _listenForegroundMessages();
      _listenOpenedMessages();
      await _handleInitialMessage();
      _listenTokenRefresh();
      _initialized = true;
    } finally {
      _initializing = false;
    }
  }

  Future<NotificationSettings> requestUserPermission() async {
    return _requestPermission();
  }

  Future<void> markAllAsRead() async {
    _unreadCount = 0;
    await _persistUnreadCount();
    await _applyBadgeCount(0);
  }

  Future<void> _restoreUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    _unreadCount = prefs.getInt(_prefsUnreadCountKey) ?? 0;
    await _applyBadgeCount(_unreadCount);
  }

  Future<void> _persistUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsUnreadCountKey, _unreadCount);
  }

  String _handledBroadcastIdsPrefsKey(String uid) {
    return '$_prefsHandledBroadcastIdsPrefix.$uid';
  }

  Future<void> _loadHandledBroadcastIdsForUser(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final stored =
        prefs.getStringList(_handledBroadcastIdsPrefsKey(uid)) ?? <String>[];
    _handledBroadcastIds
      ..clear()
      ..addAll(stored.where((id) => id.trim().isNotEmpty));
    _trimHandledBroadcastIds();
  }

  Future<void> _persistHandledBroadcastIdsForCurrentUser() async {
    final uid = _currentUid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _handledBroadcastIdsPrefsKey(uid),
      _handledBroadcastIds.toList(growable: false),
    );
  }

  void _trimHandledBroadcastIds() {
    while (_handledBroadcastIds.length > _maxHandledBroadcastIds) {
      _handledBroadcastIds.remove(_handledBroadcastIds.first);
    }
  }

  Future<void> _markBroadcastHandled(String id) async {
    if (_handledBroadcastIds.contains(id)) return;
    _handledBroadcastIds.add(id);
    _trimHandledBroadcastIds();
    await _persistHandledBroadcastIdsForCurrentUser();
  }

  Future<int> _incrementUnreadCount() async {
    _unreadCount += 1;
    await _persistUnreadCount();
    await _applyBadgeCount(_unreadCount);
    return _unreadCount;
  }

  Future<void> _applyBadgeCount(int count) async {
    try {
      final isSupported = await FlutterAppBadger.isAppBadgeSupported();
      if (!isSupported) return;
      if (count <= 0) {
        FlutterAppBadger.removeBadge();
      } else {
        FlutterAppBadger.updateBadgeCount(count);
      }
    } catch (_) {
      // Evita fallar si el launcher/dispositivo no soporta badge numérico.
    }
  }

  void _initializeTimeZones() {
    if (_timezonesInitialized) return;
    tzdata.initializeTimeZones();
    _timezonesInitialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final target = _targetFromPayload(response.payload);
        if (target == null) return;
        _publishTarget(target);
      },
      onDidReceiveBackgroundNotificationResponse: _onLocalNotificationTapBg,
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final androidLocalNotifications =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidLocalNotifications?.requestNotificationsPermission();
  }

  @pragma('vm:entry-point')
  static void _onLocalNotificationTapBg(NotificationResponse response) {
    final target = NotificationService.instance._targetFromPayload(
      response.payload,
    );
    if (target == null) return;
    NotificationService.instance._publishTarget(target);
  }

  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      'Permiso de notificaciones: ${settings.authorizationStatus.name}',
    );
    return settings;
  }

  Future<void> _configureForegroundPresentation() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showForegroundNotification(message);
    });
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    final target = _targetFromMessage(message) ?? AppNotificationTarget.news;

    await _showTrackedLocalNotification(
      id: message.hashCode,
      title: title ?? 'Taberna del Buho',
      body: body ?? 'Tienes una nueva notificacion',
      target: target,
      kind: 'fcm',
    );
  }

  Future<void> _showTrackedLocalNotification({
    required int id,
    required String title,
    required String body,
    required AppNotificationTarget target,
    String? kind,
    String? broadcastId,
  }) async {
    final badgeNumber = await _incrementUnreadCount();
    final payload = jsonEncode(<String, String>{
      'target': target.key,
      if (kind != null) 'kind': kind,
      if (broadcastId != null) 'broadcastId': broadcastId,
    });

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(badgeNumber: badgeNumber),
      payload: payload,
    );
  }

  Future<void> _scheduleTrackedLocalNotification({
    required int id,
    required String title,
    required String body,
    required AppNotificationTarget target,
    required DateTime scheduledAtUtc,
    required int badgeNumber,
    String? kind,
    String? broadcastId,
  }) async {
    final payload = jsonEncode(<String, String>{
      'target': target.key,
      if (kind != null) 'kind': kind,
      if (broadcastId != null) 'broadcastId': broadcastId,
    });

    final scheduleDate = tz.TZDateTime.from(scheduledAtUtc, tz.local);

    try {
      await _localNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduleDate,
        _notificationDetails(badgeNumber: badgeNumber),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (_) {
      await _localNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduleDate,
        _notificationDetails(badgeNumber: badgeNumber),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  NotificationDetails _notificationDetails({required int badgeNumber}) {
    final normalizedBadge = badgeNumber < 1 ? 1 : badgeNumber;
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      number: normalizedBadge,
      channelShowBadge: true,
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: normalizedBadge,
    );
    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  void _listenOpenedMessages() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final target = _targetFromMessage(message);
      if (target == null) return;
      _publishTarget(target);
    });
  }

  Future<void> _handleInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage == null) return;
    final target = _targetFromMessage(initialMessage);
    if (target == null) return;
    _publishTarget(target);
  }

  void _listenTokenRefresh() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (newToken) async {
        final uid = _currentUid;
        if (uid == null || newToken.isEmpty) return;

        final previousToken = _currentToken;
        _currentToken = newToken;

        try {
          await _userRepository.upsertFcmToken(
            uid: uid,
            token: newToken,
            platform: _platformName,
          );
          if (previousToken != null && previousToken != newToken) {
            await _userRepository.deleteFcmToken(
              uid: uid,
              token: previousToken,
            );
          }
        } catch (e) {
          debugPrint('No se pudo refrescar token FCM: $e');
        }
      },
    );
  }

  Future<void> syncForUser(String uid) async {
    await initialize();
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    // Si cambia de cuenta, elimina token previo de la cuenta anterior.
    if (_currentUid != null && _currentUid != uid && _currentToken != null) {
      try {
        await _userRepository.deleteFcmToken(
          uid: _currentUid!,
          token: _currentToken!,
        );
      } catch (_) {
        // Ignora errores de limpieza para no bloquear el alta de la cuenta actual.
      }
    }

    await _userRepository.upsertFcmToken(
      uid: uid,
      token: token,
      platform: _platformName,
    );
    _currentUid = uid;
    _currentToken = token;
    await _loadHandledBroadcastIdsForUser(uid);

    _listenAdminBroadcasts(uid);
    await _syncPendingScheduledBroadcasts(uid);
  }

  Future<void> _syncPendingScheduledBroadcasts(String uid) async {
    try {
      final pending = await _broadcastRepository.fetchPendingScheduled(
        fromUtc: DateTime.now().toUtc(),
      );

      for (final broadcast in pending) {
        if (broadcast.createdByUid == uid) continue;
        if (_handledBroadcastIds.contains(broadcast.id)) continue;
        await _deliverBroadcast(broadcast);
        await _markBroadcastHandled(broadcast.id);
      }
    } catch (e) {
      debugPrint('No se pudieron sincronizar avisos programados: $e');
    }
  }

  Future<void> subscribeToDefaultTopics() async {
    await initialize();
    if (_topicsSubscribed) return;
    for (final topic in _defaultTopics) {
      await _messaging.subscribeToTopic(topic);
    }
    _topicsSubscribed = true;
  }

  Future<void> unsubscribeFromDefaultTopics() async {
    if (!_topicsSubscribed) return;
    for (final topic in _defaultTopics) {
      await _messaging.unsubscribeFromTopic(topic);
    }
    _topicsSubscribed = false;
  }

  Future<void> detachCurrentUser() async {
    final uid = _currentUid;
    final token = _currentToken;

    await unsubscribeFromDefaultTopics();
    _broadcastsSubscription?.cancel();
    _broadcastsSubscription = null;
    for (final timer in _inAppBroadcastTimers.values) {
      timer.cancel();
    }
    _inAppBroadcastTimers.clear();
    _handledBroadcastIds.clear();
    await _cancelPendingAdminBroadcastNotifications();
    await markAllAsRead();

    _currentUid = null;
    _currentToken = null;

    if (uid == null || token == null) return;
    try {
      await _userRepository.deleteFcmToken(uid: uid, token: token);
    } catch (_) {
      // Evita romper el logout por un error de red.
    }
  }

  Future<void> _cancelPendingAdminBroadcastNotifications() async {
    try {
      final pending =
          await _localNotificationsPlugin.pendingNotificationRequests();
      for (final request in pending) {
        final payload = _decodePayload(request.payload);
        if (payload == null) continue;
        if (payload['kind'] != _payloadKindAdminBroadcast) continue;
        await _localNotificationsPlugin.cancel(request.id);
      }
    } catch (_) {
      // Ignora plataformas donde no se pueda consultar pendientes.
    }
  }

  AppNotificationTarget? consumePendingTarget() {
    final target = _pendingTarget;
    _pendingTarget = null;
    return target;
  }

  void _publishTarget(AppNotificationTarget target) {
    _pendingTarget = target;
    _openTargetController.add(target);
  }

  void _listenAdminBroadcasts(String uid) {
    _broadcastsSubscription?.cancel();
    final since = Timestamp.fromDate(
      DateTime.now().toUtc().subtract(const Duration(days: 2)),
    );

    _broadcastsSubscription = _broadcastRepository
        .watchBroadcastsSince(since: since)
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added) continue;
        final broadcast = AdminBroadcast.fromDoc(change.doc);
        if (_handledBroadcastIds.contains(broadcast.id)) continue;
        if (broadcast.createdByUid == uid) continue;

        await _deliverBroadcast(broadcast);
        await _markBroadcastHandled(broadcast.id);
      }
    });
  }

  Future<void> _deliverBroadcast(AdminBroadcast broadcast) async {
    final scheduledFor = broadcast.scheduledFor?.toDate().toUtc();
    if (scheduledFor != null && scheduledFor.isAfter(DateTime.now().toUtc())) {
      final badgeNumber = await _nextScheduledBadgeNumber();
      await _scheduleAdminBroadcastNotification(
        broadcast,
        scheduledAtUtc: scheduledFor,
        badgeNumber: badgeNumber,
      );
      _scheduleInAppBroadcastTimer(
        broadcast: broadcast,
        scheduledAtUtc: scheduledFor,
      );
      return;
    }

    await _showAdminBroadcastNotification(broadcast);
  }

  void _scheduleInAppBroadcastTimer({
    required AdminBroadcast broadcast,
    required DateTime scheduledAtUtc,
  }) {
    final id = broadcast.id;
    _inAppBroadcastTimers[id]?.cancel();

    final delay = scheduledAtUtc.difference(DateTime.now().toUtc());
    if (delay <= Duration.zero) {
      unawaited(_showAdminBroadcastNotification(broadcast));
      return;
    }

    _inAppBroadcastTimers[id] = Timer(delay, () async {
      _inAppBroadcastTimers.remove(id);
      try {
        await _localNotificationsPlugin.cancel(broadcast.id.hashCode);
      } catch (_) {
        // Si no hay notificación pendiente para cancelar, seguimos.
      }
      await _showAdminBroadcastNotification(broadcast);
    });
  }

  Future<int> _nextScheduledBadgeNumber() async {
    int pendingAdmin = 0;
    try {
      final pending =
          await _localNotificationsPlugin.pendingNotificationRequests();
      pendingAdmin = pending.where((request) {
        final payload = _decodePayload(request.payload);
        return payload != null && payload['kind'] == _payloadKindAdminBroadcast;
      }).length;
    } catch (_) {
      pendingAdmin = 0;
    }

    final next = _unreadCount + pendingAdmin + 1;
    return next < 1 ? 1 : next;
  }

  Future<void> _showAdminBroadcastNotification(AdminBroadcast broadcast) async {
    await _showTrackedLocalNotification(
      id: broadcast.id.hashCode,
      title: broadcast.title,
      body: broadcast.body,
      target: broadcast.target,
      kind: _payloadKindAdminBroadcast,
      broadcastId: broadcast.id,
    );
  }

  Future<void> _scheduleAdminBroadcastNotification(
    AdminBroadcast broadcast, {
    required DateTime scheduledAtUtc,
    required int badgeNumber,
  }) async {
    await _scheduleTrackedLocalNotification(
      id: broadcast.id.hashCode,
      title: broadcast.title,
      body: broadcast.body,
      target: broadcast.target,
      scheduledAtUtc: scheduledAtUtc,
      badgeNumber: badgeNumber,
      kind: _payloadKindAdminBroadcast,
      broadcastId: broadcast.id,
    );
  }

  AppNotificationTarget? _targetFromMessage(RemoteMessage message) {
    final fromData = AppNotificationTargetX.tryParse(
      message.data['target']?.toString() ??
          message.data['tab']?.toString() ??
          message.data['route']?.toString(),
    );
    if (fromData != null) return fromData;

    final title = (message.notification?.title ?? '').toLowerCase();
    final body = (message.notification?.body ?? '').toLowerCase();

    if (title.contains('playlist') || body.contains('playlist')) {
      return AppNotificationTarget.playlist;
    }
    if (title.contains('nota') || body.contains('nota')) {
      return AppNotificationTarget.notes;
    }
    if (title.contains('dnd') || body.contains('dnd')) {
      return AppNotificationTarget.dnd;
    }

    return AppNotificationTarget.news;
  }

  AppNotificationTarget? _targetFromPayload(String? payload) {
    final decoded = _decodePayload(payload);
    if (decoded == null) {
      return AppNotificationTargetX.tryParse(payload);
    }
    return AppNotificationTargetX.tryParse(decoded['target']?.toString());
  }

  Map<String, dynamic>? _decodePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _broadcastsSubscription?.cancel();
    _openTargetController.close();
  }
}

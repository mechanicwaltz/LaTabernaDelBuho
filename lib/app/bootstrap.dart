import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:appantibloqueo/app/app.dart';
import 'package:appantibloqueo/core/notifications/notification_service.dart';
import 'package:appantibloqueo/core/providers/audio_provider.dart';
import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/firebase_options.dart';

Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.initialize();

  runApp(
    MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<SnowProvider>(create: (_) => SnowProvider()),
        ChangeNotifierProvider<AudioProvider>(create: (_) => AudioProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

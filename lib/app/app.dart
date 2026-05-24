import 'package:flutter/material.dart';

import 'package:appantibloqueo/app/presentation/pages/splash_page.dart';
import 'package:appantibloqueo/core/theme/app_themes.dart';
import 'package:appantibloqueo/core/ui/tavern_chrome.dart';
import 'package:appantibloqueo/core/widgets/global_snow_wrapper.dart';
import 'package:appantibloqueo/features/auth/presentation/widgets/auth_gate.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _showSplash = true;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Escritura Creativa',
      builder: (context, child) {
        return TavernChrome(
          child: GlobalSnowWrapper(child: child ?? const SizedBox.shrink()),
        );
      },
      themeMode: _themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: _showSplash
          ? SplashPage(
              onFinished: () {
                if (!mounted) return;
                setState(() => _showSplash = false);
              },
            )
          : AuthGate(
              onToggleTheme: _toggleTheme,
              isDark: _themeMode == ThemeMode.dark,
            ),
    );
  }
}

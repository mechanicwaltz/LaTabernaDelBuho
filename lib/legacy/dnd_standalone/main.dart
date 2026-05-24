import 'package:flutter/material.dart';
import 'package:appantibloqueo/features/dnd/presentation/pages/characters_list_page.dart';
import 'package:appantibloqueo/legacy/dnd_standalone/theme/app_theme.dart';

void main() {
  runApp(const DnDApp());
}

class DnDApp extends StatelessWidget {
  const DnDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'D&D Companion BG3',
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const CharactersListPage(ownerUid: 'standalone-local'),
    );
  }
}

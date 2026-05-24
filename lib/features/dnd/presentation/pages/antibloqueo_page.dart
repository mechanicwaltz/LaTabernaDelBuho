import 'package:flutter/material.dart';

import 'package:appantibloqueo/features/dnd/presentation/pages/characters_list_page.dart';

class AntiBloqueoPage extends StatelessWidget {
  final String ownerUid;
  const AntiBloqueoPage({super.key, required this.ownerUid});

  @override
  Widget build(BuildContext context) {
    // El módulo Juego hereda el Theme (claro/oscuro) de la app principal.
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CharactersListPage(ownerUid: ownerUid),
        );
      },
    );
  }
}

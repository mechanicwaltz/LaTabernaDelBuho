enum AppNotificationTarget {
  notes,
  dnd,
  playlist,
  news,
}

extension AppNotificationTargetX on AppNotificationTarget {
  String get key => switch (this) {
        AppNotificationTarget.notes => 'notes',
        AppNotificationTarget.dnd => 'dnd',
        AppNotificationTarget.playlist => 'playlist',
        AppNotificationTarget.news => 'news',
      };

  int get homeTabIndex => switch (this) {
        AppNotificationTarget.notes => 0,
        AppNotificationTarget.dnd => 1,
        AppNotificationTarget.playlist => 2,
        AppNotificationTarget.news => 3,
      };

  static AppNotificationTarget? tryParse(String? raw) {
    final value = raw?.trim().toLowerCase();
    switch (value) {
      case 'notes':
      case 'note':
      case 'notas':
      case 'nota':
        return AppNotificationTarget.notes;
      case 'dnd':
      case 'juego':
      case 'dice':
        return AppNotificationTarget.dnd;
      case 'playlist':
      case 'music':
      case 'musica':
      case 'songs':
        return AppNotificationTarget.playlist;
      case 'news':
      case 'noticias':
      case 'noticia':
        return AppNotificationTarget.news;
      default:
        return null;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:appantibloqueo/core/notifications/app_notification_target.dart';
import 'package:appantibloqueo/core/providers/audio_provider.dart';
import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/features/notifications/data/admin_broadcast_repository.dart';
import 'package:appantibloqueo/features/notifications/domain/admin_broadcast.dart';
import 'package:appantibloqueo/features/profile/domain/app_user.dart';

class AdminBroadcastPage extends StatefulWidget {
  const AdminBroadcastPage({
    super.key,
    required this.adminUser,
  });

  final AppUser adminUser;

  @override
  State<AdminBroadcastPage> createState() => _AdminBroadcastPageState();
}

class _AdminBroadcastPageState extends State<AdminBroadcastPage> {
  final AdminBroadcastRepository _repository = AdminBroadcastRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final Set<String> _deletingIds = <String>{};

  static const int _maxCountdownSeconds = 99 * 3600 + 59 * 60 + 59;

  AppNotificationTarget _target = AppNotificationTarget.news;
  int _countdownSeconds = 0;
  bool _sending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String _formatCountdown(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}-'
        '${minutes.toString().padLeft(2, '0')}-'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _adjustCountdown(int deltaSeconds) {
    if (_sending) return;
    setState(() {
      final next = _countdownSeconds + deltaSeconds;
      _countdownSeconds = next.clamp(0, _maxCountdownSeconds);
    });
  }

  Future<void> _onSendTap() async {
    final scheduledFor = _countdownSeconds > 0
        ? DateTime.now().toUtc().add(Duration(seconds: _countdownSeconds))
        : null;
    await _publishBroadcast(scheduledFor: scheduledFor);
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }

  Future<void> _publishBroadcast({DateTime? scheduledFor}) async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa titulo y mensaje.')),
      );
      return;
    }

    if (_sending) return;
    setState(() => _sending = true);

    try {
      await _repository.publish(
        title: title,
        body: body,
        target: _target,
        createdByUid: widget.adminUser.uid,
        createdByEmail: widget.adminUser.correo,
        scheduledFor: scheduledFor,
      );

      _titleController.clear();
      _bodyController.clear();

      if (!mounted) return;
      setState(() => _countdownSeconds = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            scheduledFor == null
                ? 'Aviso enviado correctamente.'
                : 'Aviso programado para ${_formatDateTime(scheduledFor)}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar el aviso: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Widget _buildTimeAdjuster({
    required String label,
    required String value,
    required VoidCallback onPlus,
    required VoidCallback onMinus,
    required bool enabled,
  }) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: const Color(0xFFE0A52B),
            onPressed: enabled ? onPlus : null,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: const Color(0xFF8B5A2B),
            onPressed: enabled ? onMinus : null,
          ),
        ],
      ),
    );
  }

  String _targetLabel(AppNotificationTarget target) {
    switch (target) {
      case AppNotificationTarget.notes:
        return 'Notas';
      case AppNotificationTarget.dnd:
        return 'DyD';
      case AppNotificationTarget.playlist:
        return 'Playlist';
      case AppNotificationTarget.news:
        return 'Noticias';
    }
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return <Widget>[
      Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          if (audioProvider.currentUrl == null) {
            return const SizedBox.shrink();
          }
          return IconButton(
            tooltip: audioProvider.isPlaying
                ? 'Pausar: ${audioProvider.currentSongName}'
                : 'Reanudar: ${audioProvider.currentSongName}',
            icon: Icon(
              audioProvider.isPlaying
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
            ),
            onPressed: audioProvider.globalTogglePlayPause,
          );
        },
      ),
      Consumer<SnowProvider>(
        builder: (context, snowProvider, _) {
          return IconButton(
            tooltip: snowProvider.isSnowing ? 'Quitar nieve' : 'Activar nieve',
            icon: Icon(
              Icons.ac_unit,
              color: snowProvider.isSnowing ? Colors.lightBlueAccent : null,
            ),
            onPressed: () => context.read<SnowProvider>().toggleSnow(),
          );
        },
      ),
    ];
  }

  Future<void> _deleteBroadcast(AdminBroadcast item) async {
    if (_deletingIds.contains(item.id)) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar aviso'),
          content: Text(
            'Se eliminara el aviso "${item.title}". Esta accion no se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    setState(() => _deletingIds.add(item.id));

    try {
      await _repository.deleteById(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aviso eliminado.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar el aviso: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingIds.remove(item.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos Admin'),
        centerTitle: true,
        actions: _buildAppBarActions(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Enviar aviso',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AppNotificationTarget>(
                    initialValue: _target,
                    decoration: const InputDecoration(
                      labelText: 'Destino (pantalla al abrir)',
                      border: OutlineInputBorder(),
                    ),
                    items: AppNotificationTarget.values.map((target) {
                      return DropdownMenuItem<AppNotificationTarget>(
                        value: target,
                        child: Text(_targetLabel(target)),
                      );
                    }).toList(growable: false),
                    onChanged: _sending
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() => _target = value);
                          },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    enabled: !_sending,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Titulo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyController,
                    enabled: !_sending,
                    maxLength: 220,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Mensaje',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temporizador (HH-MM-SS)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8B5A2B).withAlpha(120),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          _formatCountdown(_countdownSeconds),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            _buildTimeAdjuster(
                              label: 'Horas',
                              value: (_countdownSeconds ~/ 3600)
                                  .toString()
                                  .padLeft(2, '0'),
                              onPlus: () => _adjustCountdown(3600),
                              onMinus: () => _adjustCountdown(-3600),
                              enabled: !_sending,
                            ),
                            _buildTimeAdjuster(
                              label: 'Min',
                              value: ((_countdownSeconds % 3600) ~/ 60)
                                  .toString()
                                  .padLeft(2, '0'),
                              onPlus: () => _adjustCountdown(60),
                              onMinus: () => _adjustCountdown(-60),
                              enabled: !_sending,
                            ),
                            _buildTimeAdjuster(
                              label: 'Seg',
                              value: (_countdownSeconds % 60)
                                  .toString()
                                  .padLeft(2, '0'),
                              onPlus: () => _adjustCountdown(1),
                              onMinus: () => _adjustCountdown(-1),
                              enabled: !_sending,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _sending ? null : _onSendTap,
                    icon: const Icon(Icons.send),
                    label: Text(
                      _sending
                          ? 'Enviando...'
                          : _countdownSeconds > 0
                              ? 'Programar aviso'
                              : 'Enviar aviso',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Si el temporizador esta en 00-00-00 se envia al instante. '
                    'Si marcas tiempo, el aviso queda programado y se lanza a esa hora.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Avisos recientes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<AdminBroadcast>>(
            stream: _repository.watchRecent(limit: 25),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final items = snapshot.data ?? const <AdminBroadcast>[];
              if (items.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aun no hay avisos enviados.'),
                  ),
                );
              }

              return Column(
                children: items.map((item) {
                  final createdAt =
                      item.clientCreatedAt?.toDate() ?? DateTime.now();
                  final scheduledFor = item.scheduledFor?.toDate();
                  final isScheduled = scheduledFor != null &&
                      scheduledFor.isAfter(DateTime.now());
                  final timeText = isScheduled
                      ? 'Programado: ${scheduledFor.day.toString().padLeft(2, '0')}/'
                          '${scheduledFor.month.toString().padLeft(2, '0')}/'
                          '${scheduledFor.year} '
                          '${scheduledFor.hour.toString().padLeft(2, '0')}:'
                          '${scheduledFor.minute.toString().padLeft(2, '0')}'
                      : 'Enviado: ${createdAt.day.toString().padLeft(2, '0')}/'
                          '${createdAt.month.toString().padLeft(2, '0')}/'
                          '${createdAt.year} '
                          '${createdAt.hour.toString().padLeft(2, '0')}:'
                          '${createdAt.minute.toString().padLeft(2, '0')}';
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: Text(item.title),
                      subtitle: Text(
                        '${_targetLabel(item.target)} · ${item.body}\n$timeText',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Eliminar aviso',
                        icon: _deletingIds.contains(item.id)
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline,
                                color: Color(0xFF8B5A2B),
                              ),
                        onPressed: _deletingIds.contains(item.id)
                            ? null
                            : () => _deleteBroadcast(item),
                      ),
                    ),
                  );
                }).toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

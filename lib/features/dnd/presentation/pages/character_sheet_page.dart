import 'dart:math';
import 'package:flutter/material.dart';

import 'package:appantibloqueo/features/dnd/presentation/widgets/rpg_scaffold.dart';
import 'package:appantibloqueo/features/dnd/domain/rules/constants.dart';
import 'package:appantibloqueo/features/dnd/domain/character.dart';
import 'package:appantibloqueo/features/dnd/data/character_repository.dart';
import 'package:appantibloqueo/features/dnd/presentation/pages/combat_page.dart';

class CharacterSheetPage extends StatefulWidget {
  final Character character;
  final String ownerUid;

  const CharacterSheetPage({
    required this.character,
    required this.ownerUid,
    super.key,
  });

  @override
  State<CharacterSheetPage> createState() => _CharacterSheetPageState();
}

class _CharacterSheetPageState extends State<CharacterSheetPage> {
  final CharacterRepository _characterRepository = CharacterRepository();
  // 🔝 Scroll-to-top (flecha) — se muestra solo al empezar a hacer scroll hacia abajo
  late final ScrollController _scrollController;
  bool _mostrarFlechaArriba = false;

  late Character c;
  late Map<String, int> classLevels;
  static const int maxTotalLevel = 12;

  // Errores inline (sustituyen SnackBars)
  String? _levelInlineError;
  String? _classInlineError;
  String? _spellsInlineError;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    c = widget.character;
    classLevels = _initClassLevels(c);
    _syncLevelsToCharacter();
  }

  void _syncLevelsToCharacter() {
    c.classLevels = Map<String, int>.from(classLevels);
    c.level = _totalLevel();
  }

  Map<String, int> _initClassLevels(Character ch) {
    if (ch.classLevels.isNotEmpty) {
      final map = <String, int>{};
      ch.classLevels.forEach((k, v) {
        map[k] = v.clamp(0, maxTotalLevel);
      });
      if (map.values.any((v) => v > 0)) {
        map.removeWhere((_, v) => v <= 0);
        return map.isNotEmpty
            ? map
            : {ch.charClass: ch.level.clamp(1, maxTotalLevel)};
      }
    }
    return {ch.charClass: ch.level.clamp(1, maxTotalLevel)};
  }

  int _totalLevel() => classLevels.values.fold(0, (a, b) => a + b);

  Set<String> _spellNamesForClassUpToLevel(String cls, int level) {
    final names = <String>{};
    final byLevel = spellsByClassLevel[cls];
    if (byLevel == null) return names;
    for (int i = 1; i <= level; i++) {
      names.addAll(byLevel[i] ?? const <String>[]);
    }
    return names;
  }

  Set<String> _spellNamesForCurrentClasses({String? excludingClass}) {
    final names = <String>{};
    classLevels.forEach((cls, lv) {
      if (excludingClass != null && cls == excludingClass) return;
      names.addAll(_spellNamesForClassUpToLevel(cls, lv));
    });
    return names;
  }

  Future<void> _persistCharacter() async {
    _syncLevelsToCharacter();
    await _characterRepository.upsertCharacter(
      uid: widget.ownerUid,
      character: c,
    );
  }

  void _setPrimaryClass(String cls) {
    if (!classLevels.containsKey(cls)) return;
    setState(() {
      c.charClass = cls;
      _classInlineError = null;
    });
    _persistCharacter();
  }

  bool _isCompetent(String stat) {
    return classCompetencies[c.charClass]?.contains(stat) ?? false;
  }

  // Dialog temático (no banner)
  Future<void> _showRollDialog({
    required String title,
    required String body,
  }) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void rollAbilityCheck(String stat) {
    final mod = ((c.attributes[stat] ?? 10) - 10) ~/ 2;
    final comp = _isCompetent(stat) ? 2 : 0;
    final roll = Random().nextInt(20) + 1;
    final total = roll + mod + comp;

    final modStr = mod >= 0 ? '+$mod' : '$mod';
    _showRollDialog(
      title: 'Tirada: $stat',
      body:
          'd20 = $roll\nModificador = $modStr\nCompetencia = ${comp > 0 ? '+$comp' : '+0'}\n\nTotal = $total',
    );
  }

  String _getAttrKeyFromName(String name) {
    switch (name) {
      case 'Fuerza':
        return 'FUE';
      case 'Destreza':
        return 'DES';
      case 'Constitución':
        return 'CON';
      case 'Inteligencia':
        return 'INT';
      case 'Sabiduría':
        return 'SAB';
      case 'Carisma':
        return 'CAR';
      default:
        return 'INT';
    }
  }

  void rollSkillCheck(String skillName) {
    final skillData = skills[skillName];
    if (skillData == null) return;
    final attrName = skillData['caracteristica'] ?? '';
    final attrKey = _getAttrKeyFromName(attrName);

    final val = c.attributes[attrKey] ?? 10;
    final mod = (val - 10) ~/ 2;
    final isComp = c.competencies.contains(skillName);
    const profBonus = 2; // Simplificado para este ejemplo
    final roll = Random().nextInt(20) + 1;
    final total = roll + mod + (isComp ? profBonus : 0);

    _showRollDialog(
      title: 'Habilidad: $skillName ($attrKey)',
      body:
          'd20 = $roll\nModificador ($attrKey) = ${mod >= 0 ? "+$mod" : "$mod"}\nCompetencia = ${isComp ? "+$profBonus" : "+0"}\n\nTotal = $total',
    );
  }

  void changeAttribute(String key, int delta) {
    setState(() {
      c.attributes[key] = (c.attributes[key] ?? 10) + delta;
      c.attributes[key] = c.attributes[key]!.clamp(1, 20);
      final dexMod = ((c.attributes['DES'] ?? 10) - 10) ~/ 2;
      c.ac = 10 + dexMod;
    });
    _persistCharacter();
  }

  void changeClassLevel(String cls, int delta) {
    final current = classLevels[cls] ?? 0;
    final newLevel = (current + delta).clamp(0, maxTotalLevel);
    final projectedTotal = _totalLevel() - current + newLevel;

    // Sustituye SnackBars por errores inline
    if (projectedTotal < 1) {
      setState(() {
        _levelInlineError = 'El nivel total no puede ser menor que 1.';
      });
      return;
    }
    if (projectedTotal > maxTotalLevel) {
      setState(() {
        _levelInlineError = 'Nivel total máximo: $maxTotalLevel.';
      });
      return;
    }

    setState(() {
      _levelInlineError = null;

      final hitDie = classHitDie[cls] ?? 8;
      final conMod = ((c.attributes['CON'] ?? 10) - 10) ~/ 2;
      final hpStep = (hitDie / 2).floor() + 1 + conMod;

      if (newLevel > current) {
        final gained = newLevel - current;
        c.maxHp += hpStep * gained;
        c.hp = (c.hp + hpStep * gained).clamp(0, c.maxHp);
      } else if (newLevel < current) {
        final lost = current - newLevel;
        c.maxHp = (c.maxHp - hpStep * lost).clamp(1, c.maxHp);
        c.hp = c.hp.clamp(1, c.maxHp);
      }

      classLevels[cls] = newLevel;
      c.level = _totalLevel();

      // Si por alguna razón la clase principal se queda fuera (por ejemplo, bajada a 0 + limpieza)
      if (classLevels[cls] == 0) {
        classLevels.remove(cls);
        if (!classLevels.containsKey(c.charClass)) {
          c.charClass = classLevels.keys.isNotEmpty
              ? classLevels.keys.first
              : c.charClass;
        }
      }
    });

    _persistCharacter();
  }

  void addClass() {
    if (_totalLevel() >= maxTotalLevel) {
      setState(() {
        _classInlineError =
            'No puedes añadir más clases: nivel máximo alcanzado.';
      });
      return;
    }

    final available =
        classHitDie.keys.where((k) => !classLevels.containsKey(k)).toList();

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Añadir clase'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: available.map((cls) {
              return ChoiceChip(
                label: Text(cls),
                selected: false,
                onSelected: (_) {
                  setState(() {
                    _classInlineError = null;

                    classLevels[cls] = 1;
                    c.level = _totalLevel();

                    final hitDie = classHitDie[cls] ?? 8;
                    final conMod = ((c.attributes['CON'] ?? 10) - 10) ~/ 2;
                    final hpGain = (hitDie / 2).floor() + 1 + conMod;

                    c.maxHp += hpGain;
                    c.hp = (c.hp + hpGain).clamp(0, c.maxHp);
                  });
                  _persistCharacter();
                  Navigator.pop(dialogContext);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void removeClass(String cls) {
    if (!classLevels.containsKey(cls)) return;

    if (classLevels.length == 1) {
      setState(() {
        _classInlineError = 'No puedes eliminar la última clase.';
      });
      return;
    }

    final removedClassLevel = classLevels[cls] ?? 0;
    final removedClassSpells =
        _spellNamesForClassUpToLevel(cls, removedClassLevel);
    final remainingClassSpells =
        _spellNamesForCurrentClasses(excludingClass: cls);

    setState(() {
      _classInlineError = null;

      // Elimina hechizos ligados a la clase borrada.
      c.spells.removeWhere((spell) {
        final sourceClass = (spell['class'] ?? '').trim();
        if (sourceClass == cls) return true;

        final name = (spell['name'] ?? '').trim();
        if (name.isEmpty) return false;
        if (!removedClassSpells.contains(name)) return false;
        // Para hechizos antiguos sin metadato de clase:
        // solo los quitamos si no están disponibles por clases restantes.
        return !remainingClassSpells.contains(name);
      });

      // Elimina objetos ligados a la clase borrada.
      c.items.removeWhere((item) => (item['class'] ?? '').trim() == cls);

      // Limpieza defensiva de entradas vacías.
      c.spells.removeWhere((s) => (s['name'] ?? '').trim().isEmpty);
      c.items.removeWhere((i) => (i['name'] ?? '').trim().isEmpty);

      final lv = removedClassLevel;
      if (lv > 0) {
        final hitDie = classHitDie[cls] ?? 8;
        final conMod = ((c.attributes['CON'] ?? 10) - 10) ~/ 2;
        final hpStep = (hitDie / 2).floor() + 1 + conMod;

        c.maxHp = (c.maxHp - hpStep * lv).clamp(1, c.maxHp);
        c.hp = c.hp.clamp(1, c.maxHp);
      }

      classLevels.remove(cls);
      c.level = _totalLevel();

      if (!classLevels.containsKey(c.charClass)) {
        c.charClass = classLevels.keys.first;
      }
    });

    _persistCharacter();
  }

  void selectSpell() {
    final availableSpells = <Map<String, String>>[];
    final seen = <String>{};

    classLevels.forEach((cls, lv) {
      final Map<int, List<String>> byLevel = (spellsByClassLevel[cls] ?? {})
          .map((k, v) => MapEntry<int, List<String>>(k, List<String>.from(v)));

      for (int i = 1; i <= lv; i++) {
        final lvlSpells = byLevel[i] ?? [];
        for (final name in lvlSpells) {
          final key = '$cls::$name';
          final alreadyLearnt = c.spells.any(
            (sp) => sp['name'] == name && (sp['class'] ?? '').trim() == cls,
          );
          if (!alreadyLearnt && seen.add(key)) {
            final desc = allSpells[name]?['i'] ?? '';
            availableSpells.add({'name': name, 'desc': desc, 'class': cls});
          }
        }
      }
    });

    if (availableSpells.isEmpty) {
      setState(() {
        _spellsInlineError = 'No hay hechizos disponibles.';
      });
      return;
    }

    setState(() {
      _spellsInlineError = null;
    });

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Seleccionar hechizo'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: availableSpells.map((s) {
              return ChoiceChip(
                label: Text(s['name'] ?? ''),
                selected: false,
                onSelected: (_) {
                  setState(() {
                    c.spells.add({
                      'name': s['name']!,
                      'desc': s['desc']!,
                      'class': s['class'] ?? c.charClass,
                    });
                  });
                  _persistCharacter();
                  Navigator.pop(dialogContext);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void selectCompetency() {
    final availableSkills =
        skills.keys.where((s) => !c.competencies.contains(s)).toList();

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Seleccionar competencia'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: availableSkills.map((s) {
              return ChoiceChip(
                label: Text(s),
                selected: false,
                onSelected: (_) {
                  setState(() {
                    c.competencies.add(s);
                  });
                  _persistCharacter();
                  Navigator.pop(dialogContext);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void addOrEditItem({int? index}) {
    final nameCtl = TextEditingController(
        text: index != null ? c.items[index]['name'] : '');
    final descCtl = TextEditingController(
        text: index != null ? c.items[index]['desc'] : '');

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(index == null ? 'Añadir objeto' : 'Editar objeto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtl,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: descCtl,
                decoration: const InputDecoration(labelText: 'Descripción')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar')),
          if (index != null)
            TextButton(
              onPressed: () {
                setState(() => c.items.removeAt(index));
                _persistCharacter();
                Navigator.pop(dialogContext);
              },
              child: const Text('Borrar', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () {
              if (nameCtl.text.trim().isEmpty) return;
              setState(() {
                final existingClass =
                    index != null ? (c.items[index]['class'] ?? '').trim() : '';
                final item = {
                  'name': nameCtl.text.trim(),
                  'desc': descCtl.text.trim(),
                  // Nuevos objetos quedan vinculados a la clase principal activa.
                  'class':
                      existingClass.isNotEmpty ? existingClass : c.charClass,
                };
                if (index == null) {
                  c.items.add(item);
                } else {
                  c.items[index] = item;
                }
              });
              _persistCharacter();
              Navigator.pop(dialogContext);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  List<String> _raceTraits() {
    final List<String> traits = [];
    if (races[c.race]?['descripcion'] is String) {
      traits.add(races[c.race]!['descripcion'] as String);
    } else if (races[c.race]?['i'] is String) {
      traits.add(races[c.race]!['i'] as String);
    }
    if (c.subrace.isNotEmpty &&
        races[c.race]?['subrazas'] is Map<String, String>) {
      final sub =
          (races[c.race]!['subrazas'] as Map<String, String>)[c.subrace];
      if (sub != null) traits.add(sub);
    }
    return traits;
  }

  String _classInfoText() {
    final parts = classLevels.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key} ${e.value}')
        .toList();
    final total = _totalLevel();
    return parts.isEmpty
        ? '${c.charClass} ${c.level}'
        : '${parts.join(' / ')} (Nv. $total)';
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title.isNotEmpty)
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (title.isNotEmpty) const SizedBox(height: 6),
          ...children,
        ]),
      ),
    );
  }

  Widget _inlineError(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        msg,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    const double threshold = 180.0;
    final shouldShow = _scrollController.offset > threshold;
    if (shouldShow != _mostrarFlechaArriba) {
      setState(() => _mostrarFlechaArriba = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final raceInfo = [
      c.race,
      if (c.subrace.isNotEmpty) c.subrace,
    ].join(' · ');

    final raceTraits = _raceTraits();

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        await _persistCharacter();
        if (!mounted) return;
        navigator.pop(true);
      },
      child: RpgScaffold(
        title: 'Hoja de personaje',
        floatingActionButton: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: anim, child: child),
          ),
          child: _mostrarFlechaArriba
              ? FloatingActionButton.small(
                  key: const ValueKey('scroll_to_top'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  tooltip: 'Volver arriba',
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: const Icon(Icons.keyboard_arrow_up),
                )
              : const SizedBox.shrink(key: ValueKey('no_scroll_to_top')),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildCard(title: '', children: [
                Center(
                  child: Text(
                    '${c.name} - Nv. ${_totalLevel()}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                // Acciones
                Center(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () => selectCompetency(),
                          icon: const Icon(Icons.star)),
                      IconButton(
                          onPressed: () => selectSpell(),
                          icon: const Icon(Icons.menu_book)),
                      IconButton(
                          onPressed: () => addOrEditItem(),
                          icon: const Icon(Icons.backpack)),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (dialogContext) =>
                                      CombatPage(character: c)));
                        },
                        icon: const Icon(Icons.casino),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Mensajes inline de esta sección (sin banners)
                if (_levelInlineError != null) _inlineError(_levelInlineError!),
                if (_classInlineError != null) _inlineError(_classInlineError!),
                if (_spellsInlineError != null)
                  _inlineError(_spellsInlineError!),

                const SizedBox(height: 6),

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ElevatedButton.icon(
                      onPressed: addClass,
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir clase'),
                    ),
                    ...classLevels.entries.map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: cs.primary.withValues(alpha: 0.22)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _setPrimaryClass(e.key),
                              borderRadius: BorderRadius.circular(999),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      c.charClass == e.key
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${e.key}: ${e.value}'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.arrow_upward, size: 18),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                  width: 32, height: 32),
                              onPressed: () => changeClassLevel(e.key, 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward, size: 18),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                  width: 32, height: 32),
                              onPressed: () => changeClassLevel(e.key, -1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                  width: 32, height: 32),
                              onPressed: () => removeClass(e.key),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ]),
              const SizedBox(height: 10),
              _buildCard(title: 'Información', children: [
                Text(raceInfo),
                Text(_classInfoText()),
                Text(
                    'HP: ${c.hp}/${c.maxHp}  |  CA: ${c.ac}  |  Velocidad: ${c.speed}'),
                const SizedBox(height: 8),
                const Text('Rasgos raciales:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (raceTraits.isEmpty) const Text('• Sin rasgos definidos'),
                ...raceTraits.map((t) => Text('• $t')),
              ]),
              _buildCard(
                title: 'Atributos',
                children: c.attributes.keys.map((k) {
                  final value = c.attributes[k] ?? 10;
                  final mod = ((value - 10) ~/ 2);
                  final comp = _isCompetent(k) ? 2 : 0;
                  final total = mod + comp;

                  final modStr = mod >= 0 ? '+$mod' : '$mod';
                  final compStr = comp > 0
                      ? ' +$comp competencia = ${total >= 0 ? "+$total" : "$total"}'
                      : '';
                  final finalStr = 'Mod: $modStr$compStr';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$k: $value ${_isCompetent(k) ? "⭐" : ""}'),
                            Text(finalStr),
                          ]),
                      Row(children: [
                        IconButton(
                            onPressed: () => changeAttribute(k, -1),
                            icon: const Icon(Icons.remove)),
                        IconButton(
                            onPressed: () => rollAbilityCheck(k),
                            icon: const Icon(Icons.casino)),
                        IconButton(
                            onPressed: () => changeAttribute(k, 1),
                            icon: const Icon(Icons.add)),
                      ]),
                    ],
                  );
                }).toList(),
              ),
              _buildCard(
                title: 'Competencias',
                children: c.competencies.map((comp) {
                  return ListTile(
                    title: Text(comp),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.casino),
                          onPressed: () => rollSkillCheck(comp),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() => c.competencies.remove(comp));
                            _persistCharacter();
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              _buildCard(
                title: 'Hechizos',
                children: c.spells.asMap().entries.map((e) {
                  return ListTile(
                    title: Text(e.value['name'] ?? ''),
                    subtitle: Text(e.value['desc'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() => c.spells.removeAt(e.key));
                        _persistCharacter();
                      },
                    ),
                    onTap: () => selectSpell(),
                  );
                }).toList(),
              ),
              _buildCard(
                title: 'Inventario',
                children: c.items.asMap().entries.map((e) {
                  final itemClass = (e.value['class'] ?? '').trim();
                  final itemDesc = (e.value['desc'] ?? '').trim();
                  final subtitle = itemClass.isEmpty
                      ? itemDesc
                      : itemDesc.isEmpty
                          ? 'Clase: $itemClass'
                          : '$itemDesc\nClase: $itemClass';
                  return ListTile(
                    title: Text(e.value['name'] ?? ''),
                    subtitle: Text(subtitle),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => addOrEditItem(index: e.key),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

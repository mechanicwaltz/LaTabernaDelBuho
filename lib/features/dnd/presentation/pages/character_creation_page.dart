import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:appantibloqueo/features/dnd/presentation/widgets/rpg_scaffold.dart';
import 'package:appantibloqueo/features/dnd/domain/character.dart';
import 'package:appantibloqueo/features/dnd/domain/rules/constants.dart';
import 'package:appantibloqueo/features/dnd/data/character_repository.dart';

class CharacterCreationPage extends StatefulWidget {
  const CharacterCreationPage({super.key, required this.ownerUid});

  final String ownerUid;

  @override
  State<CharacterCreationPage> createState() => _CharacterCreationPageState();
}

class _CharacterCreationPageState extends State<CharacterCreationPage> {
  final CharacterRepository _characterRepository = CharacterRepository();
  // 🔝 Scroll-to-top (flecha) — se muestra solo al empezar a hacer scroll hacia abajo
  late final ScrollController _scrollController;
  bool _mostrarFlechaArriba = false;

  final _nameController = TextEditingController();

  String? _race;
  String? _subrace;
  String? _charClass;
  String? _subclass;

  Map<String, int> _attributes = {for (final a in baseAttributes) a: 8};
  int _remainingPoints = pointBuyBudget;

  final List<String> _selectedSkills = [];

  bool _submitAttempted = false;

  String? _pointsInlineError; // error inline en Point Buy (sin SnackBar)
  String? _skillsInlineError; // error inline en Skills (sin SnackBar)

  final Map<String, int> maxSkillsPerClass = const {
    'Bárbaro': 2,
    'Bardo': 3,
    'Clérigo': 2,
    'Druida': 2,
    'Guerrero': 2,
    'Mago': 2,
    'Monje': 2,
    'Paladín': 2,
    'Pícaro': 4,
    'Hechicero': 2,
    'Explorador': 3,
    'Brujo': 2,
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _attributes = {for (final a in baseAttributes) a: 8};
    _remainingPoints = pointBuyBudget;
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
    _nameController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool _isCompetent(String stat) {
    return classCompetencies[_charClass]?.contains(stat) ?? false;
  }

  bool get _requiresSubrace {
    if (_race == null) return false;
    final sub = races[_race]?['subraces'];
    return sub is Map && sub.isNotEmpty;
  }

  bool get _requiresSubclass {
    if (_charClass == null) return false;
    return subclasses[_charClass]?.isNotEmpty == true;
  }

  int get _maxSkills =>
      (_charClass != null ? (maxSkillsPerClass[_charClass!] ?? 2) : 0);

  bool get _nameOk => _nameController.text.trim().isNotEmpty;
  bool get _raceOk => _race != null;
  bool get _subraceOk => !_requiresSubrace || _subrace != null;
  bool get _classOk => _charClass != null;
  bool get _subclassOk => !_requiresSubclass || _subclass != null;
  bool get _pointsOk => _remainingPoints == 0;
  bool get _skillsOk =>
      _charClass != null && _selectedSkills.length == _maxSkills;

  bool get _canSave =>
      _nameOk &&
      _raceOk &&
      _subraceOk &&
      _classOk &&
      _subclassOk &&
      _pointsOk &&
      _skillsOk;

  void _changeAttribute(String key, int delta) {
    final current = _attributes[key]!;
    final next = current + delta;

    // límites point buy
    if (next < 8 || next > 15) return;

    final diff = pointBuyCost[next]! - pointBuyCost[current]!;
    if (_remainingPoints - diff < 0) {
      // sin SnackBar: solo feedback inline
      setState(() {
        _pointsInlineError = 'No tienes puntos suficientes.';
      });
      return;
    }

    setState(() {
      _pointsInlineError = null;
      _attributes[key] = next;
      _remainingPoints -= diff;
    });
  }

  Future<void> _saveCharacter() async {
    setState(() {
      _submitAttempted = true;
    });

    if (!_canSave) {
      // Sin SnackBar: la UI ya mostrará los errores inline.
      return;
    }

    final id = const Uuid().v4();
    final raceBonus = raceBonuses[_race] ?? {};
    final finalAttrs = Map<String, int>.from(_attributes);

    raceBonus.forEach((k, v) {
      if (baseAttributes.contains(k)) {
        finalAttrs[k] = (finalAttrs[k] ?? 0) + v;
      }
    });

    final speed = (raceBonus['speed'] is int) ? raceBonus['speed'] as int : 30;

    // FIX precedencia: (CON - 10) ~/ 2
    final conMod = (((finalAttrs['CON'] ?? 10) - 10) ~/ 2);
    final dexMod = (((finalAttrs['DES'] ?? 10) - 10) ~/ 2);

    // Nota: tu fórmula original sumaba +1 extra. Mantengo tu intención si era “nivel 1 + algo”
    final hp = classHitDie[_charClass!]! + conMod + 1;
    final ac = 10 + dexMod;

    final traits = _traitsForRace(_race, _subrace);

    final newChar = Character(
      id: id,
      name: _nameController.text.trim(),
      race: _race!,
      subrace: _subrace ?? '',
      charClass: _charClass!,
      subclass: _subclass ?? '',
      level: 1,
      classLevels: {_charClass!: 1},
      hp: hp,
      maxHp: hp,
      ac: ac,
      speed: speed,
      attributes: finalAttrs,
      competencies: List<String>.from(_selectedSkills),
      spells: const [],
      items: const [],
      traits: traits,
    );

    await _characterRepository.upsertCharacter(
      uid: widget.ownerUid,
      character: newChar,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  List<String> _traitsForRace(String? race, String? subrace) {
    if (race == null) return const [];

    final List<String> traits = [];
    final i = races[race]?['i'];
    if (i is String && i.isNotEmpty) traits.add(i);

    final sub = races[race]?['subraces'];
    if (subrace != null && sub is Map<String, String>) {
      final subTrait = sub[subrace];
      if (subTrait != null && subTrait.isNotEmpty) traits.add(subTrait);
    }

    return traits;
  }

  Widget _inlineError(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        msg,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RpgScaffold(
      title: 'Crear personaje',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              title: 'Nombre',
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '',
                    errorText: (_submitAttempted && !_nameOk)
                        ? 'El nombre es obligatorio.'
                        : null,
                  ),
                  style: const TextStyle(fontSize: 20),
                  onChanged: (_) {
                    if (_submitAttempted) setState(() {});
                  },
                ),
              ],
            ),

            _buildCard(
              title: 'Raza',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: races.keys.map((r) {
                    final sel = _race == r;
                    return ChoiceChip(
                      label: Text(r),
                      selected: sel,
                      onSelected: (_) => setState(() {
                        _race = r;
                        _subrace = null;
                      }),
                    );
                  }).toList(),
                ),
                if (_submitAttempted && !_raceOk)
                  _inlineError('Selecciona una raza.'),
                if (_race != null && _requiresSubrace) ...[
                  const SizedBox(height: 10),
                  const Text('Subraza',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (races[_race]!['subraces'] as Map<String, String>)
                        .keys
                        .map((s) {
                      final sel = _subrace == s;
                      return ChoiceChip(
                        label: Text(s),
                        selected: sel,
                        onSelected: (_) => setState(() => _subrace = s),
                      );
                    }).toList(),
                  ),
                  if (_submitAttempted && !_subraceOk)
                    _inlineError('Selecciona una subraza.'),
                ],
                if (_race != null) ...[
                  const SizedBox(height: 10),
                  const Text('Rasgos raciales:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._traitsForRace(_race, _subrace).map((t) => Text('• $t')),
                ],
              ],
            ),

            _buildCard(
              title: 'Clase',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: classHitDie.keys.map((cl) {
                    final sel = _charClass == cl;
                    return ChoiceChip(
                      label: Text(cl),
                      selected: sel,
                      onSelected: (_) => setState(() {
                        _charClass = cl;
                        _subclass = null;
                        _selectedSkills.clear();
                        _skillsInlineError = null;
                      }),
                    );
                  }).toList(),
                ),
                if (_submitAttempted && !_classOk)
                  _inlineError('Selecciona una clase.'),
                if (_charClass != null && _requiresSubclass) ...[
                  const SizedBox(height: 10),
                  const Text('Subclase',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subclasses[_charClass]!.map((s) {
                      final sel = _subclass == s;
                      return ChoiceChip(
                        label: Text(s),
                        selected: sel,
                        onSelected: (_) => setState(() => _subclass = s),
                      );
                    }).toList(),
                  ),
                  if (_submitAttempted && !_subclassOk)
                    _inlineError('Selecciona una subclase.'),
                ],
              ],
            ),

            _buildCard(
              title: 'Atributos (Point Buy)',
              children: [
                ...baseAttributes.map((k) {
                  final val = _attributes[k]!;
                  return Row(
                    children: [
                      Expanded(
                        child: Text('$k: $val ${_isCompetent(k) ? "⭐" : ""}'),
                      ),
                      IconButton(
                        onPressed: () => _changeAttribute(k, -1),
                        icon: const Icon(Icons.remove),
                      ),
                      IconButton(
                        onPressed: () => _changeAttribute(k, 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  );
                }),
                Text('Puntos restantes: $_remainingPoints'),
                if (_pointsInlineError != null)
                  _inlineError(_pointsInlineError!),
                if (_submitAttempted && !_pointsOk)
                  _inlineError('Debes gastar todos los puntos (0 restantes).'),
              ],
            ),

            if (_charClass != null)
              _buildCard(
                title: 'Competencias disponibles (Máx: $_maxSkills)',
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: skills.keys.map((skill) {
                      final selected = _selectedSkills.contains(skill);
                      final canSelectMore = _selectedSkills.length < _maxSkills;

                      // Sin SnackBar: si ya has llegado al máximo, deshabilita chips no seleccionados.
                      final bool enabled = selected || canSelectMore;

                      return FilterChip(
                        label: Text(skill),
                        selected: selected,
                        onSelected: enabled
                            ? (_) {
                                setState(() {
                                  _skillsInlineError = null;
                                  if (selected) {
                                    _selectedSkills.remove(skill);
                                  } else {
                                    _selectedSkills.add(skill);
                                  }
                                });
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                      'Seleccionadas: ${_selectedSkills.length} / $_maxSkills'),
                  if (_skillsInlineError != null)
                    _inlineError(_skillsInlineError!),
                  if (_submitAttempted && !_skillsOk)
                    _inlineError(
                        'Debes seleccionar exactamente $_maxSkills competencias.'),
                ],
              ),

            const SizedBox(height: 20),

            // Mensaje general (opcional) SIN banner: solo aparece si intentas guardar y no es válido
            if (_submitAttempted && !_canSave)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Center(
                  child: Text(
                    'Revisa los campos marcados en rojo.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Botón deshabilitado hasta que sea válido: sin SnackBar y UX limpia
                  onPressed: _canSave
                      ? _saveCharacter
                      : _saveCharacter, // permite marcar errores al intentar
                  child: const Text('Crear personaje'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

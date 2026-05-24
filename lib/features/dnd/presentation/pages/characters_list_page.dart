import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:appantibloqueo/features/dnd/data/character_repository.dart';
import 'package:appantibloqueo/features/dnd/data/dnd_race_assets_repository.dart';
import 'package:appantibloqueo/features/dnd/domain/character.dart';
import 'package:appantibloqueo/features/dnd/presentation/pages/character_creation_page.dart';
import 'package:appantibloqueo/features/dnd/presentation/pages/character_sheet_page.dart';

class CharactersListPage extends StatefulWidget {
  const CharactersListPage({super.key, required this.ownerUid});

  final String ownerUid;

  @override
  State<CharactersListPage> createState() => _CharactersListPageState();
}

class _CharactersListPageState extends State<CharactersListPage> {
  final CharacterRepository _characterRepository = CharacterRepository();
  final DndRaceAssetsRepository _dndRaceAssetsRepository =
      DndRaceAssetsRepository();
  late final ScrollController _scrollController;
  StreamSubscription<Map<String, String>>? _raceAssetsSub;
  bool _mostrarFlechaArriba = false;
  final Set<String> _fireCards = <String>{};
  final Set<String> _flippedCards = <String>{};
  Map<String, String> _remoteRaceCardUrls = <String, String>{};

  static const Map<String, String> _raceCardAssets = <String, String>{
    'draconido': 'assets/images/dnd_races/race_draconido.png',
    'drow': 'assets/images/dnd_races/race_drow.png',
    'elfo': 'assets/images/dnd_races/race_elfo.png',
    'enano': 'assets/images/dnd_races/race_enano.png',
    'githyanki': 'assets/images/dnd_races/race_githyanki.png',
    'gnomo': 'assets/images/dnd_races/race_gnomo.png',
    'gnomos': 'assets/images/dnd_races/race_gnomo.png',
    'humano': 'assets/images/dnd_races/race_humano.png',
    'mediano': 'assets/images/dnd_races/race_mediano.png',
    'semielfo': 'assets/images/dnd_races/race_semielfo.png',
    'semielfos': 'assets/images/dnd_races/race_semielfo.png',
    'semiorco': 'assets/images/dnd_races/race_semiorco.png',
    'semiorcos': 'assets/images/dnd_races/race_semiorco.png',
    'tiefling': 'assets/images/dnd_races/race_tiefling.png',
  };

  static const Map<String, Color> _raceBorderColors = <String, Color>{
    'draconido': Color(0xFF72838D),
    'drow': Color(0xFF8A6FD0),
    'elfo': Color(0xFFA78A4A),
    'enano': Color(0xFF2B4B60),
    'githyanki': Color(0xFFB97748),
    'gnomo': Color(0xFF8A93A3),
    'humano': Color(0xFFE1782B),
    'mediano': Color(0xFF3AA08F),
    'semielfo': Color(0xFFC7ECFF),
    'semiorco': Color(0xFF5FA25A),
    'tiefling': Color(0xFFB84A3F),
  };

  static const Map<String, Color> _raceLeftTints = <String, Color>{
    'draconido': Color(0xFF2E3840),
    'drow': Color(0xFF2A2060),
    'elfo': Color(0xFF3C331E),
    'enano': Color(0xFF071A28),
    'githyanki': Color(0xFF4A2E23),
    'gnomo': Color(0xFF313744),
    'humano': Color(0xFF7A3411),
    'mediano': Color(0xFF175447),
    'semielfo': Color(0xFF5CA7D6),
    'semiorco': Color(0xFF1E4A2A),
    'tiefling': Color(0xFF4E140D),
  };

  static const Map<String, Alignment> _raceImageFocus = <String, Alignment>{
    'elfo': Alignment(-0.14, 0.0),
    'drow': Alignment(-0.12, 0.0),
  };

  static const Map<String, double> _raceImageZoom = <String, double>{
    'elfo': 1.05,
    'drow': 1.05,
  };

  static const double _topRowInset = 12;
  static const double _deleteInset = _topRowInset;
  static const double _flipInsetTop = _topRowInset;
  static const double _flipInsetLeft = 12;
  static const double _flipPairGap = 8;
  static const double _deleteSize = 52;
  static const double _deleteIconSize = 24;
  static const double _flipSize = 46;
  static const double _flipIconSize = 22;
  static const Color _deleteIconColor = Color(0xFFD39B38);

  List<Character> chars = <Character>[];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _bindRaceAssets();
    _load();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    const threshold = 180.0;
    final shouldShow = _scrollController.offset > threshold;
    if (shouldShow != _mostrarFlechaArriba) {
      setState(() => _mostrarFlechaArriba = shouldShow);
    }
  }

  @override
  void dispose() {
    _raceAssetsSub?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _bindRaceAssets() {
    _raceAssetsSub?.cancel();
    _raceAssetsSub = _dndRaceAssetsRepository.watchRaceImageUrls().listen(
      (urls) {
        if (!mounted) return;
        setState(() => _remoteRaceCardUrls = urls);
      },
    );
    _dndRaceAssetsRepository.refreshFromServer();
  }

  Future<void> _load() async {
    final loaded = await _characterRepository.loadCharacters(widget.ownerUid);
    if (!mounted) return;
    setState(() {
      chars = loaded;
      final liveKeys = loaded
          .map<String>((character) => _characterFireKey(character))
          .toSet();
      _fireCards.removeWhere((id) => !liveKeys.contains(id));
      _flippedCards.removeWhere((id) => !liveKeys.contains(id));
    });
  }

  Future<void> _delete(Character c) async {
    await _characterRepository.deleteCharacter(
      uid: widget.ownerUid,
      characterId: c.id,
    );
    await _load();
  }

  Future<void> _confirmDelete(Character c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar personaje'),
        content: Text(
          'Se borrara "${c.name}". Esta accion no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _delete(c);
  }

  Future<void> _create() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterCreationPage(ownerUid: widget.ownerUid),
      ),
    );
    if (result == true) await _load();
  }

  void _open(Character c) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterSheetPage(
          character: c,
          ownerUid: widget.ownerUid,
        ),
      ),
    );
    if (result == true) await _load();
  }

  void _toggleCardFire(Character c) {
    final key = _characterFireKey(c);
    setState(() {
      if (_fireCards.contains(key)) {
        _fireCards.remove(key);
      } else {
        _fireCards.add(key);
      }
    });
  }

  void _toggleCardFlip(Character c) {
    final key = _characterFireKey(c);
    setState(() {
      if (_flippedCards.contains(key)) {
        _flippedCards.remove(key);
      } else {
        _flippedCards.add(key);
      }
    });
  }

  String _characterFireKey(Character c) {
    final id = c.id.trim();
    if (id.isNotEmpty) return id;
    return '${c.name}|${c.race}|${c.charClass}|${c.level}';
  }

  String _normalizeRaceKey(String race) {
    var value = race.trim().toLowerCase();

    // Normal accents.
    value = value
        .replaceAll('\u00e1', 'a')
        .replaceAll('\u00e9', 'e')
        .replaceAll('\u00ed', 'i')
        .replaceAll('\u00f3', 'o')
        .replaceAll('\u00fa', 'u')
        .replaceAll('\u00fc', 'u')
        .replaceAll('\u00f1', 'n');

    // Mojibake fallback.
    value = value
        .replaceAll('Ã¡', 'a')
        .replaceAll('Ã©', 'e')
        .replaceAll('Ã­', 'i')
        .replaceAll('Ã³', 'o')
        .replaceAll('Ãº', 'u')
        .replaceAll('Ã¼', 'u')
        .replaceAll('Ã±', 'n')
        .replaceAll('ÃƒÂ¡', 'a')
        .replaceAll('ÃƒÂ©', 'e')
        .replaceAll('ÃƒÂ­', 'i')
        .replaceAll('ÃƒÂ³', 'o')
        .replaceAll('ÃƒÂº', 'u')
        .replaceAll('ÃƒÂ¼', 'u')
        .replaceAll('ÃƒÂ±', 'n');

    value = value.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (value == 'dracnido') return 'draconido';
    return value;
  }

  String _resolveRaceKey(String race) {
    final normalized = _normalizeRaceKey(race);
    if (_raceCardAssets.containsKey(normalized)) return normalized;

    if (normalized.startsWith('drac')) return 'draconido';
    if (normalized.startsWith('semielf')) return 'semielfo';
    if (normalized.startsWith('semiorc')) return 'semiorco';
    if (normalized.startsWith('gnom')) return 'gnomo';
    if (normalized.startsWith('gith')) return 'githyanki';
    if (normalized.startsWith('tiefl')) return 'tiefling';
    if (normalized.startsWith('medi')) return 'mediano';
    if (normalized.startsWith('huma')) return 'humano';
    if (normalized.startsWith('enan')) return 'enano';
    if (normalized.startsWith('drow')) return 'drow';
    if (normalized.startsWith('elf')) return 'elfo';

    return normalized;
  }

  Widget _buildDefaultCard(Character c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        child: ListTile(
          title: Text(c.name),
          subtitle: Text('${c.charClass} | Nv.${c.level}'),
          onTap: () => _open(c),
          trailing: _buildDeleteButton(c, size: 42, iconSize: 20),
        ),
      ),
    );
  }

  Widget _buildRaceCard(Character c) {
    final raceKey = _resolveRaceKey(c.race);
    final imageAsset = _raceCardAssets[raceKey];
    if (imageAsset == null) return _buildDefaultCard(c);
    final cardKey = _characterFireKey(c);
    final fireActive = _fireCards.contains(cardKey);
    final flipped = _flippedCards.contains(cardKey);
    final remoteImageUrl = _remoteRaceCardUrls[raceKey];

    final borderColor = _raceBorderColors[raceKey] ?? const Color(0xFFBE8D37);
    final leftTint = _raceLeftTints[raceKey] ?? const Color(0xFF6A2C00);
    final imageFocus = _raceImageFocus[raceKey] ?? const Alignment(-0.10, 0.0);
    final imageZoom = _raceImageZoom[raceKey] ?? 1.03;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderColor, width: 1.8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _open(c),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: _buildFlippableRaceCard(
                flipped: flipped,
                front: _buildRaceCardFace(
                  c: c,
                  fireKey: cardKey,
                  fireActive: fireActive,
                  borderColor: borderColor,
                  leftTint: leftTint,
                  imageAsset: imageAsset,
                  remoteImageUrl: remoteImageUrl,
                  imageFocus: imageFocus,
                  imageZoom: imageZoom,
                  backSide: false,
                ),
                back: _buildRaceCardFace(
                  c: c,
                  fireKey: cardKey,
                  fireActive: fireActive,
                  borderColor: borderColor,
                  leftTint: leftTint,
                  imageAsset: imageAsset,
                  remoteImageUrl: remoteImageUrl,
                  imageFocus: imageFocus,
                  imageZoom: imageZoom,
                  backSide: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlippableRaceCard({
    required bool flipped,
    required Widget front,
    required Widget back,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: flipped ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeInOutCubic,
      builder: (context, value, _) {
        final angle = value * math.pi;
        final showFront = angle <= (math.pi / 2);
        final surface = showFront ? front : back;
        final rotationY = showFront ? angle : angle - math.pi;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(rotationY),
          child: surface,
        );
      },
    );
  }

  Widget _buildRaceCardFace({
    required Character c,
    required String fireKey,
    required bool fireActive,
    required Color borderColor,
    required Color leftTint,
    required String imageAsset,
    required String? remoteImageUrl,
    required Alignment imageFocus,
    required double imageZoom,
    required bool backSide,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _buildRaceImageLayer(
          localAsset: imageAsset,
          remoteImageUrl: remoteImageUrl,
          leftTint: leftTint,
          imageFocus: imageFocus,
          imageZoom: imageZoom,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                leftTint.withValues(alpha: backSide ? 0.86 : 0.92),
                leftTint.withValues(alpha: backSide ? 0.72 : 0.78),
                leftTint.withValues(alpha: backSide ? 0.24 : 0.34),
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.34, 0.62, 0.92],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black.withValues(alpha: backSide ? 0.18 : 0.08),
                Colors.black.withValues(alpha: backSide ? 0.40 : 0.14),
                Colors.black.withValues(alpha: backSide ? 0.90 : 0.84),
              ],
              stops: const <double>[0.0, 0.56, 1.0],
            ),
          ),
        ),
        const Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
            child: SizedBox(
              width: 116,
              height: 116,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 0.95,
                    colors: <Color>[
                      Color(0xE6000000),
                      Color(0x9C000000),
                      Color(0x00000000),
                    ],
                    stops: <double>[0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (fireActive)
          Positioned.fill(
            child: IgnorePointer(
              child: _CardFireOverlay(seed: fireKey),
            ),
          ),
        Positioned(
          top: _topRowInset,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderColor),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  c.race,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: _flipInsetTop,
          left: _flipInsetLeft,
          child: _buildFlipButton(c, active: backSide),
        ),
        Positioned(
          top: _flipInsetTop,
          left: _flipInsetLeft + _flipSize + _flipPairGap,
          child: _buildFireButton(
            c,
            active: fireActive,
            size: _flipSize,
            iconSize: _flipIconSize,
          ),
        ),
        Positioned(
          top: _deleteInset,
          right: _deleteInset,
          child: _buildDeleteButton(
            c,
            size: _flipSize,
            iconSize: _flipIconSize,
          ),
        ),
        if (backSide)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 52, 40, 24),
                child: _buildBackInfoPanel(c),
              ),
            ),
          )
        else
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.84),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      shadows: <Shadow>[
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${c.charClass} | Nivel ${c.level}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBackInfoPanel(Character c) {
    final subrace = c.subrace.trim();
    final raceLine = subrace.isEmpty ? c.race : '${c.race} - $subrace';
    final normalizedTraits = c.traits
        .map((trait) => trait.trim())
        .where((trait) => trait.isNotEmpty)
        .map((trait) => trait.replaceFirst(RegExp(r'^(i:|I:)\s*'), ''))
        .toList(growable: false);
    final traitsText = normalizedTraits.isEmpty
        ? '- Sin rasgos definidos'
        : normalizedTraits.map((trait) => '- $trait').join('\n');
    final competenciesText = c.competencies.isEmpty
        ? ''
        : '\n\nCompetencias: ${_compactList(c.competencies, maxItems: 4)}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.6,
            height: 1.2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Informacion',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '$raceLine\n${c.charClass} (Nv.${c.level})',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                'HP: ${c.hp}/${c.maxHp} | CA: ${c.ac} | Velocidad: ${c.speed}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Rasgos raciales:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  thickness: 3,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '$traitsText$competenciesText',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _compactList(List<String> values, {int maxItems = 4}) {
    final cleaned = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (cleaned.isEmpty) return 'Sin competencias';
    final visible = cleaned.take(maxItems).toList(growable: false);
    final suffix = cleaned.length > maxItems ? ', ...' : '';
    return '${visible.join(', ')}$suffix';
  }

  Widget _buildRaceImageLayer({
    required String localAsset,
    required String? remoteImageUrl,
    required Color leftTint,
    required Alignment imageFocus,
    required double imageZoom,
  }) {
    return ClipRect(
      child: Align(
        alignment: imageFocus,
        child: FractionallySizedBox(
          widthFactor: imageZoom,
          heightFactor: imageZoom,
          child: _buildRaceImage(
            localAsset: localAsset,
            remoteImageUrl: remoteImageUrl,
            leftTint: leftTint,
          ),
        ),
      ),
    );
  }

  Widget _buildRaceImage({
    required String localAsset,
    required String? remoteImageUrl,
    required Color leftTint,
  }) {
    final fallback = _buildRaceImageFallback(leftTint);
    final remoteUrl = (remoteImageUrl ?? '').trim();

    Widget localImage() => Image.asset(
          localAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        );

    if (remoteUrl.isEmpty) {
      return localImage();
    }

    if (!remoteUrl.startsWith('http')) {
      return Image.asset(
        remoteUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => localImage(),
      );
    }

    return Image.network(
      remoteUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return localImage();
      },
      errorBuilder: (_, __, ___) => localImage(),
    );
  }

  Widget _buildRaceImageFallback(Color leftTint) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            leftTint.withValues(alpha: 0.95),
            Colors.black.withValues(alpha: 0.72),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(
    Character c, {
    double size = _deleteSize,
    double iconSize = _deleteIconSize,
  }) {
    return _buildCardActionButton(
      tooltip: 'Borrar personaje',
      icon: Icons.delete,
      onTap: () => _confirmDelete(c),
      size: size,
      iconSize: iconSize,
      iconColor: _deleteIconColor,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildFlipButton(Character c, {required bool active}) {
    return _buildCardActionButton(
      tooltip: active ? 'Ver portada' : 'Ver informacion',
      icon: Icons.autorenew_rounded,
      onTap: () => _toggleCardFlip(c),
      iconColor: _deleteIconColor,
      iconSize: _flipIconSize,
      size: _flipSize,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildFireButton(
    Character c, {
    required bool active,
    double size = _deleteSize,
    double iconSize = _deleteIconSize,
  }) {
    return _buildCardActionButton(
      tooltip: active ? 'Quitar llamas' : 'Activar llamas',
      icon: Icons.local_fire_department_rounded,
      onTap: () => _toggleCardFire(c),
      iconColor: _deleteIconColor,
      iconSize: iconSize,
      size: size,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildCardActionButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
    required double size,
    required double iconSize,
    Color backgroundColor = const Color(0xDB000000),
  }) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    const fabArea = 140.0;
    final listBottom = safeBottom + fabArea;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: chars.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: _create,
                child: const Text('Crear personaje'),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(8, 16, 8, listBottom),
              itemCount: chars.length,
              itemBuilder: (context, i) {
                final c = chars[i];
                return _buildRaceCard(c);
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: (chars.isNotEmpty && _mostrarFlechaArriba)
                  ? FloatingActionButton.small(
                      key: const ValueKey('dnd_scroll_to_top'),
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
                  : const SizedBox.shrink(
                      key: ValueKey('dnd_no_scroll_to_top'),
                    ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _create,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFireOverlay extends StatefulWidget {
  const _CardFireOverlay({required this.seed});

  final String seed;

  @override
  State<_CardFireOverlay> createState() => _CardFireOverlayState();
}

class _CardFireOverlayState extends State<_CardFireOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_EmberParticle> _embers;
  double _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    final random = math.Random(widget.seed.hashCode);
    _embers = List<_EmberParticle>.generate(
      42,
      (_) => _EmberParticle(random),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        var delta = _controller.value - _lastValue;
        if (delta < 0) delta += 1;
        _lastValue = _controller.value;
        final durationSeconds =
            (_controller.duration?.inMilliseconds ?? 1800) / 1000.0;
        final dt = (delta * durationSeconds).clamp(0.0, 0.05);
        for (final ember in _embers) {
          ember.tick(dt);
        }
        return RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _FirePainter(
              embers: _embers,
              time: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _FirePainter extends CustomPainter {
  const _FirePainter({
    required this.embers,
    required this.time,
  });

  final List<_EmberParticle> embers;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = time * (2 * math.pi);

    _paintAmbientGlow(canvas, rect, t);

    _paintFlameBand(
      canvas: canvas,
      size: size,
      t: t,
      crest: 0.96,
      amplitude: 0.20,
      speed: 0.42,
      frequency: 2.3,
      core: const Color(0xFFFF5A00),
      mid: const Color(0xFFFF8C1A),
      blurSigma: 10,
      xBias: 0.70,
    );
    _paintFlameBand(
      canvas: canvas,
      size: size,
      t: t + 0.65,
      crest: 0.90,
      amplitude: 0.17,
      speed: 0.62,
      frequency: 2.9,
      core: const Color(0xFFFF7B00),
      mid: const Color(0xFFFFB74D),
      blurSigma: 8,
      xBias: 0.62,
    );
    _paintFlameBand(
      canvas: canvas,
      size: size,
      t: t + 1.2,
      crest: 0.85,
      amplitude: 0.13,
      speed: 0.82,
      frequency: 3.6,
      core: const Color(0xFFFFB347),
      mid: const Color(0xFFFFE082),
      blurSigma: 5,
      xBias: 0.55,
    );

    _paintFlameTongues(canvas, size, t);
    _paintEmbers(canvas, size);
  }

  void _paintAmbientGlow(Canvas canvas, Rect rect, double t) {
    final flicker = 0.9 + (math.sin(t * 1.9) * 0.1);
    final wideGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, 0.9),
        radius: 1.05,
        colors: <Color>[
          const Color(0xFFFF6A00).withValues(alpha: 0.20 * flicker),
          const Color(0xFFFFB347).withValues(alpha: 0.12 * flicker),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.56, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.plus;
    canvas.drawRect(rect, wideGlow);

    final lowFlare = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: <Color>[
          const Color(0xFFFF4A00).withValues(alpha: 0.24 * flicker),
          const Color(0xFFFFA726).withValues(alpha: 0.08 * flicker),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.32, 0.95],
      ).createShader(rect)
      ..blendMode = BlendMode.plus;
    canvas.drawRect(rect, lowFlare);
  }

  void _paintFlameBand({
    required Canvas canvas,
    required Size size,
    required double t,
    required double crest,
    required double amplitude,
    required double speed,
    required double frequency,
    required Color core,
    required Color mid,
    required double blurSigma,
    required double xBias,
  }) {
    final path = Path()..moveTo(0, size.height);
    const steps = 34;
    for (var i = 0; i <= steps; i++) {
      final nx = i / steps;
      final waveA = math.sin((nx * frequency + t * speed) * (2 * math.pi));
      final waveB = math.sin(
          (nx * (frequency * 0.57) - t * (speed * 1.35) + 0.33) *
              (2 * math.pi));
      final wave = (waveA * 0.62) + (waveB * 0.38);

      final distanceToHotspot = (nx - xBias).abs();
      final hotspotBoost = (1.0 - (distanceToHotspot / 0.72)).clamp(0.0, 1.0);
      final lift = size.height *
          amplitude *
          (0.40 + ((wave + 1) * 0.30)) *
          (0.72 + hotspotBoost * 0.48);
      final y = (size.height * crest - lift).clamp(
        size.height * 0.12,
        size.height * 0.98,
      );
      path.lineTo(nx * size.width, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: <Color>[
          core.withValues(alpha: 0.40),
          mid.withValues(alpha: 0.20),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.58, 1.0],
      ).createShader(Offset.zero & size)
      ..blendMode = BlendMode.plus
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawPath(path, paint);
  }

  void _paintFlameTongues(Canvas canvas, Size size, double t) {
    for (var i = 0; i < 8; i++) {
      final seed = (i + 1) * 0.77;
      final xBaseNorm = 0.08 + (i / 7) * 0.84;
      final sway = math.sin((t * (0.58 + ((i % 3) * 0.06))) + seed) * 0.035;
      final x = (xBaseNorm + sway).clamp(0.04, 0.96) * size.width;

      final baseY = size.height * (0.97 - ((i % 2) * 0.01));
      final width = size.width * (0.050 + ((i % 3) * 0.008));
      final riseFactor = 0.18 +
          0.09 * ((math.sin((t * 0.92) + seed * 1.6) + 1) * 0.5) +
          ((i.isEven ? 0.02 : 0.0));
      final height = size.height * riseFactor;
      final topY = (baseY - height).clamp(size.height * 0.18, size.height);

      final tonguePath = Path()
        ..moveTo(x - width, baseY)
        ..quadraticBezierTo(
          x - width * 0.52,
          baseY - height * 0.45,
          x,
          topY,
        )
        ..quadraticBezierTo(
          x + width * 0.50,
          baseY - height * 0.42,
          x + width,
          baseY,
        )
        ..close();

      final center = Offset(x, topY + height * 0.42);
      final radius = width * 1.9;
      final colorHot =
          i.isEven ? const Color(0xFFFFA000) : const Color(0xFFFF6A00);

      final paint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 1.0,
          colors: <Color>[
            const Color(0xFFFFF3C0).withValues(alpha: 0.42),
            colorHot.withValues(alpha: 0.30),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.56, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.8);
      canvas.drawPath(tonguePath, paint);
    }
  }

  void _paintEmbers(Canvas canvas, Size size) {
    final shortSide = size.shortestSide;
    for (final ember in embers) {
      final alpha = ember.alpha;
      if (alpha <= 0.02) continue;

      final radius = shortSide * ember.size;
      final center = Offset(
        ember.x * size.width,
        ember.y * size.height,
      );

      final glow = Paint()
        ..color = ember.color.withValues(alpha: alpha * 0.30)
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(center, radius * 2.4, glow);

      final streakEnd = center.translate(
        -ember.drift * size.width * 0.03,
        -radius * 2.8,
      );
      final streak = Paint()
        ..color = ember.color.withValues(alpha: alpha * 0.55)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = radius * 0.95
        ..blendMode = BlendMode.plus;
      canvas.drawLine(center, streakEnd, streak);

      final core = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.90)
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(center, radius * 0.78, core);
    }
  }

  @override
  bool shouldRepaint(covariant _FirePainter oldDelegate) => true;
}

class _EmberParticle {
  _EmberParticle(this._random) {
    _reset(initial: true);
  }

  final math.Random _random;
  late double x;
  late double y;
  late double size;
  late double speed;
  late double drift;
  late double life;
  late double maxLife;
  late double phase;
  late Color color;

  static const List<Color> _palette = <Color>[
    Color(0xFFFFF59D),
    Color(0xFFFFCA28),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
  ];

  void _reset({bool initial = false}) {
    x = _random.nextDouble();
    y = initial
        ? (_random.nextDouble() * 1.08)
        : (0.86 + _random.nextDouble() * 0.22);
    size = 0.0028 + _random.nextDouble() * 0.009;
    speed = 0.14 + _random.nextDouble() * 0.32;
    drift = (_random.nextDouble() - 0.5) * 0.18;
    maxLife = 0.8 + _random.nextDouble() * 1.5;
    life = _random.nextDouble() * maxLife * 0.6;
    phase = _random.nextDouble() * math.pi * 2;
    color = _palette[_random.nextInt(_palette.length)];
  }

  void tick(double dt) {
    life += dt;
    y -= speed * dt;
    x += (drift * dt) + (math.sin((life * 8.5) + phase) * 0.0018);
    if (y < -0.10 || life >= maxLife || x < -0.2 || x > 1.2) {
      _reset();
    }
  }

  double get alpha {
    final t = (life / maxLife).clamp(0.0, 1.0);
    final fadeIn = (t / 0.18).clamp(0.0, 1.0);
    final fadeOut = ((1 - t) / 0.72).clamp(0.0, 1.0);
    final flicker = 0.82 + (math.sin((life * 14.0) + phase) * 0.18);
    return (fadeIn * fadeOut * flicker).clamp(0.0, 1.0);
  }
}

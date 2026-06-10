import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

const _gold = Color(0xFFD4AF37);
const _arcane = Color(0xFF2A1A5E);
const _parchment = Color(0xFFF5E6C8);

const _schoolColors = {
  'Abjuration': Color(0xFF1565C0),
  'Conjuration': Color(0xFF6A1B9A),
  'Divination': Color(0xFF00838F),
  'Enchantment': Color(0xFFAD1457),
  'Evocation': Color(0xFFBF360C),
  'Illusion': Color(0xFF4527A0),
  'Necromancy': Color(0xFF1B5E20),
  'Transmutation': Color(0xFFE65100),
};

const _schoolIcons = {
  'Abjuration': '🛡️',
  'Conjuration': '🌀',
  'Divination': '🔮',
  'Enchantment': '💫',
  'Evocation': '⚡',
  'Illusion': '👁️',
  'Necromancy': '💀',
  'Transmutation': '⚗️',
};

const _levelOptions = ['Todos', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
const _schoolOptions = [
  'Todos', 'Abjuration', 'Conjuration', 'Divination', 'Enchantment',
  'Evocation', 'Illusion', 'Necromancy', 'Transmutation',
];

// ─── Modelos ──────────────────────────────────────────────────────────────────

class SpellSummary {
  final String index, name;
  SpellSummary({required this.index, required this.name});
  factory SpellSummary.fromJson(Map<String, dynamic> j) =>
      SpellSummary(index: j['index'] ?? '', name: j['name'] ?? '');
}

class SpellDetail {
  final String name, school, castingTime, range, duration, description;
  final int level;
  final List<String> components;
  final String? material, higherLevel;
  final bool ritual, concentration;
  final List<String> classes;

  SpellDetail({
    required this.name, required this.school, required this.castingTime,
    required this.range, required this.duration, required this.description,
    required this.level, required this.components, required this.ritual,
    required this.concentration, required this.classes,
    this.material, this.higherLevel,
  });

  factory SpellDetail.fromJson(Map<String, dynamic> j) {
    final descList = (j['desc'] as List?) ?? [];
    final description = descList.map((e) => e.toString()).join('\n\n');
    final higherList = (j['higher_level'] as List?) ?? [];
    final higherLevel = higherList.isNotEmpty ? higherList.join('\n') : null;
    final components = (j['components'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final classes = (j['classes'] as List?)?.map((e) => e['name']?.toString() ?? '').where((s) => s.isNotEmpty).toList() ?? [];

    return SpellDetail(
      name: j['name'] ?? '',
      school: j['school']?['name'] ?? '',
      castingTime: j['casting_time'] ?? '',
      range: j['range'] ?? '',
      duration: j['duration'] ?? '',
      description: description,
      level: j['level'] ?? 0,
      components: components,
      material: j['material'],
      ritual: j['ritual'] ?? false,
      concentration: j['concentration'] ?? false,
      higherLevel: higherLevel,
      classes: classes,
    );
  }
}

// ─── Servicio ─────────────────────────────────────────────────────────────────

class SpellsService {
  static const _base = 'https://www.dnd5eapi.co/api';

  static Future<List<SpellSummary>> fetchAll() async {
    final res = await http.get(Uri.parse('$_base/spells?limit=500'));
    if (res.statusCode != 200) throw Exception('Error cargando hechizos');
    final data = jsonDecode(res.body);
    return (data['results'] as List).map((e) => SpellSummary.fromJson(e)).toList();
  }

  static Future<SpellDetail> fetchDetail(String index) async {
    final res = await http.get(Uri.parse('$_base/spells/$index'));
    if (res.statusCode != 200) throw Exception('Error cargando hechizo');
    return SpellDetail.fromJson(jsonDecode(res.body));
  }

  // Obtiene nivel y escuela de todos los hechizos de una vez para filtrar localmente
  static Future<List<Map<String, dynamic>>> fetchAllWithMeta() async {
    final summaries = await fetchAll();
    return summaries.map((s) => {'index': s.index, 'name': s.name}).toList();
  }
}

// ─── Página principal ─────────────────────────────────────────────────────────

class SpellsPage extends StatefulWidget {
  const SpellsPage({super.key});
  @override
  State<SpellsPage> createState() => _SpellsPageState();
}

class _SpellsPageState extends State<SpellsPage> {
  List<SpellSummary> _all = [];
  List<SpellSummary> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  String _selectedLevel = 'Todos';
  String _selectedSchool = 'Todos';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await SpellsService.fetchAll();
      setState(() { _all = list; _filtered = list; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyFilters() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _all.where((s) {
        final matchesSearch = q.isEmpty || s.name.toLowerCase().contains(q);
        return matchesSearch;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() { _selectedLevel = 'Todos'; _selectedSchool = 'Todos'; });
    _searchCtrl.clear();
  }

  bool get _hasActiveFilters => _selectedLevel != 'Todos' || _selectedSchool != 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          if (_showFilters) _buildFilterPanel(),
          if (!_loading && _error == null) _buildResultCount(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _arcane.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: _gold, width: 2)),
      ),
      child: Column(
        children: [
          Text('✨  GRIMORIO  ✨',
              style: GoogleFonts.cinzelDecorative(fontSize: 22, fontWeight: FontWeight.bold, color: _gold, letterSpacing: 4)),
          const SizedBox(height: 4),
          Text('Hechizos y Conjuros de los Reinos',
              style: GoogleFonts.cinzel(fontSize: 11, color: _gold.withValues(alpha: 0.75), letterSpacing: 2)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar hechizo...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.auto_fix_high, color: _gold),
                    filled: true, fillColor: Colors.black45,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gold)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _gold.withValues(alpha: 0.5))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gold, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _showFilters = !_showFilters),
                    icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list,
                        color: _hasActiveFilters ? Colors.amber : _gold),
                    tooltip: 'Filtros',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: _hasActiveFilters ? Colors.amber : _gold.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  if (_hasActiveFilters)
                    Positioned(right: 6, top: 6,
                        child: Container(width: 8, height: 8,
                            decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        border: const Border(bottom: BorderSide(color: _gold, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NIVEL DEL HECHIZO', style: GoogleFonts.cinzel(fontSize: 10, color: _gold, letterSpacing: 2)),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _levelOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final lvl = _levelOptions[i];
                final selected = _selectedLevel == lvl;
                final label = lvl == '0' ? 'Truco' : lvl == 'Todos' ? 'Todos' : 'Nv $lvl';
                return GestureDetector(
                  onTap: () { setState(() => _selectedLevel = lvl); _applyFilters(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? _gold : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? _gold : _gold.withValues(alpha: 0.3)),
                    ),
                    child: Text(label,
                        style: TextStyle(fontSize: 11, color: selected ? Colors.black : Colors.white70,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text('ESCUELA DE MAGIA', style: GoogleFonts.cinzel(fontSize: 10, color: _gold, letterSpacing: 2)),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _schoolOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final school = _schoolOptions[i];
                final selected = _selectedSchool == school;
                final emoji = _schoolIcons[school] ?? '';
                final color = _schoolColors[school] ?? _arcane;
                return GestureDetector(
                  onTap: () { setState(() => _selectedSchool = school); _applyFilters(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? color : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? color : _gold.withValues(alpha: 0.3)),
                    ),
                    child: Text(school == 'Todos' ? 'Todos' : '$emoji $school',
                        style: TextStyle(fontSize: 11, color: selected ? Colors.white : Colors.white70,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              },
            ),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.clear, size: 14, color: Colors.red),
                label: const Text('Limpiar filtros', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.black.withValues(alpha: 0.3),
      child: Row(children: [
        Icon(Icons.auto_stories, size: 14, color: _gold.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text('${_filtered.length} hechizo${_filtered.length == 1 ? '' : 's'}',
            style: GoogleFonts.cinzel(fontSize: 11, color: _gold.withValues(alpha: 0.6))),
      ]),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: _gold), const SizedBox(height: 16),
        Text('Abriendo el grimorio...', style: GoogleFonts.cinzel(color: _gold)),
      ]));
    }
    if (_error != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off, size: 48, color: Colors.red), const SizedBox(height: 12),
        Text('No se pudo contactar\ncon el plano arcano', textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
          icon: const Icon(Icons.refresh), label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(backgroundColor: _arcane, foregroundColor: _gold),
        ),
      ]));
    }
    if (_filtered.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔍', style: TextStyle(fontSize: 48)), const SizedBox(height: 12),
        Text('Ningún hechizo encontrado', style: GoogleFonts.cinzel(color: _gold)),
        const SizedBox(height: 8),
        TextButton(onPressed: _resetFilters, child: const Text('Limpiar filtros', style: TextStyle(color: _gold))),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filtered.length,
      itemBuilder: (context, i) => _SpellTile(spell: _filtered[i]),
    );
  }
}

// ─── Tile de hechizo ──────────────────────────────────────────────────────────

class _SpellTile extends StatelessWidget {
  final SpellSummary spell;
  const _SpellTile({required this.spell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _gold.withValues(alpha: 0.35)),
      ),
      child: ListTile(
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _arcane.withValues(alpha: 0.8), border: Border.all(color: _gold, width: 1.5)),
          child: const Center(child: Text('✨', style: TextStyle(fontSize: 18))),
        ),
        title: Text(spell.name,
            style: GoogleFonts.cinzel(fontWeight: FontWeight.w600, fontSize: 14,
                color: isDark ? Colors.white : Colors.black87)),
        trailing: const Icon(Icons.chevron_right, color: _gold),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => SpellDetailPage(index: spell.index, name: spell.name),
        )),
      ),
    );
  }
}

// ─── Página de detalle del hechizo ────────────────────────────────────────────

class SpellDetailPage extends StatefulWidget {
  final String index, name;
  const SpellDetailPage({super.key, required this.index, required this.name});
  @override
  State<SpellDetailPage> createState() => _SpellDetailPageState();
}

class _SpellDetailPageState extends State<SpellDetailPage> {
  SpellDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final d = await SpellsService.fetchDetail(widget.index);
      setState(() { _detail = d; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schoolColor = _detail != null
        ? (_schoolColors[_detail!.school] ?? _arcane)
        : _arcane;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0820) : _parchment,
      appBar: AppBar(
        backgroundColor: schoolColor,
        foregroundColor: _gold,
        title: Text(widget.name.toUpperCase(),
            style: GoogleFonts.cinzel(color: _gold, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: _loading
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CircularProgressIndicator(color: _gold), const SizedBox(height: 16),
              Text('Descifrando el conjuro...', style: GoogleFonts.cinzel(color: _gold)),
            ]))
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _buildDetail(isDark),
    );
  }

  Widget _buildDetail(bool isDark) {
    final d = _detail!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.75);
    final schoolColor = _schoolColors[d.school] ?? _arcane;
    final schoolEmoji = _schoolIcons[d.school] ?? '✨';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Cabecera nivel + escuela
        Center(
          child: Column(children: [
            Text(schoolEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: schoolColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _gold, width: 1.5),
              ),
              child: Text(
                d.level == 0 ? '${d.school} • Truco' : '${d.school} • Nivel ${d.level}',
                style: GoogleFonts.cinzel(color: _gold, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            // Tags ritual/concentración
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (d.ritual) _tag('Ritual', Colors.teal),
              if (d.ritual && d.concentration) const SizedBox(width: 8),
              if (d.concentration) _tag('Concentración', Colors.deepOrange),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Ficha rápida
        Container(
          decoration: BoxDecoration(
            color: schoolColor.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _gold, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _infoBadge('⏱', 'Tiempo', d.castingTime),
            _vDiv(),
            _infoBadge('📏', 'Alcance', d.range),
            _vDiv(),
            _infoBadge('⏳', 'Duración', d.duration),
          ]),
        ),
        const SizedBox(height: 16),

        // Componentes
        _secTitle('Componentes'),
        Card(color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: _gold.withValues(alpha: 0.4))),
          child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: d.components.map((c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: schoolColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _gold.withValues(alpha: 0.5)),
                ),
                child: Text(c, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              ),
            )).toList()),
            if (d.material != null) ...[
              const SizedBox(height: 8),
              Text('Material: ${d.material}', style: TextStyle(color: textColor, fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ])),
        ),
        const SizedBox(height: 16),

        // Descripción
        _secTitle('Descripción'),
        Card(color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: _gold.withValues(alpha: 0.4))),
          child: Padding(padding: const EdgeInsets.all(12),
            child: Text(d.description, style: TextStyle(color: textColor, fontSize: 13, height: 1.5)),
          ),
        ),

        // A niveles superiores
        if (d.higherLevel != null) ...[
          const SizedBox(height: 16),
          _secTitle('A niveles superiores'),
          Card(color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: _gold.withValues(alpha: 0.4))),
            child: Padding(padding: const EdgeInsets.all(12),
              child: Text(d.higherLevel!, style: TextStyle(color: textColor, fontSize: 13, height: 1.5)),
            ),
          ),
        ],

        // Clases que pueden usar el hechizo
        if (d.classes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _secTitle('Clases'),
          Wrap(spacing: 8, runSpacing: 6,
            children: d.classes.map((c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: schoolColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withValues(alpha: 0.5)),
              ),
              child: Text(c, style: TextStyle(color: textColor, fontSize: 12)),
            )).toList(),
          ),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _tag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  Widget _infoBadge(String emoji, String label, String value) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)),
    const SizedBox(height: 2),
    Text(label, style: GoogleFonts.cinzel(color: _gold.withValues(alpha: 0.75), fontSize: 10)),
    const SizedBox(height: 2),
    Text(value, textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
  ]);

  Widget _vDiv() => Container(width: 1, height: 50, color: _gold.withValues(alpha: 0.4));

  Widget _secTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(title.toUpperCase(),
        style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: _gold, letterSpacing: 2)),
  );
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

const _gold = Color(0xFFD4AF37);
const _blood = Color(0xFF8B1A1A);
const _parchment = Color(0xFFF5E6C8);

const _typeIcons = {
  'aberration': '🐙',
  'beast': '🐺',
  'celestial': '✨',
  'construct': '⚙️',
  'dragon': '🐉',
  'elemental': '🌊',
  'fey': '🧚',
  'fiend': '👿',
  'giant': '🗿',
  'humanoid': '🧙',
  'monstrosity': '👾',
  'ooze': '🫧',
  'plant': '🌿',
  'undead': '💀',
};

const _crOptions = [
  'Todos','0','1/8','1/4','1/2','1','2','3','4','5','6','7','8','9','10',
  '11','12','13','14','15','16','17','18','19','20','21','22','23','24','30',
];

const _typeOptions = [
  'Todos','aberration','beast','celestial','construct','dragon','elemental',
  'fey','fiend','giant','humanoid','monstrosity','ooze','plant','undead',
];

// ─── Modelos ──────────────────────────────────────────────────────────────────

class MonsterSummary {
  final String index;
  final String name;
  final String type;
  final double cr;
  MonsterSummary({required this.index, required this.name, required this.type, required this.cr});
  factory MonsterSummary.fromJson(Map<String, dynamic> j) => MonsterSummary(
        index: j['index'] ?? '',
        name: j['name'] ?? '',
        type: j['type'] ?? '',
        cr: (j['challenge_rating'] as num?)?.toDouble() ?? 0,
      );
}

class MonsterDetail {
  final String name, size, type, alignment, hitDice, cr;
  final int ac, hp, str, dex, con, int_, wis, cha;
  final List<String> speeds, actions;
  final String? imageUrl;
  MonsterDetail({
    required this.name, required this.size, required this.type,
    required this.alignment, required this.ac, required this.hp,
    required this.hitDice, required this.cr, required this.str,
    required this.dex, required this.con, required this.int_,
    required this.wis, required this.cha, required this.speeds,
    required this.actions, this.imageUrl,
  });
  factory MonsterDetail.fromJson(Map<String, dynamic> j) {
    final acList = j['armor_class'] as List? ?? [];
    final acVal = acList.isNotEmpty ? (acList[0]['value'] ?? 0) : 0;
    final speedMap = (j['speed'] as Map<String, dynamic>?) ?? {};
    final speeds = speedMap.entries.map((e) => '${e.key}: ${e.value}').toList();
    final actionsList = (j['actions'] as List?) ?? [];
    final actions = actionsList.map((a) => a['name']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    return MonsterDetail(
      name: j['name'] ?? '', size: j['size'] ?? '', type: j['type'] ?? '',
      alignment: j['alignment'] ?? '', ac: acVal, hp: j['hit_points'] ?? 0,
      hitDice: j['hit_points_roll'] ?? '', cr: j['challenge_rating']?.toString() ?? '?',
      str: j['strength'] ?? 0, dex: j['dexterity'] ?? 0, con: j['constitution'] ?? 0,
      int_: j['intelligence'] ?? 0, wis: j['wisdom'] ?? 0, cha: j['charisma'] ?? 0,
      speeds: speeds, actions: actions,
      imageUrl: j['image'] != null ? 'https://www.dnd5eapi.co${j['image']}' : null,
    );
  }
}

// ─── Servicio ─────────────────────────────────────────────────────────────────

class BestiaryService {
  static const _base = 'https://www.dnd5eapi.co/api';
  static Future<List<MonsterSummary>> fetchAll() async {
    final res = await http.get(Uri.parse('$_base/monsters?limit=500'));
    if (res.statusCode != 200) throw Exception('Error cargando bestiario');
    final data = jsonDecode(res.body);
    return (data['results'] as List).map((e) => MonsterSummary.fromJson(e)).toList();
  }
  static Future<MonsterDetail> fetchDetail(String index) async {
    final res = await http.get(Uri.parse('$_base/monsters/$index'));
    if (res.statusCode != 200) throw Exception('Error cargando monstruo');
    return MonsterDetail.fromJson(jsonDecode(res.body));
  }
}

// ─── Página principal ─────────────────────────────────────────────────────────

class BestiaryPage extends StatefulWidget {
  const BestiaryPage({super.key});
  @override
  State<BestiaryPage> createState() => _BestiaryPageState();
}

class _BestiaryPageState extends State<BestiaryPage> {
  List<MonsterSummary> _all = [];
  List<MonsterSummary> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  String _selectedType = 'Todos';
  String _selectedCr = 'Todos';
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
      final list = await BestiaryService.fetchAll();
      setState(() { _all = list; _filtered = list; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  double _crToDouble(String cr) {
    switch (cr) {
      case '1/8': return 0.125;
      case '1/4': return 0.25;
      case '1/2': return 0.5;
      default: return double.tryParse(cr) ?? 0;
    }
  }

  void _applyFilters() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _all.where((m) {
        final matchesSearch = q.isEmpty || m.name.toLowerCase().contains(q);
        final matchesType = _selectedType == 'Todos' || m.type == _selectedType;
        final matchesCr = _selectedCr == 'Todos' || _crToDouble(_selectedCr) == m.cr;
        return matchesSearch && matchesType && matchesCr;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() { _selectedType = 'Todos'; _selectedCr = 'Todos'; });
    _searchCtrl.clear();
  }

  bool get _hasActiveFilters => _selectedType != 'Todos' || _selectedCr != 'Todos';

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
        color: _blood.withValues(alpha: 0.85),
        border: const Border(bottom: BorderSide(color: _gold, width: 2)),
      ),
      child: Column(
        children: [
          Text('⚔  BESTIARIO  ⚔',
              style: GoogleFonts.cinzelDecorative(fontSize: 22, fontWeight: FontWeight.bold, color: _gold, letterSpacing: 4)),
          const SizedBox(height: 4),
          Text('Criaturas de los Reinos Olvidados',
              style: GoogleFonts.cinzel(fontSize: 11, color: _gold.withValues(alpha: 0.75), letterSpacing: 2)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar criatura...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: _gold),
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
                    Positioned(
                      right: 6, top: 6,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      ),
                    ),
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
          Text('TIPO DE CRIATURA', style: GoogleFonts.cinzel(fontSize: 10, color: _gold, letterSpacing: 2)),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _typeOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final t = _typeOptions[i];
                final selected = _selectedType == t;
                final emoji = _typeIcons[t] ?? '';
                return GestureDetector(
                  onTap: () { setState(() => _selectedType = t); _applyFilters(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? _gold : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? _gold : _gold.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      t == 'Todos' ? 'Todos' : '$emoji ${_capitalize(t)}',
                      style: TextStyle(fontSize: 11, color: selected ? Colors.black : Colors.white70,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text('NIVEL DE DESAFÍO (CR)', style: GoogleFonts.cinzel(fontSize: 10, color: _gold, letterSpacing: 2)),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _crOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final cr = _crOptions[i];
                final selected = _selectedCr == cr;
                return GestureDetector(
                  onTap: () { setState(() => _selectedCr = cr); _applyFilters(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? _blood : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? _blood : _gold.withValues(alpha: 0.3)),
                    ),
                    child: Text('CR $cr',
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
      child: Row(
        children: [
          Icon(Icons.format_list_numbered, size: 14, color: _gold.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text('${_filtered.length} criatura${_filtered.length == 1 ? '' : 's'}',
              style: GoogleFonts.cinzel(fontSize: 11, color: _gold.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: _gold), const SizedBox(height: 16),
        Text('Consultando el grimorio...', style: GoogleFonts.cinzel(color: _gold)),
      ]));
    }
    if (_error != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off, size: 48, color: Colors.red), const SizedBox(height: 12),
        Text('No se pudo conectar\ncon el oráculo', textAlign: TextAlign.center, style: GoogleFonts.cinzel(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
          icon: const Icon(Icons.refresh), label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(backgroundColor: _blood, foregroundColor: _gold),
        ),
      ]));
    }
    if (_filtered.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔍', style: TextStyle(fontSize: 48)), const SizedBox(height: 12),
        Text('Ninguna criatura encontrada', style: GoogleFonts.cinzel(color: _gold)),
        const SizedBox(height: 8),
        TextButton(onPressed: _resetFilters, child: const Text('Limpiar filtros', style: TextStyle(color: _gold))),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filtered.length,
      itemBuilder: (context, i) => _MonsterTile(monster: _filtered[i]),
    );
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _MonsterTile extends StatelessWidget {
  final MonsterSummary monster;
  const _MonsterTile({required this.monster});

  String get _crLabel {
    final cr = monster.cr;
    if (cr == 0.125) return '1/8';
    if (cr == 0.25) return '1/4';
    if (cr == 0.5) return '1/2';
    if (cr == cr.truncateToDouble()) return cr.toInt().toString();
    return cr.toString();
  }

  Color get _crColor {
    final cr = monster.cr;
    if (cr <= 1) return Colors.green;
    if (cr <= 5) return Colors.yellow;
    if (cr <= 10) return Colors.orange;
    if (cr <= 20) return Colors.red;
    return Colors.purple;
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emoji = _typeIcons[monster.type] ?? '👾';
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
          decoration: BoxDecoration(shape: BoxShape.circle, color: _blood.withValues(alpha: 0.8), border: Border.all(color: _gold, width: 1.5)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
        ),
        title: Text(monster.name,
            style: GoogleFonts.cinzel(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text(_capitalize(monster.type),
            style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: _crColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _crColor, width: 1),
              ),
              child: Text('CR $_crLabel', style: TextStyle(fontSize: 10, color: _crColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: _gold),
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => MonsterDetailPage(index: monster.index, name: monster.name),
        )),
      ),
    );
  }
}

// ─── Detalle ──────────────────────────────────────────────────────────────────

class MonsterDetailPage extends StatefulWidget {
  final String index, name;
  const MonsterDetailPage({super.key, required this.index, required this.name});
  @override
  State<MonsterDetailPage> createState() => _MonsterDetailPageState();
}

class _MonsterDetailPageState extends State<MonsterDetailPage> {
  MonsterDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final d = await BestiaryService.fetchDetail(widget.index);
      setState(() { _detail = d; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A0F00) : _parchment,
      appBar: AppBar(
        backgroundColor: _blood, foregroundColor: _gold,
        title: Text(widget.name.toUpperCase(),
            style: GoogleFonts.cinzel(color: _gold, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: _loading
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CircularProgressIndicator(color: _gold), const SizedBox(height: 16),
              Text('Invocando ficha...', style: GoogleFonts.cinzel(color: _gold)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (d.imageUrl != null)
          Center(child: ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.network(d.imageUrl!, height: 200, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()))),
        const SizedBox(height: 12),
        Center(child: Text('${d.size} ${d.type} • ${d.alignment}',
            style: GoogleFonts.cinzel(fontSize: 13, fontStyle: FontStyle.italic, color: _gold))),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: _blood.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(10), border: Border.all(color: _gold, width: 1.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _statBadge('CA', '${d.ac}'),
            _vDiv(),
            _statBadge('HP', '${d.hp}\n${d.hitDice}'),
            _vDiv(),
            _statBadge('CR', d.cr),
          ]),
        ),
        const SizedBox(height: 16),
        _secTitle('Atributos'),
        Card(color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: _gold.withValues(alpha: 0.4))),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _attrBox('FUE', d.str, textColor), _attrBox('DES', d.dex, textColor),
              _attrBox('CON', d.con, textColor), _attrBox('INT', d.int_, textColor),
              _attrBox('SAB', d.wis, textColor), _attrBox('CAR', d.cha, textColor),
            ]),
          ),
        ),
        if (d.speeds.isNotEmpty) ...[
          const SizedBox(height: 16),
          _secTitle('Movimiento'),
          Card(color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: _gold.withValues(alpha: 0.4))),
            child: Padding(padding: const EdgeInsets.all(12),
              child: Wrap(spacing: 16, runSpacing: 4,
                children: d.speeds.map((s) => Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.directions_run, size: 16, color: _gold), const SizedBox(width: 4),
                  Text(s, style: TextStyle(color: textColor, fontSize: 13)),
                ])).toList(),
              ),
            ),
          ),
        ],
        if (d.actions.isNotEmpty) ...[
          const SizedBox(height: 16),
          _secTitle('Acciones'),
          Card(color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: _gold.withValues(alpha: 0.4))),
            child: Padding(padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: d.actions.map((a) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('⚔ ', style: TextStyle(color: _gold)),
                    Expanded(child: Text(a, style: TextStyle(color: textColor, fontSize: 13))),
                  ]),
                )).toList(),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _statBadge(String label, String value) => Column(children: [
    Text(label, style: GoogleFonts.cinzel(color: _gold.withValues(alpha: 0.75), fontSize: 11)),
    const SizedBox(height: 2),
    Text(value, textAlign: TextAlign.center, style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
  ]);

  Widget _vDiv() => Container(width: 1, height: 36, color: _gold.withValues(alpha: 0.4));

  Widget _attrBox(String label, int val, Color textColor) {
    final mod = (val - 10) ~/ 2;
    return Column(children: [
      Text(label, style: GoogleFonts.cinzel(fontSize: 10, color: _gold, fontWeight: FontWeight.bold)),
      Text('$val', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
      Text(mod >= 0 ? '+$mod' : '$mod', style: TextStyle(fontSize: 11, color: mod >= 0 ? Colors.green : Colors.red)),
    ]);
  }

  Widget _secTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(title.toUpperCase(), style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: _gold, letterSpacing: 2)),
  );
}

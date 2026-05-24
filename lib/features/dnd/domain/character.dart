class Character {
  String id;
  String name;
  String race;
  String subrace;
  String charClass;
  String subclass;
  int level;

  /// Niveles por clase para multiclase (p.ej. {"Mago": 2, "Guerrero": 1}).
  /// Si está vacío, se asume una sola clase: [charClass] con nivel [level].
  Map<String, int> classLevels;
  int hp;
  int maxHp;
  int ac;
  int speed;
  Map<String, int> attributes;
  List<String> competencies;
  List<Map<String, String>> spells;
  List<Map<String, String>> items;
  List<String> traits;

  Character({
    required this.id,
    required this.name,
    required this.race,
    this.subrace = '',
    required this.charClass,
    this.subclass = '',
    this.level = 1,
    Map<String, int>? classLevels,
    this.hp = 0,
    this.maxHp = 0,
    this.ac = 10,
    this.speed = 30,
    required this.attributes,
    this.competencies = const [],
    this.spells = const [],
    this.items = const [],
    this.traits = const [],
  }) : classLevels = classLevels ?? const {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'race': race,
        'subrace': subrace,
        'charClass': charClass,
        'subclass': subclass,
        'level': level,
        'classLevels': classLevels,
        'hp': hp,
        'maxHp': maxHp,
        'ac': ac,
        'speed': speed,
        'attributes': attributes,
        'competencies': competencies,
        'spells': spells,
        'items': items,
        'traits': traits,
      };

  factory Character.fromJson(Map<String, dynamic> json) {
    final parsedClassLevels = <String, int>{};
    final rawClassLevels = json['classLevels'];
    if (rawClassLevels is Map) {
      rawClassLevels.forEach((k, v) {
        final key = k?.toString();
        if (key == null || key.trim().isEmpty) return;
        if (v is num) {
          parsedClassLevels[key] = v.toInt();
        } else if (v is String) {
          parsedClassLevels[key] = int.tryParse(v) ?? 0;
        }
      });
      // Limpieza de entradas inválidas
      parsedClassLevels.removeWhere((_, v) => v <= 0);
    }

    final rawAttributes = json['attributes'] ?? {};
    final Map<String, int> parsedAttributes = {};
    rawAttributes.forEach((key, value) {
      if (value is String) {
        parsedAttributes[key] = int.tryParse(value) ?? 10;
      } else if (value is num) {
        parsedAttributes[key] = value.toInt();
      } else {
        parsedAttributes[key] = 10;
      }
    });

    final rawSpells = json['spells'] ?? [];
    final parsedSpells = rawSpells.map<Map<String, String>>((spell) {
      if (spell is Map) {
        final parsed = <String, String>{
          'name': spell['name']?.toString() ?? '',
          'desc': spell['desc']?.toString() ?? '',
        };
        final sourceClass = spell['class']?.toString().trim() ?? '';
        if (sourceClass.isNotEmpty) {
          parsed['class'] = sourceClass;
        }
        return parsed;
      } else if (spell is String) {
        return {'name': spell, 'desc': ''};
      } else {
        return {'name': '', 'desc': ''};
      }
    }).toList();

    final rawItems = json['items'] ?? [];
    final parsedItems = rawItems.map<Map<String, String>>((item) {
      if (item is Map) {
        final parsed = <String, String>{
          'name': item['name']?.toString() ?? '',
          'desc': item['desc']?.toString() ?? '',
        };
        final sourceClass = item['class']?.toString().trim() ?? '';
        if (sourceClass.isNotEmpty) {
          parsed['class'] = sourceClass;
        }
        return parsed;
      } else if (item is String) {
        return {'name': item, 'desc': ''};
      } else {
        return {'name': '', 'desc': ''};
      }
    }).toList();

    // Normalizamos el nivel a int SIEMPRE para evitar inferencias de tipo "dynamic"
    // que rompan la asignación de `classLevels` (Map<String,int>).
    final dynamic rawLevel = json['level'];
    final int levelFromJson;
    if (rawLevel is int) {
      levelFromJson = rawLevel;
    } else if (rawLevel is num) {
      levelFromJson = rawLevel.toInt();
    } else if (rawLevel is String) {
      levelFromJson = int.tryParse(rawLevel) ?? 1;
    } else {
      levelFromJson = 1;
    }

    final int computedTotalLevel = parsedClassLevels.isNotEmpty
        ? parsedClassLevels.values.fold<int>(0, (a, b) => a + b)
        : levelFromJson;

    final charClass = json['charClass']?.toString() ?? '';
    final Map<String, int> normalizedClassLevels = parsedClassLevels.isNotEmpty
        ? parsedClassLevels
        : (charClass.isNotEmpty
            ? <String, int>{charClass: computedTotalLevel}
            : <String, int>{});

    final List<String> parsedCompetencies = (json['competencies'] is List)
        ? (json['competencies'] as List)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.trim().isNotEmpty)
            .toList()
        : const <String>[];

    final List<String> parsedTraits = (json['traits'] is List)
        ? (json['traits'] as List)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.trim().isNotEmpty)
            .toList()
        : const <String>[];

    final int parsedHp = (json['hp'] is String)
        ? int.tryParse(json['hp']) ?? 0
        : (json['hp'] ?? 0);

    final int parsedMaxHp = (json['maxHp'] is String)
        ? int.tryParse(json['maxHp']) ?? parsedHp
        : (json['maxHp'] ?? parsedHp);

    final int normalizedMaxHp = parsedMaxHp <= 0 ? parsedHp : parsedMaxHp;

    return Character(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      race: json['race']?.toString() ?? '',
      subrace: json['subrace']?.toString() ?? '',
      charClass: charClass,
      subclass: json['subclass']?.toString() ?? '',
      level: computedTotalLevel,
      classLevels: normalizedClassLevels,
      hp: parsedHp,
      maxHp: normalizedMaxHp,
      ac: (json['ac'] is String)
          ? int.tryParse(json['ac']) ?? 10
          : (json['ac'] ?? 10),
      speed: (json['speed'] is String)
          ? int.tryParse(json['speed']) ?? 30
          : (json['speed'] ?? 30),
      attributes: parsedAttributes,
      competencies: parsedCompetencies,
      spells: parsedSpells,
      items: parsedItems,
      traits: parsedTraits,
    );
  }
}

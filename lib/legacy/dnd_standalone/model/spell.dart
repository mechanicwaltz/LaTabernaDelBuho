class Spell {
  String name;
  String description;

  Spell({
    required this.name,
    this.description = '',
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  // Crear desde JSON
  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

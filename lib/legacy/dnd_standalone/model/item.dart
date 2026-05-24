class Item {
  String name;
  String description;

  Item({
    required this.name,
    this.description = '',
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  // Crear desde JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

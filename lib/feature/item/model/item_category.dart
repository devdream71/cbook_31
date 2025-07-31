 



class ItemCategory {
  final int id;
  final String name;
  final int status;

  ItemCategory({
    required this.id,
    required this.name,
    required this.status,
  });

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      status: json['status'] ?? 0,
    );
  }

  static List<ItemCategory> fromJsonMap(Map<String, dynamic> jsonMap) {
    return jsonMap.values
        .map((item) => ItemCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

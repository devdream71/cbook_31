

class ItemCategoryModel {
  final int id;
  final int userId;
  final String name;
  final int status;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  ItemCategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.status,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      status: json['status'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  static List<ItemCategoryModel> fromJsonList(Map<String, dynamic> json) {
    return json.entries.map((entry) {
      return ItemCategoryModel.fromJson(entry.value);
    }).toList();
  }
}

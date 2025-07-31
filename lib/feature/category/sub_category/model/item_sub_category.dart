class ItemSubCategory {
  final int id;
  final int userId;
  final int itemCategoryId;
  final String name;
  final int status;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemSubCategory({
    required this.id,
    required this.userId,
    required this.itemCategoryId,
    required this.name,
    required this.status,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  

 factory ItemSubCategory.fromJson(Map<String, dynamic> json) {
  return ItemSubCategory(
    id: json['id'], // Already an int
    userId: int.parse(json['user_id'].toString()), // Convert to int
    itemCategoryId: int.parse(json['item_category_id'].toString()), // Convert to int
    name: json['name'],
    status: int.parse(json['status'].toString()), // Convert to int
    deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
}


  static List<ItemSubCategory> fromJsonList(Map<String, dynamic> jsonMap) {
    return jsonMap.values.map((e) => ItemSubCategory.fromJson(e)).toList();
  }
}

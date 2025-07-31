class CategoryCreateResponse {
  final bool success;
  final String message;
  final ItemCategoryModel data;

  CategoryCreateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryCreateResponse.fromJson(Map<String, dynamic> json) {
    return CategoryCreateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ItemCategoryModel.fromJson(json['data']),
    );
  }
}

class ItemCategoryModel {
  final int id;
  final String userId;
  final String name;
  final String status;
  final String createdAt;
  final String updatedAt;

  ItemCategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  static List<ItemCategoryModel> fromJsonList(Map<String, dynamic> json) {
    return json.entries.map((entry) {
      return ItemCategoryModel.fromJson(entry.value);
    }).toList();
  }
}

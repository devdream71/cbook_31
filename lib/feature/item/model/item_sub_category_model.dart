class SubCategoryModel {
  final int id;
  final int itemCategoryId;
  final String name;
  final int status;

  SubCategoryModel({
    required this.id,
    required this.itemCategoryId,
    required this.name,
    required this.status,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'],
      itemCategoryId: int.tryParse(json['item_category_id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown',
      status: json['status'] ?? 0,
    );
  }

  static List<SubCategoryModel> fromJsonList(Map<String, dynamic> jsonData) {
    return jsonData.entries
        .map((entry) => SubCategoryModel.fromJson(entry.value))
        .toList();
  }
}

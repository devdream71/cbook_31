class SubcategoryEditResponse {
  final int categoryId;
  final String name;
  final int status;

  SubcategoryEditResponse({
    required this.categoryId,
    required this.name,
    required this.status,
  });

  factory SubcategoryEditResponse.fromJson(Map<String, dynamic> json) {
    return SubcategoryEditResponse(
      categoryId: int.parse(json['category_id'].toString()),
      name: json['name'],
      status: json['status'],
    );
  }
}

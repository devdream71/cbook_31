class EditCategoryModel {
  final String name;
  final int status;

  EditCategoryModel({required this.name, required this.status});

  factory EditCategoryModel.fromJson(Map<String, dynamic> json) {
    return EditCategoryModel(
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

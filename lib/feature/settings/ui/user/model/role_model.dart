class RoleModel {
  final int id;
  final String name;
  final int status;

  RoleModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      status: json['status'],
    );
  }
}
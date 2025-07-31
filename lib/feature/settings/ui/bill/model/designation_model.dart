class DesignationModel {
  final int id;
  final String name;
  final int status;

  DesignationModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json['id'],
      name: json['name'],
      status: json['status'],
    );
  }
}

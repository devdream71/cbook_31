class TaxModel {
  final int id;
  final int userId;
  final String name;
  final String percent;
  final int status;

  TaxModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.percent,
    required this.status,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      percent: json['percent'],
      status: json['status'],
    );
  }
}
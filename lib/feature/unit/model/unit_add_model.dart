class UnitAddResponseModel {
  final int id;
  final String name;
  final String symbol;
  final String status;
  final String createdAt;
  final String updatedAt;

  UnitAddResponseModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UnitAddResponseModel.fromJson(Map<String, dynamic> json) {
    return UnitAddResponseModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      status: json['status'].toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

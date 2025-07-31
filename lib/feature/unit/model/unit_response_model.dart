class UnitResponseModel {
  final int id;
  final String name;
  final String symbol;
  final dynamic status;

  UnitResponseModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.status,
  });

  factory UnitResponseModel.fromJson(Map<String, dynamic> json) {
    return UnitResponseModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      status: json['status'],
    );
  }
}

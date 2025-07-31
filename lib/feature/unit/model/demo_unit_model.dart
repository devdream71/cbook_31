class DemoUnitModel {
  final int ? id;
  final String ?name;
  final String ?symbol;
  final String ?status;
  final String ?createdAt;
  final String ?updatedAt;

  DemoUnitModel({
     this.id,
     this.name,
     this.symbol,
     this.status,
     this.createdAt,
     this.updatedAt,
  });

  factory DemoUnitModel.fromJson(Map<String, dynamic> json) {
    return DemoUnitModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      status: json['status'].toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

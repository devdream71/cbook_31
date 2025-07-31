
class UnitResponse {
  final bool success;
  final String message;
  final List<Unit> units;

  UnitResponse({
    required this.success,
    required this.message,
    required this.units,
  });

  factory UnitResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] ?? {};

    List<Unit> unitList = data.entries.map((entry) {
      return Unit.fromJson(entry.value);
    }).toList();

    return UnitResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      units: unitList,
    );
  }
}

class Unit {
  final int id;
  final String name;
  final String symbol;
  final int status;
   //final String ? unitQty;

  Unit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.status,
    //this.unitQty
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      status: json['status'] ?? 0,
      //unitQty: json['unitqty'] ?? 0 ,
    );
  }
}

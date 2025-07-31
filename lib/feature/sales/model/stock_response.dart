class StockResponse {
  final bool success;
  final String message;
  final List<StockData> data;

  StockResponse({required this.success, required this.message, required this.data});

  factory StockResponse.fromJson(Map<String, dynamic> json) {
    return StockResponse(
      success: json['success'],
      message: json['message'],
      data: List<StockData>.from(json['data'].map((item) => StockData.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class StockData {
  final double stocks;
  final String unitStocks;
  final dynamic price;

  StockData({required this.stocks, required this.unitStocks, required this.price});

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      stocks: json['Stocks']?.toDouble() ?? 0.0,
      unitStocks: json['UnitStocks'] ?? '',
      price: json['sales_price'] ?? "" ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Stocks': stocks,
      'UnitStocks': unitStocks,
      'price': price
    };
  }
}

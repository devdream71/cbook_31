
class StockResponsePurchase {
  final bool success;
  final String message;
  final List<StockDataPurchase> data;

  StockResponsePurchase({required this.success, required this.message, required this.data});

  factory StockResponsePurchase.fromJson(Map<String, dynamic> json) {
    return StockResponsePurchase(
      success: json['success'],
      message: json['message'],
      data: List<StockDataPurchase>.from(json['data'].map((item) => StockDataPurchase.fromJson(item))),
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

class StockDataPurchase {
  final dynamic stocks;
  final String unitStocks;
  final dynamic price;

  StockDataPurchase({required this.stocks, required this.unitStocks, required this.price});

  factory StockDataPurchase.fromJson(Map<String, dynamic> json) {
    return StockDataPurchase(
      stocks: json['Stocks']?.toDouble() ?? 0.0,
      unitStocks: json['UnitStocks'] ?? '',
      price: json['purchase_price'] ?? "" ,
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
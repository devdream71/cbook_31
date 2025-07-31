class UpdateItemResponse {
  final bool success;
  final String message;
  final ItemData? data;

  UpdateItemResponse({required this.success, required this.message, this.data});

  factory UpdateItemResponse.fromJson(Map<String, dynamic> json) {
    return UpdateItemResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? ItemData.fromJson(json['data']) : null,
    );
  }
}

 class ItemData {
  final int id;
  final String name;
  final dynamic openingStock;
  final dynamic openingPrice;
  final dynamic openingValue;
  final String openingDate;
  final String status;

  ItemData({
    required this.id,
    required this.name,
    this.openingStock,
    this.openingPrice,
    this.openingValue,
    required this.openingDate,
    required this.status,
  });

  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      id: json['id'],
      name: json['name'],
      openingStock: json['opening_stock'],
      openingPrice: json['opening_price'],
      openingValue: json['opening_value'],
      openingDate: json['opening_date'],
      status: json['status'] == 1 ? "active" : "inactive", // Convert 1 to "active" and 0 to "inactive"
    );
  }
}
 

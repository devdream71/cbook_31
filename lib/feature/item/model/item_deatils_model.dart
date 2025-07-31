// models/item_model.dart

class ItemDetailsModel {
  final String name;
  final int? unitId;
  final double unitQty;
  final int? secondaryUnitId;
  final double openingStock;
  final double openingPrice;
  final String openingDate;
  final String image;
  final int status;
  final double? purchasePrice;
  final double? salesPrice;

  ItemDetailsModel({
    required this.name,
    required this.unitId,
    required this.unitQty,
    required this.secondaryUnitId,
    required this.openingStock,
    required this.openingPrice,
    required this.openingDate,
    required this.image,
    required this.status,
    this.purchasePrice,
    this.salesPrice,
  });

  factory ItemDetailsModel.fromJson(Map<String, dynamic> json) {
    return ItemDetailsModel(
      name: json['name'],
      unitId: json['unit_id'],
      unitQty: (json['unit_qty'] ?? 0).toDouble(),
      secondaryUnitId: json['secondary_unit_id'],
      openingStock: (json['opening_stock'] ?? 0).toDouble(),
      openingPrice: (json['opening_price'] ?? 0).toDouble(),
      openingDate: json['opening_date'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? 0,
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      salesPrice: (json['sales_price'] ?? 0).toDouble(),
    );
  }
}

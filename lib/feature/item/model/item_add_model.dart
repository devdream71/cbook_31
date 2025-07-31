class Item {
  final bool success;
  final String message;
  final ItemData data;

  Item({required this.success, required this.message, required this.data});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      success: json['success'],
      message: json['message'],
      data: ItemData.fromJson(json['data']),
    );
  }
}

 class ItemData {
  final int id;
  final dynamic categoryID;
  final dynamic subCategoryId;
  final String name;
  final String? unitId;
  final String? unitQty;
  final String? secondaryUnitId;
  final int? openingStock;
  final dynamic openingPrice;
  final dynamic openingValue;
  final String openingDate;
  final String status;
  final String createdAt;
  final String updatedAt;

  ItemData({
    required this.id,
    required this.categoryID, // Ensure it's required
    required this.subCategoryId,
    required this.name,
    this.unitId,
    this.unitQty,
    this.secondaryUnitId,
    this.openingStock,
    this.openingPrice,
    this.openingValue,
    required this.openingDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      id: json['id'],
      categoryID: json['categories_id'] ?? 0, // Fallback to 0 if null
      subCategoryId: json['sub_categories_id'] ?? 0, // Fallback to 0 if null
      name: json['name'] ?? 'Unknown', // Default name if null
      unitId: json['unit_id'],
      unitQty: json['unit_qty'],
      secondaryUnitId: json['secondary_unit_id'],
      openingStock: json['opening_stock'],
      openingPrice: json['opening_price']?.toDouble(), // Convert to double safely
      openingValue: json['value']?.toDouble(), // Convert to double safely
      openingDate: json['opening_date'] ?? '',
      status: json['status'] ?? 'inactive',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
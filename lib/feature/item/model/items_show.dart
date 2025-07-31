class ItemsModel {
  final int id;
  final int  ? userId;
  final String name;
  final String? unitId;
  final int? unitQty;
  final dynamic openingStock;
  final int? secondaryUnitId;
  final String? openingDate;
  final int? status;
  final String? image;
  final int? secondaryUnitQty;
  final String? createdAt;
  final String? updatedAt;
  final dynamic salesPrice;
  final dynamic purchasePrice;
  final dynamic mrp;
  final int? itemCategoryId;
  final int? itemSubCategoryId;

  // NEW FIELDS
  final dynamic openingPrice;
  final dynamic openingValue;
  final dynamic wholesalesPrice;
  final dynamic depoPrice;
  final dynamic dealerPrice;
  final dynamic subDealerPrice;
  final dynamic retailerPrice;
  final dynamic brokerPrice;
  final dynamic ecommercePrice;
  final dynamic outlinePrice;
  final String? description;

  final List<PurchaseDetailModel>? purchaseDetails;

  ItemsModel({
    required this.id,
     this.userId,
    required this.name,
    this.unitId,
    this.unitQty,
    this.openingStock,
    this.secondaryUnitId,
    this.openingDate,
    this.status,
    this.image,
    this.secondaryUnitQty,
    this.salesPrice,
    this.purchasePrice,
    this.mrp,
    this.itemCategoryId,
    this.itemSubCategoryId,
    this.createdAt,
    this.updatedAt,
    this.openingPrice,
    this.openingValue,
    this.wholesalesPrice,
    this.depoPrice,
    this.dealerPrice,
    this.subDealerPrice,
    this.retailerPrice,
    this.brokerPrice,
    this.ecommercePrice,
    this.outlinePrice,
    this.description,
    this.purchaseDetails,
  });

  factory ItemsModel.fromJson(Map<String, dynamic> json) {
    return ItemsModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      unitId: json['unit_id'] != null ? json['unit_id'].toString() : null,
      unitQty: json['unit_qty'],
      openingStock: json['opening_stock'],
      secondaryUnitId: json['secondary_unit_id'],
      openingDate: json['opening_date'],
      status: json['status'],
      image: json['image'],
      secondaryUnitQty: json['secondary_unit_qty'],
      salesPrice: json['sales_price'],
      purchasePrice: json['purchase_price'],
      mrp: json['mrp_price'],
      itemCategoryId: json['item_category_id'],
      itemSubCategoryId: json['item_sub_category_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],

      // New price fields
      openingPrice: json['opening_price'],
      openingValue: json['opening_value'],
      wholesalesPrice: json['wholesales_price'],
      depoPrice: json['depo_price'],
      dealerPrice: json['dealer_price'],
      subDealerPrice: json['sub_dealer_price'],
      retailerPrice: json['retailer_price'],
      brokerPrice: json['broker_price'],
      ecommercePrice: json['ecommerce_price'],
      outlinePrice: json['outline_price'],
      description: json['description'],

      purchaseDetails: json['purchaseDetails'] != null
          ? List<PurchaseDetailModel>.from(
              json['purchaseDetails'].map((x) => PurchaseDetailModel.fromJson(x)),
            )
          : [],
    );
  }
}


class PurchaseDetailModel {
  final int id;
  final int purchaseId;
  final String? purchaseDetailsId;
  final String type;
  final String purchaseDate;
  final int itemId;
  final String qty;
  final String rawQty;
  final int unitId;
  final String price;
  final String? discountPercentage;
  final String? discountAmount;
  final int? taxId;
  final String? taxPercent;
  final String? taxAmount;
  final String subTotal;
  final String? salesQty;
  final String? returnQty;
  final String? description;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  PurchaseDetailModel({
    required this.id,
    required this.purchaseId,
    this.purchaseDetailsId,
    required this.type,
    required this.purchaseDate,
    required this.itemId,
    required this.qty,
    required this.rawQty,
    required this.unitId,
    required this.price,
    this.discountPercentage,
    this.discountAmount,
    this.taxId,
    this.taxPercent,
    this.taxAmount,
    required this.subTotal,
    this.salesQty,
    this.returnQty,
    this.description,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseDetailModel.fromJson(Map<String, dynamic> json) {
    return PurchaseDetailModel(
      id: json['id'],
      purchaseId: json['purchase_id'],
      purchaseDetailsId: json['purchase_details_id'],
      type: json['type'],
      purchaseDate: json['purchase_date'],
      itemId: json['item_id'],
      qty: json['qty'],
      rawQty: json['raw_qty'],
      unitId: json['unit_id'],
      price: json['price'],
      discountPercentage: json['discount_percentage'],
      discountAmount: json['discount_amount'],
      taxId: json['tax_id'],
      taxPercent: json['tax_percent'],
      taxAmount: json['tax_amount'],
      subTotal: json['sub_total'],
      salesQty: json['sales_qty'],
      returnQty: json['return_qty'],
      description: json['description'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}










// class ItemsModel {
//   final int id;
//   final String name;
//   final String? unitId; // Note: still String? because API returns string
//   final int? unitQty;
//   final dynamic openingStock;
//   final int? secondaryUnitId;
//   final String? openingDate;
//   final int? status;
//   final String? image;
//   final int? secondaryUnitQty;
//   final String? createdAt;
//   final String? updatedAt;
//   final dynamic salesPrice;
//   final dynamic purchasePrice;
//   final dynamic mrp;
//   final int ? itemCategoryId;      // <- Must be added
//   final int ? itemSubCategoryId;

//   ItemsModel({
//     required this.id,
//     required this.name,
//     this.unitId,
//     this.unitQty,
//     this.openingStock,
//     this.secondaryUnitId,
//     this.openingDate,
//     this.status,
//     this.image,
//     this.secondaryUnitQty,
//     this.salesPrice,
//     this.purchasePrice,
//     this.mrp,
//     this.itemCategoryId,     // <- Must be added
//     this.itemSubCategoryId,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory ItemsModel.fromJson(Map<String, dynamic> json) {
//     return ItemsModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? 'Unknown',
//       unitId: json['unit_id'] != null && json['unit_id'] != "null"
//           ? json['unit_id'].toString()
//           : null,
//       salesPrice: json['sales_price'] != null ? json['sales_price'] as int? : 0,
//       purchasePrice: json['purchase_price'] != null ? json['purchase_price'] as int? : 0,
//       mrp: json['mrp_price'] != null ? json['mrp_price'] as int? : 0,
//       unitQty: json['unit_qty'] != null ? json['unit_qty'] as int? : null,
//       openingStock: json['opening_stock'] != null ? json['opening_stock'] as int? : null,
//       secondaryUnitId: json['secondary_unit_id'] != null ? json['secondary_unit_id'] as int? : null,
//       secondaryUnitQty: json['secondary_unit_qty'] != null ? json['secondary_unit_qty'] as int? : null,
//       openingDate: json['opening_date'] ?? '',
//       status: json['status'] ?? 0,
//       image: json['image'] ?? '',
//        itemCategoryId: json['item_category_id'],      // <- Correct mapping
//       itemSubCategoryId: json['item_sub_category_id'],
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }

//   static List<ItemsModel> fromJsonMap(Map<String, dynamic> jsonMap) {
//     return jsonMap.values
//         .map((item) => ItemsModel.fromJson(item as Map<String, dynamic>))
//         .toList();
//   }
// }


 
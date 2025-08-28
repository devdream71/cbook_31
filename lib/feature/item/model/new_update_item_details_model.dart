// Item Detail API Response Models
class NewItemDetailResponse {
  final bool success;
  final String message;
  final ItemDetailData data;

  NewItemDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NewItemDetailResponse.fromJson(Map<String, dynamic> json) {
    return NewItemDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ItemDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class ItemDetailData {
  final ItemDetail itemName;

  ItemDetailData({required this.itemName});

  factory ItemDetailData.fromJson(Map<String, dynamic> json) {
    return ItemDetailData(
      itemName: ItemDetail.fromJson(json['item_name'] ?? {}),
    );
  }
}

class ItemDetail {
  final int id;
  final String name;
  final String itemCategoryId;
  final String itemSubCategoryId;
  final String unitId;
  final int unitQty;
  final String secondaryUnitId;
  final int openingStock;
  final int openingPrice;
  final int openingValue;
  final String openingDate;
  final String? salesPrice;
  final String? purchasePrice;
  final String? wholesalesPrice;
  final String? mrpPrice;
  final String? depoPrice;
  final String? dealerPrice;
  final String? subDealerPrice;
  final String? retailerPrice;
  final String? brokerPrice;
  final String? ecommercePrice;
  final String? outlinePrice;
  final String? image;
  final int status;
  final String? description;
  final List<PurchaseDetail> purchaseDetails;

  ItemDetail({
    required this.id,
    required this.name,
    required this.itemCategoryId,
    required this.itemSubCategoryId,
    required this.unitId,
    required this.unitQty,
    required this.secondaryUnitId,
    required this.openingStock,
    required this.openingPrice,
    required this.openingValue,
    required this.openingDate,
    this.salesPrice,
    this.purchasePrice,
    this.wholesalesPrice,
    this.mrpPrice,
    this.depoPrice,
    this.dealerPrice,
    this.subDealerPrice,
    this.retailerPrice,
    this.brokerPrice,
    this.ecommercePrice,
    this.outlinePrice,
    this.image,
    required this.status,
    this.description,
    required this.purchaseDetails,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      itemCategoryId: json['item_category_id'] ?? 'N/A',
      itemSubCategoryId: json['item_sub_category_id'] ?? 'N/A',
      unitId: json['unit_id'] ?? 'N/A',
      unitQty: json['unit_qty'] ?? 0,
      secondaryUnitId: json['secondary_unit_id'] ?? 'N/A',
      openingStock: json['opening_stock'] ?? 0,
      openingPrice: json['opening_price'] ?? 0,
      openingValue: json['opening_value'] ?? 0,
      openingDate: json['opening_date'] ?? '',
      salesPrice: json['sales_price']?.toString(),
      purchasePrice: json['purchase_price']?.toString(),
      wholesalesPrice: json['wholesales_price']?.toString(),
      mrpPrice: json['mrp_price']?.toString(),
      depoPrice: json['depo_price']?.toString(),
      dealerPrice: json['dealer_price']?.toString(),
      subDealerPrice: json['sub_dealer_price']?.toString(),
      retailerPrice: json['retailer_price']?.toString(),
      brokerPrice: json['broker_price']?.toString(),
      ecommercePrice: json['ecommerce_price']?.toString(),
      outlinePrice: json['outline_price']?.toString(),
      image: json['image'],
      status: json['status'] ?? 0,
      description: json['description'],
      purchaseDetails: (json['pruchase_details'] as List?)
              ?.map((e) => PurchaseDetail.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PurchaseDetail {
  final int id;
  final String type;
  final String? transaction;
  final String proprietorName;
  final String billNumber;
  final String qty;
  final String subTotal;

  PurchaseDetail({
    required this.id,
    required this.type,
    this.transaction,
    required this.proprietorName,
    required this.billNumber,
    required this.qty,
    required this.subTotal,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      transaction: json['transaction'],
      proprietorName: json['proprietor_name'] ?? 'N/A',
      billNumber: json['bill_number'] ?? 'N/A',
      qty: json['qty'] ?? '0',
      subTotal: json['sub_total'] ?? '0',
    );
  }
}
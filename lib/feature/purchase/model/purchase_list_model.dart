class PurchaseResponse {
  final bool success;
  final String message;
  final Map<int, PurchaseModel> purchases;

  PurchaseResponse({
    required this.success,
    required this.message,
    required this.purchases,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    Map<int, PurchaseModel> purchaseMap = {};
    json['data'].forEach((key, value) {
      int purchaseId = int.tryParse(key) ?? 0;
      if (purchaseId > 0) {
        purchaseMap[purchaseId] = PurchaseModel.fromJson(value);
      }
    });

    return PurchaseResponse(
      success: json['success'],
      message: json['message'] ?? "",
      purchases: purchaseMap,
    );
  }
}

class PurchaseModel {
  final int userId;
  final String supplier;
  final String billNumber;
  final String purchaseDate;
  final int discount;
  final double grossTotal;
  final String? detailsNotes;
  final List<PurchaseDetail> purchaseDetails;

  PurchaseModel({
    required this.userId,
    required this.supplier,
    required this.billNumber,
    required this.purchaseDate,
    required this.discount,
    required this.grossTotal,
    this.detailsNotes,
    required this.purchaseDetails,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    var detailsList = json['purchase_details'] as List;
    List<PurchaseDetail> purchaseDetailsList =
        detailsList.map((e) => PurchaseDetail.fromJson(e)).toList();

    return PurchaseModel(
      userId: json['user_id'],
      supplier: json['supplier'], // Fixed incorrect mapping
      billNumber: json['bill_number'],
      purchaseDate: json['pruchase_date'],
      discount: json['discount'],
      grossTotal: json['gross_total'].toDouble(),
      detailsNotes: json['details_notes'],
      purchaseDetails: purchaseDetailsList,
    );
  }
}

class PurchaseDetail {
  final int id;
  final int purchaseId;
  final int? purchaseDetailsId;
  final String type;
  final String purchaseDate;
  final int itemId;
  final int defaultQty;
  final dynamic qty;
  final dynamic rawQty;
  final int unitId;
  final double price;
  final double subTotal;
  final dynamic salesQty;
  final dynamic returnQty;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  PurchaseDetail({
    required this.id,
    required this.purchaseId,
    this.purchaseDetailsId,
    required this.type,
    required this.purchaseDate,
    required this.itemId,
    required this.defaultQty,
    required this.qty,
    required this.rawQty,
    required this.unitId,
    required this.price,
    required this.subTotal,
    required this.salesQty,
    required this.returnQty,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      id: json['id'],
      purchaseId: json['purchase_id'],
      purchaseDetailsId: json['purchase_details_id'],
      type: json['type'],
      purchaseDate: json['pruchase_date'],
      itemId: json['item_id'],
      defaultQty: json['default_qty'],
      qty: json['qty'],
      rawQty: json['raw_qty'],
      unitId: json['unit_id'],
      price: json['price'].toDouble(),
      subTotal: json['sub_total'].toDouble(),
      salesQty: json['sales_qty'],
      returnQty: json['return_qty'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

import 'dart:convert';

class PurchaseEditResponse {
  final bool? success;
  final String? message;
  final PurchaseData? data;

  PurchaseEditResponse({
    this.success,
    this.message,
    this.data,
  });

  factory PurchaseEditResponse.fromJson(String source) =>
      PurchaseEditResponse.fromMap(json.decode(source));

  factory PurchaseEditResponse.fromMap(Map<String, dynamic> map) {
    return PurchaseEditResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: PurchaseData.fromMap(map['data']),
    );
  }
}

class PurchaseData {
  final String? type;
  final int? userId;
  final int? customerId;
  final String? billNumber;
  final String? purchaseDate;
  final int? discount;
  final dynamic  grossTotal;
  final String? detailsNotes;
  final List<PurchaseDetail>? purchaseDetails;

  PurchaseData({
    this.type,
    this.userId,
    this.customerId,
    this.billNumber,
    this.purchaseDate,
    this.discount,
    this.grossTotal,
    this.detailsNotes,
    this.purchaseDetails,
  });

  factory PurchaseData.fromMap(Map<String, dynamic> map) {
    return PurchaseData(
      type: map['type'] ?? '',
      userId: map['user_id'] ?? 0,
      customerId: map['customer_id'] ?? 0,
      billNumber: map['bill_number'] ?? '',
      purchaseDate: map['pruchase_date'] ?? '',
      discount: map['discount'] ?? 0,
      grossTotal: map['gross_total'] ?? 0,
      detailsNotes: map['details_notes'],
      purchaseDetails: List<PurchaseDetail>.from(
          map['purchase_details']?.map((x) => PurchaseDetail.fromMap(x)) ?? []),
    );
  }
}

class PurchaseDetail {
   int? id;
   int? purchaseId;
  //final dynamic? purchaseDetailsId;
   String? type;
   String? purchaseDate;
   int? itemId;
   dynamic  defaultQty;
  dynamic  qty;
   dynamic  rawQty;
   int ? unitId;
  dynamic price;
  dynamic  subTotal;
  final dynamic  salesQty;
  final dynamic  returnQty;
  final dynamic  deletedAt;
  final String? createdAt;
  final String? updatedAt;

  PurchaseDetail({
    this.id,
    this.purchaseId,
    //this.purchaseDetailsId,
    this.type,
    this.purchaseDate,
    this.itemId,
    this.defaultQty,
    this.qty,
    this.rawQty,
    this.unitId,
    this.price,
    this.subTotal,
    this.salesQty,
    this.returnQty,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseDetail.fromMap(Map<String, dynamic> map) {
    return PurchaseDetail(
      id: map['id'] ?? 0,
      purchaseId: map['purchase_id'] ?? 0,
      //purchaseDetailsId: map['purchase_details_id'],
      type: map['type'] ?? '',
      purchaseDate: map['pruchase_date'] ?? '',
      itemId: map['item_id'] ?? 0,
      defaultQty: map['default_qty'] ?? 0,
      qty: map['qty'] ?? 0,
      rawQty: map['raw_qty'] ?? 0,
      unitId: map['unit_id'] ?? 0,
      price: map['price'] ?? 0,
      subTotal: map['sub_total'] ?? 0,
      salesQty: map['sales_qty'] ?? 0,
      returnQty: map['return_qty'] ?? 0,
      deletedAt: map['deleted_at'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }
}

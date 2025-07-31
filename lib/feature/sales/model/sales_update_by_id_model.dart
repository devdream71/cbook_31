import 'dart:convert';

class SalesEditResponse {
  final bool? success;
  final String? message;
  final SaleData? data;

  SalesEditResponse({
    this.success,
    this.message,
    this.data,
  });

  factory SalesEditResponse.fromJson(String source) =>
      SalesEditResponse.fromMap(json.decode(source));

  factory SalesEditResponse.fromMap(Map<String, dynamic> map) {
    return SalesEditResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: SaleData.fromMap(map['data']),
    );
  }
}

class SaleData {
  final String? type;
  final int? userId;
  final int? customerId;
  final String? billNumber;
  final String? salesDate;
  final dynamic discount;
  final dynamic discountPercent;
  final dynamic grossTotal;
  final String? detailsNotes;

  final List<SaleDetail>? salesDetails;

  SaleData({
    this.type,
    this.userId,
    this.customerId,
    this.billNumber,
    this.salesDate,
    this.discount,
    this.discountPercent,
    this.grossTotal,
    this.detailsNotes,
    this.salesDetails,
  });

  factory SaleData.fromMap(Map<String, dynamic> map) {
    return SaleData(
      type: map['type'] ?? '',
      userId: map['user_id'] ?? 0,
      customerId: map['customer_id'] ?? 0,
      billNumber: map['bill_number'] ?? '',
      salesDate: map['sales_date'] ?? '',
      discount: map['discount'] ?? 0,
      discountPercent: map['discount_percent'] ?? 0,
      grossTotal: map['gross_total'] ?? 0,
      detailsNotes: map['details_notes'],
      salesDetails: List<SaleDetail>.from(
          map['sales_details']?.map((x) => SaleDetail.fromMap(x)) ?? []),
    );
  }
}

class SaleDetail {
  final int? id;
  final int? purchaseId;
  final dynamic purchaseDetailsId;
  final String? type;
  final String? purchaseDate;
  final int? itemId;
  final dynamic  defaultQty;
  dynamic qty;
  final dynamic rawQty;
  final int? unitId;
  dynamic price;
  dynamic subTotal;
  dynamic   discountPercentage;
  dynamic   discountAmount;
  dynamic   taxPercent;
  dynamic   taxid;
  dynamic   taxAmount;
  final dynamic salesQty;
  final dynamic returnQty;
  final dynamic deletedAt;
  final String? createdAt;
  final String? updatedAt;

  SaleDetail({
    this.id,
    this.purchaseId,
    this.purchaseDetailsId,
    this.type,
    this.purchaseDate,
    this.itemId,
    this.defaultQty,
    this.qty,
    this.rawQty,
    this.unitId,
    this.price,
    this.subTotal,
    this.discountPercentage,
    this.discountAmount,
    this.taxAmount,
    this.taxPercent,
    this.taxid,
    this.salesQty,
    this.returnQty,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SaleDetail.fromMap(Map<String, dynamic> map) {
    return SaleDetail(
      id: map['id'] ?? 0,
      purchaseId: map['purchase_id'] ?? 0,
      purchaseDetailsId: map['purchase_details_id'],
      type: map['type'] ?? '',
      purchaseDate: map['pruchase_date'] ?? '',
      itemId: map['item_id'] ?? 0,
      defaultQty: map['default_qty'] ?? 0,
      qty: map['qty'] ?? 0,
      rawQty: map['raw_qty'] ?? 0,
      unitId: map['unit_id'] ?? 0,
      price: map['price'] ?? 0,
      subTotal: map['sub_total'] ?? 0,
      discountPercentage: map['discount_percentage'] ?? 0,
      discountAmount: map['discount_amount'] ?? 0,
      taxPercent: map['tax_percent'] ?? 0,
      taxid: map['tax_id'] ?? 0,

      taxAmount: map['tax_amount'] ?? 0,
      salesQty: map['sales_qty'] ?? 0,
      returnQty: map['return_qty'] ?? 0,
      deletedAt: map['deleted_at'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }
}

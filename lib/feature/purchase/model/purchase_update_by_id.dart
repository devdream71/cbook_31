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
      data: map['data'] != null ? PurchaseData.fromMap(map['data']) : null,
    );
  }
}

class PurchaseData {
  final String? type;
  final int? userId;
  final int? customerId;
  final int? billPersonId;
  final String? billNumber;
  final String? purchaseDate;
  final String? discount; // ✅ Changed to String to match API
  final String? grossTotal; // ✅ Changed to String to match API
  final String? detailsNotes;
  final List<PurchaseDetail>? purchaseDetails;

  PurchaseData({
    this.type,
    this.userId,
    this.customerId,
    this.billPersonId,
    this.billNumber,
    this.purchaseDate,
    this.discount,
    this.grossTotal,
    this.detailsNotes,
    this.purchaseDetails,
  });

  factory PurchaseData.fromMap(Map<String, dynamic> map) {
    return PurchaseData(
      type: map['type']?.toString(),
      userId: _parseToInt(map['user_id']),
      customerId: _parseToInt(map['customer_id']),
      billPersonId: _parseToInt(map['bill_person_id']),
      billNumber: map['bill_number']?.toString(),
      purchaseDate: map['purchase_date']?.toString(), // ✅ Fixed typo: was 'pruchase_date'
      discount: map['discount']?.toString() ?? "0.00", // ✅ Convert to string
      grossTotal: map['gross_total']?.toString() ?? "0.00", // ✅ Convert to string
      detailsNotes: map['details_notes']?.toString(),
      purchaseDetails: map['purchase_details'] != null
          ? List<PurchaseDetail>.from(
              map['purchase_details'].map((x) => PurchaseDetail.fromMap(x)))
          : [],
    );
  }

  // ✅ Helper methods for safe conversion to double
  double get discountAsDouble => double.tryParse(discount ?? "0") ?? 0.0;
  double get grossTotalAsDouble => double.tryParse(grossTotal ?? "0") ?? 0.0;

  // ✅ Helper method for safe int parsing
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class PurchaseDetail {
  int? id;
  int? purchaseId;
  String? type;
  String? purchaseDate;
  int? itemId;
  String? defaultQty; // ✅ Changed to String to match API
  String? qty; // ✅ Changed to String to match API
  String? rawQty; // ✅ Changed to String to match API
  int? unitId;
  String? price; // ✅ Changed to String to match API
  String? subTotal; // ✅ Changed to String to match API
  final String? salesQty; // ✅ Changed to String to match API
  final String? returnQty; // ✅ Changed to String to match API
  final dynamic deletedAt;
  final String? createdAt;
  final String? updatedAt;

  PurchaseDetail({
    this.id,
    this.purchaseId,
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
      id: _parseToInt(map['id']),
      purchaseId: _parseToInt(map['purchase_id']),
      type: map['type']?.toString(),
      purchaseDate: map['purchase_date']?.toString(), // ✅ Fixed typo
      itemId: _parseToInt(map['item_id']),
      defaultQty: map['default_qty']?.toString() ?? "0",
      qty: map['qty']?.toString() ?? "0.00", // ✅ Convert to string
      rawQty: map['raw_qty']?.toString() ?? "0.00", // ✅ Convert to string
      unitId: _parseToInt(map['unit_id']),
      price: map['price']?.toString() ?? "0.00", // ✅ Convert to string
      subTotal: map['sub_total']?.toString() ?? "0.00", // ✅ Convert to string
      salesQty: map['sales_qty']?.toString() ?? "0.00",
      returnQty: map['return_qty']?.toString() ?? "0.00",
      deletedAt: map['deleted_at'],
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  // ✅ Helper methods for safe conversion to double
  double get priceAsDouble => double.tryParse(price ?? "0") ?? 0.0;
  double get qtyAsDouble => double.tryParse(qty ?? "0") ?? 0.0;
  double get subTotalAsDouble => double.tryParse(subTotal ?? "0") ?? 0.0;
  double get rawQtyAsDouble => double.tryParse(rawQty ?? "0") ?? 0.0;

  // ✅ Helper methods for safe conversion to int
  int get priceAsInt => priceAsDouble.toInt();
  int get qtyAsInt => qtyAsDouble.toInt();

  // ✅ Helper method for safe int parsing
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
}




// import 'dart:convert';

// class PurchaseEditResponse {
//   final bool? success;
//   final String? message;
//   final PurchaseData? data;

//   PurchaseEditResponse({
//     this.success,
//     this.message,
//     this.data,
//   });

//   factory PurchaseEditResponse.fromJson(String source) =>
//       PurchaseEditResponse.fromMap(json.decode(source));

//   factory PurchaseEditResponse.fromMap(Map<String, dynamic> map) {
//     return PurchaseEditResponse(
//       success: map['success'] ?? false,
//       message: map['message'] ?? '',
//       data: PurchaseData.fromMap(map['data']),
//     );
//   }
// }

// class PurchaseData {
//   final String? type;
//   final int? userId;
//   final int? customerId;
//    final int? billPersonId; 
//   final String? billNumber;
//   final String? purchaseDate;
//   final dynamic discount;
//   final dynamic  grossTotal;
//   final String? detailsNotes;
//   final List<PurchaseDetail>? purchaseDetails;

//   PurchaseData({
//     this.type,
//     this.userId,
//     this.customerId,
//     this.billPersonId,
//     this.billNumber,
//     this.purchaseDate,
//     this.discount,
//     this.grossTotal,
//     this.detailsNotes,
//     this.purchaseDetails,
//   });

//   factory PurchaseData.fromMap(Map<String, dynamic> map) {
//     return PurchaseData(
//       type: map['type'] ?? '',
//       userId: map['user_id'] ?? 0,
//       customerId: map['customer_id'] ?? 0,
//       billPersonId: map['bill_person_id'] ?? 0, 
//       billNumber: map['bill_number'] ?? '',
//       purchaseDate: map['pruchase_date'] ?? '',
//       discount: map['discount'] ?? 0,
//       grossTotal: map['gross_total'] ?? 0,
//       detailsNotes: map['details_notes'],
//       purchaseDetails: List<PurchaseDetail>.from(
//           map['purchase_details']?.map((x) => PurchaseDetail.fromMap(x)) ?? []),
//     );
//   }
// }

// class PurchaseDetail {
//    int? id;
//    int? purchaseId;
//   //final dynamic? purchaseDetailsId;
//    String? type;
//    String? purchaseDate;
//    int? itemId;
//    dynamic  defaultQty;
//   dynamic  qty;
//    dynamic  rawQty;
//    int ? unitId;
//   dynamic price;
//   dynamic  subTotal;
//   final dynamic  salesQty;
//   final dynamic  returnQty;
//   final dynamic  deletedAt;
//   final String? createdAt;
//   final String? updatedAt;

//   PurchaseDetail({
//     this.id,
//     this.purchaseId,
//     //this.purchaseDetailsId,
//     this.type,
//     this.purchaseDate,
//     this.itemId,
//     this.defaultQty,
//     this.qty,
//     this.rawQty,
//     this.unitId,
//     this.price,
//     this.subTotal,
//     this.salesQty,
//     this.returnQty,
//     this.deletedAt,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory PurchaseDetail.fromMap(Map<String, dynamic> map) {
//     return PurchaseDetail(
//       id: map['id'] ?? 0,
//       purchaseId: map['purchase_id'] ?? 0,
//       //purchaseDetailsId: map['purchase_details_id'],
//       type: map['type'] ?? '',
//       purchaseDate: map['pruchase_date'] ?? '',
//       itemId: map['item_id'] ?? 0,
//       defaultQty: map['default_qty'] ?? 0,
//       qty: map['qty'] ?? 0,
//       rawQty: map['raw_qty'] ?? 0,
//       unitId: map['unit_id'] ?? 0,
//       price: map['price'] ?? 0,
//       subTotal: map['sub_total'] ?? 0,
//       salesQty: map['sales_qty'] ?? 0,
//       returnQty: map['return_qty'] ?? 0,
//       deletedAt: map['deleted_at'],
//       createdAt: map['created_at'] ?? '',
//       updatedAt: map['updated_at'] ?? '',
//     );
//   }
// }

import 'dart:convert';

class SalesReturnResponse {
  final bool success;
  final String message;
  final List<SalesReturnData> salesReturns;
  final double totalReturn;

  SalesReturnResponse({
    required this.success,
    required this.message,
    required this.salesReturns,
    required this.totalReturn,
  });

  factory SalesReturnResponse.fromJson(String str) =>
      SalesReturnResponse.fromMap(json.decode(str));

  factory SalesReturnResponse.fromMap(Map<String, dynamic> json) {
    List<dynamic> data = json['data'] ?? [];

    // Separate normal entries from total_return summary object
    List<SalesReturnData> returns = data
        .where((item) => item is Map && !item.containsKey('total_return'))
        .map((item) => SalesReturnData.fromMap(item))
        .toList();

    double total = 0.0;
    for (var item in data) {
      if (item is Map && item.containsKey('total_return')) {
        total = double.tryParse(item['total_return'].toString()) ?? 0.0;
        break;
      }
    }

    return SalesReturnResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
      salesReturns: returns,
      totalReturn: total,
    );
  }
}

class SalesReturnData {
  final id;
  final int userId;
  final dynamic supplierId;
  final String supplierName;
  final String? transactionMethod;
  final String billNumber;
  final String? purchaseDate;
  final dynamic discount;
  final dynamic grossTotal;
  final String? detailsNotes;
  final String disabled;
  final List<PurchaseDetails> purchaseDetails;

  SalesReturnData({
    required this.id,
    required this.userId,
    required this.supplierId,
    required this.supplierName,
    this.transactionMethod,
    required this.billNumber,
    required this.purchaseDate,
    required this.discount,
    required this.grossTotal,
    this.detailsNotes,
    required this.disabled,
    required this.purchaseDetails,
  });

  factory SalesReturnData.fromMap(Map<String, dynamic> json) => SalesReturnData(
        id: json['id'] ?? 0,
        userId: json["user_id"] ?? 0,
        supplierId: json["supplier_id"],
        supplierName: json["supplier_name"] ?? '',
        transactionMethod: json["transaction_method"],
        billNumber: json["bill_number"]?.toString() ?? '',
        purchaseDate: json["purchase_date"]?.toString(),
        discount: json["discount"],
        grossTotal: json["gross_total"],
        detailsNotes: json["details_notes"],
        disabled: json["disabled"] ?? '',
        purchaseDetails: json["purchase_details"] == null
            ? []
            : List<PurchaseDetails>.from(json["purchase_details"]
                .map((x) => PurchaseDetails.fromMap(x))),
      );
}

class PurchaseDetails {
  final int id;
  final dynamic purchaseId;
  final dynamic purchaseDetailsId;
  final String type;
  final String purchaseDate;
  final dynamic itemId;
  final dynamic defaultQty;
  final dynamic qty;
  final dynamic rawQty;
  final dynamic unitId;
  final dynamic price;
  final dynamic subTotal;
  final dynamic salesQty;
  final dynamic returnQty;
  final dynamic deletedAt;
  final String createdAt;
  final String updatedAt;

  PurchaseDetails({
    required this.id,
    required this.purchaseId,
    required this.purchaseDetailsId,
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

  factory PurchaseDetails.fromMap(Map<String, dynamic> json) => PurchaseDetails(
        id: json["id"] ?? 0,
        purchaseId: json["purchase_id"],
        purchaseDetailsId: json["purchase_details_id"],
        type: json["type"] ?? '',
        purchaseDate: json["purchase_date"]?.toString() ?? '',
        itemId: json["item_id"],
        defaultQty: json["default_qty"],
        qty: json["qty"],
        rawQty: json["raw_qty"],
        unitId: json["unit_id"],
        price: json["price"],
        subTotal: json["sub_total"],
        salesQty: json["sales_qty"],
        returnQty: json["return_qty"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
      );
}







// import 'dart:convert';

// class SalesReturnResponse {
//   final bool success;
//   final String message;
//   final List<SalesReturnData> data;

//   SalesReturnResponse({
//     required this.success,
//     required this.message,
//     required this.data,
//   });

//   factory SalesReturnResponse.fromJson(String str) =>
//       SalesReturnResponse.fromMap(json.decode(str));

//   factory SalesReturnResponse.fromMap(Map<String, dynamic> json) =>
//       SalesReturnResponse(
//         success: json["success"] ?? false,
//         message: json["message"] ?? '',
//         data: json["data"] == null
//             ? []
//             : List<SalesReturnData>.from(
//                 json["data"].map((x) => SalesReturnData.fromMap(x))),
//       );
// }

// class SalesReturnData {
//   final id;
//   final int userId;
//   final dynamic supplierId;
//   final String supplierName;
//   final String? transactionMethod;
//   final String billNumber;
//   final String? purchaseDate;
//   final dynamic discount;
//   final dynamic grossTotal;
//   final String? detailsNotes;
//   final String disabled;
//   final List<PurchaseDetails> purchaseDetails;

//   SalesReturnData({
//     required this.id,
//     required this.userId,
//     required this.supplierId,
//     required this.supplierName,
//     this.transactionMethod,
//     required this.billNumber,
//     required this.purchaseDate,
//     required this.discount,
//     required this.grossTotal,
//     this.detailsNotes,
//     required this.disabled,
//     required this.purchaseDetails,
//   });

//   factory SalesReturnData.fromMap(Map<String, dynamic> json) => SalesReturnData(
//         id: json['id'] ?? 0,
//         userId: json["user_id"] ?? 0,
//         supplierId: json["supplier_id"],
//         supplierName: json["supplier_name"] ?? '',
//         transactionMethod: json["transection_method"],
//         billNumber: json["bill_number"]?.toString() ?? '',
    

//         purchaseDate: json["purchase_date"] != null
//             ? json["purchase_date"].toString()
//             : null,

//         discount: json["discount"],
//         grossTotal: json["gross_total"],
//         detailsNotes: json["details_notes"],
//         disabled: json["disabled"] ?? '',
//         purchaseDetails: json["purchase_details"] == null
//             ? []
//             : List<PurchaseDetails>.from(json["purchase_details"]
//                 .map((x) => PurchaseDetails.fromMap(x))),
//       );
// }

// class PurchaseDetails {
//   final int id;
//   final dynamic purchaseId;
//   final dynamic purchaseDetailsId;
//   final String type;
//   final String purchaseDate;
//   final dynamic itemId;
//   final dynamic defaultQty;
//   final dynamic qty;
//   final dynamic rawQty;
//   final dynamic unitId;
//   final dynamic price;
//   final dynamic subTotal;
//   final dynamic salesQty;
//   final dynamic returnQty;
//   final dynamic deletedAt;
//   final String createdAt;
//   final String updatedAt;

//   PurchaseDetails({
//     required this.id,
//     required this.purchaseId,
//     required this.purchaseDetailsId,
//     required this.type,
//     required this.purchaseDate,
//     required this.itemId,
//     required this.defaultQty,
//     required this.qty,
//     required this.rawQty,
//     required this.unitId,
//     required this.price,
//     required this.subTotal,
//     required this.salesQty,
//     required this.returnQty,
//     this.deletedAt,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory PurchaseDetails.fromMap(Map<String, dynamic> json) => PurchaseDetails(
//         id: json["id"] ?? 0,
//         purchaseId: json["purchase_id"],
//         purchaseDetailsId: json["purchase_details_id"],
//         type: json["type"] ?? '',
//         purchaseDate: json["purchase_date"]?.toString() ?? '',
//         itemId: json["item_id"],
//         defaultQty: json["default_qty"],
//         qty: json["qty"],
//         rawQty: json["raw_qty"],
//         unitId: json["unit_id"],
//         price: json["price"],
//         subTotal: json["sub_total"],
//         salesQty: json["sales_qty"],
//         returnQty: json["return_qty"],
//         deletedAt: json["deleted_at"],
//         createdAt: json["created_at"] ?? '',
//         updatedAt: json["updated_at"] ?? '',
//       );
// }

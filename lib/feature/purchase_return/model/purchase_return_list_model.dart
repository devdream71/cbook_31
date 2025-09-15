import 'dart:convert';

class PurchaseReturnResponse {
  final bool success;
  final String message;
  final List<PurchaseReturn> data;
  final double totalReturn;

  PurchaseReturnResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.totalReturn,
  });

  factory PurchaseReturnResponse.fromJson(String str) =>
      PurchaseReturnResponse.fromMap(json.decode(str));

  factory PurchaseReturnResponse.fromMap(Map<String, dynamic> json) {
    final List<dynamic> rawList = json["data"];
    double totalReturn = 0;
    List<PurchaseReturn> parsedData = [];

    for (var item in rawList) {
      // total_return object
      if (item is Map<String, dynamic> && item.containsKey("total_return")) {
        totalReturn = double.tryParse(item["total_return"].toString()) ?? 0.0;
      } else {
        parsedData.add(PurchaseReturn.fromMap(item));
      }
    }

    return PurchaseReturnResponse(
      success: json["success"],
      message: json["message"] ?? '',
      data: parsedData,
      totalReturn: totalReturn,
    );
  }
}

class PurchaseReturn {
  final dynamic id;
  final dynamic userId;
  final dynamic supplierId;
  final dynamic supplierName;
  final dynamic transactionMethod;
  final dynamic billNumber;
  final dynamic purchaseDate;
  final double discount;
  final double grossTotal;
  final dynamic detailsNotes;
  final dynamic disabled;
  final List<PurchaseDetail> purchaseDetails;

  PurchaseReturn({
    this.id,
    this.userId,
    this.supplierId,
    this.supplierName,
    this.transactionMethod,
    required this.billNumber,
    this.purchaseDate,
    required this.discount,
    required this.grossTotal,
    this.detailsNotes,
    required this.disabled,
    required this.purchaseDetails,
  });

  factory PurchaseReturn.fromMap(Map<String, dynamic> json) => PurchaseReturn(
        id: json["id"],
        userId: json["user_id"],
        supplierId: json["supplier_id"],
        supplierName: json["supplier_name"],
        transactionMethod: json["transaction_method"], // Fixed typo
        billNumber: json["bill_number"],
        purchaseDate: json["purchase_date"],
        // FIX: Handle string numbers properly
        discount: double.tryParse(json["discount"]?.toString() ?? "0") ?? 0.0,
        grossTotal: double.tryParse(json["gross_total"]?.toString() ?? "0") ?? 0.0,
        detailsNotes: json["details_notes"],
        disabled: json["disabled"],
        purchaseDetails: json["purchase_details"] != null
            ? List<PurchaseDetail>.from(
                json["purchase_details"].map((x) => PurchaseDetail.fromMap(x)))
            : [],
      );
}

class PurchaseDetail {
  final dynamic id;
  final dynamic purchaseId;
  final dynamic purchaseDetailsId;
  final dynamic type;
  final dynamic purchaseDate;
  final dynamic itemId;
  final dynamic defaultQty;
  final String qty;
  final String rawQty;
  final dynamic unitId;
  final double price;
  final double subTotal;

  PurchaseDetail({
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
  });

  factory PurchaseDetail.fromMap(Map<String, dynamic> json) => PurchaseDetail(
        id: json["id"],
        purchaseId: json["purchase_id"],
        purchaseDetailsId: json["purchase_details_id"],
        type: json["type"],
        purchaseDate: json["purchase_date"], // Fixed typo
        itemId: json["item_id"],
        defaultQty: json["default_qty"],
        qty: json["qty"]?.toString() ?? "0",
        rawQty: json["raw_qty"]?.toString() ?? "0",
        unitId: json["unit_id"],
        // FIX: Handle string numbers properly
        price: double.tryParse(json["price"]?.toString() ?? "0") ?? 0.0,
        subTotal: double.tryParse(json["sub_total"]?.toString() ?? "0") ?? 0.0,
      );
}






// import 'dart:convert';

 

// class PurchaseReturnResponse {
//   final bool success;
//   final String message;
//   final List<PurchaseReturn> data;
//   final double totalReturn;

//   PurchaseReturnResponse({
//     required this.success,
//     required this.message,
//     required this.data,
//     required this.totalReturn,
//   });

//   factory PurchaseReturnResponse.fromJson(String str) =>
//       PurchaseReturnResponse.fromMap(json.decode(str));

//   factory PurchaseReturnResponse.fromMap(Map<String, dynamic> json) {
//     final List<dynamic> rawList = json["data"];
//     double totalReturn = 0;
//     List<PurchaseReturn> parsedData = [];

//     for (var item in rawList) {
//       // total_return object
//       if (item is Map<String, dynamic> && item.containsKey("total_return")) {
//         totalReturn = double.tryParse(item["total_return"].toString()) ?? 0.0;
//       } else {
//         parsedData.add(PurchaseReturn.fromMap(item));
//       }
//     }

//     return PurchaseReturnResponse(
//       success: json["success"],
//       message: json["message"] ?? '',
//       data: parsedData,
//       totalReturn: totalReturn,
//     );
//   }
// }




// class PurchaseReturn {
//   final dynamic id;
//   final dynamic userId;
//   final dynamic supplierId;
//   final dynamic supplierName;
//   final dynamic transactionMethod;
//   final dynamic billNumber;
//   final dynamic purchaseDate;
//   final dynamic discount;
//   final dynamic grossTotal;
//   final dynamic detailsNotes;
//   final dynamic disabled;
//   final List<PurchaseDetail> purchaseDetails;

//   PurchaseReturn({
//     this.id,
//     this.userId,
//     this.supplierId,
//     this.supplierName,
//     this.transactionMethod,
//     required this.billNumber,
//     this.purchaseDate,
//     required this.discount,
//     required this.grossTotal,
//     this.detailsNotes,
//     required this.disabled,
//     required this.purchaseDetails,
//   });

//   factory PurchaseReturn.fromMap(Map<String, dynamic> json) => PurchaseReturn(
//         id: json["id"] ,
//         userId: json["user_id"], // safely nullable
//         supplierId: json["supplier_id"] ,
//         supplierName: json["supplier_name"],
//         transactionMethod: json["transection_method"],
//         billNumber: json["bill_number"],
//         purchaseDate: json["purchase_date"],
//         discount: (json["discount"] ?? 0).toDouble(),
//         grossTotal: (json["gross_total"] ?? 0).toDouble(),
//         detailsNotes: json["details_notes"],
//         disabled: json["disabled"],
//         purchaseDetails: List<PurchaseDetail>.from(
//             json["purchase_details"].map((x) => PurchaseDetail.fromMap(x))),
//       );
// }

 


// class PurchaseDetail {
//   final dynamic id;
//   final dynamic purchaseId;
//   final dynamic purchaseDetailsId;
//   final dynamic type;
//   final dynamic purchaseDate;
//   final dynamic itemId;
//   final dynamic defaultQty;
//   final dynamic qty;
//   final dynamic rawQty;
//   final dynamic unitId;
//   final dynamic price;
//   final dynamic subTotal;

//   PurchaseDetail({
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
//   });

   


//    factory PurchaseDetail.fromMap(Map<String, dynamic> json) => PurchaseDetail(
//         id: json["id"],
//         purchaseId: json["purchase_id"],
//         purchaseDetailsId: json["purchase_details_id"],
//         type: json["type"],
//         // FIX THIS TYPO: "pruchase_date" should be "purchase_date"
//         purchaseDate: json["purchase_date"], // Fixed from "pruchase_date"
//         itemId: json["item_id"],
//         defaultQty: json["default_qty"],
//         qty: json["qty"],
//         rawQty: json["raw_qty"],
//         unitId: json["unit_id"],
//         price: json["price"],
//         subTotal: json["sub_total"],
//       );
// }

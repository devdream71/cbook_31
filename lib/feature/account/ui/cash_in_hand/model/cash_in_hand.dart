class CashInHandModel {
  bool? success;
  String? message;
  List<CashInHandData>? data;

  CashInHandModel({this.success, this.message, this.data});

  factory CashInHandModel.fromJson(Map<String, dynamic> json) {
    return CashInHandModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<CashInHandData>.from(
              json['data'].map((x) => CashInHandData.fromJson(x)))
          : [],
    );
  }
}

class CashInHandData {
  final int? id;
  final String? date;
  final String? billType;
  final String? billNumber;
  final String? account;
  final String? amount;

  CashInHandData({
    this.id,
    this.date,
    this.billType,
    this.billNumber,
    this.account,
    this.amount,
  });

  factory CashInHandData.fromJson(Map<String, dynamic> json) {
    return CashInHandData(
      id: json['id'],
      date: json['date'],
      billType: json['bill_type'],
      billNumber: json['bill_number'],
      account: json['account'],
      amount: json['amount'],
    );
  }
}

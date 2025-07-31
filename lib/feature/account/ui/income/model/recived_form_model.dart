class ReceiptFromModel {
  List<ReceiptFromData> data;

  ReceiptFromModel({required this.data});

  factory ReceiptFromModel.fromJson(Map<String, dynamic> json) {
    return ReceiptFromModel(
      data: List<ReceiptFromData>.from(json['data'].map((x) => ReceiptFromData.fromJson(x))),
    );
  }
}

class ReceiptFromData {
  int id;
  String accountName;

  ReceiptFromData({required this.id, required this.accountName});

  factory ReceiptFromData.fromJson(Map<String, dynamic> json) {
    return ReceiptFromData(
      id: json['id'],
      accountName: json['account_name'],
    );
  }
}

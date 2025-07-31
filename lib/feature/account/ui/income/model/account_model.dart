class AccountModel {
  List<AccountData> data;

  AccountModel({required this.data});

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      data: List<AccountData>.from(json['data'].map((x) => AccountData.fromJson(x))),
    );
  }
}

class AccountData {
  int id;
  String accountName;

  AccountData({required this.id, required this.accountName});

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      id: json['id'],
      accountName: json['account_name'], // ✅ Correct JSON key //account_name
    );
  }
}

class AccountTypeNameModel {
  final int id;
  final String name;

  AccountTypeNameModel({required this.id, required this.name});

  factory AccountTypeNameModel.fromJson(Map<String, dynamic> json) {
    return AccountTypeNameModel(
      id: json['id'],
      name: json['account_name'],
    );
  }
}

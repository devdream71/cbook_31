class AccountTypeModel {
  final int id;
  final int userId;
  final String accountName;
  final String accountType;
  final String? accountGroup;
  final String? openingBalance;
  final String date;
  final String? accountHolderName;
  final String? accountNo;
  final String? routingNumber;
  final String? bankLocation;
  final int status;

  AccountTypeModel({
    required this.id,
    required this.userId,
    required this.accountName,
    required this.accountType,
    this.accountGroup,
    this.openingBalance,
    required this.date,
    this.accountHolderName,
    this.accountNo,
    this.routingNumber,
    this.bankLocation,
    required this.status,
  });

  factory AccountTypeModel.fromJson(Map<String, dynamic> json) {
    return AccountTypeModel(
      id: json['id'],
      userId: json['user_id'],
      accountName: json['account_name'],
      accountType: json['account_type'],
      accountGroup: json['account_group'],
      openingBalance: json['opening_balance'],
      date: json['date'],
      accountHolderName: json['account_holder_name'],
      accountNo: json['account_no'],
      routingNumber: json['routing_number'],
      bankLocation: json['bank_location'],
      status: json['status'],
    );
  }
}

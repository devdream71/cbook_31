class BankAdjustAccount {
  final int id;
  final String name;

  BankAdjustAccount({required this.id, required this.name});

  factory BankAdjustAccount.fromJson(Map<String, dynamic> json) {
    return BankAdjustAccount(
      id: json['id'],
      name: json['name'],
    );
  }
}
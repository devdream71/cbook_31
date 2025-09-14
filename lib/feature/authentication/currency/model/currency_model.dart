class CurrencyModel {
  final String currency;

  CurrencyModel({required this.currency});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      currency: json['currency'] ?? '',
    );
  }
}

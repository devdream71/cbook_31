class CountryResponse {
  final bool success;
  final String message;
  final List<Country> data;

  CountryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    return CountryResponse(
      success: json['success'],
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((item) => Country.fromJson(item))
          .toList(),
    );
  }
}

class Country {
  final int id;
  final String name;
  final String currency;
  final String code;
  final String symbol;

  Country({
    required this.id,
    required this.name,
    required this.currency,
    required this.code,
    required this.symbol,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      currency: json['currency'],
      code: json['code'],
      symbol: json['symbol'],
    );
  }
}

class CashInHandResponse {
  final int data;

  CashInHandResponse({required this.data});

  factory CashInHandResponse.fromJson(Map<String, dynamic> json) {
    return CashInHandResponse(data: json['data'] ?? 0);
  }
}

class TotalSupplierCountModel {
  final bool success;
  final String message;
  final int data;

  TotalSupplierCountModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TotalSupplierCountModel.fromJson(Map<String, dynamic> json) {
    return TotalSupplierCountModel(
      success: json['success'],
      message: json['message'].toString(),
      data: json['data'],
    );
  }
}

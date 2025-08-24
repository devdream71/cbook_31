class CustomerTransactionCountModel {
  final bool success;
  final dynamic message;
  final double data;

  CustomerTransactionCountModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerTransactionCountModel.fromJson(Map<String, dynamic> json) {
    double rawData = (json['data'] ?? 0).toDouble();

    // ✅ Make positive & format to 2 decimals
    double formattedData = double.parse(rawData.abs().toStringAsFixed(2));

    return CustomerTransactionCountModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: formattedData,
    );
  }
}



// class CustomerTransactionCountModel {
//   final bool success;
//   final dynamic message;
//   final int data;

//   CustomerTransactionCountModel({
//     required this.success,
//     required this.message,
//     required this.data,
//   });

//   factory CustomerTransactionCountModel.fromJson(Map<String, dynamic> json) {
//     return CustomerTransactionCountModel(
//       success: json['success'] ?? false,
//       message: json['message'],
//       data: json['data'] ?? 0,
//     );
//   }
// }

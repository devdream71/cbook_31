class PaidFormModel {
  final bool success;
  final String message;
  final List<PaidFormData> data;

  PaidFormModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaidFormModel.fromJson(Map<String, dynamic> json) {
    return PaidFormModel(
      success: json['success'],
      message: json['message'],
      data: List<PaidFormData>.from(
          json['data'].map((x) => PaidFormData.fromJson(x))),
    );
  }
}

class PaidFormData {
  final int id;
  final String accountName;

  PaidFormData({
    required this.id,
    required this.accountName,
  });

  factory PaidFormData.fromJson(Map<String, dynamic> json) {
    return PaidFormData(
      id: json['id'],
      accountName: json['account_name'],
    );
  }
}

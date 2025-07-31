class AccountCreateResponseModel {
  final bool success;
  final String message;

  AccountCreateResponseModel({
    required this.success,
    required this.message,
  });

  factory AccountCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return AccountCreateResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

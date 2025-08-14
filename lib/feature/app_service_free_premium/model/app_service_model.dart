class AppServiceModel {
  final bool success;
  final String message;
  final String appService;

  AppServiceModel({
    required this.success,
    required this.message,
    required this.appService,
  });

  factory AppServiceModel.fromJson(Map<String, dynamic> json) {
    return AppServiceModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      appService: json['data'] != null ? json['data']['app_service'] ?? '' : '',
    );
  }
}

class ReceiveFromItem {
  final int id;
  final String accountName;

  ReceiveFromItem({required this.id, required this.accountName});

  factory ReceiveFromItem.fromJson(Map<String, dynamic> json) {
    return ReceiveFromItem(
      id: json['id'],
      accountName: json['account_name'],
    );
  }
}

class ReceiveFromModel {
  final bool success;
  final String message;
  final List<ReceiveFromItem> data;

  ReceiveFromModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReceiveFromModel.fromJson(Map<String, dynamic> json) {
    return ReceiveFromModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((e) => ReceiveFromItem.fromJson(e))
          .toList(),
    );
  }
}

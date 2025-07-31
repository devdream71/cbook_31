class ExpenseListModel {
  bool success;
  String message;
  List<ExpenseData> data;
  String totalExpense;

  ExpenseListModel({
    required this.success,
    required this.message,
    required this.data,
    required this.totalExpense,
  });

  factory ExpenseListModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawData = json['data'] ?? [];
    List<ExpenseData> expenseDataList = [];
    String total = '0.00';

    for (var item in rawData) {
      if (item is Map<String, dynamic> && item.containsKey('id')) {
        expenseDataList.add(ExpenseData.fromJson(item));
      } else if (item is Map<String, dynamic> && item.containsKey('total_expense')) {
        total = item['total_expense'] ?? '0.00';
      }
    }

    return ExpenseListModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: expenseDataList,
      totalExpense: total,
    );
  }
}

class ExpenseData {
  int id;
  String type;
  String voucherNumber;
  String voucherDate;
  String voucherTime;
  String receivedTo;
  int totalAmount;
  String notes;
  int accountID;

  ExpenseData({
    required this.id,
    required this.type,
    required this.voucherNumber,
    required this.voucherDate,
    required this.voucherTime,
    required this.receivedTo,
    required this.totalAmount,
    required this.notes,
    required this.accountID,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: json['id'],
      type: json['type'] ?? '',
      voucherNumber: json['voucher_number'] ?? '',
      voucherDate: json['voucher_date'] ?? '',
      voucherTime: json['voucher_time'] ?? '',
      receivedTo: json['received_to'] ?? '',
      totalAmount: json['total_amount'] ?? 0,
      notes: json['notes'] ?? '',
      accountID: json['account_id'],
    );
  }
}

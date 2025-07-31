class IncomeItem {
  final String accountId;
  final String narration;
  final String amount;

  IncomeItem({
    required this.accountId,
    required this.narration,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'narration': narration,
        'amount': amount,
      };
}

class IncomeStoreRequest {
  final List<IncomeItem> incomeItems;

  IncomeStoreRequest({required this.incomeItems});

  Map<String, dynamic> toJson() => {
        'income_items': incomeItems.map((item) => item.toJson()).toList(),
      };
}

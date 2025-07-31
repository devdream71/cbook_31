class ExpenseItemPopUp {
  final String itemAccountId;
  final String narration;
  final String amount;

  ExpenseItemPopUp({
    required this.itemAccountId,
    required this.narration,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'account_id': itemAccountId,
        'narration': narration,
        'amount': amount,
        
      };
}

class ExpenseStoreRequest {
  final List<ExpenseItemPopUp> expenseItems;

  ExpenseStoreRequest({required this.expenseItems});

  Map<String, dynamic> toJson() => {
        'expense_items': expenseItems.map((item) => item.toJson()).toList(),
      };
}

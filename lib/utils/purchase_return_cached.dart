import 'package:shared_preferences/shared_preferences.dart';

class PurchaseReturnCached {
  String? cashCreditGroup;
  bool isCash;
  bool isReturnAmount;
  bool isAdditionalCost;
  bool isTotalReturnAmount;
  bool isSalesAmount;
  bool isDiscount;
  bool isAdditionalCost2;
  bool isMergeAmount;
  bool isAmount;
  bool isAdditionalCostCredit;
  bool isTotalAmount;
  bool isPaymentType;
  bool isPaymentAmount;
  bool isDue;

  PurchaseReturnCached({
    this.cashCreditGroup,
    this.isCash = true,
    this.isReturnAmount = false,
    this.isAdditionalCost = false,
    this.isTotalReturnAmount = false,
    this.isSalesAmount = false,
    this.isDiscount = false,
    this.isAdditionalCost2 = false,
    this.isMergeAmount = false,
    this.isAmount = false,
    this.isAdditionalCostCredit = false,
    this.isTotalAmount = false,
    this.isPaymentType = false,
    this.isPaymentAmount = false,
    this.isDue = false,
  });

  // Save to shared preferences
  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cashCreditGroup', cashCreditGroup ?? '');
    prefs.setBool('isCash', isCash);
    prefs.setBool('isReturnAmount', isReturnAmount);
    prefs.setBool('isAdditionalCost', isAdditionalCost);
    prefs.setBool('isTotalReturnAmount', isTotalReturnAmount);
    prefs.setBool('isSalesAmount', isSalesAmount);
    prefs.setBool('isDiscount', isDiscount);
    prefs.setBool('isAdditionalCost2', isAdditionalCost2);
    prefs.setBool('isMergeAmount', isMergeAmount);
    prefs.setBool('isAmount', isAmount);
    prefs.setBool('isAdditionalCostCredit', isAdditionalCostCredit);
    prefs.setBool('isTotalAmount', isTotalAmount);
    prefs.setBool('isPaymentType', isPaymentType);
    prefs.setBool('isPaymentAmount', isPaymentAmount);
    prefs.setBool('isDue', isDue);
  }

  // Load from shared preferences
  static Future<PurchaseReturnCached> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return PurchaseReturnCached(
      cashCreditGroup: prefs.getString('cashCreditGroup'),
      isCash: prefs.getBool('isCash') ?? true,
      isReturnAmount: prefs.getBool('isReturnAmount') ?? false,
      isAdditionalCost: prefs.getBool('isAdditionalCost') ?? false,
      isTotalReturnAmount: prefs.getBool('isTotalReturnAmount') ?? false,
      isSalesAmount: prefs.getBool('isSalesAmount') ?? false,
      isDiscount: prefs.getBool('isDiscount') ?? false,
      isAdditionalCost2: prefs.getBool('isAdditionalCost2') ?? false,
      isMergeAmount: prefs.getBool('isMergeAmount') ?? false,
      isAmount: prefs.getBool('isAmount') ?? false,
      isAdditionalCostCredit: prefs.getBool('isAdditionalCostCredit') ?? false,
      isTotalAmount: prefs.getBool('isTotalAmount') ?? false,
      isPaymentType: prefs.getBool('isPaymentType') ?? false,
      isPaymentAmount: prefs.getBool('isPaymentAmount') ?? false,
      isDue: prefs.getBool('isDue') ?? false,
    );
  }
}

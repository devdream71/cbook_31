import 'dart:convert';
import 'package:cbook_dt/feature/purchase/model/purchase_create_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/date_time_helper.dart';
import '../../item/model/items_show.dart';
import '../../sales/sales_view.dart';
import 'package:http/http.dart' as http;

class PurchaseController extends ChangeNotifier {
  TextEditingController mrpController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController amountController2 = TextEditingController();
  TextEditingController discountPercentageController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController additionalCostController = TextEditingController();
  TextEditingController subtotalController = TextEditingController();
  TextEditingController receivedMoneyController = TextEditingController();
  TextEditingController returnController = TextEditingController();
  TextEditingController dueController = TextEditingController();
  TextEditingController billReceiptController = TextEditingController();
  TextEditingController previousReceiptController = TextEditingController();
  TextEditingController advancedController = TextEditingController();
  TextEditingController billTotal = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController amountCreditController = TextEditingController();
  TextEditingController amountCreditController2 = TextEditingController();
  TextEditingController subtotalCreditController = TextEditingController();
  TextEditingController additionalCostCreditController =
      TextEditingController();
  TextEditingController discountPercentageCreditController =
      TextEditingController();
  TextEditingController purchaseNoteController = TextEditingController();
  TextEditingController receivedAmountController = TextEditingController();
  TextEditingController discountController = TextEditingController();

   TextEditingController controller = TextEditingController(text: "Cash");

  List<ItemModel> itemsCash = [];
  List<ItemModel> itemsCredit = [];
  List<PurchaseItemModel> purchaseItem = [];
  List<String> unitIdsList = [];
  
  String text = "Cash";

  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedUnit;
  String? selectedWarehouse;
  String? selectedReceiptType;
  String? seletedItemName;
  bool isCreditSale = true;
  
  double purchasePrice = 0.0;
  int onlinePaymentValue = 0;
  double _subtotalItemDialog = 0.0;

  int unitQty = 1;

  String primaryUnitName = '';
  String secondaryUnitName = '';
  String customerName = "";
  String phone = "";
  String email = "";
  String address = "";
  String selcetedItemId = "";

  bool isAmountCredit = true;
  bool isDiscountCredit = true;
  bool isAdditionalCredit = true;
  bool isSubTotalCredit = true;
  bool isBillRecipt = true;
  bool isPreviousRecipt = true;
  bool isAdvance = true;
  bool isBillTotal = true;
  bool isDue = true;
  bool isAmount = true;
  bool isDisocunt = true;
  bool isAdditionalCost = true;
  bool isSubTotoal = true;
  bool isReciptType = true;
  bool isRecivedMoney = true;
  bool isReturn = true;
  bool _isListenerAttached = false;
  bool isOnlineMoneyChecked = false;
  bool isCash = true;
  bool isReceived = true;

  double get subtotalItemDiolog => _subtotalItemDialog;


  void dialogtotalController() {
    if (_isListenerAttached) return;
    mrpController.addListener(_dialogSubtotal);
    qtyController.addListener(_dialogSubtotal);
    _isListenerAttached = true;
  }

  void _dialogSubtotal() {
    final price = double.tryParse(mrpController.text) ?? 0;
    final qty = double.tryParse(qtyController.text) ?? 0;
    _subtotalItemDialog = price * qty;
    notifyListeners();
  }

  void clearFields() {
    mrpController.clear();
    qtyController.clear();
    _subtotalItemDialog = 0.0;
    _isListenerAttached = false;
  }

  void updateUnitIds(List<String> units) {
    unitIdsList = units;
    notifyListeners();
  }

// Ensure discount input is controlled

  
  ///cash...discount amount and percentance
  void updateDiscountcash(String value) {
    double discountAmount = double.tryParse(value) ?? 0.0;
    double subtotal = double.tryParse(addAmount2()) ?? 0.0;

    if (subtotal > 0) {
      double percentage = (discountAmount / subtotal) * 100;
      discountAmountController.text = percentage.toStringAsFixed(2);
    } else {
      discountAmountController.text = "0.00";
    }

    // No need to reassign value to discountController.text again
    notifyListeners();
  }

  ///cash.  upadte discount percentanct
  void updateDiscountPercentageCash(String value) {
  double percentage = double.tryParse(value) ?? 0.0;
  double subtotal = double.tryParse(addAmount2()) ?? 0.0;

  if (subtotal > 0) {
    double discount = (percentage / 100) * subtotal;
    discountController.text = discount.toStringAsFixed(2);
  } else {
    discountController.text = "0.00";
  }

  notifyListeners();
}


  
  ///credit...discount amount and percentance 
  void updateDiscountCredit(String value) {
    double discountAmount = double.tryParse(value) ?? 0.0;
    double subtotal = double.tryParse(addAmount()) ?? 0.0;

    if (subtotal > 0) {
      double percentage = (discountAmount / subtotal) * 100;
      discountAmountController.text = percentage.toStringAsFixed(2);
    } else {
      discountAmountController.text = "0.00";
    }

    // No need to reassign value to discountController.text again
    notifyListeners();
  }


  ///credit discount percentace to amount calculation.
   void updateDiscountPercentageCredit(String value) {
  double percentage = double.tryParse(value) ?? 0.0;
  double subtotal = double.tryParse(addAmount()) ?? 0.0;

  if (subtotal > 0) {
    double discount = (percentage / 100) * subtotal;
    discountController.text = discount.toStringAsFixed(2);
  } else {
    discountController.text = "0.00";
  }

  notifyListeners();
}



  void updateOnlineMoney() {
    isOnlineMoneyChecked = !isOnlineMoneyChecked;

    // Set value: 0=unpaid;1=partial;2=paid
    onlinePaymentValue = isOnlineMoneyChecked ? 2 : 1;

    if (isOnlineMoneyChecked) {
      receivedAmountController.text = totalAmount2;
    } else {
      receivedAmountController.clear();
    }

    notifyListeners();
  }

  void updateCash() {
    isCash = !isCash;
    isReceived =
        isCash; // Automatically check when cash is selected, uncheck when credit is selected
    discountController.clear();
    itemsCash.clear();
    itemsCredit.clear();
    discountAmountController.clear();
    notifyListeners();
  }

  void itemUpdate(String item, List<ItemsModel> items) {
    seletedItemName = item;
    if (items.isNotEmpty) {
      items.forEach((e) {
        if (item == e.name.toString()) {
          selcetedItemId = e.id.toString();
        }
      });
    }
    notifyListeners();
  }

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String get formattedDate => DateTimeHelper.formatDate(_selectedDate);
  String get formattedTime => DateTimeHelper.formatTimeOfDay(_selectedTime);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  //for form settiing

  void updateIsAmount() {
    isAmount = !isAmount;
    notifyListeners();
  }

  void updateIsDiscount() {
    isDisocunt = !isDisocunt;
    notifyListeners();
  }

  void updateIsAdditionalCost() {
    isAdditionalCost = !isAdditionalCost;
    notifyListeners();
  }

  void updateIsSubTotal() {
    isSubTotoal = !isSubTotoal;
    notifyListeners();
  }

  void updateIsReciptType() {
    isReciptType = !isReciptType;
    notifyListeners();
  }

  void updateIsRecivedMoney() {
    isRecivedMoney = !isRecivedMoney;
    notifyListeners();
  }

  void updateIsReturn() {
    isReturn = !isReturn;
    notifyListeners();
  }

//credit

  void updateIsAmountCredit() {
    isAmountCredit = !isAmountCredit;
    notifyListeners();
  }

  void updateIsDiscountCredit() {
    isDiscountCredit = !isDiscountCredit;
    notifyListeners();
  }

  void updateIsAdditionalCredit() {
    isAdditionalCredit = !isAdditionalCredit;
    notifyListeners();
  }

  void updateIsSubTotalCredit() {
    isSubTotalCredit = !isSubTotalCredit;
    notifyListeners();
  }

  void updateIsBillRecipt() {
    isBillRecipt = !isBillRecipt;
    notifyListeners();
  }

  void updateIsPreviousRecipt() {
    isPreviousRecipt = !isPreviousRecipt;
    notifyListeners();
  }

  void updateIsAdvance() {
    isAdvance = !isAdvance;
    notifyListeners();
  }

  void updateIsBillTotal() {
    isBillTotal = !isBillTotal;
    notifyListeners();
  }

  void updateIsDue() {
    isDue = !isDue;
    notifyListeners();
  }

  //end form setting

  updateCashForDefaultSet() {
    isCash = true;
    notifyListeners();
  }

  updateCreditForDefaultSet() {
    isCash = false;
    notifyListeners();
  }

  updatedCustomerInfomation(
      {required String nameFrom,
      required String phoneFrom,
      required String emailFrom,
      required String addressFrom}) {
    customerName = nameFrom;
    phone = phoneFrom;
    email = emailFrom;
    address = addressFrom;

    notifyListeners();
    debugPrint("as $customerName");
  }

  Future<void> pickTime(BuildContext context) async {
    final pickedTime = await DateTimeHelper.pickTime(context, _selectedTime);
    if (pickedTime != null && pickedTime != _selectedTime) {
      _selectedTime = pickedTime;
      notifyListeners();
    }
  }

  ////credit
  String addAmount() {
    if (itemsCredit.isNotEmpty) {
      double subtotal = 0.0;

      debugPrint("dddd $subtotal");

      for (var element in itemsCredit) {
        // Ensure values are not null or empty before parsing
        double price = double.tryParse(element.mrp?.toString() ?? "0") ?? 0.0;
        double quantity =
            double.tryParse(element.quantity?.toString() ?? "0") ?? 0.0;
        debugPrint("$price $quantity");
        subtotal += price * quantity;
      }

      debugPrint(subtotal.toString());

      return subtotal.toStringAsFixed(2); // Format to 2 decimal places
    }
    return "0.00";
  }

  ///purchase cash
  String addAmount2() {
    if (itemsCash.isNotEmpty) {
      double subtotal = 0.0;
      debugPrint("dddd $subtotal");

      for (var element in itemsCash) {
        // Ensure values are not null or empty before parsing
        double price = double.tryParse(element.mrp?.toString() ?? "0") ?? 0.0;
        double quantity =
            double.tryParse(element.quantity?.toString() ?? "0") ?? 0.0;

        debugPrint("$price $quantity");

        subtotal += price * quantity;
      }

      debugPrint(subtotal.toString());

      return subtotal.toStringAsFixed(2); // Format to 2 decimal places
    }
    return "0.00";
  }

  ///==> cash total
  String get totalAmount {
    double subtotal = double.tryParse(addAmount2()) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double total = subtotal - discount;
    //notifyListeners();

    debugPrint(
        "Subtotal: $subtotal, Discount: $discount, Total: $total"); // Debugging

    return total.toStringAsFixed(2);
  }

  ///===>credit total
  String get totalAmount2 {
    double subtotal = double.tryParse(addAmount()) ?? 0.0; // Get subtotal
    debugPrint(subtotal.toString());
    double discount =
        double.tryParse(discountController.text) ?? 0.0; // Get discount
    double total = subtotal - discount; // Calculate total

    //notifyListeners();

    debugPrint("Subtotal: $subtotal, Discount: $discount, Total: $total");

    debugPrint(total.toString());

    return total.toStringAsFixed(2);
    // Format to 2 decimal places
  }

  void clearPurchaseForm() {
    purchaseItem.clear();
    amountController.clear();
    amountController2.clear();
    receivedAmountController.clear();
    discountController.clear();
    noteController.clear();
    purchaseItem.clear();

    // Reset any other state if needed

    isCash = true; // or false based on your default
    notifyListeners();
  }

  /// Store purchase API call
  Future<bool> storePurchase(
    BuildContext context, {
    required String date,
    required String amount,
    required String total,
    required String discount,
    required saleType,
    required String customerId,
    required String billNo,
    String? note,
    String? paymnetAmount,
    int? billPersonId,
  }) async {
    // Notify UI about loading state

    try {
      debugPrint("bill $billNo");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Check if bill_number exists, if not, set an initial value
      // if (!prefs.containsKey("bill_number")) {
      //   await prefs.setInt("bill_number", 521444); // Set default bill number
      // }

      // Get the last bill number and increment it
      //int lastBillNumber = prefs.getInt("bill_number") ?? 521444;
      //int newBillNumber = lastBillNumber + 1;

      // Save the updated bill number
      //await prefs.setInt("bill_number", newBillNumber);

      debugPrint('$noteController');

      onlinePaymentValue;

      final String note = noteController.text;

      // Calculate total amount

      // ✅ Convert String date to DateTime before formatting
      DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(date);

      // ✅ Format the date properly
      String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);

      // ✅ Encode the formatted date to avoid errors in the URL
      String encodedDate = Uri.encodeComponent(formattedDate);

      debugPrint(
          "amount =====>${customerId.isNotEmpty ? addAmount() : addAmount2()}");
      debugPrint(
          "total =====>${customerId.isNotEmpty ? totalAmount2 : totalAmount}");
      debugPrint("discount =====>${discountController.text}");

      debugPrint("customerId =====>$customerId");
      debugPrint("date =====>$date");

      debugPrint("Cash Subtotal: ${addAmount2()}");
      debugPrint("Cash Total (after discount): $totalAmount");
      debugPrint("Note : $note");

      debugPrint("bill $billNo");

      final encodedNote = Uri.encodeComponent(note ?? "");

      //"https://commercebook.site/api/v1/purchase/store?user_id=${prefs.getString("id")}&customer_id=${purchaseCreditOrCash ? "cash" : selectedCustomerId}&bill_number=${newBillNumber}&pruchase_date=${billDate}&details_notes=notes&gross_total=${calculateSubTotal()}&discount=0&payment_out=${purchaseCreditOrCash ? 1 : 0}&payment_amount=${purchaseCreditOrCash ? calculateSubTotal() : paymentController.value.text}";

      final url =
          "https://commercebook.site/api/v1/purchase/store?user_id=${prefs.getInt("user_id").toString()}&customer_id=${customerId.isNotEmpty ? customerId : 'cash'}&bill_number=$billNo&purchase_date=$encodedDate&details_notes=$note&gross_total=${isCash ? addAmount2() : addAmount()}&discount=$discount&payment_out=${isCash ? 1 : onlinePaymentValue}&payment_amount=${isCash ? totalAmount : paymnetAmount}&bill_person_id=$billPersonId";

      debugPrint("API URL: $url");

      // Prepare request body
      final requestBody = {
        "purchase_items": purchaseItem.map((item) => item.toJson()).toList(),
        // "details_notes": note ?? "",
      };

      debugPrint("Request Body: $requestBody");


      debugPrint("Stop === > ");


      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      debugPrint("API Response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          clearPurchaseForm();
          notifyListeners();
          return true;
        } else {
          notifyListeners();
          return false;
        }
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  addCreditItem() {
    debugPrint(
        "Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

    itemsCredit.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "I",
      unit: selectedUnit ?? "PC",
      //discount: discountController.text,
      itemCode: codeController.text,
      mrp: mrpController.text,
      quantity: qtyController.text,
      total: amountController.text,
    ));
    purchaseItem.add(PurchaseItemModel(
        itemId: selcetedItemId,
        price: mrpController.value.text,
        qty: qtyController.value.text,
        subTotal: (double.parse(mrpController.value.text) *
                double.parse(qtyController.value.text))
            .toString(),
        unitId: selectedUnitIdWithName));

    codeController.clear();
    mrpController.clear();
    qtyController.clear();
    amountController.clear();
    unitController.clear();
    priceController.clear();

    notifyListeners();
  }

  void removeCreditItem(int index) {
    // Remove the item from the itemsCash list
    itemsCredit.removeAt(index);

    // Also remove the corresponding purchase item from purchaseItem list
    purchaseItem.removeAt(index);

    // Notify listeners to update UI
    notifyListeners();
  }

  void removeCashItem(int index) {
    // Remove the item from the itemsCash list
    itemsCash.removeAt(index);

    // Also remove the corresponding purchase item from purchaseItem list
    purchaseItem.removeAt(index);

    // Notify listeners to update UI
    notifyListeners();
  }

  List<PurchaseItemModel> purchaseUpdateList = [];

  ///add cash item
  addCashItemPurchaseUpdate() {
    debugPrint(
        "Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");
    itemsCash.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      unit: selectedUnit ?? "dc",
      itemCode: codeController.text,
      mrp: mrpController.text,
      quantity: qtyController.text,
      total: amountController.text,
      //discount: discountController.text,
    ));
    purchaseItem.add(PurchaseItemModel(
        itemId: selcetedItemId,
        price: mrpController.value.text,
        qty: qtyController.value.text,
        subTotal: (double.parse(mrpController.value.text) *
                double.parse(qtyController.value.text))
            .toString(),
        unitId: selectedUnitIdWithName));

    codeController.clear();
    mrpController.clear();
    qtyController.clear();
    amountController.clear();
    unitController.clear();
    priceController.clear();

    notifyListeners();
  }

  addCashItem() {
    debugPrint(
        "Add Item Clicked $selectedUnit $amountController $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

    itemsCash.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      // unit: selectedUnit ??
      //     (unitIdsList.isNotEmpty ? unitIdsList.first : "DC"), // ✅ fallback
      unit: selectedUnit ?? "N/A",
      itemCode: codeController.text,
      mrp: mrpController.text,
      quantity: qtyController.text,
      total: amountController.text,
      //discount: discountController.text,
    ));

    purchaseItem.add(PurchaseItemModel(
      itemId: selcetedItemId,
      price: mrpController.value.text,
      qty: qtyController.value.text,
      subTotal: (double.parse(mrpController.value.text) *
              double.parse(qtyController.value.text))
          .toString(),
      unitId: selectedUnitIdWithName,
    ));

    // Clear controllers
    codeController.clear();
    mrpController.clear();
    qtyController.clear();
    amountController.clear();
    unitController.clear();
    priceController.clear();

    notifyListeners();
  }

  // Remove Cash Item

// void removeCashItem(int index) {
//     itemsCash.removeAt(index);
//     notifyListeners();
//   }

  void updateCategory(String? newValue) {
    debugPrint("cccc $newValue");
    selectedCategory = newValue!;
    debugPrint("ddd $selectedCategory");
    notifyListeners();
  }

  void updateWarehouse(String? newValue) {
    selectedWarehouse = newValue!;
    notifyListeners();
  }

  void updateSubCategory(String? newValue) {
    selectedSubCategory = newValue!;
    notifyListeners();
  }

  void updateItemName(String? newValue) {
    seletedItemName = newValue!;
    notifyListeners();
  }

  void updatedOnlineMoney() {
    isOnlineMoneyChecked = !isOnlineMoneyChecked;
    notifyListeners();
  }

  void updateReceiptType(String? newValue) {
    selectedReceiptType = newValue!;
    notifyListeners();
  }

  void updateUnitDropdown(String selectedUnit) {}
  String selcetedUnitId = "";

  String selectedUnitIdWithName = "";

  void selectedUnitIdWithNameFunction(String data) {
    selectedUnitIdWithName = data;
    notifyListeners();
  }

  bool isNoti = false;

  void addNoti(bool bool) {
    isNoti = bool;
    notifyListeners();
  }

  String selectedCategoryId = "";
  void updateCategoryNew(newValue) {
    selectedCategoryId = newValue;
    notifyListeners();
  }

  String selectedSubCategoryId = "";

  void updateSubCategoryNew(String value) {
    selectedSubCategoryId = value;
    notifyListeners();
  }

  void selectedItemNameNew(String value) {
    seletedItemName = value;
    notifyListeners();
  }
}

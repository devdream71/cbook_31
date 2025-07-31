import 'dart:convert';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/item/model/items_show.dart';
import 'package:cbook_dt/feature/sales/model/sale_create_model.dart';
import 'package:cbook_dt/feature/unit/model/unit_response_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/date_time_helper.dart';
import '../sales_view.dart';
import 'package:http/http.dart' as http;

class SalesController extends ChangeNotifier {
  String formattedDate2 = '';

  bool hasCustomPrice = false;
  double _taxPercent = 0.0;
  double _taxAmount = 0.0;
  double get taxPercent => _taxPercent;
  double get taxAmount => _taxAmount;
  double get totalWithTax => _subtotal + _taxAmount;
  double get subtotalWithTax => subtotal + taxAmount;
  TextEditingController mrpController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController saleNoteController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController saleUpdateNoteController = TextEditingController();

  ///discount amount and discount percentance.
  TextEditingController discountAmount = TextEditingController();
  TextEditingController discountPercentance = TextEditingController();

  TextEditingController controller = TextEditingController(text: "Cash");

  String? selectedCategory;
  String? selectedWarehouse;
  String? selectedSubCategory;
  String? selectedStatus;
  String? price;
  // bool isOnlineMoneyChecked = false;
  String? selectedReceiptType;

  String customerName = "";
  String phone = "";
  String email = "";
  String address = "";

  TextEditingController amountController = TextEditingController();
  TextEditingController amountController2 = TextEditingController();
  TextEditingController discountPercentageController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController additionalCostController = TextEditingController();
  TextEditingController subtotalController = TextEditingController();
  TextEditingController receivedMoneyController = TextEditingController();
  TextEditingController returnController = TextEditingController();
  TextEditingController dueController = TextEditingController();

  TextEditingController codeController = TextEditingController();

  TextEditingController unitController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();

  TextEditingController totalController = TextEditingController();

  //add item
  TextEditingController nameAddItemController = TextEditingController();

  ////add item stock and price
  TextEditingController stockAddItemController = TextEditingController();
  TextEditingController priceAddItemController = TextEditingController();

  TextEditingController valueAddItemController = TextEditingController();

  String lastChanged = '';

  double _subtotal = 0.0;
  double get subtotal => _subtotal;

  bool isOnlineMoneyChecked = false;

  String? seletedItemName;

  TextEditingController billController = TextEditingController();
  TextEditingController billPerson = TextEditingController();

  TextEditingController receivedAmountController = TextEditingController();
  TextEditingController discountController =
      TextEditingController(); // Ensure discount input is controlled

  TextEditingController percentController = TextEditingController();

  ///add item cash
  List<SaleItemModel> saleItem = [];

  ///add item cash
  List<ItemModel> itemsCash = [];

  List<ItemModel> itemsCredit = [];

  List<String> unitIdsList = [];

  bool isCash = true;
  bool isReceived = true;

  bool isCreditSale = true; // Default to credit sale, update as needed

  ///sales tax vat provider.
  double? selectedTaxPercent;
  String taxPercentValue = "";
  String totaltaxPercentValue = "";

  String? selectedTaxId;

  double totalItemDiscounts = 0.0;
  double totalItemVats = 0.0;

  //sales field portion date tax and vat
  String? selectedTotalTaxId;
  double selectedTotalTaxPercent = 0.00;
  double totalTaxAmountl = 0.00;

  //for form settiing
  bool isAmount = true;
  bool isDisocunt = true;
  bool isVatTax = true;
  bool isAdditionalCost = true;
  bool isSubTotoal = true;
  bool isReciptType = true;
  bool isRecivedMoney = true;
  bool isReturn = true;

  bool isBillRecipt = true;
  bool isPreviousRecipt = true;
  bool isAdvance = true;
  bool isBillTotal = true;

  String primaryUnitName = "";
  String secondaryUnitName = "";
  double salePrice = 0.0;
  dynamic unitQty = 1.0;
//bool hasCustomPrice = false;

  String unitIdWithQty = "";

  salesControllerItemamount() {
    salesControllerItem();
  }

  void updateItem(int index, ItemModel updatedItem) {
    if (index >= 0 && index < itemsCash.length) {
      itemsCash[index] = updatedItem;
      //notifyListeners();
    }
  }

  salesControllerItem() {
    qtyController.addListener(calculateSubtotal);
    mrpController.addListener(calculateSubtotal);
    discountAmount.addListener(calculateSubtotal);
  }

  ///credit tax working ==== 21.7.25
  void calculateTax() {
    _taxAmount = (_subtotal * _taxPercent) / 100;
    notifyListeners();
  }

  void calculateTaxCash() {
    _taxAmount = (_subtotal * _taxPercent) / 100;
    notifyListeners();
  }

  ///credit tax total
  void calculateTotal() {
    double subtotal = double.tryParse(addAmount2()) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double total = subtotal - discount + taxAmount;

    notifyListeners(); // 👈 Important
  }

  ///cash
  void calculateTotalCash() {
    double subtotal = double.tryParse(addAmount()) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double total = subtotal - discount + taxAmount;

    notifyListeners(); // 👈 Important
  }

  set taxPercent(double value) {
    _taxPercent = value;
    calculateTax(); // 🔁 only recalculate tax when percent changes
    notifyListeners();
  }

  void calculateSubtotal() {
    double qty = double.tryParse(qtyController.text) ?? 0;
    double price = double.tryParse(mrpController.text) ?? 0;
    double total = qty * price;

    double discountPercent = double.tryParse(discountPercentance.text) ?? 0;
    double discountAmt = double.tryParse(discountAmount.text) ?? 0;

    if (lastChanged == 'percent') {
      discountAmt = (total * discountPercent) / 100;
      discountAmount.text = discountAmt.toStringAsFixed(2);
    } else if (lastChanged == 'amount') {
      if (total > 0) {
        discountPercent = (discountAmt / total) * 100;
        discountPercentance.text = discountPercent.toStringAsFixed(2);
      } else {
        discountPercentance.text = '0';
      }
    }

    _subtotal = total - discountAmt;
    if (_subtotal < 0) _subtotal = 0;

    debugPrint('--- calculateSubtotal called ---');
    debugPrint(
      'Qty: $qty, Price: $price, Discount %: $discountPercent, '
      'Discount Amount: $discountAmt, Subtotal: $_subtotal',
    );

    notifyListeners(); // No tax calculation here
  }

  set taxAmount(double value) {
    _taxAmount = value;
    notifyListeners();
  }

  // 🔥 ADDITIONAL FIX: Make sure you have a proper taxAmount2 getter
  double get taxAmount2 {
    double subtotal = double.tryParse(addAmount()) ?? 0.0; // Use credit amount
    return (subtotal * (_taxPercent / 100));
  }

// 🔥 ADDITIONAL FIX: Add a method to calculate tax for individual items

  void clearFields() {
    mrpController.clear();
    qtyController.clear();
    discountAmount.clear();
    discountPercentance.clear();
    _taxAmount = 0.0; // 👈 fixed
    _taxPercent = 0.0;
    _subtotal = 0.0;
    notifyListeners();
  }

  void updateUnitIds(List<String> units) {
    unitIdsList = units;
    notifyListeners();
  }

  void updateDiscountAmount(String value) {
    if (value.isEmpty || double.tryParse(value) == null) {
      percentController.text = '';
      notifyListeners();
      return;
    }

    final discount = double.tryParse(value) ?? 0;
    final total = double.tryParse(totalAmount) ?? 1;
    final percent = (discount / total) * 100;

    percentController.text = percent.toStringAsFixed(2);
    notifyListeners();
  }

  void updateDiscountAmountUpdate(String value) {
    if (value.isEmpty || double.tryParse(value) == null) {
      percentController.text = '';
      notifyListeners();
      return;
    }

    final discount = double.tryParse(value) ?? 0;
    final total = double.tryParse(totalAmount) ?? 1;
    final percent = (discount / total) * 100;

    percentController.text = percent.toStringAsFixed(2);
    notifyListeners();
  }

  void updateDiscountAmountUpdate2(String value) {
    if (value.isEmpty || double.tryParse(value) == null) {
      percentController.text = '';
      notifyListeners();
      return;
    }

    final discount = double.tryParse(value) ?? 0;
    final total = double.tryParse(totalAmount) ?? 1;
    final percent = (discount / total) * 100;

    percentController.text = percent.toStringAsFixed(2);
    notifyListeners();
  }

  void updateDiscountPercent(String value) {
    if (value.isEmpty || double.tryParse(value) == null) {
      discountController.text = '';
      debugPrint("Invalid or empty discount percent entered.");
      notifyListeners();
      return;
    }

    final percent = double.tryParse(value) ?? 0;
    final total = double.tryParse(totalAmount) ?? 1;
    final discount = (percent / 100) * total;

    // Update the discount field
    discountController.text = discount.toStringAsFixed(2);

    // Debug output
    debugPrint("Discount amount: $discount from $percent% of total $total");

    notifyListeners();
  }

  //credit discount amount
  void updateDiscountCreditAmount(String value) {
    if (value.isEmpty || double.tryParse(value) == null) {
      percentController.text = '';
      notifyListeners();
      return;
    }

    final discount = double.tryParse(value) ?? 0;
    final total = double.tryParse(totalAmount2) ?? 1;
    final percent = (discount / total) * 100;

    percentController.text = percent.toStringAsFixed(2);
    notifyListeners();
  }

  ///credit discount percentance
  void updateDiscountCreditPercent(String value) {
    if (value.isEmpty || double.tryParse(value) == null) {
      discountController.text = '';
      debugPrint("Invalid or empty discount percent entered.");
      notifyListeners();
      return;
    }

    final percent = double.tryParse(value) ?? 0;
    final total = double.tryParse(totalAmount2) ?? 1;
    final discount = (percent / 100) * total;

    // Update the discount field
    discountController.text = discount.toStringAsFixed(2);

    // Debug output
    debugPrint("Discount amount: $discount from $percent% of total $total");

    notifyListeners();
  }

  //cash discount amount
  void updateDiscountCashAmount(String value) {
    if (value.isEmpty || double.tryParse(value) == null) {
      percentController.text = '';
      notifyListeners();
      return;
    }

    final discount = double.tryParse(value) ?? 0;
    final total = double.tryParse(addAmount2()) ?? 1;
    final percent = (discount / total) * 100;

    percentController.text = percent.toStringAsFixed(2);
    notifyListeners();
  }

  ///cash discount percentance
  void updateDiscountCashPercent(String value) {
    if (value.isEmpty || double.tryParse(value) == null) {
      discountController.text = '';
      debugPrint("Invalid or empty discount percent entered.");
      notifyListeners();
      return;
    }

    final percent = double.tryParse(value) ?? 0;
    final total = double.tryParse(addAmount2()) ?? 1;
    final discount = (percent / 100) * total;

    // Update the discount field
    discountController.text = discount.toStringAsFixed(2);

    // Debug output
    debugPrint("Discount amount: $discount from $percent% of total $total");

    notifyListeners();
  }

  void clearPercentance() {
    percentController.clear();
  }

  void updateOnlineMoney() {
    isOnlineMoneyChecked = !isOnlineMoneyChecked;
    if (isOnlineMoneyChecked) {
      receivedAmountController.text =
          totalAmount2; // ✅ Set total amount when checked
    } else {
      receivedAmountController.clear(); // ✅ Clear value when unchecked
    }
    notifyListeners();
  }

  void setSaleType(bool isCredit) {
    isCreditSale = isCredit;
    notifyListeners();
  }

  void updateCash(context) {
    isCash = !isCash;
    isReceived =
        isCash; // Automatically check when cash is selected, uncheck when credit is selected
    discountController.clear();
    billPerson.clear();
    billController.clear();
    itemsCash.clear();
    itemsCredit.clear();

    // Clear selected customer if switching to cash
    if (isCash) {
      Provider.of<CustomerProvider>(context, listen: false)
          .clearSelectedCustomer();
    }
    notifyListeners();
  }

  String getCustomerId(BuildContext context) {
    final customer =
        Provider.of<CustomerProvider>(context, listen: false).selectedCustomer;
    return isCash ? 'cash' : customer?.id.toString() ?? '';
  }

  ///credit ===>
  String addAmount() {
    if (itemsCredit.isNotEmpty) {
      double subtotal = 0.0;

      for (var element in itemsCredit) {
        double itemTotal = double.tryParse(element.total ?? "0") ?? 0.0;
        subtotal += itemTotal;
      }
      return subtotal.toStringAsFixed(2); // Format to 2 decimal places
    }
    return "0.00";
  }

////working ==== cash amount
  String addAmount2() {
    if (itemsCash.isNotEmpty) {
      double subtotal = 0.0;

      for (var element in itemsCash) {
        double itemTotal = double.tryParse(element.total ?? "0") ?? 0.0;
        subtotal += itemTotal;
      }

      return subtotal.toStringAsFixed(2);
    }
    return "0.00";
  }

  ///===> adjust total
  String get totalAmount {
    double subtotal = double.tryParse(addAmount2()) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double total = subtotal - discount + taxAmount + totalTaxAmountl;

    debugPrint(
        "cash amount: $subtotal, cash Discount: $discount, cash Total: $total");

    // Round based on decimal
    int finalTotal = total % 1 >= 0.5 ? total.ceil() : total.floor();

    //return finalTotal.toString();
    return "$finalTotal "; //(${total.toStringAsFixed(2)})
  }



  String get totalAmount2 {
    double subtotal =
        double.tryParse(addAmount()) ?? 0.0; // Get credit subtotal
    debugPrint("Credit subtotal: $subtotal");

    double discount =
        double.tryParse(discountController.text) ?? 0.0; // Get discount

    // 🔥 FIX: Use taxAmount2 for credit instead of taxAmount
    double total =
        subtotal - discount + taxAmount2 + totalTaxAmountl; // Calculate total

    debugPrint(
        "Credit Subtotal: $subtotal, Credit Discount: $discount, Credit Tax: $taxAmount2, Credit Total: $total");

    return total.toStringAsFixed(2); // Format to 2 decimal places
  }

  updateTotalTaxId(String value) {
    totaltaxPercentValue = value;
    notifyListeners();
  }

  updateTaxPaecentId(String value) {
    taxPercentValue = value;
    notifyListeners();
  }

  //saleItem.clear();

  ///cash ... need
  addCashItem() {
    debugPrint(
        "cash Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");
    debugPrint("Selected Unit: $selectedUnit");
    debugPrint("Selected Unit ID: $selectedUnitIdWithName");

    // Parse input
    double price = double.tryParse(mrpController.text) ?? 0.0;
    double quantity = double.tryParse(qtyController.text) ?? 0.0;
    double demodiscounAmout = double.tryParse(discountAmount.text) ?? 0.0;
    double itemTotal = ((price * quantity) - demodiscounAmout) + taxAmount;

    double discountAmt = double.tryParse(discountAmount.text) ?? 0.0; ///discountAmount
    double vatAmount = taxAmount;

    //   double itemSubTotal = (price * quantity) - discountAmt;
    // double itemTotal = itemSubTotal + vatAmount;

    // ✅ Format taxPercent like "1_10"
    String formattedTaxPercent =
        "${selectedTaxId ?? '0'}_${(selectedTaxPercent ?? 0).toStringAsFixed(0)}";

    // ✅ Update total discount and VAT trackers
    totalItemDiscounts += discountAmt;
    totalItemVats += vatAmount;

// ✅ Debug for tracking after updating totals
    debugPrint("✅ Added item with:");
    debugPrint("→ VAT: $vatAmount");
    debugPrint("→ Discount: $discountAmt");
    debugPrint("→ Total Discounts (Running): $totalItemDiscounts");
    debugPrint("→ Total VATs (Running): $totalItemVats");

    // Add to item list
    itemsCash.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      discountAmount: discountAmount.text,
      discountPercentance: discountPercentance.text,
      vatAmount: taxAmount,
      vatPerentace: formattedTaxPercent,
      itemCode: codeController.text,
      unit: selectedUnit ?? "N/A",
      mrp: mrpController.text,
      quantity: qtyController.text,
      total: itemTotal.toStringAsFixed(2), // direct total
      description: 'd',
    ));

    notifyListeners();

    // Add to sale list
    saleItem.add(SaleItemModel(
        itemId: selcetedItemId,
        price: mrpController.text,
        qty: qtyController.text,
        subTotal: itemTotal.toStringAsFixed(2),
        unitId: selectedUnitIdWithName,
        discountAmount: discountAmount.text,
        discountPercentage: discountPercentance.text,
        taxAmount: taxAmount,
        taxPercent: formattedTaxPercent,
        description: ''));

    notifyListeners();
    // Clear input fields
    codeController.clear();
    mrpController.clear();
    qtyController.clear();
    amountController.clear();
    unitController.clear();
    priceController.clear();
    discountAmount.clear();
    mrpController.clear();
    unitController.clear();
    notifyListeners();
  }



  // 🔥 FIXED: Credit item addition with proper tax calculation
  addCreditItem() {
    debugPrint(
        "Credit Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

    double price = double.tryParse(mrpController.text) ?? 0.0;
    double quantity = double.tryParse(qtyController.text) ?? 0.0;
    double demodiscounAmout = double.tryParse(discountAmount.text) ?? 0.0;

    // 🔥 FIX: Use taxAmount for individual item calculation (this is correct)
    double itemTotal = ((price * quantity) - demodiscounAmout) + taxAmount;

    double discountAmt = double.tryParse(discountAmount.text) ?? 0.0;
    double vatAmount = taxAmount;

    String formattedTaxPercent =
        "${selectedTaxId ?? '0'}_${(selectedTaxPercent ?? 0).toStringAsFixed(0)}";

    // 🔥 FIX: Update total discount and VAT trackers for credit too
    totalItemDiscounts += discountAmt;
    totalItemVats += vatAmount;

    debugPrint("✅ Added credit item with:");
    debugPrint("→ VAT: $vatAmount");
    debugPrint("→ Discount: $discountAmt");
    debugPrint("→ Total Discounts (Running): $totalItemDiscounts");
    debugPrint("→ Total VATs (Running): $totalItemVats");

    itemsCredit.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      itemCode: codeController.text,
      unit: selectedUnit ?? "PC",
      mrp: mrpController.text,
      quantity: qtyController.text,
      total: itemTotal.toStringAsFixed(2),
      discountAmount: discountAmount.text,
      discountPercentance: discountPercentance.text,
      vatAmount: taxAmount,
      vatPerentace:
          formattedTaxPercent, // 🔥 FIX: Use formattedTaxPercent instead of selectedTaxPercent
    ));

    saleItem.add(SaleItemModel(
      itemId: selcetedItemId,
      price: mrpController.text, // 🔥 FIX: Remove .value
      qty: qtyController.text, // 🔥 FIX: Remove .value
      subTotal: itemTotal.toStringAsFixed(2),
      unitId: selectedUnitIdWithName,
      discountAmount: discountAmount.text,
      discountPercentage: discountPercentance.text,
      taxAmount: taxAmount,
      taxPercent: formattedTaxPercent,
      description: '', // 🔥 FIX: Add missing description
    ));

    // Clear input fields
    codeController.clear();
    mrpController.clear();
    qtyController.clear();
    amountController.clear();
    unitController.clear();
    priceController.clear();
    discountAmount.clear();
    discountPercentance.clear(); // 🔥 FIX: Clear discount percentage too

    notifyListeners();
  }

  ///sales store, with stock not found scafault messge
  Future<bool> storeSales(
    BuildContext context, {
    required String date,
    required String amount,
    required String customerId,
    required String total,
    required String billNo,
    required double taxPercent,
    required String taxAmount,
    required String discount,
    required String discountPercent,
    required saleType,
    required int paymentOut,
  }) async {
    try {
      debugPrint('bill number: $billNo');

      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey("bill_number")) {
        await prefs.setInt("bill_number", 521444);
      }

      int lastBillNumber = prefs.getInt("bill_number") ?? 521444;
      int newBillNumber = lastBillNumber + 1;
      await prefs.setInt("bill_number", newBillNumber);

      DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(date);
      String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
      String encodedDate = Uri.encodeComponent(formattedDate);

      final String note = saleNoteController.text;
       
      debugPrint('date $encodedDate'); 
      debugPrint("cash Subtotal: ${addAmount2()}");
      debugPrint("credit Subtotal: ${addAmount()}");
      debugPrint("Cash Total (after discount): $totalAmount");
      debugPrint("discountPercent: ${percentController.text}"); //discountController
      debugPrint("discount amount: ${discountController.text}"); //percentController
      debugPrint("taxAmount: $totalTaxAmountl ");  ///$taxAmount
      debugPrint("taxPercent: $taxPercent");
      
      debugPrint("note $note");
      debugPrint("total amount $totalAmount");

      final paymentAmount = isCash ? totalAmount.toString() : receivedAmountController.text;

      String formattedTaxPercent =
          "${selectedTaxId ?? '0'}_${(selectedTaxPercent ?? 0).toStringAsFixed(0)}";

      debugPrint("payment out  true or false-  $paymentOut"); 
      debugPrint("payment Amount -  ${paymentAmount}");

      final url = "https://commercebook.site/api/v1/sales/store"
          "?user_id=${prefs.getInt("user_id").toString()}"
          "&customer_id=${customerId.isNotEmpty ? customerId : 'cash'}"
          "&bill_number=$billNo"
          "&sale_date=$encodedDate"
          "&details_notes=$note"

          "&discount=${discountController.text}"
          "&discount_percent=${percentController.text}"

          "&total_item_discounts=${totalItemDiscounts.toStringAsFixed(2)}"  ///total item discount
          "&total_item_vats=${totalItemVats.toStringAsFixed(2)}"   ///total item vats (ok)
          
          "&tax=${totalTaxAmountl.toStringAsFixed(2)}" ///tax amount
          "&tax_percents=$formattedTaxPercent" ///tax percentance 
          
          // "&gross_total=$totalAmount"
          "&gross_total=${isCash ? addAmount2() : addAmount()}"
          
          "&payment_out=$paymentOut"
          "&payment_amount=$paymentAmount"; // ✅ Only send integer

      debugPrint("API URL: $url");

      final requestBody = {
        "sales_items": saleItem.map((item) => item.toJson()).toList(),
      };

      debugPrint("Request Body: $requestBody");

      debugPrint('====Stop=====');

      debugPrint('====Stop 2=====');

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      debugPrint("API Response: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        notifyListeners();
        saleItem.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomeView()),
        );

        return true;
      } else {
        // ✅ Show message for success=false or non-200
        _showErrorSnackBar(context, data["message"] ?? "An error occurred.");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _showErrorSnackBar(
          context, "An unexpected error occurred. Please try again.");
      debugPrint("❌ Exception: $e");
      return false;
    }
  }

// ✅ Safe way to show error message from API
  void _showErrorSnackBar(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  // bool isOnlineMoneyChecked = false;
  void updatedOnlineMoney() {
    isOnlineMoneyChecked = !isOnlineMoneyChecked; // ✅ Toggle value
    notifyListeners(); // ✅ Notify UI to rebuild
  }

  TextEditingController conversionRateController = TextEditingController();
  String conversionRate = "";

  String? selectedUnit;
  String? selectedUnit2;

  int? selectedUnitID;
  int? selectedUnit2ID;

  SalesController() {
    conversionRateController.addListener(() {
      conversionRate = conversionRateController.text;
      notifyListeners();
    });
  }

  // 👇 Add this method to reset the unit data
  void clearUnitSelection() {
    selectedUnit = null;
    selectedUnit2 = null;
    selectedUnitID = null;
    selectedUnit2ID = null;
    conversionRate = "";
    conversionRateController.clear();
    notifyListeners(); // Notify UI listeners to refresh
  }

  void updateUnit1(String? value) {
    selectedUnit = value;
    notifyListeners();
  }

  void updateUnit2(String? value) {
    selectedUnit2 = value;
    notifyListeners();
  }

  String selcetedItemId = "";

  String selcetedUnitId = "";

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

  void salesControllerAS() {
    stockAddItemController.addListener(_calculateValue);
    priceAddItemController.addListener(_calculateValue);
  }

  double _calculateValue() {
    final stockText = stockAddItemController.text.trim();
    final priceText = priceAddItemController.text.trim();

    final stock = double.tryParse(stockText) ?? 0.0;
    final price = double.tryParse(priceText) ?? 0.0;

    final value = stock * price;

    // Prevent infinite loop if text doesn't change
    final currentText = valueAddItemController.text;
    final formattedValue = value.toStringAsFixed(1);

    if (currentText != formattedValue) {
      valueAddItemController.text = formattedValue;
    }

    notifyListeners();
    return value;
  }

  void clearSalesFields() {
    stockAddItemController.clear();
    priceAddItemController.clear();
    valueAddItemController.clear();
    notifyListeners();
  }



  DateTime _selectedDate = DateTime.now();
  

  void updateIsAmount() {
    isAmount = !isAmount;
    notifyListeners();
  }

  void updateIsDiscount() {
    isDisocunt = !isDisocunt;
    notifyListeners();
  }

  void updateIsVatTax() {
    isVatTax = !isVatTax;
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

  void updateIsBillTotal() {
    isBillTotal = !isBillTotal;
    notifyListeners();
  }

  void updateIsAdvance() {
    isAdvance = !isAdvance;
    notifyListeners();
  }

  void updateIsPreviousRecipt() {
    isPreviousRecipt = !isPreviousRecipt;
    notifyListeners();
  }

  void updateIsBillRecipt() {
    isBillRecipt = !isBillRecipt;
    notifyListeners();
  }

  String get formattedDate => DateTimeHelper.formatDate(_selectedDate);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

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

  //===>credit

  void updateCategory(String? newValue) {
    selectedCategory = newValue!;
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

  ///===> remove cash item.
  void removeCashItem(int index) {
    // Remove the item from the itemsCash list
    itemsCash.removeAt(index);

    // Also remove the corresponding purchase item from purchaseItem list
    saleItem.removeAt(index);

    // Notify listeners to update UI
    notifyListeners();
  }

  ///===>remove credit item
  void removeCreditItem(int index) {
    // Remove the item from the itemsCash list
    itemsCredit.removeAt(index);

    // Also remove the corresponding purchase item from purchaseItem list
    saleItem.removeAt(index);

    // Notify listeners to update UI
    notifyListeners();
  }

  void updateReceiptType(String? newValue) {
    selectedReceiptType = newValue!;
    notifyListeners();
  }

  String selectedUnitIdWithName = "";

  void selectedUnitIdWithNameFunction(String data) {
    selectedUnitIdWithName = data;
    notifyListeners();
  }

  void updateSelectedUnitIdWithName(
      String unitName, List<UnitResponseModel> units) {
    if (units.isNotEmpty) {
      for (var unit in units) {
        if (unit.name.toString() == unitName) {
          final qtyText = qtyController.text.trim();
          final qty = qtyText.isNotEmpty ? qtyText : "1";
          selectedUnitIdWithName = "${unit.id}_${unit.name}_$qty";
          break;
        }
      }
    }
    notifyListeners();
  }

  ///tax dropdown
  selectTotalTaxDropdown(double totalAmount, String tax) {
    selectedTotalTaxPercent = double.parse(tax);
    totalTaxAmountl = (totalAmount * selectedTotalTaxPercent) / 100;
    notifyListeners();
  }

  ///credit tax drop down
  selectTotalCreditTaxDropdown(double totalAmount, String tax) {
    selectedTotalTaxPercent = double.parse(tax);
    totalTaxAmountl = (totalAmount * selectedTotalTaxPercent) / 100;
    notifyListeners();
  }
}





// import 'dart:convert';
// import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
// import 'package:cbook_dt/feature/home/presentation/home_view.dart';
// import 'package:cbook_dt/feature/item/model/items_show.dart';
// import 'package:cbook_dt/feature/sales/model/sale_create_model.dart';
// import 'package:cbook_dt/feature/unit/model/unit_response_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../utils/date_time_helper.dart';
// import '../sales_view.dart';
// import 'package:http/http.dart' as http;

// class SalesController extends ChangeNotifier {
//   String formattedDate2 = '';

//   bool hasCustomPrice = false;
//   double _taxPercent = 0.0;
//   double _taxAmount = 0.0;
//   double get taxPercent => _taxPercent;
//   double get taxAmount => _taxAmount;
//   double get totalWithTax => _subtotal + _taxAmount;
//   double get subtotalWithTax => subtotal + taxAmount;
//   TextEditingController mrpController = TextEditingController();
//   TextEditingController qtyController = TextEditingController();
//   TextEditingController saleNoteController = TextEditingController();
//   TextEditingController customerNameController = TextEditingController();
//   TextEditingController saleUpdateNoteController = TextEditingController();

//   ///discount amount and discount percentance.
//   TextEditingController discountAmount = TextEditingController();
//   TextEditingController discountPercentance = TextEditingController();

//   TextEditingController controller = TextEditingController(text: "Cash");

//   String? selectedCategory;
//   String? selectedWarehouse;
//   String? selectedSubCategory;
//   String? selectedStatus;
//   String? price;
//   // bool isOnlineMoneyChecked = false;
//   String? selectedReceiptType;

//   String customerName = "";
//   String phone = "";
//   String email = "";
//   String address = "";

//   TextEditingController amountController = TextEditingController();
//   TextEditingController amountController2 = TextEditingController();
//   TextEditingController discountPercentageController = TextEditingController();
//   TextEditingController discountAmountController = TextEditingController();
//   TextEditingController additionalCostController = TextEditingController();
//   TextEditingController subtotalController = TextEditingController();
//   TextEditingController receivedMoneyController = TextEditingController();
//   TextEditingController returnController = TextEditingController();
//   TextEditingController dueController = TextEditingController();

//   TextEditingController codeController = TextEditingController();

//   TextEditingController unitController = TextEditingController();
//   TextEditingController priceController = TextEditingController();
//   TextEditingController totalAmountController = TextEditingController();

//   TextEditingController totalController = TextEditingController();

//   //add item
//   TextEditingController nameAddItemController = TextEditingController();

//   ////add item stock and price
//   TextEditingController stockAddItemController = TextEditingController();
//   TextEditingController priceAddItemController = TextEditingController();

//   TextEditingController valueAddItemController = TextEditingController();

//   String lastChanged = '';

//   double _subtotal = 0.0;
//   double get subtotal => _subtotal;

//   bool isOnlineMoneyChecked = false;

//   String? seletedItemName;

//   TextEditingController billController = TextEditingController();
//   TextEditingController billPerson = TextEditingController();

//   TextEditingController receivedAmountController = TextEditingController();
//   TextEditingController discountController =
//       TextEditingController(); // Ensure discount input is controlled

//   TextEditingController percentController = TextEditingController();

//   ///add item cash
//   List<SaleItemModel> saleItem = [];

//   ///add item cash
//   List<ItemModel> itemsCash = [];

//   List<ItemModel> itemsCredit = [];

//   List<String> unitIdsList = [];

//   bool isCash = true;
//   bool isReceived = true;

//   bool isCreditSale = true; // Default to credit sale, update as needed

//   ///sales tax vat provider.
//   double? selectedTaxPercent;
//   String taxPercentValue = "";
//   String totaltaxPercentValue = "";

//   String? selectedTaxId;

//   double totalItemDiscounts = 0.0;
//   double totalItemVats = 0.0;

//   //sales field portion date tax and vat
//   String? selectedTotalTaxId;
//   double selectedTotalTaxPercent = 0.00;
//   double totalTaxAmountl = 0.00;

//   //for form settiing
//   bool isAmount = true;
//   bool isDisocunt = true;
//   bool isVatTax = true;
//   bool isAdditionalCost = true;
//   bool isSubTotoal = true;
//   bool isReciptType = true;
//   bool isRecivedMoney = true;
//   bool isReturn = true;

//   bool isBillRecipt = true;
//   bool isPreviousRecipt = true;
//   bool isAdvance = true;
//   bool isBillTotal = true;

//   String primaryUnitName = "";
//   String secondaryUnitName = "";
//   double salePrice = 0.0;
//   dynamic unitQty = 1.0;
// //bool hasCustomPrice = false;

//   String unitIdWithQty = "";

//   salesControllerItemamount() {
//     salesControllerItem();
//   }

//   void updateItem(int index, ItemModel updatedItem) {
//     if (index >= 0 && index < itemsCash.length) {
//       itemsCash[index] = updatedItem;
//       //notifyListeners();
//     }
//   }

//   salesControllerItem() {
//     qtyController.addListener(calculateSubtotal);
//     mrpController.addListener(calculateSubtotal);
//     discountAmount.addListener(calculateSubtotal);
//   }

//   ///credit tax working ==== 21.7.25
//   void calculateTax() {
//     _taxAmount = (_subtotal * _taxPercent) / 100;
//     notifyListeners();
//   }

//   void calculateTaxCash() {
//     _taxAmount = (_subtotal * _taxPercent) / 100;
//     notifyListeners();
//   }

//   ///credit tax total
//   void calculateTotal() {
//     double subtotal = double.tryParse(addAmount2()) ?? 0.0;
//     double discount = double.tryParse(discountController.text) ?? 0.0;
//     double total = subtotal - discount + taxAmount;

//     notifyListeners(); // 👈 Important
//   }

//   ///cash
//   void calculateTotalCash() {
//     double subtotal = double.tryParse(addAmount()) ?? 0.0;
//     double discount = double.tryParse(discountController.text) ?? 0.0;
//     double total = subtotal - discount + taxAmount;

//     notifyListeners(); // 👈 Important
//   }

//   set taxPercent(double value) {
//     _taxPercent = value;
//     calculateTax(); // 🔁 only recalculate tax when percent changes
//     notifyListeners();
//   }

//   void calculateSubtotal() {
//     double qty = double.tryParse(qtyController.text) ?? 0;
//     double price = double.tryParse(mrpController.text) ?? 0;
//     double total = qty * price;

//     double discountPercent = double.tryParse(discountPercentance.text) ?? 0;
//     double discountAmt = double.tryParse(discountAmount.text) ?? 0;

//     if (lastChanged == 'percent') {
//       discountAmt = (total * discountPercent) / 100;
//       discountAmount.text = discountAmt.toStringAsFixed(2);
//     } else if (lastChanged == 'amount') {
//       if (total > 0) {
//         discountPercent = (discountAmt / total) * 100;
//         discountPercentance.text = discountPercent.toStringAsFixed(2);
//       } else {
//         discountPercentance.text = '0';
//       }
//     }

//     _subtotal = total - discountAmt;
//     if (_subtotal < 0) _subtotal = 0;

//     debugPrint('--- calculateSubtotal called ---');
//     debugPrint(
//       'Qty: $qty, Price: $price, Discount %: $discountPercent, '
//       'Discount Amount: $discountAmt, Subtotal: $_subtotal',
//     );

//     notifyListeners(); // No tax calculation here
//   }


//   // 🔥 ADDITIONAL FIX: Make sure you have a proper taxAmount2 getter
//   double get taxAmount2 {
//     double subtotal = double.tryParse(addAmount()) ?? 0.0; // Use credit amount
//     return (subtotal * (_taxPercent / 100));
//   }

 

//   void clearFields() {
//     mrpController.clear();
//     qtyController.clear();
//     discountAmount.clear();
//     discountPercentance.clear();
//     _taxAmount = 0.0; // 👈 fixed
//     _taxPercent = 0.0;
//     _subtotal = 0.0;
//     notifyListeners();
//   }


 

// void updateDiscountCreditAmount(String value) {
//   final discount = double.tryParse(value) ?? 0;
//   final total = double.tryParse(totalAmount) ?? 0;

//   if (total <= 0) {
//     percentController.text = '0.00';
//     notifyListeners();
//     return;
//   }

//   final percent = (discount / total) * 100;

//   percentController.text = percent.toStringAsFixed(2);
//   notifyListeners();
// }

//    // CreditPercent
//   void updateDiscountCreditPercent(String value) {
//   if (value.isEmpty || double.tryParse(value) == null) {
//     discountController.text = '';
//     notifyListeners();
//     return;
//   }

//   final percent = double.tryParse(value) ?? 0;
//   final total = double.tryParse(totalAmount) ?? 1;
//   final discount = (total * percent) / 100;

//   discountController.text = discount.toStringAsFixed(2);
//   notifyListeners();
// }



//   //cash discount amount
//   void updateDiscountCashAmount(String value) {
//     if (value.isEmpty || double.tryParse(value) == null) {
//       percentController.text = '';
//       notifyListeners();
//       return;
//     }

//     final discount = double.tryParse(value) ?? 0;
//     final total = double.tryParse(addAmount2()) ?? 1;
//     final percent = (discount / total) * 100;

//     percentController.text = percent.toStringAsFixed(2);
//     notifyListeners();
//   }

//   ///cash discount percentance
//   void updateDiscountCashPercent(String value) {
//     if (value.isEmpty || double.tryParse(value) == null) {
//       discountController.text = '';
//       debugPrint("Invalid or empty discount percent entered.");
//       notifyListeners();
//       return;
//     }

//     final percent = double.tryParse(value) ?? 0;
//     final total = double.tryParse(addAmount2()) ?? 1;
//     final discount = (percent / 100) * total;

//     // Update the discount field
//     discountController.text = discount.toStringAsFixed(2);

//     // Debug output
//     debugPrint("Discount amount: $discount from $percent% of total $total");

//     notifyListeners();
//   }

//   void clearPercentance() {
//     percentController.clear();
//   }

//   void updateOnlineMoney() {
//     isOnlineMoneyChecked = !isOnlineMoneyChecked;
//     if (isOnlineMoneyChecked) {
//       receivedAmountController.text =
//           totalAmount2; // ✅ Set total amount when checked
//     } else {
//       receivedAmountController.clear(); // ✅ Clear value when unchecked
//     }
//     notifyListeners();
//   }

//   void setSaleType(bool isCredit) {
//     isCreditSale = isCredit;
//     notifyListeners();
//   }

//   void updateCash(context) {
//     isCash = !isCash;
//     isReceived =
//         isCash; // Automatically check when cash is selected, uncheck when credit is selected
//     discountController.clear();
//     billPerson.clear();
//     billController.clear();
//     itemsCash.clear();
//     itemsCredit.clear();

//     // Clear selected customer if switching to cash
//     if (isCash) {
//       Provider.of<CustomerProvider>(context, listen: false)
//           .clearSelectedCustomer();
//     }
//     notifyListeners();
//   }

//   String getCustomerId(BuildContext context) {
//     final customer =
//         Provider.of<CustomerProvider>(context, listen: false).selectedCustomer;
//     return isCash ? 'cash' : customer?.id.toString() ?? '';
//   }

//   ///credit amount
//   String addAmount() {
//     if (itemsCredit.isNotEmpty) {
//       double subtotal = 0.0;

//       for (var element in itemsCredit) {
//         double itemTotal = double.tryParse(element.total ?? "0") ?? 0.0;
//         subtotal += itemTotal;
//       }
//       return subtotal.toStringAsFixed(2); // Format to 2 decimal places
//     }
//     return "0.00";
//   }

// ////cash amount
//   String addAmount2() {
//     if (itemsCash.isNotEmpty) {
//       double subtotal = 0.0;

//       for (var element in itemsCash) {
//         double itemTotal = double.tryParse(element.total ?? "0") ?? 0.0;
//         subtotal += itemTotal;
//       }

//       return subtotal.toStringAsFixed(2);
//     }
//     return "0.00";
//   }

//   ///===>cash total
//   String get totalAmount {
//     double subtotal = double.tryParse(addAmount2()) ?? 0.0;
//     double discount = double.tryParse(discountController.text) ?? 0.0;
//     double total = subtotal - discount + taxAmount + totalTaxAmountl;

//     debugPrint(
//         "cash amount: $subtotal, cash Discount: $discount, cash Total: $total");

//     // Round based on decimal
//     int finalTotal = total % 1 >= 0.5 ? total.ceil() : total.floor();

//     //return finalTotal.toString();
//     return "$finalTotal "; //(${total.toStringAsFixed(2)})
//   }



//   ///credit total.
//   String get totalAmount2 {
//     double subtotal =
//         double.tryParse(addAmount()) ?? 0.0; // Get credit subtotal
//     debugPrint("Credit subtotal: $subtotal");

//     double discount =
//         double.tryParse(discountController.text) ?? 0.0; // Get discount

//     // 🔥 FIX: Use taxAmount2 for credit instead of taxAmount
//     double total =
//         subtotal - discount + taxAmount2 + totalTaxAmountl; // Calculate total

//     debugPrint(
//         "Credit Subtotal: $subtotal, Credit Discount: $discount, Credit Tax: $taxAmount2, Credit Total: $total");

//     return total.toStringAsFixed(2); // Format to 2 decimal places
//   }

//   updateTotalTaxId(String value) {
//     totaltaxPercentValue = value;
//     notifyListeners();
//   }

//   updateTaxPaecentId(String value) {
//     taxPercentValue = value;
//     notifyListeners();
//   }


//   ///cash ... need
//   addCashItem() {
//     debugPrint(
//         "cash Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");
//     debugPrint("Selected Unit: $selectedUnit");
//     debugPrint("Selected Unit ID: $selectedUnitIdWithName");

//     // Parse input
//     double price = double.tryParse(mrpController.text) ?? 0.0;
//     double quantity = double.tryParse(qtyController.text) ?? 0.0;
//     double demodiscounAmout = double.tryParse(discountAmount.text) ?? 0.0;
//     double itemTotal = ((price * quantity) - demodiscounAmout) + taxAmount;

//     double discountAmt = double.tryParse(discountAmount.text) ?? 0.0; ///discountAmount
//     double vatAmount = taxAmount;

//     //   double itemSubTotal = (price * quantity) - discountAmt;
//     // double itemTotal = itemSubTotal + vatAmount;

//     // ✅ Format taxPercent like "1_10"
//     String formattedTaxPercent =
//         "${selectedTaxId ?? '0'}_${(selectedTaxPercent ?? 0).toStringAsFixed(0)}";

//     // ✅ Update total discount and VAT trackers
//     totalItemDiscounts += discountAmt;
//     totalItemVats += vatAmount;

// // ✅ Debug for tracking after updating totals
//     debugPrint("✅ Added item with:");
//     debugPrint("→ VAT: $vatAmount");
//     debugPrint("→ Discount: $discountAmt");
//     debugPrint("→ Total Discounts (Running): $totalItemDiscounts");
//     debugPrint("→ Total VATs (Running): $totalItemVats");

//     // Add to item list
//     itemsCash.add(ItemModel(
//       category: selectedCategory ?? "Category1",
//       subCategory: selectedSubCategory ?? "Sub Category1",
//       itemName: seletedItemName ?? "Item1",
//       discountAmount: discountAmount.text,
//       discountPercentance: discountPercentance.text,
//       vatAmount: taxAmount,
//       vatPerentace: formattedTaxPercent,
//       itemCode: codeController.text,
//       unit: selectedUnit ?? "N/A",
//       mrp: mrpController.text,
//       quantity: qtyController.text,
//       total: itemTotal.toStringAsFixed(2), // direct total
//       description: 'd',
//     ));

//     notifyListeners();

//     // Add to sale list
//     saleItem.add(SaleItemModel(
//         itemId: selcetedItemId,
//         price: mrpController.text,
//         qty: qtyController.text,
//         subTotal: itemTotal.toStringAsFixed(2),
//         unitId: selectedUnitIdWithName,
//         discountAmount: discountAmount.text,
//         discountPercentage: discountPercentance.text,
//         taxAmount: taxAmount,
//         taxPercent: formattedTaxPercent,
//         description: ''));

//     notifyListeners();
//     // Clear input fields
//     codeController.clear();
//     mrpController.clear();
//     qtyController.clear();
//     amountController.clear();
//     unitController.clear();
//     priceController.clear();
//     discountAmount.clear();
//     mrpController.clear();
//     unitController.clear();
//     notifyListeners();
//   }



//   // 🔥 FIXED: Credit item addition with proper tax calculation
//   addCreditItem() {
//     debugPrint(
//         "Credit Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

//     double price = double.tryParse(mrpController.text) ?? 0.0;
//     double quantity = double.tryParse(qtyController.text) ?? 0.0;
//     double demodiscounAmout = double.tryParse(discountAmount.text) ?? 0.0;

//     // 🔥 FIX: Use taxAmount for individual item calculation (this is correct)
//     double itemTotal = ((price * quantity) - demodiscounAmout) + taxAmount;

//     double discountAmt = double.tryParse(discountAmount.text) ?? 0.0;
//     double vatAmount = taxAmount;

//     String formattedTaxPercent =
//         "${selectedTaxId ?? '0'}_${(selectedTaxPercent ?? 0).toStringAsFixed(0)}";

//     // 🔥 FIX: Update total discount and VAT trackers for credit too
//     totalItemDiscounts += discountAmt;
//     totalItemVats += vatAmount;

//     debugPrint("✅ Added credit item with:");
//     debugPrint("→ VAT: $vatAmount");
//     debugPrint("→ Discount: $discountAmt");
//     debugPrint("→ Total Discounts (Running): $totalItemDiscounts");
//     debugPrint("→ Total VATs (Running): $totalItemVats");

//     itemsCredit.add(ItemModel(
//       category: selectedCategory ?? "Category1",
//       subCategory: selectedSubCategory ?? "Sub Category1",
//       itemName: seletedItemName ?? "Item1",
//       itemCode: codeController.text,
//       unit: selectedUnit ?? "PC",
//       mrp: mrpController.text,
//       quantity: qtyController.text,
//       total: itemTotal.toStringAsFixed(2),
//       discountAmount: discountAmount.text,
//       discountPercentance: discountPercentance.text,
//       vatAmount: taxAmount,
//       vatPerentace:
//           formattedTaxPercent, // 🔥 FIX: Use formattedTaxPercent instead of selectedTaxPercent
//     ));

//     saleItem.add(SaleItemModel(
//       itemId: selcetedItemId,
//       price: mrpController.text, // 🔥 FIX: Remove .value
//       qty: qtyController.text, // 🔥 FIX: Remove .value
//       subTotal: itemTotal.toStringAsFixed(2),
//       unitId: selectedUnitIdWithName,
//       discountAmount: discountAmount.text,
//       discountPercentage: discountPercentance.text,
//       taxAmount: taxAmount,
//       taxPercent: formattedTaxPercent,
//       description: '', // 🔥 FIX: Add missing description
//     ));

//     // Clear input fields
//     codeController.clear();
//     mrpController.clear();
//     qtyController.clear();
//     amountController.clear();
//     unitController.clear();
//     priceController.clear();
//     discountAmount.clear();
//     discountPercentance.clear(); // 🔥 FIX: Clear discount percentage too

//     notifyListeners();
//   }

//   ///sales store, with stock not found scafault messge
//   Future<bool> storeSales(
//     BuildContext context, {
//     required String date,
//     required String amount,
//     required String customerId,
//     required String total,
//     required String billNo,
//     required double taxPercent,
//     required String taxAmount,
//     required String discount,
//     required String discountPercent,
//     required saleType,
//     required int paymentOut,
//   }) async {
//     try {
//       debugPrint('bill number: $billNo');

//       SharedPreferences prefs = await SharedPreferences.getInstance();

//       if (!prefs.containsKey("bill_number")) {
//         await prefs.setInt("bill_number", 521444);
//       }

//       int lastBillNumber = prefs.getInt("bill_number") ?? 521444;
//       int newBillNumber = lastBillNumber + 1;
//       await prefs.setInt("bill_number", newBillNumber);

//       DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(date);
//       String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
//       String encodedDate = Uri.encodeComponent(formattedDate);

//       final String note = saleNoteController.text;
       
//       debugPrint('date $encodedDate'); 
//       debugPrint("Cash Subtotal: ${addAmount2()}");
//       debugPrint("Cash Total (after discount): $totalAmount");
//       debugPrint("discountPercent: ${percentController.text}"); //discountController
//       debugPrint("discount amount: ${discountController.text}"); //percentController
//       debugPrint("taxAmount: $totalTaxAmountl ");  ///$taxAmount
//       debugPrint("taxPercent: $taxPercent");
      
//       debugPrint("note $note");
//       debugPrint("total amount $totalAmount");

//       final paymentAmount = isCash ? totalAmount.toString() : receivedAmountController.text;

//       String formattedTaxPercent =
//           "${selectedTaxId ?? '0'}_${(selectedTaxPercent ?? 0).toStringAsFixed(0)}";

//       debugPrint("payment out  true or false-  $paymentOut"); 
//       debugPrint("payment Amount -  ${paymentAmount}");

//       final url = "https://commercebook.site/api/v1/sales/store"
//           "?user_id=${prefs.getInt("user_id").toString()}"
//           "&customer_id=${customerId.isNotEmpty ? customerId : 'cash'}"
//           "&bill_number=$billNo"
//           "&sale_date=$encodedDate"
//           "&details_notes=$note"

//           "&discount=${discountController.text}"
//           "&discount_percent=${percentController.text}"

//           "&total_item_discounts=${totalItemDiscounts.toStringAsFixed(2)}"  ///total item discount
//           "&total_item_vats=${totalItemVats.toStringAsFixed(2)}"   ///total item vats (ok)
          
//           "&tax=$totalTaxAmountl" ///tax amount
//           "&tax_percents=$formattedTaxPercent" ///tax percentance 
          
//           //"&gross_total=$totalAmount" //working 
//           "&gross_total=${customerId.isNotEmpty ? totalAmount2 : totalAmount}"

//           "&payment_out=$paymentOut"
//           "&payment_amount=$paymentAmount"; // ✅ Only send integer

//       debugPrint("API URL: $url");

//       final requestBody = {
//         "sales_items": saleItem.map((item) => item.toJson()).toList(),
//       };

//       debugPrint("Request Body: $requestBody");

//       debugPrint('====Stop=====');

//       debugPrint('====Stop 2=====');

//       final response = await http.post(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode(requestBody),
//       );

//       debugPrint("API Response: ${response.body}");

//       final data = json.decode(response.body);

//       if (response.statusCode == 200 && data["success"] == true) {
//         notifyListeners();
//         saleItem.clear();

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (BuildContext context) => const HomeView()),
//         );

//         return true;
//       } else {
//         // ✅ Show message for success=false or non-200
//         _showErrorSnackBar(context, data["message"] ?? "An error occurred.");
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _showErrorSnackBar(
//           context, "An unexpected error occurred. Please try again.");
//       debugPrint("❌ Exception: $e");
//       return false;
//     }
//   }

// // ✅ Safe way to show error message from API
//   void _showErrorSnackBar(BuildContext context, String message) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//         ),
//       );
//     });
//   }

//   // bool isOnlineMoneyChecked = false;
//   void updatedOnlineMoney() {
//     isOnlineMoneyChecked = !isOnlineMoneyChecked; // ✅ Toggle value
//     notifyListeners(); // ✅ Notify UI to rebuild
//   }

//   TextEditingController conversionRateController = TextEditingController();
//   String conversionRate = "";

//   String? selectedUnit;
//   String? selectedUnit2;

//   int? selectedUnitID;
//   int? selectedUnit2ID;

//   SalesController() {
//     conversionRateController.addListener(() {
//       conversionRate = conversionRateController.text;
//       notifyListeners();
//     });
//   }

//   // 👇 Add this method to reset the unit data
//   void clearUnitSelection() {
//     selectedUnit = null;
//     selectedUnit2 = null;
//     selectedUnitID = null;
//     selectedUnit2ID = null;
//     conversionRate = "";
//     conversionRateController.clear();
//     notifyListeners(); // Notify UI listeners to refresh
//   }

//   void updateUnit1(String? value) {
//     selectedUnit = value;
//     notifyListeners();
//   }

//   void updateUnit2(String? value) {
//     selectedUnit2 = value;
//     notifyListeners();
//   }

//   String selcetedItemId = "";

//   String selcetedUnitId = "";

//   void itemUpdate(String item, List<ItemsModel> items) {
//     seletedItemName = item;
//     if (items.isNotEmpty) {
//       items.forEach((e) {
//         if (item == e.name.toString()) {
//           selcetedItemId = e.id.toString();
//         }
//       });
//     }
//     notifyListeners();
//   }

//   void salesControllerAS() {
//     stockAddItemController.addListener(_calculateValue);
//     priceAddItemController.addListener(_calculateValue);
//   }

//   double _calculateValue() {
//     final stockText = stockAddItemController.text.trim();
//     final priceText = priceAddItemController.text.trim();

//     final stock = double.tryParse(stockText) ?? 0.0;
//     final price = double.tryParse(priceText) ?? 0.0;

//     final value = stock * price;

//     // Prevent infinite loop if text doesn't change
//     final currentText = valueAddItemController.text;
//     final formattedValue = value.toStringAsFixed(1);

//     if (currentText != formattedValue) {
//       valueAddItemController.text = formattedValue;
//     }

//     notifyListeners();
//     return value;
//   }

//   void clearSalesFields() {
//     stockAddItemController.clear();
//     priceAddItemController.clear();
//     valueAddItemController.clear();
//     notifyListeners();
//   }



//   DateTime _selectedDate = DateTime.now();
  

//   void updateIsAmount() {
//     isAmount = !isAmount;
//     notifyListeners();
//   }

//   void updateIsDiscount() {
//     isDisocunt = !isDisocunt;
//     notifyListeners();
//   }

//   void updateIsVatTax() {
//     isVatTax = !isVatTax;
//     notifyListeners();
//   }

//   void updateIsAdditionalCost() {
//     isAdditionalCost = !isAdditionalCost;
//     notifyListeners();
//   }

//   void updateIsSubTotal() {
//     isSubTotoal = !isSubTotoal;
//     notifyListeners();
//   }

//   void updateIsReciptType() {
//     isReciptType = !isReciptType;
//     notifyListeners();
//   }

//   void updateIsRecivedMoney() {
//     isRecivedMoney = !isRecivedMoney;
//     notifyListeners();
//   }

//   void updateIsReturn() {
//     isReturn = !isReturn;
//     notifyListeners();
//   }

//   void updateIsBillTotal() {
//     isBillTotal = !isBillTotal;
//     notifyListeners();
//   }

//   void updateIsAdvance() {
//     isAdvance = !isAdvance;
//     notifyListeners();
//   }

//   void updateIsPreviousRecipt() {
//     isPreviousRecipt = !isPreviousRecipt;
//     notifyListeners();
//   }

//   void updateIsBillRecipt() {
//     isBillRecipt = !isBillRecipt;
//     notifyListeners();
//   }

//   String get formattedDate => DateTimeHelper.formatDate(_selectedDate);

//   Future<void> pickDate(BuildContext context) async {
//     final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
//     if (pickedDate != null && pickedDate != _selectedDate) {
//       _selectedDate = pickedDate;
//       notifyListeners();
//     }
//   }

//   updateCashForDefaultSet() {
//     isCash = true;
//     notifyListeners();
//   }

//   updateCreditForDefaultSet() {
//     isCash = false;
//     notifyListeners();
//   }

//   updatedCustomerInfomation(
//       {required String nameFrom,
//       required String phoneFrom,
//       required String emailFrom,
//       required String addressFrom}) {
//     customerName = nameFrom;
//     phone = phoneFrom;
//     email = emailFrom;
//     address = addressFrom;

//     notifyListeners();
//     debugPrint("as $customerName");
//   }

//   //===>credit

//   void updateCategory(String? newValue) {
//     selectedCategory = newValue!;
//     notifyListeners();
//   }

//   void updateSubCategory(String? newValue) {
//     selectedSubCategory = newValue!;
//     notifyListeners();
//   }

//   void updateItemName(String? newValue) {
//     seletedItemName = newValue!;
//     notifyListeners();
//   }

//   ///===> remove cash item.
//   void removeCashItem(int index) {
//     // Remove the item from the itemsCash list
//     itemsCash.removeAt(index);

//     // Also remove the corresponding purchase item from purchaseItem list
//     saleItem.removeAt(index);

//     // Notify listeners to update UI
//     notifyListeners();
//   }

//   ///===>remove credit item
//   void removeCreditItem(int index) {
//     // Remove the item from the itemsCash list
//     itemsCredit.removeAt(index);

//     // Also remove the corresponding purchase item from purchaseItem list
//     saleItem.removeAt(index);

//     // Notify listeners to update UI
//     notifyListeners();
//   }

//   void updateReceiptType(String? newValue) {
//     selectedReceiptType = newValue!;
//     notifyListeners();
//   }

//   String selectedUnitIdWithName = "";

//   void selectedUnitIdWithNameFunction(String data) {
//     selectedUnitIdWithName = data;
//     notifyListeners();
//   }

//   void updateSelectedUnitIdWithName(
//       String unitName, List<UnitResponseModel> units) {
//     if (units.isNotEmpty) {
//       for (var unit in units) {
//         if (unit.name.toString() == unitName) {
//           final qtyText = qtyController.text.trim();
//           final qty = qtyText.isNotEmpty ? qtyText : "1";
//           selectedUnitIdWithName = "${unit.id}_${unit.name}_$qty";
//           break;
//         }
//       }
//     }
//     notifyListeners();
//   }

//   ///tax dropdown
//   selectTotalTaxDropdown(double totalAmount, String tax) {
//     selectedTotalTaxPercent = double.parse(tax);
//     totalTaxAmountl = (totalAmount * selectedTotalTaxPercent) / 100;
//     notifyListeners();
//   }

//   ///credit tax drop down
//   selectTotalCreditTaxDropdown(double totalAmount, String tax) {
//     selectedTotalTaxPercent = double.parse(tax);
//     totalTaxAmountl = (totalAmount * selectedTotalTaxPercent) / 100;
//     notifyListeners();
//   }
// }

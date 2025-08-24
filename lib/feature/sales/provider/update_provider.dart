 

import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/sales/model/sales_update_by_id_model.dart';
import 'package:cbook_dt/feature/sales/model/sales_update_model.dart';
import 'package:cbook_dt/feature/unit/model/demo_unit_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SaleUpdateProvider extends ChangeNotifier {
  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();
  TextEditingController billNumberController = TextEditingController();
  TextEditingController purchaseDateController = TextEditingController();
  TextEditingController grossTotalController = TextEditingController();
  TextEditingController customerController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController saleUpdateNoteController = TextEditingController();

  TextEditingController updateDiscountAmount = TextEditingController();
  TextEditingController updateDiscountPercentance = TextEditingController();

  TextEditingController itemDiscountPercentance = TextEditingController();
  TextEditingController itemDiscountAmount = TextEditingController();

  TextEditingController itemTaxVatAmount = TextEditingController();
  TextEditingController itemTaxVatPercentance = TextEditingController();

  String taxPercentValue = "";
  String totaltaxPercentValue = "";
  String selctedUnitId = "";

  bool hasCustomer = false;
  bool isLoading = false;

  int? purchaseId;
  int? itemId;
  int? customerId;
  int? currentSaleId; // Add this to store the current sale ID
  String? selectedItem;
  String? selectedItemNameInvoice;
  String? selectedItemName;
  String? selectedUnitName; // Selected unit name for UI
  double? selectedTaxPercent;

  Map<int, String> itemMap = {}; // Store item IDs and names
  Map<int, String> unitMap = {}; // Store unit ID → unit Name

  List<String> itemNames = []; // Store only item names for dropdown
  List<String> unitNames = []; // Store only unit names for dropdown
  List<dynamic> purchaseDetailsList = [];
  List<DemoUnitModel> unitResponseModel = [];
  List<SaleUpdateModel> saleUpdateList = [];
  List<dynamic> _itemList = [];

  List<dynamic> get itemList => _itemList;

  // Remove the old model dependency
  // SalesEditResponse saleEditResponse = SalesEditResponse();

  String lastChanged = '';
  double _subtotal = 0.0;
  double get subtotal => _subtotal;

  double _taxAmount = 0.0;
  double get taxPercent => _taxPercent;
  double get taxAmount => _taxAmount;
  double _taxPercent = 0.0;

  selectedDropdownUnitId(String value) {
    unitResponseModel.forEach((e) {
      if (e.name == value) {
        //selctedUnitId = e.id.toString(); //real
        selctedUnitId = '5_Packet_1';
      }
    });
    notifyListeners();
  }

  /// fetch unit.
  Future<void> fetchUnits() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


    const url = "https://commercebook.site/api/v1/units";
    final response = await http.get(Uri.parse(url,),  headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      data["data"].forEach((key, value) {
        final item = DemoUnitModel.fromJson(value);
        unitResponseModel.add(item);
      });

      if (data['success']) {
        unitMap.clear();
        unitNames.clear();

        data['data'].forEach((key, value) {
          unitMap[value['id']] = value['name']; // Store ID → Name
          unitNames.add(value['name']); // Add name to dropdown
        });

        notifyListeners();
      }
    }
  }

  void setItemList(List<dynamic> newList) {
    _itemList = newList;
    notifyListeners();
  }

  ///fetch item
  Future<void> fetchItems() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    

    const url = "https://commercebook.site/api/v1/items";
    final response = await http.get(Uri.parse(url),  headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success']) {
        itemMap.clear();
        itemNames.clear();

        _itemList = data['data'];

        /// ✅ Corrected `forEach` loop
        for (var item in data['data']) {
          itemMap[item['id']] = item['name'];
          itemNames.add(item['name']); // ✅ Add names to the dropdown list
        }

        notifyListeners();
      }
    }
  }

  ///fetch sale data.
  Future<void> fetchSaleData(int id) async {
    currentSaleId = id; // Store the sale ID
    isLoading = true;
    notifyListeners();

    await fetchItems();
    await fetchUnits();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = "https://commercebook.site/api/v1/sales/edit/$id";
    final response = await http.get(Uri.parse(url),  headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },);

    debugPrint("API Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        saleUpdateList.clear();

        // Extract main sale data
        final saleData = data['data'];
        
        // Set form fields with actual API response structure
        billNumberController.text = saleData['bill_number']?.toString() ?? "";
        purchaseDateController.text = saleData['sales_date']?.toString() ?? "";
        updateDiscountAmount.text = saleData['discount']?.toString() ?? '0.00';
        updateDiscountPercentance.text = saleData['discount_percent']?.toString() ?? '0.00';
        grossTotalController.text = saleData['gross_total']?.toString() ?? "";
        customerController.text = saleData['customer_id']?.toString() ?? "";
        
        // Set customer flag
        hasCustomer = saleData['customer_id'] != null && saleData['customer_id'] != 0;

        // Process sales details
        if (saleData['sales_details'] != null) {
          List<dynamic> salesDetails = saleData['sales_details'];
          
          for (var detail in salesDetails) {
            saleUpdateList.add(SaleUpdateModel(
              itemId: detail['item_id']?.toString() ?? "",
              price: detail['price']?.toString() ?? "0",
              qty: detail['qty']?.toString() ?? "0",
              subTotal: detail['sub_total']?.toString() ?? "0",
              unitId: "${detail['unit_id']?.toString() ?? ""}_${getUnitName(detail['unit_id']?.toString() ?? "")}_${detail['qty']?.toString() ?? "1"}",
              salesUpdateDiscountPercentace: detail['discount_percentage']?.toString() ?? "0",
              salesUpdateDiscountAmount: detail['discount_amount']?.toString() ?? "0",
              salesUpdateVATTAXAmount: detail['tax_amount']?.toString() ?? "0",
              salesUpdateVATTAXPercentance: detail['tax_percent']?.toString() ?? "0",
            ));
          }

          // Set item-level discount and tax from first item (if exists)
          if (salesDetails.isNotEmpty) {
            final firstItem = salesDetails.first;
            itemDiscountAmount.text = firstItem['discount_amount']?.toString() ?? '';
            itemDiscountPercentance.text = firstItem['discount_percentage']?.toString() ?? '';
            itemTaxVatAmount.text = firstItem['tax_amount']?.toString() ?? '';
            itemTaxVatPercentance.text = firstItem['tax_percent']?.toString() ?? '';
          }
        }

        debugPrint("Sale data loaded successfully");
        debugPrint("Bill Number: ${billNumberController.text}");
        debugPrint("Sales Date: ${purchaseDateController.text}");
        debugPrint("Items Count: ${saleUpdateList.length}");
      } else {
        debugPrint("API returned success: false");
      }
    } else {
      debugPrint("API call failed with status: ${response.statusCode}");
    }

    isLoading = false;
    notifyListeners();
  }

  ///show customer list.
  CustomerResponse? customerResponse;

  String errorMessage = "";

  ///show supplier
  Future<void> fetchCustomsr() async {
    isLoading = true;
    errorMessage = "";
    notifyListeners(); // Notify listeners that data is being fetched


    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    //final url = Uri.parse('https://commercebook.site/api/v1/customers/list');

    final url = Uri.parse(
        'https://commercebook.site/api/v1/all/customers/'); //api/v1/all/customers/

    try {
      final response = await http.get(url,  headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },);
      final data = jsonDecode(response.body);

      // Print the entire response in the terminal
      debugPrint("API Response: $data");

      if (response.statusCode == 200 && data["success"] == true) {
        customerResponse = CustomerResponse.fromJson(data);
        // Print the parsed data for debugging
        debugPrint("Parsed Supplier Data: ${customerResponse!.data}");
      } else {
        errorMessage = "Failed to fetch suppliers";
        debugPrint("Error: $errorMessage");
      }
    } catch (e) {
      errorMessage = "Error: $e";
      debugPrint("Error: $e");
    }

    isLoading = false;
    notifyListeners(); // Notify after data fetch is completed
  }

  Customer? selectedCustomer;

  void setCustomerFromSale(int saleCustomerId) {
    if (customerResponse != null) {
      try {
        selectedCustomer = customerResponse!.data.firstWhere(
          (c) => c.id == saleCustomerId,
          orElse: () => Customer(
            id: 0,
            userId: 0,
            name: "Unknown",
            proprietorName: "",
            due: 0.0,
            purchases: [],
          ),
        );
        notifyListeners();
      } catch (e) {
        debugPrint("Error selecting customer: $e");
      }
    }
  }

  // Method to add a new item to the list
  void addSaleItem(SaleUpdateModel newItem) {
    saleUpdateList.add(newItem);
    notifyListeners();
    debugPrint("=====>>>New item added to the list");
  }

  ///update selcted item.
  void updateSelectedItem(String name) {
    try {
      itemId = itemMap.entries.firstWhere((entry) => entry.value == name).key;
    } catch (e) {
      // Handle the case where no match is found
      itemId = null;
      selectedItemName = null; // Optional: Reset selected item if not found
    }
    selectedItemName = name;
    notifyListeners();
  }

  ///updated selected unit
  void updateSelectedUnit(String name) {
    try {
      int unitId =
          unitMap.entries.firstWhere((entry) => entry.value == name).key;
      unitController.text = unitId.toString();
    } catch (e) {
      // Handle the case where no match is found
      unitController.clear();
      selectedUnitName = null; // Optional: Reset selected unit if not found
    }
    selectedUnitName = name;
    notifyListeners();
  }

  ///get sub total
  String getSubTotal() {
    double subTotal = 0.00;

    for (var e in saleUpdateList) {
      subTotal += double.tryParse(e.subTotal) ?? 0.0;
    }
    return subTotal.toStringAsFixed(2);
  }

  /// gross total after giving discount amount.
  String getGrossTotalAfterDiscount() {
    double subtotal = double.tryParse(getSubTotal()) ?? 0.0;
    double discount = double.tryParse(updateDiscountAmount.text) ?? 0.0;

    double grossTotal = subtotal - discount;
    if (grossTotal < 0) grossTotal = 0;

    return grossTotal.toStringAsFixed(2);
  }

  ///update discount amount updted 2
  void updateDiscountAmountUpdate2(String value) {
    lastChanged = 'amount';
    updateDiscountAmount.text = value;

    double subtotal = double.tryParse(getSubTotal()) ?? 0.0;
    double discount = double.tryParse(value) ?? 0.0;

    // Update discount % field
    if (subtotal > 0) {
      double percent = (discount / subtotal) * 100;
      updateDiscountPercentance.text = percent.toStringAsFixed(2);
    } else {
      updateDiscountPercentance.text = "0";
    }

    // ✅ Update Gross Total live
    grossTotalController.text = getGrossTotalAfterDiscount();

    notifyListeners(); // ✅ Important!
  }

  ///update discount percent
  void updateDiscountPercent(String value) {
    lastChanged = 'percent';
    updateDiscountPercentance.text = value;

    double subtotal = double.tryParse(getSubTotal()) ?? 0.0;
    double percent = double.tryParse(value) ?? 0.0;

    double amount = (subtotal * percent) / 100;
    updateDiscountAmount.text = amount.toStringAsFixed(2);

    // ✅ Update Gross Total live
    grossTotalController.text = getGrossTotalAfterDiscount();

    notifyListeners(); // ✅ Important!
  }

  ///gross total
  void setGrossTotal() {
    final gross = getGrossTotalAfterDiscount();
    grossTotalController.text = gross;
    debugPrint("Updated Gross Total: $gross");
    notifyListeners();
  }

  ///final gross total with tax.
  String calculateFinalGrossTotalWithTax() {
    double subtotal = double.tryParse(getSubTotal()) ?? 0.0;
    double discount = double.tryParse(updateDiscountAmount.text) ?? 0.0;
    double tax = ((subtotal - discount) * taxPercent) / 100;

    _taxAmount = tax;

    double grossTotal = subtotal - discount + tax;
    return grossTotal.toStringAsFixed(2);
  }

  ///updated cash item sales updated
  addCashItemSaleUpdate(
    //String unitId,
    String selectedItemId,
    String price,
    String selectedUnitIdWithName,
    String qty,
    String discountAmount,
    String discountpercentace,
    String taxAmount,
    String taxPercentace,
    String dis,
  ) {
    saleUpdateList.add(SaleUpdateModel(
        itemId: selectedItemId,
        price: price,
        qty: qty,
        subTotal: (double.parse(price) * double.parse(qty)).toString(),
        unitId: '5_Packet_1',
        salesUpdateDiscountPercentace: discountpercentace,
        salesUpdateDiscountAmount: discountAmount,
        salesUpdateVATTAXAmount: taxAmount,
        salesUpdateVATTAXPercentance: taxPercentace,
        dis: dis));

    notifyListeners();
  }

  ///update sales details.
  void updateSaleDetail(int index) {
    final updatedPrice = double.tryParse(priceController.text);
    final updatedQty = double.tryParse(qtyController.text);
    final updatedDiscountAmount = double.tryParse(updateDiscountAmount.text);
    final updatedDiscountPercentage =
        double.tryParse(updateDiscountPercentance.text);
    final updatedTaxPercent = taxPercent;
    final updatedTaxAmount = taxAmount;
    final updatedSubtotal = double.tryParse(subTotalController.text);

    if (updatedPrice != null && updatedQty != null && updatedSubtotal != null) {
      saleUpdateList[index] = SaleUpdateModel(
        itemId: itemId?.toString() ?? saleUpdateList[index].itemId,
        price: updatedPrice.toStringAsFixed(2),
        qty: updatedQty.toStringAsFixed(2),
        subTotal: updatedSubtotal.toStringAsFixed(2),
        unitId: unitController.text.isNotEmpty
            ? unitController.text
            : saleUpdateList[index].unitId,
        salesUpdateDiscountAmount: updatedDiscountAmount?.toStringAsFixed(2),
        salesUpdateDiscountPercentace:
            updatedDiscountPercentage?.toStringAsFixed(2),
        salesUpdateVATTAXAmount: updatedTaxAmount.toStringAsFixed(2),
        salesUpdateVATTAXPercentance: taxPercentValue,
      );

      notifyListeners();
    } else {
      debugPrint("Invalid input: Cannot update.");
    }
  }

  ///get unit name
  String? getUnitName(String id) {
    for (var e in unitResponseModel) {
      if (e.id.toString() == id) {
        return e.name.toString();
      }
    }
    return null;
  }

  ///save data.
  void saveData(
      {required String qty,
      required String price,
      required String subtotal,
      required String itemId,
      required String unitId}) {
    qtyController = TextEditingController(text: qty);
    priceController = TextEditingController(text: price);
    subTotalController = TextEditingController(text: subtotal);
    selectedItemName = itemId;
    selectedUnitName = unitId;
    notifyListeners();
  }

  ///addItem
  void addItem({
    required int id,
    required int price,
    required int qty,
    required int subTotal,
    required int unitId,
    required dynamic discountPercentage,
    required dynamic discountAmount,
    required dynamic taxPercent,
    required dynamic taxAmount,
    required dynamic saleEditResponse,
  }) {
    saleEditResponse.data!.salesDetails!.add(SaleDetail(
      itemId: id,
      price: price,
      qty: qty,
      subTotal: subTotal,
      unitId: unitId,
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
      taxPercent: taxPercent,
      taxAmount: taxAmount,
    ));

    saleUpdateList.add((SaleUpdateModel(
        itemId: id.toString(),
        qty: qty.toString(),
        unitId:
            "${unitId.toString()}_${getUnitName(unitId.toString())}_${qty.toString()}",
        price: price.toString(),
        subTotal: subTotal.toString(),
        salesUpdateDiscountPercentace: null,
        salesUpdateDiscountAmount: null,
        salesUpdateVATTAXAmount: null,
        salesUpdateVATTAXPercentance: '5_10')));

    notifyListeners();
  }

  ///calculate subtotal
  void calculateSubtotal() {
    double qty = double.tryParse(qtyController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;
    double total = qty * price;

    double discountPercent =
        double.tryParse(updateDiscountPercentance.text) ?? 0;
    double discountAmt = double.tryParse(updateDiscountAmount.text) ?? 0;
    double subtotal = double.parse(subTotalController.text.toString());

    if (lastChanged == 'percent') {
      discountAmt = (total * discountPercent) / 100;
      updateDiscountAmount.text = discountAmt.toStringAsFixed(2);
      subTotalController.text = (subtotal + taxAmount - discountAmt).toString();
    } else if (lastChanged == 'amount') {
      if (total > 0) {
        discountPercent = (discountAmt / total) * 100;
        updateDiscountPercentance.text = discountPercent.toStringAsFixed(2);
        subTotalController.text =
            (subtotal + taxAmount - discountAmt).toString();
      } else {
        updateDiscountPercentance.text = '0';
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

  ///calculate tax
  void calculateTax() {
    double subtotal = double.tryParse(getSubTotal()) ?? 0.0;
    double discount = double.tryParse(updateDiscountAmount.text) ?? 0.0;
    double discountedSubtotal = subtotal - discount;

    if (discountedSubtotal < 0) discountedSubtotal = 0;

    _taxAmount = (discountedSubtotal * _taxPercent) / 100;
    notifyListeners();
  }

  ///updated tax percentane
  updateTaxPaecentId(String value) {
    taxPercentValue = value;
    notifyListeners();
  }

  ///updated total tax id
  updateTotalTaxId(String value) {
    totaltaxPercentValue = value;
    notifyListeners();
  }

  set taxPercent(double value) {
    _taxPercent = value;
    calculateTax(); // 🔁 only recalculate tax when percent changes
    notifyListeners();
  }

  ///update sales
  Future<void> updateSale(BuildContext context) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final discountAmount = updateDiscountAmount.text;
      final discountPercent = updateDiscountPercentance.text;

      // Get the current sale ID
      final saleId = currentSaleId?.toString() ;

      final url = "https://commercebook.site/api/v1/sales/update"
          "?id=$saleId"
          "&user_id=${prefs.getInt("user_id")}"
          "&customer_id=${customerController.text}"
          "&bill_number=${billNumberController.text}"
          "&sale_date=${purchaseDateController.text}"
          "&details_notes=notes"
          "&gross_total=${grossTotalController.text}"
          "&payment_out=1"
          "&payment_amount=${calculateFinalGrossTotalWithTax()}"
          "&discount_percent=$discountPercent"
          "&discount=$discountAmount"
          "&tax_percents=${taxPercentValue}"
          "&tax=${taxAmount.toStringAsFixed(2)}"
          "&total_item_discounts=${updateDiscountAmount.text}"
          "&total_item_vats=${taxAmount.toStringAsFixed(2)}";

      debugPrint("API URL: $url");

      final requestBody = {
        "sales_items": saleUpdateList.map((e) => e.toJson()).toList(),
      };

      debugPrint("Request Body: ${jsonEncode(requestBody)}");

      if (requestBody.isEmpty) return;

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json",
        "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      debugPrint("API Response: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data["success"] == true) {
          debugPrint("Sale successful: ${data["data"]}");

          // Navigate to home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sale Update successful!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Handle API returning success: false
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ?? "An error occurred."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Handle API returning an error status code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Failed to process sale. Please try again.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle network or JSON decoding errors
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


 
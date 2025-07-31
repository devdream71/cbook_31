import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/give_information_dialog.dart';
import 'package:cbook_dt/common/item_dropdown_custom.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/model/sales_update_by_id_model.dart';
import 'package:cbook_dt/feature/sales/model/sales_update_model.dart';
import 'package:cbook_dt/feature/sales/update_sale_item_view.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/suppliers/suppliers_create.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:cbook_dt/feature/unit/model/demo_unit_model.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

  SalesEditResponse saleEditResponse = SalesEditResponse();

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
    const url = "https://commercebook.site/api/v1/units";
    final response = await http.get(Uri.parse(url));

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
    const url = "https://commercebook.site/api/v1/items";
    final response = await http.get(Uri.parse(url));

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

  ///fetch unit date.
  Future<void> fetchSaleData(int id) async {
    isLoading = true;

    notifyListeners();

    await fetchItems();
    await fetchUnits();

    final url = "https://commercebook.site/api/v1/sales/edit/$id";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      saleEditResponse = SalesEditResponse.fromJson(response.body);

      saleUpdateList.clear();

      saleEditResponse.data!.salesDetails!.forEach((e) {
        saleUpdateList.add(SaleUpdateModel(
          itemId: e.itemId.toString(),
          price: e.price.toString(),
          qty: e.qty.toString(),
          subTotal: e.subTotal.toString(),
          unitId:
              "${e.unitId.toString()}_${getUnitName(e.unitId.toString())}_${e.qty.toString()}",
          salesUpdateDiscountPercentace: e.discountPercentage.toString(),
          salesUpdateDiscountAmount: e.discountAmount.toString(),
          salesUpdateVATTAXAmount: e.taxAmount.toString(),
          salesUpdateVATTAXPercentance: "${(e.taxPercent ?? 0)}",
        ));
      });

      debugPrint(saleUpdateList.length.toString());

      // print(purchaseUpdateList.length);
      debugPrint(saleUpdateList.length.toString());

      if (data['success']) {
        final purchaseData = saleEditResponse.data!;

        purchaseDetailsList = purchaseData.salesDetails ?? [];
        billNumberController.text = purchaseData.billNumber ?? "";
        // updateDiscountAmount.text = purchaseData.discount ?? '0.00';
        updateDiscountAmount.text = purchaseData.discount?.toString() ?? '0.00';
        purchaseDateController.text = purchaseData.salesDate ?? "";
        grossTotalController.text = purchaseData.grossTotal?.toString() ?? "";
        grossTotalController.text = getGrossTotalAfterDiscount();
        customerController.text = purchaseData.customerId?.toString() ?? "";
        hasCustomer = purchaseData.customerId != null && purchaseData.customerId != 0;
        updateDiscountPercentance.text = purchaseData.discountPercent ?? "";
        ///item discoumt amount and item discount percentane.
        itemDiscountAmount.text = purchaseData.salesDetails!.first.discountAmount ?? '';
        itemDiscountPercentance.text = purchaseData.salesDetails!.first.discountPercentage ?? '';

        itemTaxVatAmount.text = purchaseData.salesDetails!.first.taxAmount ?? '';
        itemTaxVatPercentance.text = purchaseData.salesDetails!.first.taxPercent ?? '';
      }
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

    //final url = Uri.parse('https://commercebook.site/api/v1/customers/list');

    final url = Uri.parse(
        'https://commercebook.site/api/v1/all/customers/'); //api/v1/all/customers/

    try {
      final response = await http.get(url);
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
      print("Error selecting customer: $e");
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
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      //final saleProvider = Provider.of<SaleUpdateProvider>(context, listen: false);

      final discountAmount = updateDiscountAmount.text;
      final discountPercent = updateDiscountPercentance.text;

      // final url =
      //     "https://commercebook.site/api/v1/sales/update?id=${saleEditResponse.data!.salesDetails![0].purchaseId}&user_id=${prefs.getInt("user_id")}&customer_id=${saleEditResponse.data!.customerId}&bill_number=${saleEditResponse.data!.billNumber}&sale_date=${saleEditResponse.data!.salesDate}&details_notes=notes&gross_total=${getSubTotal()}&payment_out=1&payment_amount=0&discount_percent=&discount=&tax_percents=3_12.0&tax=41.5&total_item_discounts=15&total_item_vats=10";

      final url = "https://commercebook.site/api/v1/sales/update"
          "?id=${saleEditResponse.data!.salesDetails![0].purchaseId}"
          "&user_id=${prefs.getInt("user_id")}"
          "&customer_id=${saleEditResponse.data!.customerId}"
          "&bill_number=${saleEditResponse.data!.billNumber}"
          "&sale_date=${saleEditResponse.data!.salesDate}"
          "&details_notes=notes"
          "&gross_total=${grossTotalController.text}" // ✅ Updated here ///grossTotalController
          "&payment_out=1"
          "&payment_amount=${calculateFinalGrossTotalWithTax()}"
          "&discount_percent=$discountPercent"
          "&discount=$discountAmount"
          "&tax_percents=${taxPercentValue}"
          "&tax=${taxAmount.toStringAsFixed(2)}"
          "&total_item_discounts=${updateDiscountAmount.text}"
          "&total_item_vats=${taxAmount.toStringAsFixed(2)}";

      debugPrint("API URL: $url");

      //final requestBody = {"sales_items": saleUpdateList};

      final requestBody = {
  "sales_details": saleUpdateList.map((e) => e.toJson()).toList(),
  // other fields here...
};

      print(requestBody.length);

      //final requestBody = {"sales_items": salesItems};

      if (requestBody.isEmpty) return;

      debugPrint("Request Body: ${jsonEncode(requestBody)}");

      debugPrint("Stop === Stop");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
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
          // Handle API returning success: false (e.g., Stock not found)
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

///=====> Ui

///====>Purchase update Screen
class salesUpdateScreen extends StatefulWidget {
  final int salesId;

  const salesUpdateScreen({Key? key, required this.salesId}) : super(key: key);

  @override
  State<salesUpdateScreen> createState() => _salesUpdateScreenState();
}

class _salesUpdateScreenState extends State<salesUpdateScreen> {



  String? selectedTaxName;
  String? selectedTaxId;

  String? selectedCustomer;
  String? selectedCustomerId;
  Customer? selectedCustomerObject;

  bool showNoteField = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController billController = TextEditingController();

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  void _onCancel() {
    Navigator.pop(context);
  }



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemCategoryProvider>(context, listen: false)
          .fetchCategories();
      Provider.of<AddItemProvider>(context, listen: false).fetchItems();

      Future.microtask(() =>
          Provider.of<PaymentVoucherProvider>(context, listen: false)
              .fetchBillPersons());

      Future.microtask(() =>
          Provider.of<CustomerProvider>(context, listen: false)
              .fetchCustomsr());

      Provider.of<SaleUpdateProvider>(context, listen: false)
          .fetchSaleData(widget.salesId);

      
      // Set the selected customer based on sale data
    final saleUpdateProvider =
        Provider.of<SaleUpdateProvider>(context, listen: false);

    if (saleUpdateProvider.saleEditResponse.data != null) {
      saleUpdateProvider.setCustomerFromSale(
          saleUpdateProvider.saleEditResponse.data!.customerId ?? 0);
    }
          
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();

    final updateController = context.watch<SaleUpdateProvider>();

    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: true);

    final colorScheme = Theme.of(context).colorScheme;

    final saleProvider = Provider.of<SaleUpdateProvider>(context);

    debugPrint("purchase id");

    return ChangeNotifierProvider(
      create: (_) => SaleUpdateProvider()..fetchSaleData(widget.salesId),
      child: Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
            backgroundColor: colorScheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title: const Text(
              "Update Sale",
              style: TextStyle(color: Colors.yellow, fontSize: 16),
            )),
        body: SingleChildScrollView(
          child: Consumer<SaleUpdateProvider>(
            builder: (context, provider, child) {
              debugPrint("======================");
              // print(provider.qtyController);
              return provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: InkWell(
                              onTap: () {
                                controller.updateCash(context);
                              },
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        provider.hasCustomer
                                            ? "Credit"
                                            : "Cash",
                                        style: GoogleFonts.lato(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 1),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 12,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    ///bill to cash and customer.
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Bill To",
                                            style: TextStyle(
                                                color: Colors.black,
                                                // fontWeight: FontWeight.bold,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                          ),
                                          vPad5,
                                          const Text(
                                            "Supplier",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),

                                          ///=> supplier cash and supplier or customer list in api ,
                                          Row(
                                            children: [
                                              SizedBox(
                                                  height: 58,
                                                  width: 180,
                                                  // Adjusted height for cursor visibility
                                                  child: provider.hasCustomer
                                                      //controller.isCash
                                                      ? Column(
                                                          children: [
                                                            AddSalesFormfieldTwo(
                                                                controller:
                                                                    controller
                                                                        .codeController,
                                                                //label: "Customer",
                                                                customerorSaleslist:
                                                                    "Showing supplieer list",
                                                                customerOrSupplierButtonLavel:
                                                                    "Add new supplier",
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const SuppliersCreate()));
                                                                }),
                                                            Consumer<
                                                                CustomerProvider>(
                                                              builder: (context,
                                                                  customerProvider,
                                                                  child) {
                                                                final customerList =
                                                                    customerProvider
                                                                            .customerResponse
                                                                            ?.data ??
                                                                        [];

                                                                return Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    // If the customer list is empty, show a SizedBox
                                                                    if (customerList
                                                                        .isEmpty)
                                                                      const SizedBox(
                                                                          height:
                                                                              2), // Adjust height as needed

                                                                    // Otherwise, show the dropdown with customers
                                                                    if (customerList
                                                                        .isNotEmpty)

                                                                      // Check if the selected customer is valid
                                                                      if (customerProvider.selectedCustomer !=
                                                                              null &&
                                                                          customerProvider.selectedCustomer!.id !=
                                                                              -1)
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              "${customerProvider.selectedCustomer!.type == 'customer' ? 'Receivable' : 'Payable'}: ",
                                                                              style: TextStyle(
                                                                                fontSize: 10,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: customerProvider.selectedCustomer!.type == 'customer' ? Colors.green : Colors.red,
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 2.0),
                                                                              child: Text(
                                                                                "৳ ${customerProvider.selectedCustomer!.due.toStringAsFixed(2)}",
                                                                                style: const TextStyle(
                                                                                  fontSize: 10,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      Dialog(
                                                                child:
                                                                    ReusableForm(
                                                                  nameController:
                                                                      nameController,
                                                                  phoneController:
                                                                      phoneController,
                                                                  emailController:
                                                                      emailController,
                                                                  addressController:
                                                                      addressController,
                                                                  primaryColor:
                                                                      Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                  onCancel:
                                                                      _onCancel,
                                                                  onSubmit: () {
                                                                    setState(
                                                                        () {
                                                                      controller
                                                                          .updatedCustomerInfomation(
                                                                        nameFrom:
                                                                            nameController.text,
                                                                        phoneFrom:
                                                                            phoneController.text,
                                                                        emailFrom:
                                                                            emailController.text,
                                                                        addressFrom:
                                                                            addressController.text,
                                                                      );
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                            "Cash",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        )),

                                              hPad3, // Space between TextField and Icon
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      child: Column(
                                        children: [
                                          //bill number
                                          AddSalesFormfield(
                                              labelText: 'Bill Number',
                                              //label: "Bill Number",
                                              controller: provider
                                                  .billNumberController),

                                          const SizedBox(
                                            height: 8,
                                          ),

                                          ///date
                                          GestureDetector(
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                              );

                                              if (pickedDate != null) {
                                                String formattedDate =
                                                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                                provider.purchaseDateController
                                                    .text = formattedDate;
                                              }
                                            },
                                            child: AbsorbPointer(
                                              child: AddSalesFormfield(
                                                labelText: 'Purchase Date',
                                                //label: "Purchase Date",
                                                controller: provider
                                                    .purchaseDateController,
                                              ),
                                            ),
                                          ),

                                          ///bill person
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Consumer<
                                                PaymentVoucherProvider>(
                                              builder:
                                                  (context, provider, child) {
                                                return SizedBox(
                                                  height: 30,
                                                  width: double.infinity,
                                                  child: provider.isLoading
                                                      ? const Center(
                                                          child:
                                                              CircularProgressIndicator())
                                                      : CustomDropdownTwo(
                                                          hint: '',
                                                          items: provider
                                                              .billPersonNames,
                                                          width:
                                                              double.infinity,
                                                          height: 30,
                                                          labelText:
                                                              'Bill Person',
                                                          selectedItem:
                                                              selectedBillPerson,
                                                          onChanged: (value) {
                                                            debugPrint(
                                                                '=== Bill Person Selected: $value ===');
                                                            setState(() {
                                                              selectedBillPerson =
                                                                  value;
                                                              selectedBillPersonData =
                                                                  provider
                                                                      .billPersons
                                                                      .firstWhere(
                                                                (person) =>
                                                                    person
                                                                        .name ==
                                                                    value,
                                                              ); // ✅ Save the whole object globally
                                                              selectedBillPersonId =
                                                                  selectedBillPersonData!
                                                                      .id;
                                                            });

                                                            debugPrint(
                                                                'Selected Bill Person Details:');
                                                            debugPrint(
                                                                '- ID: ${selectedBillPersonData!.id}');
                                                            debugPrint(
                                                                '- Name: ${selectedBillPersonData!.name}');
                                                            debugPrint(
                                                                '- Phone: ${selectedBillPersonData!.phone}');
                                                          }),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                ///===>item list , api item and new item added.

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.saleUpdateList.length,
                                  itemBuilder: (context, index) {
                                    final detail =
                                        provider.saleUpdateList![index];

                                    return GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateSaleItemView(
                                              index: index,
                                              itemDetail: detail,
                                              provider: provider,
                                              // itemDetail: detail,
                                              itemMap: provider.itemMap,
                                              unitMap: provider.unitMap,
                                              itemList: provider.itemList,
                                              itemDiscoumtAmount:
                                                  provider.itemDiscountAmount,
                                              itemDiscountPercentance: provider
                                                  .itemDiscountPercentance,
                                              ItemtaxAmount:
                                                  provider.itemTaxVatAmount,
                                              ItemtaxPercentance: provider
                                                  .itemTaxVatPercentance,
                                            ),
                                          ),
                                        );
                                        if (context.mounted) {
                                          provider.notifyListeners();
                                        }
                                        //provider.notifyListeners();
                                      },
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        elevation: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${index + 1}.   ",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    /// LEFT SECTION - Item Info
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Item: ${provider.itemMap[int.tryParse(detail.itemId) ?? 0] ?? "Unknown"}  (${provider.unitMap[int.tryParse(detail.unitId.split("_")[0]) ?? 0] ?? "Unknown"})",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Qty: ${detail.qty}",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              Text(
                                                                "Price: ৳ ${detail.price}",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            "Discount: ${detail.salesUpdateDiscountAmount}৳ , ${detail.salesUpdateDiscountPercentace} %",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12),
                                                          ),
                                                          Text(
                                                            "Tax: ${detail.salesUpdateVATTAXAmount}৳, ${detail.salesUpdateVATTAXPercentance} %",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    /// RIGHT SECTION - Subtotal
                                                    Text(
                                                      "Subtotal: ৳ ${detail.subTotal}",
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                controller.isCash
                                    ? controller.itemsCash.isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              showSalesDialog(context,
                                                  controller, provider);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Add Item & Service",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        showSalesDialog(
                                                          context,
                                                          controller,
                                                          provider,
                                                        );
                                                      },
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                    : controller.itemsCredit.isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              showSalesDialog(context,
                                                  controller, provider);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Add Item & Service",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        showSalesDialog(
                                                            context,
                                                            controller,
                                                            provider);
                                                      },
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),

                                const SizedBox(
                                  height: 5,
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.note_add_outlined,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showNoteField = !showNoteField;
                                        });
                                      },
                                    ),
                                    if (showNoteField)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0),
                                          child: Container(
                                            height: 40,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                  top: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1),
                                                  bottom: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1),
                                                  left: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1),
                                                  right: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1)),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0),
                                            child: Center(
                                              child: TextField(
                                                controller: controller
                                                    .saleUpdateNoteController,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                                onChanged: (value) {
                                                  controller
                                                      .saleUpdateNoteController
                                                      .text = value;
                                                },
                                                maxLines: 2,
                                                cursorHeight: 12,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                  hintText: "Note",
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey.shade400,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                //===>subtotal

                                //===>subtotal
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 200,
                                          child: AddSalesFormfield(
                                            labelText: 'Subtotal',
                                            readOnly: true,
                                            controller: TextEditingController(
                                                text: provider.getSubTotal()),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 0.0),
                                                child:

                                                    ///discount amount.
                                                    SizedBox(
                                                  width: 95,
                                                  child: AddSalesFormfield(
                                                    labelText: "DIS AMT",
                                                    controller: updateController
                                                        .updateDiscountAmount,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      updateController
                                                          .updateDiscountAmountUpdate2(
                                                              value);

                                                      saleProvider
                                                              .grossTotalController
                                                              .text =
                                                          saleProvider
                                                              .calculateFinalGrossTotalWithTax();
                                                      debugPrint(
                                                          "Discount Amount Changed: ${updateController.updateDiscountAmount.text}");
                                                      debugPrint(
                                                          "Discount Percent Changed: ${updateController.updateDiscountPercentance.text}");
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child:

                                                    /// discount percentance
                                                    SizedBox(
                                                  width: 95,
                                                  child: AddSalesFormfield(
                                                    labelText: 'DIS (%)',
                                                    controller: updateController
                                                        .updateDiscountPercentance,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      updateController
                                                          .updateDiscountPercent(
                                                              value);
                                                      saleProvider
                                                              .grossTotalController
                                                              .text =
                                                          saleProvider
                                                              .calculateFinalGrossTotalWithTax();
                                                      debugPrint(
                                                          "Discount Percent Changed: ${updateController.updateDiscountPercentance.text}");
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),
                                ////Vat, Tax

                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      /// --- VAT Dropdown ---
                                      Consumer2<TaxProvider,
                                          SaleUpdateProvider>(
                                        builder: (context, taxProvider,
                                            saleProvider, _) {
                                          if (taxProvider.isLoading) {
                                            return const SizedBox();
                                          }

                                          if (taxProvider.taxList.isEmpty) {
                                            return const Text(
                                              'No tax options available.',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            );
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomDropdownTwo(
                                                  labelText: 'VAT/TAX',
                                                  items: taxProvider.taxList
                                                      .map((tax) =>
                                                          "${tax.name} - (${tax.percent})")
                                                      .toList(),
                                                  width: 95,
                                                  height: 30,
                                                  selectedItem: selectedTaxName,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      selectedTaxName =
                                                          newValue;

                                                      final nameOnly = newValue
                                                          ?.split(" - ")
                                                          ?.first;
                                                      final selected =
                                                          taxProvider.taxList
                                                              .firstWhere(
                                                        (tax) =>
                                                            tax.name ==
                                                            nameOnly,
                                                        orElse: () =>
                                                            taxProvider
                                                                .taxList.first,
                                                      );

                                                      selectedTaxId = selected
                                                          .id
                                                          .toString();
                                                      final selectedPercent =
                                                          double.tryParse(selected
                                                                  .percent) ??
                                                              0.0;

                                                      // ✅ Update provider values
                                                      saleProvider
                                                              .selectedTaxPercent =
                                                          selectedPercent;
                                                      saleProvider.taxPercent =
                                                          selectedPercent;

                                                      saleProvider
                                                          .updateTaxPaecentId(
                                                              '${selectedTaxId}_${selectedPercent}');

                                                      // ✅ Update Gross Total
                                                      saleProvider
                                                              .grossTotalController
                                                              .text =
                                                          saleProvider
                                                              .calculateFinalGrossTotalWithTax();

                                                      debugPrint(
                                                          'TAX PERCENT VALUE: ${saleProvider.taxPercent}');
                                                      debugPrint(
                                                          'Gross: ${saleProvider.grossTotalController.text}');
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(
                                        width: 8,
                                      ),

                                      /// --- TAX AMOUNT FIELD (ReadOnly) ---
                                      Consumer<SaleUpdateProvider>(
                                        builder: (context, controller, _) {
                                          return SizedBox(
                                            width: 95,
                                            child: AddSalesFormfield(
                                              //label: "TAX AMT",
                                              labelText: 'TAX AMT',
                                              controller: TextEditingController(
                                                text: controller.taxAmount
                                                    .toStringAsFixed(2),
                                              ),
                                              readOnly: true,
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          );
                                        },
                                      ),
                                    ]),

                                const SizedBox(
                                  height: 8,
                                ),

                                //===>Gross Total, working, discount.
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 10),

                                        /// --- GROSS TOTAL ---
                                        Consumer<SaleUpdateProvider>(
                                          builder: (context, controller, _) {
                                            return SizedBox(
                                              width: 200,
                                              child: AddSalesFormfield(
                                                //label: "Gross Total",
                                                labelText: 'Gross Total',
                                                controller: controller
                                                    .grossTotalController,
                                                readOnly: true,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                //cash Received ,, working ,
                                controller.isReciptType && controller.isCash
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                  height: 25,
                                                  child: Checkbox(
                                                    value:
                                                        controller.isReceived,
                                                    onChanged: (bool? value) {
                                                      if (controller.isCash) {
                                                        // Allow checking, but prevent unchecking
                                                        if (value == true) {
                                                          controller
                                                                  .isReceived =
                                                              true;
                                                          controller
                                                              .notifyListeners();
                                                        }
                                                      } else {
                                                        // Allow normal toggling when not cash
                                                        controller.isReceived =
                                                            value ?? false;
                                                        controller
                                                            .notifyListeners();
                                                      }
                                                    },
                                                  )),
                                              const Text("",
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                height: 30,
                                                width: 200,
                                                child: Consumer<
                                                    SaleUpdateProvider>(
                                                  builder:
                                                      (context, controller, _) {
                                                    return SizedBox(
                                                      width: 160,
                                                      child: AddSalesFormfield(
                                                        labelText: "Received",
                                                        controller: controller
                                                            .grossTotalController,
                                                        readOnly: true,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              onPressed: () async {
                                updateController.updateSale(context);

                                //await provider.updateSale(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Update Sale",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  ///new sales show
  void showSalesDialog(BuildContext context, SalesController controller,
      SaleUpdateProvider updateProvider) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);
    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);
    final taxProvider = Provider.of<TaxProvider>(context, listen: false);
    final salesController =
        Provider.of<SalesController>(context, listen: false);

    final TextEditingController itemController = TextEditingController();

    String? selectedTaxName;
    String? selectedTaxId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.fetchCategories();
    }

    if (taxProvider.taxList.isEmpty) {
      await taxProvider.fetchTaxes();
    }

    Provider.of<AddItemProvider>(context, listen: false).clearStockData();
    controller.clearFields();

    Navigator.of(context).pop();

    String? selectedCategoryId;
    String? selectedSubCategoryId;

    showDialog(
      context: context,
      builder: (context) {
        // Local state variables that will persist within StatefulBuilder
        List<String> unitIdsList = [];
        String? localSelectedUnit;
        bool isItemSelected = false;

        return StatefulBuilder(builder: (context, setState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final controller =
                Provider.of<SalesController>(context, listen: false);
            controller.addListener(() {
              setState(() {});
            });
          });

          bool isLoading =
              categoryProvider.isLoading || fetchStockQuantity.isLoading;

          final double screenWidth = MediaQuery.of(context).size.width;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 380,
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  ///dialog title and close button.
                  Container(
                    height: 30,
                    color: const Color(0xff278d46),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 30),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 5),
                            Text(
                              "Update Item & service",
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey.shade100,
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ///Content
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, right: 10.0, top: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        ///Item search dropdown
                        Container(
                          child: ItemCustomDropDownTextField(
                            controller: itemController,
                            onItemSelected: (selectedItem) async {
                              debugPrint(
                                  "=======> Selected Item: ${selectedItem.name} (ID: ${selectedItem.id})");

                              // Save selected item name and id in controller
                              controller.seletedItemName = selectedItem.name;
                              controller.selcetedItemId =
                                  selectedItem.id.toString();

                              // Fetch stock quantity
                              if (controller.selcetedItemId != null) {
                                fetchStockQuantity.fetchStockQuantity(
                                    controller.selcetedItemId!);
                              }

                              // Ensure unitProvider is loaded
                              if (unitProvider.units.isEmpty) {
                                await unitProvider.fetchUnits();
                              }

                              // Clear and reset everything
                              unitIdsList.clear();
                              localSelectedUnit = null;
                              controller.selectedUnit = null;

                              debugPrint(
                                  "Selected item unitId: ${selectedItem.unitId}");
                              debugPrint(
                                  "Selected item secondaryUnitId: ${selectedItem.secondaryUnitId}");

                              // Add base unit
                              if (selectedItem.unitId != null &&
                                  selectedItem.unitId != '') {
                                final unit = unitProvider.units.firstWhere(
                                  (unit) =>
                                      unit.id.toString() ==
                                      selectedItem.unitId.toString(),
                                  orElse: () => Unit(
                                      id: 0,
                                      name: 'Unknown Unit',
                                      symbol: '',
                                      status: 0),
                                );
                                if (unit.id != 0) {
                                  unitIdsList.add(unit.name);
                                  // Set as default selected unit
                                  localSelectedUnit = unit.name;
                                  controller.selectedUnit = unit.name;

                                  String finalUnitString =
                                      "${unit.id}_${unit.name}_1";
                                  controller.selectedUnitIdWithNameFunction(
                                      finalUnitString);
                                }
                              }

                              // Add secondary unit
                              if (selectedItem.secondaryUnitId != null &&
                                  selectedItem.secondaryUnitId != '') {
                                final secondaryUnit =
                                    unitProvider.units.firstWhere(
                                  (unit) =>
                                      unit.id.toString() ==
                                      selectedItem.secondaryUnitId.toString(),
                                  orElse: () => Unit(
                                      id: 0,
                                      name: 'Unknown Unit',
                                      symbol: '',
                                      status: 0),
                                );
                                if (secondaryUnit.id != 0) {
                                  unitIdsList.add(secondaryUnit.name);
                                }
                              }

                              isItemSelected = true;

                              if (unitIdsList.isEmpty) {
                                debugPrint(
                                    "No valid units found for this item.");
                              } else {
                                debugPrint("Units Available: $unitIdsList");
                                debugPrint(
                                    "Default selected unit: $localSelectedUnit");
                              }

                              // Trigger UI rebuild
                              setState(() {});
                            },
                          ),
                        ),

                        ///Stock available display
                        Container(
                          child: Consumer<AddItemProvider>(
                            builder: (context, stockProvider, child) {
                              final stock = stockProvider.stockData;

                              if (stock != null && !controller.hasCustomPrice) {
                                controller.mrpController.text =
                                    stock.price.toString();
                              }

                              return stock != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 0.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "   Stock Available: ${stock.unitStocks} ",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            },
                          ),
                        ),

                        ///Quantity and Unit row
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Qty field
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Container(
                                      child: AddSalesFormfield(
                                        label: "",
                                        labelText: "Item Qty",
                                        controller: controller.qtyController,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            controller.calculateSubtotal();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              /// Unit Dropdown
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 30,
                                      child: CustomDropdownTwo(
                                        key: ValueKey(
                                            '${unitIdsList.length}_${localSelectedUnit}_${isItemSelected}'), // Force rebuild when data changes
                                        hint: !isItemSelected
                                            ? '' //Select item first
                                            : unitIdsList.isEmpty
                                                ? 'No units available'
                                                : 'Select unit',
                                        items: unitIdsList,
                                        width: double.infinity,
                                        height: 30,
                                        labelText: 'Unit',
                                        selectedItem: localSelectedUnit,
                                        onChanged: (selectedUnit) {
                                          print("Selected Unit: $selectedUnit");

                                          // Update both local and controller state
                                          setState(() {
                                            localSelectedUnit = selectedUnit;
                                            controller.selectedUnit =
                                                selectedUnit;
                                          });

                                          final selectedUnitObj =
                                              unitProvider.units.firstWhere(
                                            (unit) => unit.name == selectedUnit,
                                            orElse: () => Unit(
                                              id: 0,
                                              name: "Unknown Unit",
                                              symbol: "",
                                              status: 0,
                                            ),
                                          );

                                          String finalUnitString = '';
                                          int qty = 1;

                                          for (var item
                                              in fetchStockQuantity.items) {
                                            if (item.id.toString() ==
                                                controller.selcetedItemId) {
                                              String unitId =
                                                  selectedUnitObj.id.toString();
                                              String unitName = selectedUnit;

                                              if (unitId ==
                                                  item.secondaryUnitId
                                                      .toString()) {
                                                qty = item.secondaryUnitQty ??
                                                    item.unitQty ??
                                                    1;
                                              } else if (unitId ==
                                                  item.unitId.toString()) {
                                                qty = item.unitQty ?? 1;
                                              }

                                              finalUnitString =
                                                  "${unitId}_${unitName}_$qty";
                                              controller
                                                  .selectedUnitIdWithNameFunction(
                                                      finalUnitString);
                                              break;
                                            }
                                          }

                                          if (finalUnitString.isEmpty) {
                                            finalUnitString =
                                                "${selectedUnitObj.id}_${selectedUnit}_1";
                                            controller
                                                .selectedUnitIdWithNameFunction(
                                                    finalUnitString);
                                          }

                                          print(
                                              "🆔 Final Unit ID: $finalUnitString");

                                          controller.notifyListeners();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        //purchase price
                        Container(
                          //color: Colors.blueGrey,
                          child: AddSalesFormfield(
                            //height: 35,
                            label: "", //price
                            labelText: "Price",
                            controller: controller.mrpController,
                            keyboardType: TextInputType.number,
                            readOnly: false,
                            onChanged: (value) {
                              setState(() {
                                controller.hasCustomPrice = true;
                                controller.calculateSubtotal();
                              });
                            },
                          ),
                        ),

                        ////discount percentan ande amount

                        // Discount percentage and amount row
                        Container(
                          // color: Colors.tealAccent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Discount Percentage (%)
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0),
                                      child: AddSalesFormfield(
                                        labelText: "Discount (%)",
                                        label: " ",
                                        controller:
                                            controller.discountPercentance,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            controller.lastChanged = 'percent';
                                            controller.calculateSubtotal();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                  width: 8), // spacing between fields

                              /// Discount Amount
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0),
                                      child: AddSalesFormfield(
                                        label: "",
                                        labelText: "Amount",
                                        controller: controller.discountAmount,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            controller.lastChanged = 'amount';
                                            controller.calculateSubtotal();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ✅ VAT/TAX Dropdown Row
                        Container(
                          // color: Colors.brown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dropdown (VAT / TAX)
                              Expanded(
                                flex: 1,
                                child: Consumer<TaxProvider>(
                                  builder: (context, taxProvider, child) {
                                    if (taxProvider.isLoading) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (taxProvider.taxList.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No tax options available.',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      );
                                    }

                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          height: 30,
                                          child: CustomDropdownTwo(
                                            labelText: 'Vat/Tax',
                                            hint: '',
                                            items: taxProvider.taxList
                                                .map((tax) =>
                                                    "${tax.name} - (${tax.percent})")
                                                .toList(),
                                            width: double.infinity,
                                            height: 30,
                                            selectedItem: selectedTaxName,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedTaxName = newValue;

                                                final nameOnly = newValue
                                                    ?.split(" - ")
                                                    .first;

                                                final selected = taxProvider
                                                    .taxList
                                                    .firstWhere(
                                                  (tax) => tax.name == nameOnly,
                                                  orElse: () =>
                                                      taxProvider.taxList.first,
                                                );

                                                selectedTaxId =
                                                    selected.id.toString();

                                                controller.selectedTaxPercent =
                                                    double.tryParse(
                                                        selected.percent);

                                                controller
                                                    .taxPercent = controller
                                                        .selectedTaxPercent ??
                                                    0.0;

                                                controller.selectedTaxId =
                                                    selected.id.toString();
                                                controller.selectedTaxPercent =
                                                    double.tryParse(
                                                        selected.percent);

                                                // controller.updateTaxPaecentId(
                                                //     '${selectedTaxId}_${controller.selectedTaxPercent}');

                                                final taxPercent = (controller
                                                            .selectedTaxPercent ??
                                                        0)
                                                    .toStringAsFixed(0);
                                                controller.updateTaxPaecentId(
                                                    '${selectedTaxId}_$taxPercent');

                                                debugPrint(
                                                    'tax_percent: "${controller.taxPercentValue}"');
                                                debugPrint(
                                                    "Selected Tax ID: $selectedTaxId");
                                                debugPrint(
                                                    "Selected Tax Percent: ${controller.selectedTaxPercent}");
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 8),

                              // VAT / TAX Amount (Read-only field)
                              Expanded(
                                flex: 1,
                                child: AddSalesFormfield(
                                  readOnly: true,
                                  label: "",
                                  labelText: "Amount",
                                  controller: TextEditingController(
                                    text:
                                        controller.taxAmount.toStringAsFixed(2),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        ///total sub
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  "Subtotal (with Tax):  ",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 7.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    controller.subtotalWithTax
                                        .toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  ///add & new , add
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ////add & new
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () async {
                              debugPrint("Add & New");

                              // debugPrint(
                              //     "selectedItem ======= $selectedItem =====|>");

                              debugPrint(
                                  "Selected Unit: ${controller.selectedUnit}");
                              debugPrint(
                                  "Selected Unit ID: ${controller.selectedUnitIdWithName}");

                              if (controller.qtyController.text.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    'Please entry the QTY',
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                setState(() {
                                  controller.isCash
                                      ? controller.addCashItem()
                                      : controller.addCreditItem();

                                  controller.isCash
                                      ? controller.addAmount2()
                                      : controller.addAmount();

                                  //controller.addAmount();
                                });

                                Navigator.pop(context);
                              }

                              Provider.of<SalesController>(context,
                                      listen: false)
                                  .notifyListeners();

                              controller.clearFields();

                              setState(() {
                                controller.seletedItemName = null;

                                Provider.of<AddItemProvider>(context,
                                        listen: false)
                                    .clearPurchaseStockDatasale();
                                controller.mrpController.clear();
                                controller.qtyController.clear();
                              });

                              Provider.of<SalesController>(context,
                                      listen: false)
                                  .notifyListeners();

                              // setState(() {
                              //   showSalesDialog(context, controller,  );
                              // });

                              // ✅ Clear stock info

                              // debugPrint(controller.items.length.toString());
                            },
                            child: SizedBox(
                              width: 90,
                              child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: colorScheme.primary,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 2),
                                    child: Center(
                                      child: Text(
                                        "Add & New",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      /////====> add item
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () async {
                              debugPrint("Add Item");

                              controller.isCash
                                  ? updateProvider.addCashItemSaleUpdate(
                                      controller.selcetedItemId,
                                      controller.mrpController.text,
                                      controller.selectedUnitIdWithName,
                                      controller.qtyController.text,
                                      controller.discountAmount.text,
                                      controller.discountPercentance.text,
                                      // controller.selectedTaxPercent.toString(),
                                      controller.taxPercentValue,
                                      controller.taxAmount.toString(),
                                      '',
                                    )
                                  : controller.addCreditItem();



                              controller.addAmount();

                              Navigator.pop(context);

                              controller.clearFields();

                              setState(() {
                                controller.seletedItemName = null;

                                Provider.of<AddItemProvider>(context,
                                        listen: false)
                                    .clearPurchaseStockDatasale();

                                controller.mrpController.clear();
                                controller.qtyController.clear();
                              });
                            }

                            // ✅ Clear stock info

                            // debugPrint(controller.items.length.toString());
                            ,
                            child: SizedBox(
                              width: 90,
                              child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: colorScheme.primary,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 2),
                                    child: Center(
                                      child: Text(
                                        "Add",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class ItemModel {
  final String? category;
  final String? subCategory;
  final String? itemName;
  final String? itemCode;
  final String? mrp;
  final String? quantity;
  final String? total;
  final String? price;
  final String? unit;
  ItemModel({
    this.category,
    this.subCategory,
    this.itemName,
    this.itemCode,
    this.mrp,
    this.quantity,
    this.total,
    this.price,
    this.unit,
  });
}

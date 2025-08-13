import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_close_button.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/payment_out/model/bill_person_list_model.dart';
import 'package:cbook_dt/feature/payment_out/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/purchase/controller/purchase_controller.dart';
import 'package:cbook_dt/feature/purchase/purchase_update_item.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/suppliers/suppliers_create.dart';
import 'package:cbook_dt/feature/unit/model/demo_unit_model.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'model/purchase_update_by_id.dart';
import 'model/purchase_update_model.dart';

class PurchaseUpdateProvider extends ChangeNotifier {
  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();
  TextEditingController billNumberController = TextEditingController();
  TextEditingController purchaseDateController = TextEditingController();
  TextEditingController customerController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController grossTotalController = TextEditingController();
  TextEditingController discountTotalController = TextEditingController();

  List<PurchaseUpdateModel> purchaseUpdateList = [];
  List<String> itemNames = [];
  List<String> unitNames = [];
  List<dynamic> purchaseDetailsList = [];
  List<DemoUnitModel> unitResponseModel = [];

  Map<int, String> itemMap = {};
  Map<int, String> unitMap = {};

  int? customerId;
  int? billPersonId; // ✅ Add billPersonId from API
  String? selectedBillPerson;
  int? purchaseId;
  int? itemId;
  String? selectedItem;
  String? selectedItemNameInvoice;
  String? selectedItemName;
  String? selectedUnitName;

  String selctedUnitId = "";

  bool isLoading = false;
  bool isCash = true;

  List<dynamic> _itemList = [];

  List<dynamic> get itemList => _itemList;

  void setItemList(List<dynamic> newList) {
    _itemList = newList;
    notifyListeners();
  }

  // ✅ Add helper methods for cash/credit logic
  bool get isCashTransaction => customerId == null || customerId == 0;

  // ✅ Get customer name by ID
  String? getCustomerNameById(
      int? customerId, CustomerProvider customerProvider) {
    if (customerId == null || customerId == 0) return null;

    final customer = customerProvider.findCustomerById(customerId);
    return customer?.name;
  }

  // ✅ Get bill person name by ID
  String? getBillPersonNameById(
      int? billPersonId, PaymentVoucherProvider paymentProvider) {
    if (billPersonId == null || billPersonId == 0) return null;

    try {
      final billPerson = paymentProvider.billPersons.firstWhere(
        (person) => person.id == billPersonId,
      );
      return billPerson.name;
    } catch (e) {
      debugPrint('Bill person not found with ID: $billPersonId');
      return null;
    }
  }

  String getSubTotal() {
    double subTotal = 0.00;
    for (var e in purchaseUpdateList) {
      subTotal += double.tryParse(e.subTotal) ?? 0.0;
    }
    return subTotal.toStringAsFixed(2);
  }

  /// Calculate Gross Total (Sub Total - Discount)
  String getGrossTotal() {
    double subTotal = double.tryParse(getSubTotal()) ?? 0.0;
    double discount = double.tryParse(discountTotalController.text) ?? 0.0;
    double grossTotal = subTotal - discount;
    return grossTotal.toStringAsFixed(2);
  }

  /// Update Gross Total whenever discount changes
  void updateGrossTotal() {
    grossTotalController.text = getGrossTotal(); // Update field
    notifyListeners();
  }

  void removeItemAt(int index) {
    if (index >= 0 && index < purchaseUpdateList.length) {
      purchaseUpdateList.removeAt(index);
      notifyListeners();
    }
  }

  selectedDropdownUnitId(String value) {
    unitResponseModel.forEach((e) {
      if (e.name == value) {
        selctedUnitId = e.id.toString();
      }
    });
    notifyListeners();
  }

  ///unit.
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
          unitMap[value['id']] =
              value['symbol']; // ✅ Use symbol instead of name
          unitNames.add(value['symbol']); // ✅ Use symbol in dropdown
        });

        notifyListeners();
      }
    }
  }

  ///items
  Future<void> fetchItems() async {
    const url = "https://commercebook.site/api/v1/items";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success']) {
        itemMap.clear();
        itemNames.clear();

        _itemList = data['data']; // ✅ Set itemList here

        /// ✅ Corrected `forEach` loop
        for (var item in data['data']) {
          itemMap[item['id']] = item['name'];
          itemNames.add(item['name']); // ✅ Add names to the dropdown list
        }

        notifyListeners();
      }
    }
  }

  PurchaseEditResponse purchaseEditResponse = PurchaseEditResponse();

  ///fetch purchase data by id
  Future<void> fetchPurchaseData(int id) async {
    isLoading = true;
    notifyListeners();

    await fetchItems();
    await fetchUnits();

    final url = "https://commercebook.site/api/v1/purchase/edit/$id";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      purchaseEditResponse = PurchaseEditResponse.fromJson(response.body);
      purchaseUpdateList.clear();
      purchaseEditResponse.data!.purchaseDetails!.forEach((e) {
        purchaseUpdateList.add(PurchaseUpdateModel(
          itemId: e.itemId.toString(),
          price: e.price.toString(),
          qty: e.qty.toString(),
          subTotal: e.subTotal.toString(),
          unitId: "${e.unitId.toString()}_${getUnitName(e.unitId.toString())}",
        ));
      });

      debugPrint(purchaseUpdateList.length.toString());

      if (data['success']) {
        final purchaseData = purchaseEditResponse.data!;

        purchaseDetailsList = purchaseData.purchaseDetails ?? [];
        billNumberController.text = purchaseData.billNumber ?? "";
        purchaseDateController.text = purchaseData.purchaseDate ?? "";
        grossTotalController.text = purchaseData.grossTotal?.toString() ?? "";
        customerController.text = purchaseData.customerId?.toString() ?? "";
        discountTotalController.text = purchaseData.discount?.toString() ?? "0";

        /// ✅ Set customerId and billPersonId from API response
        customerId =
            purchaseData.customerId; // This will be null for cash transactions
        billPersonId =
            purchaseData.billPersonId; // ✅ Get bill person ID from API
      }
    }

    isLoading = false;
    notifyListeners();
  }

  ///update selected item, in update
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

  ///update selected unit.
  void updateSelectedUnit(String name) {
    try {
      int unitId =
          unitMap.entries.firstWhere((entry) => entry.value == name).key;
      unitController.text = unitId.toString();
    } catch (e) {
      // Handle the case where no match is found
      unitController.clear();
      selectedUnitName = null;
    }
    selectedUnitName = name;
    notifyListeners();
  }

  ///add cash item
  addCashItemPurchaseUpdate(String selectedItemId, String price,
      String selectedUnitIdWithName, String qty) {
    purchaseUpdateList.add(PurchaseUpdateModel(
        itemId: selectedItemId,
        price: price,
        qty: qty,
        subTotal: (double.parse(price) * double.parse(qty)).toString(),
        unitId: selectedUnitIdWithName));

    notifyListeners();
  }

  void updatePurchaseDetail(int index) {
    // Convert input values to double (assuming qty and price are double)
    int? updatedPrice = int.tryParse(priceController.text);
    int? updatedQty = int.tryParse(qtyController.text);

    // Ensure values are not null before updating
    if (updatedPrice != null && updatedQty != null) {
      purchaseUpdateList[index].qty = updatedQty.toString();
      purchaseUpdateList[index].price = updatedPrice.toString();
      purchaseUpdateList[index].subTotal =
          (updatedQty * updatedPrice).toString();

      purchaseUpdateList[index].unitId =
          "${purchaseEditResponse.data!.purchaseDetails![index].unitId.toString()}_${getUnitName(purchaseEditResponse.data!.purchaseDetails![index].unitId.toString())}";

      // Updating response model
      purchaseEditResponse.data!.purchaseDetails![index].price = updatedPrice;
      purchaseEditResponse.data!.purchaseDetails![index].qty = updatedQty;
      purchaseEditResponse.data!.purchaseDetails![index].subTotal =
          (updatedQty * updatedPrice);

      debugPrint(
          "Updated Price: ${purchaseEditResponse.data!.purchaseDetails![index].price}");
      debugPrint(
          "Updated Qty: ${purchaseEditResponse.data!.purchaseDetails![index].qty}");

      // Notify UI of changes
      notifyListeners();
    } else {
      debugPrint(
          "Invalid input: Please enter valid numbers for price and quantity.");
    }
  }

  ///unit name
  String? getUnitName(String id) {
    for (var e in unitResponseModel) {
      if (e.id.toString() == id) {
        return e.name.toString();
      }
    }
    return null;
  }

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String get formattedTime => DateTimeHelper.formatTimeOfDay(_selectedTime);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  ///update purchase.
  Future<void> updatePurchase(context, int billPersonID) async {
    debugPrint(jsonEncode(purchaseUpdateList));

    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime _selectedDate = DateTime.now(); // or your selected date

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    debugPrint("purchase_date=$formattedDate");

    final url =
        "https://commercebook.site/api/v1/purchase/update?id=${purchaseEditResponse.data!.purchaseDetails![0].purchaseId}&user_id=${prefs.getInt("user_id")}&customer_id=${purchaseEditResponse.data!.customerId}&bill_number=${billNumberController.text}&purchase_date=$formattedDate&details_notes=notes&gross_total=${getSubTotal()}&discount=${discountTotalController.text}&payment_out=${isCash ? 1 : 0}&payment_amount=${getGrossTotal()}&bill_person_id=$billPersonID";

    debugPrint("url  ===> $url");

    // Prepare request body
    final requestBody = {"purchase_items": purchaseUpdateList};

    debugPrint('_selectedDate $_selectedDate');

    if (requestBody.isNotEmpty) {
      debugPrint(jsonEncode(requestBody));
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      debugPrint("API response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          debugPrint("Purchase successful: ${data["data"]}");

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeView()));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Purchase Update successful!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          debugPrint("Error: ${data["message"]}");
        }
      } else {
        // print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } else {}
  }

  ///add new item in item list
  void addItem(
      {required int id,
      required int price,
      required int qty,
      required int subTotal,
      required int unitId}) {
    purchaseEditResponse.data!.purchaseDetails!.add(PurchaseDetail(
      itemId: id,
      price: price,
      qty: qty,
      subTotal: subTotal,
      unitId: unitId,
    ));
    purchaseUpdateList.add((PurchaseUpdateModel(
        itemId: id.toString(),
        qty: qty.toString(),
        unitId: "${unitId.toString()}_${getUnitName(unitId.toString())}}",
        price: price.toString(),
        subTotal: subTotal.toString())));
    notifyListeners();
  }
}



///====> Purchase Update Screen UI
class PurchaseUpdateScreen extends StatefulWidget {
  final int purchaseId;

  const PurchaseUpdateScreen({super.key, required this.purchaseId});

  @override
  State<PurchaseUpdateScreen> createState() => _PurchaseUpdateScreenState();
}

class _PurchaseUpdateScreenState extends State<PurchaseUpdateScreen> {
  late PurchaseUpdateProvider provider;

  bool showNoteField = false;
  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController billController = TextEditingController();

  // ✅ Payment state variables
  bool isPaymentReceived = false;
  TextEditingController paymentController = TextEditingController();

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

      provider = Provider.of<PurchaseUpdateProvider>(context, listen: false);

      // Set today's date as default in the text controller
      provider.purchaseDateController.text =
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    });

    // ✅ Always fetch customers to populate dropdown if needed
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());
  }

  // ✅ Initialize payment based on transaction type
  void initializePayment(PurchaseUpdateProvider provider) {
    if (provider.isCashTransaction) {
      isPaymentReceived = true;
      paymentController.text = provider.getGrossTotal();
    } else {
      // For credit transactions, check if payment was previously received
      // You can initialize this based on your API data if needed
    }
  }

  // ✅ Handle payment checkbox changes
  void updatePaymentReceived(bool? value, PurchaseUpdateProvider provider) {
    setState(() {
      if (provider.isCashTransaction) {
        // For cash transactions, prevent unchecking
        if (value == true) {
          isPaymentReceived = true;
          paymentController.text = provider.getGrossTotal();
        }
        // Don't allow unchecking for cash transactions
      } else {
        // For credit transactions, allow normal toggling
        isPaymentReceived = value ?? false;
        if (isPaymentReceived) {
          paymentController.text = provider.getGrossTotal();
        } else {
          paymentController.clear();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseController>();
    final colorScheme = Theme.of(context).colorScheme;
    debugPrint("purchase id");
    debugPrint(widget.purchaseId.toString());

    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: true);

    return ChangeNotifierProvider(
      create: (_) =>
          PurchaseUpdateProvider()..fetchPurchaseData(widget.purchaseId),
      child: Scaffold(
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
            backgroundColor: colorScheme.primary,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            automaticallyImplyLeading: true,
            title: const Text(
              "Update Purchase",
              style: TextStyle(color: Colors.yellow, fontSize: 16),
            )),
        body: SingleChildScrollView(
          child: Consumer<PurchaseUpdateProvider>(
            builder: (context, provider, child) {
              // ✅ Initialize payment when provider is ready
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!provider.isLoading) {
                  initializePayment(provider);
                }
              });

              return provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // ✅ Modified Cash/Credit indicator section
                          Align(
                            alignment: Alignment.topLeft,
                            child: InkWell(
                              onTap: () {
                                controller.updateCash();
                              },
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: provider.isCashTransaction
                                      ? AppColors.primaryColor
                                      : Colors
                                          .orange, // Different color for credit
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        provider.isCashTransaction
                                            ? "Cash"
                                            : "Credit",
                                        style: GoogleFonts.lato(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
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
                          const SizedBox(height: 5),

                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
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
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                          ),
                                          vPad5,

                                          // ✅ Modified customer/supplier section
                                          Consumer2<PurchaseUpdateProvider,
                                              CustomerProvider>(
                                            builder: (context, provider,
                                                customerProvider, child) {
                                              // Show customer dropdown for credit transactions
                                              if (!provider.isCashTransaction) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Supplier",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    SizedBox(
                                                      height: 58,
                                                      width: 180,
                                                      child: Column(
                                                        children: [
                                                          AddSalesFormfieldTwo(
                                                            controller: controller
                                                                .codeController,
                                                            customerorSaleslist:
                                                                "Supplier list",
                                                            customerOrSupplierButtonLavel:
                                                                "Add new",
                                                            selectedCustomer: provider
                                                                        .customerId !=
                                                                    null
                                                                ? customerProvider
                                                                    .findCustomerById(
                                                                        provider
                                                                            .customerId!)
                                                                : null,
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const SuppliersCreate(),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                              // Show "Cash" for cash transactions
                                              else {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Transaction Type",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Container(
                                                      height: 40,
                                                      width: 180,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .green.shade50,
                                                        border: Border.all(
                                                            color: Colors.green
                                                                .shade300),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.money,
                                                              color: Colors
                                                                  .green
                                                                  .shade600,
                                                              size: 16),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            "Cash Transaction",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .green
                                                                  .shade700,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),

                                    // Right side - Bill number, date, bill person
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Bill number
                                          SizedBox(
                                            width: double.infinity,
                                            child: AddSalesFormfield(
                                              labelText: "Bill Number",
                                              controller:
                                                  provider.billNumberController,
                                              onChanged: (value) {
                                                provider.customerId;
                                              },
                                            ),
                                          ),

                                          // Date
                                          const Text(
                                            "Bill Date",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            width: double.infinity,
                                            child: InkWell(
                                              onTap: () =>
                                                  controller.pickDate(context),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        controller.formattedDate
                                                                .isNotEmpty
                                                            ? controller
                                                                .formattedDate
                                                            : "Select Date",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: Colors.blue,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Bill person
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Consumer2<
                                                PaymentVoucherProvider,
                                                PurchaseUpdateProvider>(
                                              builder: (context,
                                                  paymentProvider,
                                                  purchaseProvider,
                                                  child) {
                                                // ✅ Auto-select bill person from API if not already selected
                                                if (selectedBillPerson ==
                                                        null &&
                                                    purchaseProvider
                                                            .billPersonId !=
                                                        null &&
                                                    paymentProvider.billPersons
                                                        .isNotEmpty) {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    final billPersonName =
                                                        purchaseProvider
                                                            .getBillPersonNameById(
                                                                purchaseProvider
                                                                    .billPersonId,
                                                                paymentProvider);

                                                    if (billPersonName !=
                                                            null &&
                                                        mounted) {
                                                      setState(() {
                                                        selectedBillPerson =
                                                            billPersonName;
                                                        selectedBillPersonData =
                                                            paymentProvider
                                                                .billPersons
                                                                .firstWhere(
                                                          (person) =>
                                                              person.id ==
                                                              purchaseProvider
                                                                  .billPersonId,
                                                        );
                                                        selectedBillPersonId =
                                                            selectedBillPersonData!
                                                                .id;
                                                      });
                                                    }
                                                  });
                                                }

                                                return SizedBox(
                                                  height: 30,
                                                  width: double.infinity,
                                                  child: paymentProvider
                                                          .isLoading
                                                      ? const Center(
                                                          child:
                                                              CircularProgressIndicator())
                                                      : CustomDropdownTwo(
                                                          hint: '',
                                                          items: paymentProvider
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
                                                                  paymentProvider
                                                                      .billPersons
                                                                      .firstWhere(
                                                                (person) =>
                                                                    person
                                                                        .name ==
                                                                    value,
                                                              );
                                                              selectedBillPersonId =
                                                                  selectedBillPersonData!
                                                                      .id;
                                                            });
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

                                const SizedBox(height: 5),

                                // Item list
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.purchaseUpdateList.length,
                                  itemBuilder: (context, index) {
                                    final detail =
                                        provider.purchaseUpdateList[index];

                                    return GestureDetector(
                                      onTap: () async {
                                        // Call the dialog instead of navigating to a new page
                                        await showPurchaseItemUpdateDialog(
                                          context,
                                          index,
                                          detail,
                                          provider,
                                          provider.itemMap,
                                          provider.unitMap,
                                          provider.itemList,
                                        );
                                      },
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        elevation: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Text(
                                                "${index + 1}.  ",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Item: ${provider.itemMap[int.tryParse(detail.itemId) ?? 0] ?? "Unknown"}  (${provider.unitMap[int.tryParse(detail.unitId.split("_")[0]) ?? 0] ?? "Unknown"})",
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Qty: ${double.parse(detail.qty!).truncate()},",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Text(
                                                              "Price: ৳ ${detail.price}",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "Subtotal: ৳ ${detail.subTotal}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(width: 4),

                                              // Delete button
                                              CloseButtonWidget(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                        dialogContext) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Confirm Delete'),
                                                        content: const Text(
                                                          'Are you sure you want to delete this item?',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        dialogContext)
                                                                    .pop(),
                                                            child: const Text(
                                                                'Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              provider
                                                                  .removeItemAt(
                                                                      index);
                                                              Navigator.of(
                                                                      dialogContext)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              )
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
                          const SizedBox(height: 30),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                // Add Item button - Show when items list is empty or always show
                                InkWell(
                                  onTap: () {
                                    showSalesDialog(
                                        context, controller, provider);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Add Item & Service",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showSalesDialog(context,
                                                  controller, provider);
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
                                ),

                                const SizedBox(height: 5),

                                // Note field
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
                                              horizontal: 8.0),
                                          child: Container(
                                            height: 40,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.grey.shade400,
                                                  width: 1),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Center(
                                              child: TextField(
                                                controller: controller
                                                    .purchaseNoteController,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                                onChanged: (value) {
                                                  controller
                                                      .purchaseNoteController
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

                                const SizedBox(height: 2),

                                // Subtotal
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Subtotal",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 150,
                                          height: 30,
                                          child: AddSalesFormfield(
                                            labelText: "Subtotal",
                                            controller: TextEditingController(
                                                text: provider.getSubTotal()),
                                            readOnly: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Discount
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Discount",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        const SizedBox(width: 10),

                                        SizedBox(
                                          width: 70,
                                          height: 30,
                                          child: AddSalesFormfield(
                                            labelText: "%",
                                            controller: provider
                                                .discountTotalController,
                                            onChanged: (value) {
                                              provider.updateGrossTotal();
                                              // ✅ Update payment if checkbox is checked
                                              if (isPaymentReceived) {
                                                setState(() {
                                                  paymentController.text = provider.getGrossTotal();
                                                });
                                              }
                                            },
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        SizedBox(
                                          width: 70,
                                          height: 30,
                                          child: AddSalesFormfield(
                                            labelText: "tk",
                                            controller: provider
                                                .discountTotalController,
                                            onChanged: (value) {
                                              provider.updateGrossTotal();
                                              // ✅ Update payment if checkbox is checked
                                              if (isPaymentReceived) {
                                                setState(() {
                                                  paymentController.text = provider.getGrossTotal();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Gross total
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text("Gross Total",
                                            style:
                                                TextStyle(color: Colors.black)),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 150,
                                          height: 30,
                                          child:
                                              Consumer<PurchaseUpdateProvider>(
                                            builder:
                                                (context, provider, child) {
                                              return AddSalesFormfield(
                                                labelText: "Gross Total",
                                                controller:
                                                    TextEditingController(
                                                        text: provider
                                                            .getGrossTotal()),
                                                readOnly: true,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // ✅ Updated Payment Section
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 25,
                                              child: Checkbox(
                                                value: provider.isCashTransaction ? true : isPaymentReceived,
                                                onChanged: (bool? value) {
                                                  updatePaymentReceived(value, provider);
                                                },
                                              ),
                                            ),
                                            Text(
                                              provider.isCashTransaction ? "Cash Payment" : "Payment",
                                              style: TextStyle(
                                                color: provider.isCashTransaction ? Colors.green : Colors.black,
                                                fontSize: 12,
                                                fontWeight: provider.isCashTransaction ? FontWeight.w600 : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            const Text("Payment",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black)),
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              height: 30,
                                              width: 150,
                                              child: AddSalesFormfield(
                                                controller: paymentController,
                                                readOnly: provider.isCashTransaction || isPaymentReceived,
                                                keyboardType: TextInputType.number,
                                                onChanged: (value) {
                                                  // Allow manual input only for credit transactions when not auto-filled
                                                  if (!provider.isCashTransaction && !isPaymentReceived) {
                                                    setState(() {
                                                      paymentController.text = value;
                                                    });
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: provider.isCashTransaction 
                                                      ? Colors.green.shade50 
                                                      : (isPaymentReceived ? Colors.blue.shade50 : Colors.white),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: provider.isCashTransaction 
                                                          ? Colors.green.shade300 
                                                          : (isPaymentReceived ? Colors.blue.shade300 : Colors.grey.shade400),
                                                    ),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                  prefixText: "৳ ",
                                                  prefixStyle: const TextStyle(color: Colors.black87),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ✅ Payment Status Indicator
                                if (provider.isCashTransaction || isPaymentReceived)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: provider.isCashTransaction ? Colors.green.shade100 : Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: provider.isCashTransaction ? Colors.green.shade300 : Colors.blue.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              provider.isCashTransaction ? Icons.money : Icons.payment,
                                              size: 12,
                                              color: provider.isCashTransaction ? Colors.green.shade700 : Colors.blue.shade700,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              provider.isCashTransaction ? "Cash Transaction" : "Payment Confirmed",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: provider.isCashTransaction ? Colors.green.shade700 : Colors.blue.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Update Purchase button
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: double.maxFinite,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (selectedBillPersonData == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please select a bill person.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  int billPersonID = selectedBillPersonData!.id;
                                  await provider.updatePurchase(
                                      context, billPersonID);
                                  debugPrint(
                                      'bill number ${billController.text}');
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
                                  "Update Purchase",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20)
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  /// purchase update new item added.
  void showSalesDialog(
    BuildContext context,
    PurchaseController controller,
    PurchaseUpdateProvider provider,
  ) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);
    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    Navigator.of(context).pop();

    // Define local state variables
    String? selectedCategoryId;
    String? selectedSubCategoryId;
    String? selectedItemName;
    int? selectedItemId;
    List<String> unitIdsList = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          // ✅ ADD LISTENERS FOR QTY AND PRICE CHANGES
          void updateSubtotal() {
            controller.dialogtotalController();
            setState(() {});
          }

          // Add listeners to text controllers if not already added
          if (!controller.qtyController.hasListeners) {
            controller.qtyController.addListener(updateSubtotal);
          }
          if (!controller.mrpController.hasListeners) {
            controller.mrpController.addListener(updateSubtotal);
          }

          return Dialog(
              backgroundColor: Colors.grey.shade400,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xffe7edf4),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    // Header
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
                                "Add Item & service",
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              // ✅ REMOVE LISTENERS WHEN CLOSING DIALOG
                              controller.qtyController
                                  .removeListener(updateSubtotal);
                              controller.mrpController
                                  .removeListener(updateSubtotal);
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
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                          left: 6.0, right: 6.0, top: 4.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 3),
                          const SizedBox(height: 5),

                          // ✅ Item Dropdown
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Consumer<AddItemProvider>(
                              builder: (context, itemProvider, child) {
                                return SizedBox(
                                  height: 30,
                                  width: double.infinity,
                                  child: itemProvider.isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : CustomDropdownTwo(
                                          enableSearch: true,
                                          hint: 'Select Item',
                                          items: itemProvider.items
                                              .map((item) => item.name)
                                              .toList(),
                                          width: double.infinity,
                                          height: 30,
                                          selectedItem: selectedItemName,
                                          onChanged: (value) async {
                                            debugPrint(
                                                '=== Item Selected: $value ===');

                                            final selectedItem =
                                                itemProvider.items.firstWhere(
                                              (item) => item.name == value,
                                            );

                                            setState(() {
                                              selectedItemName = value;
                                              selectedItemId = selectedItem.id;
                                              unitIdsList.clear();

                                              controller.seletedItemName =
                                                  selectedItem.name;
                                              controller.selcetedItemId =
                                                  selectedItem.id.toString();

                                              controller.purchasePrice =
                                                  selectedItem.purchasePrice
                                                          is int
                                                      ? (selectedItem
                                                                  .purchasePrice
                                                              as int)
                                                          .toDouble()
                                                      : (selectedItem
                                                              .purchasePrice ??
                                                          0.0);

                                              controller.unitQty =
                                                  selectedItem.unitQty ?? 1;

                                              // ✅ Clear fields properly
                                              controller.qtyController.clear();
                                              controller.subtotalItemDiolog =
                                                  0.0;

                                              // Set initial price
                                              controller.mrpController.text =
                                                  controller.purchasePrice
                                                      .toStringAsFixed(2);
                                            });

                                            // Fetch stock quantity
                                            if (controller.selcetedItemId !=
                                                null) {
                                              fetchStockQuantity
                                                  .fetchStockQuantity(controller
                                                      .selcetedItemId!);
                                            }

                                            // Ensure unitProvider is loaded
                                            if (unitProvider.units.isEmpty) {
                                              await unitProvider.fetchUnits();
                                            }

                                            // Populate units
                                            setState(() {
                                              unitIdsList.clear();

                                              // Primary unit
                                              if (selectedItem.unitId != null) {
                                                final unit = unitProvider.units
                                                    .firstWhere(
                                                  (unit) =>
                                                      unit.id.toString() ==
                                                      selectedItem.unitId
                                                          .toString(),
                                                  orElse: () => Unit(
                                                    id: 0,
                                                    name: 'Unknown',
                                                    symbol: '',
                                                    status: 0,
                                                  ),
                                                );
                                                if (unit.id != 0) {
                                                  unitIdsList.add(unit.name);
                                                  controller.primaryUnitName =
                                                      unit.name;
                                                  controller.selectedUnit =
                                                      unit.name;
                                                  controller
                                                      .selectedUnitIdWithNameFunction(
                                                          "${unit.id}_${unit.name}");
                                                }
                                              }

                                              // Secondary unit
                                              if (selectedItem
                                                      .secondaryUnitId !=
                                                  null) {
                                                final secondaryUnit =
                                                    unitProvider.units
                                                        .firstWhere(
                                                  (unit) =>
                                                      unit.id.toString() ==
                                                      selectedItem
                                                          .secondaryUnitId
                                                          .toString(),
                                                  orElse: () => Unit(
                                                    id: 0,
                                                    name: 'Unknown',
                                                    symbol: '',
                                                    status: 0,
                                                  ),
                                                );
                                                if (secondaryUnit.id != 0) {
                                                  unitIdsList
                                                      .add(secondaryUnit.name);
                                                  controller.secondaryUnitName =
                                                      secondaryUnit.name;
                                                }
                                              }
                                            });

                                            debugPrint(
                                                "Units Available: $unitIdsList");
                                            debugPrint(
                                                "purchase price ===> ${controller.purchasePrice}");
                                          }),
                                );
                              },
                            ),
                          ),

                          // Qty and Unit row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Qty
                              Column(
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: AddSalesFormfield(
                                      labelText: "Qty",
                                      label: "",
                                      controller: controller.qtyController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),

                              // Unit Dropdown
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 150,
                                    child: CustomDropdownTwo(
                                      key: ValueKey(
                                          'unit_dropdown_${selectedItemId}_${unitIdsList.length}'),
                                      labelText: "Unit",
                                      hint: '',
                                      items: unitIdsList,
                                      width: 150,
                                      height: 30,
                                      selectedItem: unitIdsList.isNotEmpty &&
                                              controller.selectedUnit != null &&
                                              unitIdsList.contains(
                                                  controller.selectedUnit)
                                          ? controller.selectedUnit
                                          : (unitIdsList.isNotEmpty
                                              ? unitIdsList.first
                                              : null),
                                      onChanged: (selectedUnit) {
                                        debugPrint(
                                            "Selected Unit: $selectedUnit");

                                        controller.selectedUnit = selectedUnit;

                                        final selectedUnitObj =
                                            unitProvider.units.firstWhere(
                                          (unit) => unit.name == selectedUnit,
                                          orElse: () => Unit(
                                              id: 0,
                                              name: "Unknown",
                                              symbol: "",
                                              status: 0),
                                        );

                                        controller.selectedUnitIdWithNameFunction(
                                            "${selectedUnitObj.id}_${selectedUnitObj.symbol}");

                                        debugPrint(
                                            "🆔 Unit ID: ${selectedUnitObj.id}_${selectedUnitObj.symbol}");

                                        // Price update logic
                                        setState(() {
                                          if (selectedUnit ==
                                              controller.secondaryUnitName) {
                                            double newPrice =
                                                controller.purchasePrice /
                                                    controller.unitQty;
                                            controller.mrpController.text =
                                                newPrice.toStringAsFixed(2);
                                          } else if (selectedUnit ==
                                              controller.primaryUnitName) {
                                            controller.mrpController.text =
                                                controller.purchasePrice
                                                    .toStringAsFixed(2);
                                          }

                                          controller.dialogtotalController();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),

                          // Price
                          AddSalesFormfield(
                            labelText: "Price",
                            label: "",
                            controller: controller.mrpController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtotal display
                    Consumer<PurchaseController>(
                      builder: (context, purchaseController, _) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Subtotal: ",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(top: 7.0),
                              child: Text(
                                purchaseController.subtotalItemDiolog
                                    .toStringAsFixed(2),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Add & new button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () async {
                                debugPrint("🟢 Add & New Item button tapped");

                                if (controller.qtyController.text.isEmpty ||
                                    controller.mrpController.text.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text('Please enter the qty & price'),
                                    backgroundColor: Colors.red,
                                  ));
                                } else {
                                  // Add new PurchaseUpdateModel to provider list
                                  provider.purchaseUpdateList
                                      .add(PurchaseUpdateModel(
                                    itemId: controller.selcetedItemId ?? "0",
                                    qty: controller.qtyController.text,
                                    unitId: controller.selectedUnitIdWithName ??
                                        "0_unit",
                                    price: controller.mrpController.text,
                                    subTotal: controller.subtotalItemDiolog
                                        .toStringAsFixed(2),
                                  ));

                                  provider.notifyListeners();

                                  // ✅ COMPLETE FIELD CLEARING
                                  setState(() {
                                    selectedCategoryId = null;
                                    selectedSubCategoryId = null;
                                    selectedItemName = null;
                                    selectedItemId = null;
                                    unitIdsList.clear();
                                  });

                                  // ✅ Clear ALL controller fields
                                  controller.mrpController.clear();
                                  controller.qtyController.clear();
                                  controller.subtotalItemDiolog = 0.0;
                                  controller.selectedUnit = null;
                                  controller.selectedUnitIdWithName = "";
                                  controller.seletedItemName = null;
                                  controller.selcetedItemId = "";
                                  controller.primaryUnitName = "";
                                  controller.secondaryUnitName = "";
                                  controller.purchasePrice = 0.0;
                                  controller.unitQty = 1;

                                  // Clear providers
                                  Provider.of<ItemCategoryProvider>(context,
                                          listen: false)
                                      .subCategories = [];
                                  Provider.of<AddItemProvider>(context,
                                          listen: false)
                                      .clearPurchaseStockData();

                                  // Re-add listeners for next item
                                  controller.qtyController
                                      .addListener(updateSubtotal);
                                  controller.mrpController
                                      .addListener(updateSubtotal);
                                }
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
                                        "Add & new",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Add item button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () async {
                                debugPrint("🟢 Add Item button tapped");

                                if (controller.qtyController.text.isEmpty ||
                                    controller.mrpController.text.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text('Please enter the qty & price'),
                                    backgroundColor: Colors.red,
                                  ));
                                } else {
                                  // ✅ REMOVE LISTENERS BEFORE CLOSING
                                  controller.qtyController
                                      .removeListener(updateSubtotal);
                                  controller.mrpController
                                      .removeListener(updateSubtotal);

                                  // Add new PurchaseUpdateModel to provider list
                                  provider.purchaseUpdateList
                                      .add(PurchaseUpdateModel(
                                    itemId: controller.selcetedItemId ?? "0",
                                    qty: controller.qtyController.text,
                                    unitId: controller.selectedUnitIdWithName ??
                                        "0_unit",
                                    price: controller.mrpController.text,
                                    subTotal: controller.subtotalItemDiolog
                                        .toStringAsFixed(2),
                                  ));

                                  provider.notifyListeners();

                                  // ✅ COMPLETE FIELD CLEARING
                                  setState(() {
                                    selectedCategoryId = null;
                                    selectedSubCategoryId = null;
                                    selectedItemName = null;
                                    selectedItemId = null;
                                    unitIdsList.clear();
                                  });

                                  // ✅ Clear ALL controller fields
                                  controller.mrpController.clear();
                                  controller.qtyController.clear();
                                  controller.subtotalItemDiolog = 0.0;
                                  controller.selectedUnit = null;
                                  controller.selectedUnitIdWithName = "";
                                  controller.seletedItemName = null;
                                  controller.selcetedItemId = "";
                                  controller.primaryUnitName = "";
                                  controller.secondaryUnitName = "";
                                  controller.purchasePrice = 0.0;
                                  controller.unitQty = 1;

                                  // Clear providers
                                  Provider.of<ItemCategoryProvider>(context,
                                          listen: false)
                                      .subCategories = [];
                                  Provider.of<AddItemProvider>(context,
                                          listen: false)
                                      .clearPurchaseStockData();

                                  Navigator.pop(context);
                                }
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
                                          "Add",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ));
        });
      },
    );
  }

  // Add this function to your PurchaseUpdateScreen class
  Future<void> showPurchaseItemUpdateDialog(
    BuildContext context,
    int index,
    PurchaseUpdateModel itemDetail,
    PurchaseUpdateProvider provider,
    Map<int, String> itemMap,
    Map<int, String> unitMap,
    List<dynamic> itemList,
  ) async {
    final priceController =
        TextEditingController(text: itemDetail.price.toString());
    final qtyController =
        TextEditingController(text: itemDetail.qty.toString());
    final subTotalController =
        TextEditingController(text: itemDetail.subTotal.toString());

    // Initialize selected values
    String? selectedItemName =
        itemMap[int.tryParse(itemDetail.itemId) ?? 0] ?? 'No Items Available';
    String? selectedUnitName =
        unitMap[int.tryParse(itemDetail.unitId.split("_")[0]) ?? 0] ??
            'No Units Available';
    int? selectedItemId = int.tryParse(itemDetail.itemId);
    int? selectedUnitId = int.tryParse(itemDetail.unitId.split("_")[0]);

    // Function to get filtered units for selected item
    List<String> getFilteredUnitsForSelectedItem() {
      if (selectedItemId == null) return [];

      final item = itemList.firstWhere(
        (element) => element['id'] == selectedItemId,
        orElse: () => null,
      );

      if (item == null) return [];

      final primaryUnitId = item['unit_id'];
      final secondaryUnitId = item['secondary_unit_id'];

      final unitNames = <String>[];

      // Use unitMap to convert unitId → name (e.g., 5 → "Pc")
      if (primaryUnitId != null && unitMap.containsKey(primaryUnitId)) {
        unitNames.add(unitMap[primaryUnitId]!);
      }

      if (secondaryUnitId != null && unitMap.containsKey(secondaryUnitId)) {
        unitNames.add(unitMap[secondaryUnitId]!);
      }

      return unitNames;
    }

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          void calculateSubtotal() {
            final price = double.tryParse(priceController.text) ?? 0.0;
            final qty = double.tryParse(qtyController.text) ?? 0.0;
            final subTotal = price * qty;
            subTotalController.text = subTotal.toStringAsFixed(2);
          }

          // Add listeners for automatic calculation
          priceController.addListener(calculateSubtotal);
          qtyController.addListener(calculateSubtotal);

          void updateItem() {
            final priceText = priceController.text.trim();
            final qtyText = qtyController.text.trim();
            final subTotalText = subTotalController.text.trim();

            debugPrint("Updating item:");
            debugPrint("Selected Item: $selectedItemName");
            debugPrint("Selected Unit: $selectedUnitName");
            debugPrint("Qty: $qtyText");
            debugPrint("Price: $priceText");
            debugPrint("Subtotal: $subTotalText");

            final parsedPrice = double.tryParse(priceText);
            final parsedQty = double.tryParse(qtyText);
            final parsedSubTotal = double.tryParse(subTotalText);

            if (parsedPrice == null ||
                parsedQty == null ||
                parsedSubTotal == null) {
              debugPrint("Error: One or more fields contain invalid numbers.");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Please enter valid numeric values")),
              );
              return;
            }

            // Reverse lookup for itemId
            final updatedItemId = itemMap.entries
                .firstWhere((entry) => entry.value == selectedItemName,
                    orElse: () => const MapEntry(0, ''))
                .key;

            // Reverse lookup for unitId
            final updatedUnitId = unitMap.entries
                .firstWhere((entry) => entry.value == selectedUnitName,
                    orElse: () => const MapEntry(0, ''))
                .key;

            if (updatedItemId == 0 || updatedUnitId == 0) {
              debugPrint("Invalid item or unit selection");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invalid item or unit selection")),
              );
              return;
            }

            // Update provider list
            provider.purchaseUpdateList[index] = PurchaseUpdateModel(
              itemId: updatedItemId.toString(),
              price: priceText,
              qty: qtyText,
              subTotal: subTotalText,
              unitId: "${updatedUnitId}_$selectedUnitName",
            );

            // Also update response model
            final detail =
                provider.purchaseEditResponse.data?.purchaseDetails?[index];
            if (detail != null) {
              detail.itemId = updatedItemId;
              detail.unitId = updatedUnitId;
              detail.price = parsedPrice.toInt();
              detail.qty = parsedQty.toInt();
              detail.subTotal = parsedSubTotal;
            }

            provider.notifyListeners();
            Navigator.pop(context);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$selectedItemName updated successfully"),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          return AlertDialog(
            title: const Text(
              "Edit Purchase Item",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name (Read-only)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Item Name",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 40,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            selectedItemName ?? "Unknown Item",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Unit Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Unit",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 40,
                          child: CustomDropdownTwo(
                            labelText: 'Unit',
                            items: getFilteredUnitsForSelectedItem().isNotEmpty
                                ? getFilteredUnitsForSelectedItem()
                                : ['No Units Available'],
                            hint: selectedUnitName ?? 'Select Unit',
                            width: double.infinity,
                            selectedItem: selectedUnitName,
                            height: 40,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedUnitName = newValue;

                                // Reverse lookup the unit ID from name
                                selectedUnitId = unitMap.entries
                                    .firstWhere(
                                      (entry) => entry.value == newValue,
                                      orElse: () => const MapEntry(-1, ''),
                                    )
                                    .key;

                                debugPrint(
                                    "Selected Unit Name: $selectedUnitName");
                                debugPrint("Selected Unit ID: $selectedUnitId");
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Price and Quantity Row
                    Row(
                      children: [
                        // Price field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Price",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                height: 40,
                                child: AddSalesFormfield(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    calculateSubtotal();
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Quantity field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Quantity",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                height: 40,
                                child: AddSalesFormfield(
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    calculateSubtotal();
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Subtotal (Read-only)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Subtotal",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 40,
                          child: AddSalesFormfield(
                            controller: subTotalController,
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Remove listeners before closing
                  priceController.removeListener(calculateSubtotal);
                  qtyController.removeListener(calculateSubtotal);
                  Navigator.pop(context);
                },
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate input
                  final updatedPrice = double.tryParse(priceController.text);
                  final updatedQty = double.tryParse(qtyController.text);

                  if (updatedPrice == null || updatedPrice <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid price"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (updatedQty == null || updatedQty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid quantity"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Remove listeners before updating
                  priceController.removeListener(calculateSubtotal);
                  qtyController.removeListener(calculateSubtotal);

                  updateItem();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Update Item"),
              ),
            ],
          );
        });
      },
    );
  }
}

///====> Purchase Update Screen UI
// class PurchaseUpdateScreen extends StatefulWidget {
//   final int purchaseId;

//   const PurchaseUpdateScreen({super.key, required this.purchaseId});

//   @override
//   State<PurchaseUpdateScreen> createState() => _PurchaseUpdateScreenState();
// }

// class _PurchaseUpdateScreenState extends State<PurchaseUpdateScreen> {
//   late PurchaseUpdateProvider provider;

//   bool showNoteField = false;
//   String? selectedBillPerson;
//   int? selectedBillPersonId;
//   BillPersonModel? selectedBillPersonData;
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   TextEditingController billController = TextEditingController();

//   void _onCancel() {
//     Navigator.pop(context);
//   }

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ItemCategoryProvider>(context, listen: false)
//           .fetchCategories();
//       Provider.of<AddItemProvider>(context, listen: false).fetchItems();

//       provider = Provider.of<PurchaseUpdateProvider>(context, listen: false);

//       // Set today's date as default in the text controller
//       provider.purchaseDateController.text =
//           "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
//     });

//     // ✅ Always fetch customers to populate dropdown if needed
//     Future.microtask(() =>
//         Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

//     Future.microtask(() =>
//         Provider.of<PaymentVoucherProvider>(context, listen: false)
//             .fetchBillPersons());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.watch<PurchaseController>();
//     final colorScheme = Theme.of(context).colorScheme;
//     debugPrint("purchase id");
//     debugPrint(widget.purchaseId.toString());

//     final categoryProvider =
//         Provider.of<ItemCategoryProvider>(context, listen: true);

//     return ChangeNotifierProvider(
//       create: (_) =>
//           PurchaseUpdateProvider()..fetchPurchaseData(widget.purchaseId),
//       child: Scaffold(
//         backgroundColor: AppColors.sfWhite,
//         appBar: AppBar(
//             backgroundColor: colorScheme.primary,
//             centerTitle: true,
//             iconTheme: const IconThemeData(color: Colors.white),
//             automaticallyImplyLeading: true,
//             title: const Text(
//               "Update Purchase",
//               style: TextStyle(color: Colors.yellow, fontSize: 16),
//             )),
//         body: SingleChildScrollView(
//           child: Consumer<PurchaseUpdateProvider>(
//             builder: (context, provider, child) {
//               return provider.isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           // ✅ Modified Cash/Credit indicator section
//                           Align(
//                             alignment: Alignment.topLeft,
//                             child: InkWell(
//                               onTap: () {
//                                 controller.updateCash();
//                               },
//                               child: DecoratedBox(
//                                 decoration: BoxDecoration(
//                                   color: provider.isCashTransaction
//                                       ? AppColors.primaryColor
//                                       : Colors
//                                           .orange, // Different color for credit
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 4),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         provider.isCashTransaction
//                                             ? "Cash"
//                                             : "Credit",
//                                         style: GoogleFonts.lato(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       const Icon(
//                                         Icons.arrow_forward_ios,
//                                         color: Colors.white,
//                                         size: 12,
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 5),

//                           Align(
//                             alignment: Alignment.bottomRight,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const Text(
//                                             "Bill To",
//                                             style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 12),
//                                           ),
//                                           vPad5,

//                                           // ✅ Modified customer/supplier section
//                                           Consumer2<PurchaseUpdateProvider,
//                                               CustomerProvider>(
//                                             builder: (context, provider,
//                                                 customerProvider, child) {
//                                               // Show customer dropdown for credit transactions
//                                               if (!provider.isCashTransaction) {
//                                                 return Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     const Text(
//                                                       "Supplier",
//                                                       style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 12),
//                                                     ),
//                                                     const SizedBox(height: 5),
//                                                     SizedBox(
//                                                       height: 58,
//                                                       width: 180,
//                                                       child: Column(
//                                                         children: [
//                                                           AddSalesFormfieldTwo(
//                                                             controller: controller
//                                                                 .codeController,
//                                                             customerorSaleslist:
//                                                                 "Supplier list",
//                                                             customerOrSupplierButtonLavel:
//                                                                 "Add new",
//                                                             selectedCustomer: provider
//                                                                         .customerId !=
//                                                                     null
//                                                                 ? customerProvider
//                                                                     .findCustomerById(
//                                                                         provider
//                                                                             .customerId!)
//                                                                 : null,
//                                                             onTap: () {
//                                                               Navigator.push(
//                                                                 context,
//                                                                 MaterialPageRoute(
//                                                                   builder:
//                                                                       (context) =>
//                                                                           const SuppliersCreate(),
//                                                                 ),
//                                                               );
//                                                             },
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 );
//                                               }
//                                               // Show "Cash" for cash transactions
//                                               else {
//                                                 return Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     const Text(
//                                                       "Transaction Type",
//                                                       style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 12),
//                                                     ),
//                                                     const SizedBox(height: 5),
//                                                     Container(
//                                                       height: 40,
//                                                       width: 180,
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           horizontal: 12,
//                                                           vertical: 8),
//                                                       decoration: BoxDecoration(
//                                                         color: Colors
//                                                             .green.shade50,
//                                                         border: Border.all(
//                                                             color: Colors.green
//                                                                 .shade300),
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(4),
//                                                       ),
//                                                       child: Row(
//                                                         children: [
//                                                           Icon(Icons.money,
//                                                               color: Colors
//                                                                   .green
//                                                                   .shade600,
//                                                               size: 16),
//                                                           const SizedBox(
//                                                               width: 8),
//                                                           Text(
//                                                             "Cash Transaction",
//                                                             style: TextStyle(
//                                                               fontSize: 12,
//                                                               color: Colors
//                                                                   .green
//                                                                   .shade700,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 );
//                                               }
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const SizedBox(width: 5),

//                                     // Right side - Bill number, date, bill person
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           // Bill number
//                                           SizedBox(
//                                             width: double.infinity,
//                                             child: AddSalesFormfield(
//                                               labelText: "Bill Number",
//                                               controller:
//                                                   provider.billNumberController,
//                                               onChanged: (value) {
//                                                 provider.customerId;
//                                               },
//                                             ),
//                                           ),

//                                           // Date
//                                           const Text(
//                                             "Bill Date",
//                                             style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 12),
//                                           ),
//                                           SizedBox(
//                                             height: 30,
//                                             width: double.infinity,
//                                             child: InkWell(
//                                               onTap: () =>
//                                                   controller.pickDate(context),
//                                               child: Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 8,
//                                                         vertical: 6),
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                       color:
//                                                           Colors.grey.shade400,
//                                                       width: 1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(4),
//                                                 ),
//                                                 child: Row(
//                                                   children: [
//                                                     Expanded(
//                                                       child: Text(
//                                                         controller.formattedDate
//                                                                 .isNotEmpty
//                                                             ? controller
//                                                                 .formattedDate
//                                                             : "Select Date",
//                                                         style: const TextStyle(
//                                                           fontSize: 12,
//                                                           color: Colors.black,
//                                                           fontWeight:
//                                                               FontWeight.w400,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     const Icon(
//                                                       Icons.calendar_today,
//                                                       size: 14,
//                                                       color: Colors.blue,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ),

//                                           // Bill person
//                                           Padding(
//                                             padding:
//                                                 const EdgeInsets.only(top: 8.0),
//                                             child: Consumer2<
//                                                 PaymentVoucherProvider,
//                                                 PurchaseUpdateProvider>(
//                                               builder: (context,
//                                                   paymentProvider,
//                                                   purchaseProvider,
//                                                   child) {
//                                                 // ✅ Auto-select bill person from API if not already selected
//                                                 if (selectedBillPerson ==
//                                                         null &&
//                                                     purchaseProvider
//                                                             .billPersonId !=
//                                                         null &&
//                                                     paymentProvider.billPersons
//                                                         .isNotEmpty) {
//                                                   WidgetsBinding.instance
//                                                       .addPostFrameCallback(
//                                                           (_) {
//                                                     final billPersonName =
//                                                         purchaseProvider
//                                                             .getBillPersonNameById(
//                                                                 purchaseProvider
//                                                                     .billPersonId,
//                                                                 paymentProvider);

//                                                     if (billPersonName !=
//                                                             null &&
//                                                         mounted) {
//                                                       setState(() {
//                                                         selectedBillPerson =
//                                                             billPersonName;
//                                                         selectedBillPersonData =
//                                                             paymentProvider
//                                                                 .billPersons
//                                                                 .firstWhere(
//                                                           (person) =>
//                                                               person.id ==
//                                                               purchaseProvider
//                                                                   .billPersonId,
//                                                         );
//                                                         selectedBillPersonId =
//                                                             selectedBillPersonData!
//                                                                 .id;
//                                                       });
//                                                     }
//                                                   });
//                                                 }

//                                                 return SizedBox(
//                                                   height: 30,
//                                                   width: double.infinity,
//                                                   child: paymentProvider
//                                                           .isLoading
//                                                       ? const Center(
//                                                           child:
//                                                               CircularProgressIndicator())
//                                                       : CustomDropdownTwo(
//                                                           hint: '',
//                                                           items: paymentProvider
//                                                               .billPersonNames,
//                                                           width:
//                                                               double.infinity,
//                                                           height: 30,
//                                                           labelText:
//                                                               'Bill Person',
//                                                           selectedItem:
//                                                               selectedBillPerson,
//                                                           onChanged: (value) {
//                                                             debugPrint(
//                                                                 '=== Bill Person Selected: $value ===');
//                                                             setState(() {
//                                                               selectedBillPerson =
//                                                                   value;
//                                                               selectedBillPersonData =
//                                                                   paymentProvider
//                                                                       .billPersons
//                                                                       .firstWhere(
//                                                                 (person) =>
//                                                                     person
//                                                                         .name ==
//                                                                     value,
//                                                               );
//                                                               selectedBillPersonId =
//                                                                   selectedBillPersonData!
//                                                                       .id;
//                                                             });
//                                                           }),
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 5),

//                                 // Item list
//                                 ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: provider.purchaseUpdateList.length,
//                                   itemBuilder: (context, index) {
//                                     final detail =
//                                         provider.purchaseUpdateList[index];

//                                     return GestureDetector(
//                                       onTap: () async {
//                                         // Call the dialog instead of navigating to a new page
//                                         await showPurchaseItemUpdateDialog(
//                                           context,
//                                           index,
//                                           detail,
//                                           provider,
//                                           provider.itemMap,
//                                           provider.unitMap,
//                                           provider.itemList,
//                                         );
//                                       },
//                                       child: Card(
//                                         margin: const EdgeInsets.symmetric(
//                                             vertical: 8),
//                                         elevation: 3,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(12),
//                                           child: Row(
//                                             children: [
//                                               Text(
//                                                 "${index + 1}.  ",
//                                                 style: const TextStyle(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       "Item: ${provider.itemMap[int.tryParse(detail.itemId) ?? 0] ?? "Unknown"}  (${provider.unitMap[int.tryParse(detail.unitId.split("_")[0]) ?? 0] ?? "Unknown"})",
//                                                       style: const TextStyle(
//                                                         color: Colors.black,
//                                                         fontSize: 13,
//                                                       ),
//                                                     ),
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         Row(
//                                                           children: [
//                                                             Text(
//                                                               "Qty: ${double.parse(detail.qty!).truncate()},",
//                                                               style: const TextStyle(
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontSize: 12),
//                                                             ),
//                                                             const SizedBox(
//                                                                 width: 5),
//                                                             Text(
//                                                               "Price: ৳ ${detail.price}",
//                                                               style: const TextStyle(
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontSize: 12),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "Subtotal: ৳ ${detail.subTotal}",
//                                                 style: const TextStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 12,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               ),
//                                               const SizedBox(width: 4),

//                                               // Delete button
//                                               CloseButtonWidget(
//                                                 onPressed: () {
//                                                   showDialog(
//                                                     context: context,
//                                                     builder: (BuildContext
//                                                         dialogContext) {
//                                                       return AlertDialog(
//                                                         title: const Text(
//                                                             'Confirm Delete'),
//                                                         content: const Text(
//                                                           'Are you sure you want to delete this item?',
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.black),
//                                                         ),
//                                                         actions: [
//                                                           TextButton(
//                                                             onPressed: () =>
//                                                                 Navigator.of(
//                                                                         dialogContext)
//                                                                     .pop(),
//                                                             child: const Text(
//                                                                 'Cancel'),
//                                                           ),
//                                                           TextButton(
//                                                             onPressed: () {
//                                                               provider
//                                                                   .removeItemAt(
//                                                                       index);
//                                                               Navigator.of(
//                                                                       dialogContext)
//                                                                   .pop();
//                                                             },
//                                                             child: const Text(
//                                                               'Delete',
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .red),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       );
//                                                     },
//                                                   );
//                                                 },
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 )
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 30),

//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: Column(
//                               children: [
//                                 // Add Item button - Show when items list is empty or always show
//                                 InkWell(
//                                   onTap: () {
//                                     showSalesDialog(
//                                         context, controller, provider);
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: colorScheme.primary,
//                                       borderRadius: BorderRadius.circular(5),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.2),
//                                           blurRadius: 5,
//                                           offset: const Offset(0, 3),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(4.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           const Text(
//                                             "Add Item & Service",
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 14),
//                                           ),
//                                           InkWell(
//                                             onTap: () {
//                                               showSalesDialog(context,
//                                                   controller, provider);
//                                             },
//                                             child: const Icon(
//                                               Icons.add,
//                                               color: Colors.white,
//                                               size: 18,
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),

//                                 const SizedBox(height: 5),

//                                 // Note field
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(
//                                         Icons.note_add_outlined,
//                                         color: Colors.blueAccent,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           showNoteField = !showNoteField;
//                                         });
//                                       },
//                                     ),
//                                     if (showNoteField)
//                                       Expanded(
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 8.0),
//                                           child: Container(
//                                             height: 40,
//                                             width: double.infinity,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               border: Border.all(
//                                                   color: Colors.grey.shade400,
//                                                   width: 1),
//                                             ),
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8),
//                                             child: Center(
//                                               child: TextField(
//                                                 controller: controller
//                                                     .purchaseNoteController,
//                                                 style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12,
//                                                 ),
//                                                 onChanged: (value) {
//                                                   controller
//                                                       .purchaseNoteController
//                                                       .text = value;
//                                                 },
//                                                 maxLines: 2,
//                                                 cursorHeight: 12,
//                                                 decoration: InputDecoration(
//                                                   isDense: true,
//                                                   border: InputBorder.none,
//                                                   hintText: "Note",
//                                                   hintStyle: TextStyle(
//                                                     color: Colors.grey.shade400,
//                                                     fontSize: 10,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 2),

//                                 // Subtotal
//                                 Align(
//                                   alignment: Alignment.centerRight,
//                                   child: SizedBox(
//                                     width: 250,
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         const Text(
//                                           "Subtotal",
//                                           style: TextStyle(color: Colors.black),
//                                         ),
//                                         const SizedBox(width: 10),
//                                         SizedBox(
//                                           width: 150,
//                                           height: 30,
//                                           child: AddSalesFormfield(
//                                             labelText: "Subtotal",
//                                             controller: TextEditingController(
//                                                 text: provider.getSubTotal()),
//                                             readOnly: true,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),

//                                 const SizedBox(height: 8),

//                                 // Discount
//                                 Align(
//                                   alignment: Alignment.centerRight,
//                                   child: SizedBox(
//                                     width: 250,
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         const Text(
//                                           "Discount",
//                                           style: TextStyle(color: Colors.black),
//                                         ),
//                                         const SizedBox(width: 10),

//                                         SizedBox(
//                                           width: 70,
//                                           height: 30,
//                                           child: AddSalesFormfield(
//                                             labelText: "%",
//                                             controller: provider
//                                                 .discountTotalController,
//                                             onChanged: (value) {
//                                               provider.updateGrossTotal();
//                                             },
//                                           ),
//                                         ),

//                                          const SizedBox(width: 10),


//                                         SizedBox(
//                                           width: 70,
//                                           height: 30,
//                                           child: AddSalesFormfield(
//                                             labelText: "tk",
//                                             controller: provider
//                                                 .discountTotalController,
//                                             onChanged: (value) {
//                                               provider.updateGrossTotal();
//                                             },
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),

//                                 const SizedBox(height: 8),

//                                 // Gross total
//                                 Align(
//                                   alignment: Alignment.centerRight,
//                                   child: SizedBox(
//                                     width: 250,
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         const Text("Gross Total",
//                                             style:
//                                                 TextStyle(color: Colors.black)),
//                                         const SizedBox(width: 10),
//                                         SizedBox(
//                                           width: 150,
//                                           height: 30,
//                                           child:
//                                               Consumer<PurchaseUpdateProvider>(
//                                             builder:
//                                                 (context, provider, child) {
//                                               return AddSalesFormfield(
//                                                 labelText: "Gross Total",
//                                                 controller:
//                                                     TextEditingController(
//                                                         text: provider
//                                                             .getGrossTotal()),
//                                                 readOnly: true,
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),

//                                 controller.isReciptType && controller.isCash
//                                       ? Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 SizedBox(
//                                                     height: 25,
//                                                     child: Checkbox(
//                                                       value:
//                                                           controller.isReceived,
//                                                       onChanged: (bool? value) {
//                                                         if (controller.isCash) {
//                                                           // Allow checking, but prevent unchecking
//                                                           if (value == true) {
//                                                             controller
//                                                                     .isReceived =
//                                                                 true;
//                                                             controller
//                                                                 .notifyListeners();
//                                                           }
//                                                         } else {
//                                                           // Allow normal toggling when not cash
//                                                           controller
//                                                                   .isReceived =
//                                                               value ?? false;
//                                                           controller
//                                                               .notifyListeners();
//                                                         }
//                                                       },
//                                                     )),
//                                                 const Text("",
//                                                     style: TextStyle(
//                                                         color: Colors.green,
//                                                         fontSize: 12)),
//                                               ],
//                                             ),
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.end,
//                                               children: [
//                                                 const Text("Payment",
//                                                     style: TextStyle(
//                                                         fontSize: 12,
//                                                         color: Colors.black)),
//                                                 const SizedBox(width: 5),
//                                                 SizedBox(
//                                                   height: 30,
//                                                   width: 150,
//                                                   child: SizedBox(
//                                                     height: 25,
//                                                     width: 150,
//                                                     child: AddSalesFormfield(
//                                                       readOnly: true,
//                                                       onChanged: (value) {
//                                                         Provider.of(context)<
//                                                             PurchaseController>();
//                                                       },
//                                                       controller:
//                                                           TextEditingController(
//                                                               text: controller
//                                                                   .totalAmount),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             )
//                                           ],
//                                         )
//                                       : const SizedBox.shrink(),

                               
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 20),

//                           // Update Purchase button
//                           Align(
//                             alignment: Alignment.bottomCenter,
//                             child: SizedBox(
//                               width: double.maxFinite,
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   if (selectedBillPersonData == null) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                             'Please select a bill person.'),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                     return;
//                                   }

//                                   int billPersonID = selectedBillPersonData!.id;
//                                   await provider.updatePurchase(
//                                       context, billPersonID);
//                                   debugPrint(
//                                       'bill number ${billController.text}');
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blue,
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 12, horizontal: 20),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   "Update Purchase",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20)
//                         ],
//                       ),
//                     );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   /// purchase update new item added.

//   void showSalesDialog(
//     BuildContext context,
//     PurchaseController controller,
//     PurchaseUpdateProvider provider,
//   ) async {
//     final ColorScheme colorScheme = Theme.of(context).colorScheme;
//     final unitProvider = Provider.of<UnitProvider>(context, listen: false);
//     final fetchStockQuantity =
//         Provider.of<AddItemProvider>(context, listen: false);

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );

//     Navigator.of(context).pop();

//     // Define local state variables
//     String? selectedCategoryId;
//     String? selectedSubCategoryId;
//     String? selectedItemName;
//     int? selectedItemId;
//     List<String> unitIdsList = [];

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setState) {
//           // ✅ ADD LISTENERS FOR QTY AND PRICE CHANGES
//           void updateSubtotal() {
//             controller.dialogtotalController();
//             setState(() {});
//           }

//           // Add listeners to text controllers if not already added
//           if (!controller.qtyController.hasListeners) {
//             controller.qtyController.addListener(updateSubtotal);
//           }
//           if (!controller.mrpController.hasListeners) {
//             controller.mrpController.addListener(updateSubtotal);
//           }

//           return Dialog(
//               backgroundColor: Colors.grey.shade400,
//               child: Container(
//                 height: 300,
//                 decoration: BoxDecoration(
//                   color: const Color(0xffe7edf4),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Column(
//                   children: [
//                     // Header
//                     Container(
//                       height: 30,
//                       color: const Color(0xff278d46),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const SizedBox(width: 30),
//                           const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(width: 5),
//                               Text(
//                                 "Add Item & service",
//                                 style: TextStyle(
//                                     color: Colors.yellow,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                           InkWell(
//                             onTap: () {
//                               // ✅ REMOVE LISTENERS WHEN CLOSING DIALOG
//                               controller.qtyController
//                                   .removeListener(updateSubtotal);
//                               controller.mrpController
//                                   .removeListener(updateSubtotal);
//                               Navigator.pop(context);
//                             },
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 4.0),
//                               child: CircleAvatar(
//                                   radius: 10,
//                                   backgroundColor: Colors.grey.shade100,
//                                   child: const Icon(
//                                     Icons.close,
//                                     size: 18,
//                                     color: Colors.green,
//                                   )),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 6.0, right: 6.0, top: 4.0),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 3),
//                           const SizedBox(height: 5),

//                           // ✅ Item Dropdown
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Consumer<AddItemProvider>(
//                               builder: (context, itemProvider, child) {
//                                 return SizedBox(
//                                   height: 30,
//                                   width: double.infinity,
//                                   child: itemProvider.isLoading
//                                       ? const Center(
//                                           child: CircularProgressIndicator())
//                                       : CustomDropdownTwo(
//                                           enableSearch: true,
//                                           hint: 'Select Item',
//                                           items: itemProvider.items
//                                               .map((item) => item.name)
//                                               .toList(),
//                                           width: double.infinity,
//                                           height: 30,
//                                           selectedItem: selectedItemName,
//                                           onChanged: (value) async {
//                                             debugPrint(
//                                                 '=== Item Selected: $value ===');

//                                             final selectedItem =
//                                                 itemProvider.items.firstWhere(
//                                               (item) => item.name == value,
//                                             );

//                                             setState(() {
//                                               selectedItemName = value;
//                                               selectedItemId = selectedItem.id;
//                                               unitIdsList.clear();

//                                               controller.seletedItemName =
//                                                   selectedItem.name;
//                                               controller.selcetedItemId =
//                                                   selectedItem.id.toString();

//                                               controller.purchasePrice =
//                                                   selectedItem.purchasePrice
//                                                           is int
//                                                       ? (selectedItem
//                                                                   .purchasePrice
//                                                               as int)
//                                                           .toDouble()
//                                                       : (selectedItem
//                                                               .purchasePrice ??
//                                                           0.0);

//                                               controller.unitQty =
//                                                   selectedItem.unitQty ?? 1;

//                                               // ✅ Clear fields properly
//                                               controller.qtyController.clear();
//                                               controller.subtotalItemDiolog =
//                                                   0.0;

//                                               // Set initial price
//                                               controller.mrpController.text =
//                                                   controller.purchasePrice
//                                                       .toStringAsFixed(2);
//                                             });

//                                             // Fetch stock quantity
//                                             if (controller.selcetedItemId !=
//                                                 null) {
//                                               fetchStockQuantity
//                                                   .fetchStockQuantity(controller
//                                                       .selcetedItemId!);
//                                             }

//                                             // Ensure unitProvider is loaded
//                                             if (unitProvider.units.isEmpty) {
//                                               await unitProvider.fetchUnits();
//                                             }

//                                             // Populate units
//                                             setState(() {
//                                               unitIdsList.clear();

//                                               // Primary unit
//                                               if (selectedItem.unitId != null) {
//                                                 final unit = unitProvider.units
//                                                     .firstWhere(
//                                                   (unit) =>
//                                                       unit.id.toString() ==
//                                                       selectedItem.unitId
//                                                           .toString(),
//                                                   orElse: () => Unit(
//                                                     id: 0,
//                                                     name: 'Unknown',
//                                                     symbol: '',
//                                                     status: 0,
//                                                   ),
//                                                 );
//                                                 if (unit.id != 0) {
//                                                   unitIdsList.add(unit.name);
//                                                   controller.primaryUnitName =
//                                                       unit.name;
//                                                   controller.selectedUnit =
//                                                       unit.name;
//                                                   controller
//                                                       .selectedUnitIdWithNameFunction(
//                                                           "${unit.id}_${unit.name}");
//                                                 }
//                                               }

//                                               // Secondary unit
//                                               if (selectedItem
//                                                       .secondaryUnitId !=
//                                                   null) {
//                                                 final secondaryUnit =
//                                                     unitProvider.units
//                                                         .firstWhere(
//                                                   (unit) =>
//                                                       unit.id.toString() ==
//                                                       selectedItem
//                                                           .secondaryUnitId
//                                                           .toString(),
//                                                   orElse: () => Unit(
//                                                     id: 0,
//                                                     name: 'Unknown',
//                                                     symbol: '',
//                                                     status: 0,
//                                                   ),
//                                                 );
//                                                 if (secondaryUnit.id != 0) {
//                                                   unitIdsList
//                                                       .add(secondaryUnit.name);
//                                                   controller.secondaryUnitName =
//                                                       secondaryUnit.name;
//                                                 }
//                                               }
//                                             });

//                                             debugPrint(
//                                                 "Units Available: $unitIdsList");
//                                             debugPrint(
//                                                 "purchase price ===> ${controller.purchasePrice}");
//                                           }),
//                                 );
//                               },
//                             ),
//                           ),

//                           // Qty and Unit row
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               // Qty
//                               Column(
//                                 children: [
//                                   SizedBox(
//                                     width: 150,
//                                     child: AddSalesFormfield(
//                                       labelText: "Qty",
//                                       label: "",
//                                       controller: controller.qtyController,
//                                       keyboardType: TextInputType.number,
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                               // Unit Dropdown
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(height: 20),
//                                   SizedBox(
//                                     width: 150,
//                                     child: CustomDropdownTwo(
//                                       key: ValueKey(
//                                           'unit_dropdown_${selectedItemId}_${unitIdsList.length}'),
//                                       labelText: "Unit",
//                                       hint: '',
//                                       items: unitIdsList,
//                                       width: 150,
//                                       height: 30,
//                                       selectedItem: unitIdsList.isNotEmpty &&
//                                               controller.selectedUnit != null &&
//                                               unitIdsList.contains(
//                                                   controller.selectedUnit)
//                                           ? controller.selectedUnit
//                                           : (unitIdsList.isNotEmpty
//                                               ? unitIdsList.first
//                                               : null),
//                                       onChanged: (selectedUnit) {
//                                         debugPrint(
//                                             "Selected Unit: $selectedUnit");

//                                         controller.selectedUnit = selectedUnit;

//                                         final selectedUnitObj =
//                                             unitProvider.units.firstWhere(
//                                           (unit) => unit.name == selectedUnit,
//                                           orElse: () => Unit(
//                                               id: 0,
//                                               name: "Unknown",
//                                               symbol: "",
//                                               status: 0),
//                                         );

//                                         controller.selectedUnitIdWithNameFunction(
//                                             "${selectedUnitObj.id}_${selectedUnitObj.symbol}");

//                                         debugPrint(
//                                             "🆔 Unit ID: ${selectedUnitObj.id}_${selectedUnitObj.symbol}");

//                                         // Price update logic
//                                         setState(() {
//                                           if (selectedUnit ==
//                                               controller.secondaryUnitName) {
//                                             double newPrice =
//                                                 controller.purchasePrice /
//                                                     controller.unitQty;
//                                             controller.mrpController.text =
//                                                 newPrice.toStringAsFixed(2);
//                                           } else if (selectedUnit ==
//                                               controller.primaryUnitName) {
//                                             controller.mrpController.text =
//                                                 controller.purchasePrice
//                                                     .toStringAsFixed(2);
//                                           }

//                                           controller.dialogtotalController();
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),

//                           // Price
//                           AddSalesFormfield(
//                             labelText: "Price",
//                             label: "",
//                             controller: controller.mrpController,
//                             keyboardType: TextInputType.number,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     // Subtotal display
//                     Consumer<PurchaseController>(
//                       builder: (context, purchaseController, _) => Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             const Text("Subtotal: ",
//                                 style: TextStyle(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold)),
//                             const SizedBox(width: 5),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 7.0),
//                               child: Text(
//                                 purchaseController.subtotalItemDiolog
//                                     .toStringAsFixed(2),
//                                 style: const TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const Spacer(),

//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         // Add & new button
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Align(
//                             alignment: Alignment.bottomRight,
//                             child: InkWell(
//                               onTap: () async {
//                                 debugPrint("🟢 Add & New Item button tapped");

//                                 if (controller.qtyController.text.isEmpty ||
//                                     controller.mrpController.text.isEmpty) {
//                                   ScaffoldMessenger.of(context)
//                                       .showSnackBar(const SnackBar(
//                                     content:
//                                         Text('Please enter the qty & price'),
//                                     backgroundColor: Colors.red,
//                                   ));
//                                 } else {
//                                   // Add new PurchaseUpdateModel to provider list
//                                   provider.purchaseUpdateList
//                                       .add(PurchaseUpdateModel(
//                                     itemId: controller.selcetedItemId ?? "0",
//                                     qty: controller.qtyController.text,
//                                     unitId: controller.selectedUnitIdWithName ??
//                                         "0_unit",
//                                     price: controller.mrpController.text,
//                                     subTotal: controller.subtotalItemDiolog
//                                         .toStringAsFixed(2),
//                                   ));

//                                   provider.notifyListeners();

//                                   // ✅ COMPLETE FIELD CLEARING
//                                   setState(() {
//                                     selectedCategoryId = null;
//                                     selectedSubCategoryId = null;
//                                     selectedItemName = null;
//                                     selectedItemId = null;
//                                     unitIdsList.clear();
//                                   });

//                                   // ✅ Clear ALL controller fields
//                                   controller.mrpController.clear();
//                                   controller.qtyController.clear();
//                                   controller.subtotalItemDiolog = 0.0;
//                                   controller.selectedUnit = null;
//                                   controller.selectedUnitIdWithName = "";
//                                   controller.seletedItemName = null;
//                                   controller.selcetedItemId = "";
//                                   controller.primaryUnitName = "";
//                                   controller.secondaryUnitName = "";
//                                   controller.purchasePrice = 0.0;
//                                   controller.unitQty = 1;

//                                   // Clear providers
//                                   Provider.of<ItemCategoryProvider>(context,
//                                           listen: false)
//                                       .subCategories = [];
//                                   Provider.of<AddItemProvider>(context,
//                                           listen: false)
//                                       .clearPurchaseStockData();

//                                   // Re-add listeners for next item
//                                   controller.qtyController
//                                       .addListener(updateSubtotal);
//                                   controller.mrpController
//                                       .addListener(updateSubtotal);
//                                 }
//                               },
//                               child: SizedBox(
//                                 width: 90,
//                                 child: DecoratedBox(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(5),
//                                     color: colorScheme.primary,
//                                   ),
//                                   child: const Padding(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 6.0, vertical: 2),
//                                     child: Center(
//                                       child: Text(
//                                         "Add & new",
//                                         style: TextStyle(
//                                             color: Colors.white, fontSize: 14),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 4),

//                         // Add item button
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Align(
//                             alignment: Alignment.bottomRight,
//                             child: InkWell(
//                               onTap: () async {
//                                 debugPrint("🟢 Add Item button tapped");

//                                 if (controller.qtyController.text.isEmpty ||
//                                     controller.mrpController.text.isEmpty) {
//                                   ScaffoldMessenger.of(context)
//                                       .showSnackBar(const SnackBar(
//                                     content:
//                                         Text('Please enter the qty & price'),
//                                     backgroundColor: Colors.red,
//                                   ));
//                                 } else {
//                                   // ✅ REMOVE LISTENERS BEFORE CLOSING
//                                   controller.qtyController
//                                       .removeListener(updateSubtotal);
//                                   controller.mrpController
//                                       .removeListener(updateSubtotal);

//                                   // Add new PurchaseUpdateModel to provider list
//                                   provider.purchaseUpdateList
//                                       .add(PurchaseUpdateModel(
//                                     itemId: controller.selcetedItemId ?? "0",
//                                     qty: controller.qtyController.text,
//                                     unitId: controller.selectedUnitIdWithName ??
//                                         "0_unit",
//                                     price: controller.mrpController.text,
//                                     subTotal: controller.subtotalItemDiolog
//                                         .toStringAsFixed(2),
//                                   ));

//                                   provider.notifyListeners();

//                                   // ✅ COMPLETE FIELD CLEARING
//                                   setState(() {
//                                     selectedCategoryId = null;
//                                     selectedSubCategoryId = null;
//                                     selectedItemName = null;
//                                     selectedItemId = null;
//                                     unitIdsList.clear();
//                                   });

//                                   // ✅ Clear ALL controller fields
//                                   controller.mrpController.clear();
//                                   controller.qtyController.clear();
//                                   controller.subtotalItemDiolog = 0.0;
//                                   controller.selectedUnit = null;
//                                   controller.selectedUnitIdWithName = "";
//                                   controller.seletedItemName = null;
//                                   controller.selcetedItemId = "";
//                                   controller.primaryUnitName = "";
//                                   controller.secondaryUnitName = "";
//                                   controller.purchasePrice = 0.0;
//                                   controller.unitQty = 1;

//                                   // Clear providers
//                                   Provider.of<ItemCategoryProvider>(context,
//                                           listen: false)
//                                       .subCategories = [];
//                                   Provider.of<AddItemProvider>(context,
//                                           listen: false)
//                                       .clearPurchaseStockData();

//                                   Navigator.pop(context);
//                                 }
//                               },
//                               child: SizedBox(
//                                 width: 90,
//                                 child: DecoratedBox(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(5),
//                                       color: colorScheme.primary,
//                                     ),
//                                     child: const Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 6.0, vertical: 2),
//                                       child: Center(
//                                         child: Text(
//                                           "Add",
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 14),
//                                         ),
//                                       ),
//                                     )),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ));
//         });
//       },
//     );
//   }

// // Add this function to your PurchaseUpdateScreen class

//   Future<void> showPurchaseItemUpdateDialog(
//     BuildContext context,
//     int index,
//     PurchaseUpdateModel itemDetail,
//     PurchaseUpdateProvider provider,
//     Map<int, String> itemMap,
//     Map<int, String> unitMap,
//     List<dynamic> itemList,
//   ) async {
//     final priceController =
//         TextEditingController(text: itemDetail.price.toString());
//     final qtyController =
//         TextEditingController(text: itemDetail.qty.toString());
//     final subTotalController =
//         TextEditingController(text: itemDetail.subTotal.toString());

//     // Initialize selected values
//     String? selectedItemName =
//         itemMap[int.tryParse(itemDetail.itemId) ?? 0] ?? 'No Items Available';
//     String? selectedUnitName =
//         unitMap[int.tryParse(itemDetail.unitId.split("_")[0]) ?? 0] ??
//             'No Units Available';
//     int? selectedItemId = int.tryParse(itemDetail.itemId);
//     int? selectedUnitId = int.tryParse(itemDetail.unitId.split("_")[0]);

//     // Function to get filtered units for selected item
//     List<String> getFilteredUnitsForSelectedItem() {
//       if (selectedItemId == null) return [];

//       final item = itemList.firstWhere(
//         (element) => element['id'] == selectedItemId,
//         orElse: () => null,
//       );

//       if (item == null) return [];

//       final primaryUnitId = item['unit_id'];
//       final secondaryUnitId = item['secondary_unit_id'];

//       final unitNames = <String>[];

//       // Use unitMap to convert unitId → name (e.g., 5 → "Pc")
//       if (primaryUnitId != null && unitMap.containsKey(primaryUnitId)) {
//         unitNames.add(unitMap[primaryUnitId]!);
//       }

//       if (secondaryUnitId != null && unitMap.containsKey(secondaryUnitId)) {
//         unitNames.add(unitMap[secondaryUnitId]!);
//       }

//       return unitNames;
//     }

//     return showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setState) {
//           void calculateSubtotal() {
//             final price = double.tryParse(priceController.text) ?? 0.0;
//             final qty = double.tryParse(qtyController.text) ?? 0.0;
//             final subTotal = price * qty;
//             subTotalController.text = subTotal.toStringAsFixed(2);
//           }

//           // Add listeners for automatic calculation
//           priceController.addListener(calculateSubtotal);
//           qtyController.addListener(calculateSubtotal);

//           void updateItem() {
//             final priceText = priceController.text.trim();
//             final qtyText = qtyController.text.trim();
//             final subTotalText = subTotalController.text.trim();

//             debugPrint("Updating item:");
//             debugPrint("Selected Item: $selectedItemName");
//             debugPrint("Selected Unit: $selectedUnitName");
//             debugPrint("Qty: $qtyText");
//             debugPrint("Price: $priceText");
//             debugPrint("Subtotal: $subTotalText");

//             final parsedPrice = double.tryParse(priceText);
//             final parsedQty = double.tryParse(qtyText);
//             final parsedSubTotal = double.tryParse(subTotalText);

//             if (parsedPrice == null ||
//                 parsedQty == null ||
//                 parsedSubTotal == null) {
//               debugPrint("Error: One or more fields contain invalid numbers.");
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content: Text("Please enter valid numeric values")),
//               );
//               return;
//             }

//             // Reverse lookup for itemId
//             final updatedItemId = itemMap.entries
//                 .firstWhere((entry) => entry.value == selectedItemName,
//                     orElse: () => const MapEntry(0, ''))
//                 .key;

//             // Reverse lookup for unitId
//             final updatedUnitId = unitMap.entries
//                 .firstWhere((entry) => entry.value == selectedUnitName,
//                     orElse: () => const MapEntry(0, ''))
//                 .key;

//             if (updatedItemId == 0 || updatedUnitId == 0) {
//               debugPrint("Invalid item or unit selection");
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Invalid item or unit selection")),
//               );
//               return;
//             }

//             // Update provider list
//             provider.purchaseUpdateList[index] = PurchaseUpdateModel(
//               itemId: updatedItemId.toString(),
//               price: priceText,
//               qty: qtyText,
//               subTotal: subTotalText,
//               unitId: "${updatedUnitId}_$selectedUnitName",
//             );

//             // Also update response model
//             final detail =
//                 provider.purchaseEditResponse.data?.purchaseDetails?[index];
//             if (detail != null) {
//               detail.itemId = updatedItemId;
//               detail.unitId = updatedUnitId;
//               detail.price = parsedPrice.toInt();
//               detail.qty = parsedQty.toInt();
//               detail.subTotal = parsedSubTotal;
//             }

//             provider.notifyListeners();
//             Navigator.pop(context);

//             // Show success message
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text("$selectedItemName updated successfully"),
//                 backgroundColor: Colors.green,
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//           }

//           return AlertDialog(
//             title: const Text(
//               "Edit Purchase Item",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             content: SingleChildScrollView(
//               child: SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Item Name (Read-only)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Item Name",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Container(
//                           height: 40,
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 10),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             selectedItemName ?? "Unknown Item",
//                             style: const TextStyle(
//                               color: Colors.black87,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 15),

//                     // Unit Dropdown
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Unit",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         SizedBox(
//                           height: 40,
//                           child: CustomDropdownTwo(
//                             labelText: 'Unit',
//                             items: getFilteredUnitsForSelectedItem().isNotEmpty
//                                 ? getFilteredUnitsForSelectedItem()
//                                 : ['No Units Available'],
//                             hint: selectedUnitName ?? 'Select Unit',
//                             width: double.infinity,
//                             selectedItem: selectedUnitName,
//                             height: 40,
//                             onChanged: (String? newValue) {
//                               setState(() {
//                                 selectedUnitName = newValue;

//                                 // Reverse lookup the unit ID from name
//                                 selectedUnitId = unitMap.entries
//                                     .firstWhere(
//                                       (entry) => entry.value == newValue,
//                                       orElse: () => const MapEntry(-1, ''),
//                                     )
//                                     .key;

//                                 debugPrint(
//                                     "Selected Unit Name: $selectedUnitName");
//                                 debugPrint("Selected Unit ID: $selectedUnitId");
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 15),

//                     // Price and Quantity Row
//                     Row(
//                       children: [
//                         // Price field
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 "Price",
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               SizedBox(
//                                 height: 40,
//                                 child: AddSalesFormfield(
//                                   controller: priceController,
//                                   keyboardType: TextInputType.number,
//                                   onChanged: (value) {
//                                     calculateSubtotal();
//                                     setState(() {});
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(width: 10),

//                         // Quantity field
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 "Quantity",
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               SizedBox(
//                                 height: 40,
//                                 child: AddSalesFormfield(
//                                   controller: qtyController,
//                                   keyboardType: TextInputType.number,
//                                   onChanged: (value) {
//                                     calculateSubtotal();
//                                     setState(() {});
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 15),

//                     // Subtotal (Read-only)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Subtotal",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         SizedBox(
//                           height: 40,
//                           child: AddSalesFormfield(
//                             controller: subTotalController,
//                             readOnly: true,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.grey.shade50,
//                               border: OutlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Colors.grey.shade300),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   // Remove listeners before closing
//                   priceController.removeListener(calculateSubtotal);
//                   qtyController.removeListener(calculateSubtotal);
//                   Navigator.pop(context);
//                 },
//                 child:
//                     const Text("Cancel", style: TextStyle(color: Colors.grey)),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   // Validate input
//                   final updatedPrice = double.tryParse(priceController.text);
//                   final updatedQty = double.tryParse(qtyController.text);

//                   if (updatedPrice == null || updatedPrice <= 0) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Please enter a valid price"),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                     return;
//                   }

//                   if (updatedQty == null || updatedQty <= 0) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Please enter a valid quantity"),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                     return;
//                   }

//                   // Remove listeners before updating
//                   priceController.removeListener(calculateSubtotal);
//                   qtyController.removeListener(calculateSubtotal);

//                   updateItem();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text("Update Item"),
//               ),
//             ],
//           );
//         });
//       },
//     );
//   }
// }

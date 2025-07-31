import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_close_button.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/give_information_dialog.dart';
import 'package:cbook_dt/common/item_dropdown_custom.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
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

  ///feach purchase data by id
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

      // print(purchaseUpdateList.length);
      debugPrint(purchaseUpdateList.length.toString());

      if (data['success']) {
        final purchaseData = purchaseEditResponse.data!;

        purchaseDetailsList = purchaseData.purchaseDetails ?? [];
        billNumberController.text = purchaseData.billNumber ?? "";
        purchaseDateController.text = purchaseData.purchaseDate ?? "";
        grossTotalController.text = purchaseData.grossTotal?.toString() ?? "";
        customerController.text = purchaseData.customerId?.toString() ?? "";
        discountTotalController.text = purchaseData.discount?.toString() ?? "0";

        /// ✅ Add this:
        customerId = purchaseData.customerId;
        //customerController.text = purchaseData.customerId?.toString() ?? "";
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

  //String get formattedDate => DateTimeHelper.formatDate(_selectedDate);
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
    ///int ? billPersonID
    // if (purchaseId == null) return;

    debugPrint(jsonEncode(purchaseUpdateList));

    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime _selectedDate = DateTime.now(); // or your selected date

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    debugPrint("purchase_date=$formattedDate");

    final url =
        "https://commercebook.site/api/v1/purchase/update?id=${purchaseEditResponse.data!.purchaseDetails![0].purchaseId}&user_id=${prefs.getInt("user_id")}&customer_id=${purchaseEditResponse.data!.customerId}&bill_number=${billNumberController.text}&purchase_date=$formattedDate&details_notes=notes&gross_total=${getSubTotal()}&discount=${discountTotalController.text}&payment_out=${isCash ? 1 : 0}&payment_amount=${getGrossTotal()}&bill_person_id=$billPersonID";

    debugPrint("url  ===> ${url}");

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

      debugPrint("=====>Stop<===== ");

      debugPrint("=====>Stop<===== ");

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
        //purchaseDetailsId: "0",
        itemId: id.toString(),
        qty: qty.toString(),
        //qty: qty % 1 == 0 ? qty.toInt().toString() : qty.toString(),
        //purchaseQty: "0",
        unitId: "${unitId.toString()}_${getUnitName(unitId.toString())}}",
        price: price.toString(),
        subTotal: subTotal.toString())));
    notifyListeners();
  }
}

///====> purchase update UI
///====>Purchase update Screen UI
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

    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());

    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());
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
              debugPrint(provider.qtyController.text);
              debugPrint(provider.discountTotalController.text);

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
                                controller.updateCash();
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
                                        (provider.customerId != null &&
                                                provider.customerId != 0)
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
                                          Consumer<PurchaseUpdateProvider>(
                                            builder:
                                                (context, provider, child) {
                                              return (provider.customerId != null  )
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Supplier",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12),
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              height: 58,
                                                              width: 180,
                                                              child: provider.customerId ==
                                                          null ||
                                                      provider.customerId ==0 
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              Dialog(
                                                                            child:
                                                                                ReusableForm(
                                                                              nameController: nameController,
                                                                              phoneController: phoneController,
                                                                              emailController: emailController,
                                                                              addressController: addressController,
                                                                              primaryColor: Theme.of(context).primaryColor,
                                                                              onCancel: _onCancel,
                                                                              onSubmit: () {
                                                                                setState(() {
                                                                                  controller.updatedCustomerInfomation(
                                                                                    nameFrom: nameController.text,
                                                                                    phoneFrom: phoneController.text,
                                                                                    emailFrom: emailController.text,
                                                                                    addressFrom: addressController.text,
                                                                                  );
                                                                                });
                                                                                Navigator.pop(context);
                                                                              },
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        "Cash",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.blue,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Column(
                                                                      children: [
                                                                        AddSalesFormfieldTwo(
                                                                          controller:
                                                                              controller.codeController,
                                                                          customerorSaleslist:
                                                                              "Showing supplieer list",
                                                                          customerOrSupplierButtonLavel:
                                                                              "Add new supplier",
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => const SuppliersCreate(),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                        Consumer<
                                                                            CustomerProvider>(
                                                                          builder: (context,
                                                                              customerProvider,
                                                                              child) {
                                                                            final customerList =
                                                                                customerProvider.customerResponse?.data ?? [];

                                                                            return Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                if (customerList.isEmpty) const SizedBox(height: 2),
                                                                                if (customerList.isNotEmpty && customerProvider.selectedCustomer != null && customerProvider.selectedCustomer!.id != -1)
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
                                                                                        padding: const EdgeInsets.only(top: 2),
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
                                                                    ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  : const SizedBox(); // ✅ Empty when customerId is present
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ///bill number
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

                                          ///date
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
                                                  //color: Colors.white,
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
                                                      color: Colors
                                                          .blue, // Use your desired color
                                                    ),
                                                  ],
                                                ),
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
                                  height: 5,
                                ),

                                ////=====>item list
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.purchaseUpdateList.length,
                                  itemBuilder: (context, index) {
                                    final detail =
                                        provider.purchaseUpdateList![index];

                                    return GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdatePurchaseItemView(
                                              index: index,
                                              itemDetail: detail,
                                              provider: provider,
                                              // itemDetail: detail,
                                              itemMap: provider.itemMap,
                                              unitMap: provider.unitMap,
                                              itemList: provider.itemList,
                                            ),
                                          ),
                                        );
                                        if (context.mounted) {
                                          provider.notifyListeners();
                                        }
                                        provider.notifyListeners();
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
                                              const SizedBox(
                                                width: 4,
                                              ),

                                              ///delete button
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
                                                                  .pop(); // Close dialog
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
                                              showSalesDialog(
                                                context,
                                                controller,
                                                //PurchaseUpdateProvider provider,
                                                provider,
                                              );
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
                                              showSalesDialog(
                                                context,
                                                controller,
                                                provider,
                                              );
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
                                              horizontal: 8.0),
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

                                const SizedBox(
                                  height: 2,
                                ),
                                //===>subtotal
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    //color: Colors.red,
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
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          //color: Colors.amber,
                                          width: 150,
                                          height: 30,
                                          child: AddSalesFormfield(
                                            labelText: "Subtotal",
                                            //enabled: false,
                                            controller: TextEditingController(
                                                text: provider.getSubTotal()),
                                            // style: const TextStyle(
                                            //     color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 8,
                                ),

                                // //===>Discount
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
                                          width: 150,
                                          height: 30,
                                          child: AddSalesFormfield(
                                            labelText: "Discount",
                                            // controller: provider
                                            //     .discountTotalController,
                                            controller: provider
                                                .discountTotalController,
                                            onChanged: (value) {
                                              provider
                                                  .updateGrossTotal(); // Trigger the update for Gross Total
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                // ////===>gross total
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
                                                //  controller: TextEditingController(
                                                // text: provider.getSubTotal()),
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
                                ////payment
                                controller.isCash == false &&
                                        controller.isReturn == true
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                height: 25,
                                                child: Checkbox(
                                                  value: controller
                                                      .isOnlineMoneyChecked,
                                                  onChanged: (bool? value) {
                                                    controller
                                                        .updateOnlineMoney();
                                                  },
                                                ),
                                              ),
                                              // const Text("Online Payment",
                                              //     style: TextStyle(color: Colors.green, fontSize: 12)),
                                            ],
                                          ),

                                          ///creadit payment , cash
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Payment",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black)),
                                              const SizedBox(width: 5),
                                              AddSalesFormfield(
                                                controller: controller
                                                    .receivedAmountController,
                                                labelText: "Payment",
                                                onChanged: (value) {
                                                  if (!controller
                                                      .isOnlineMoneyChecked) {
                                                    controller
                                                            .receivedAmountController
                                                            .text =
                                                        value; // ✅ Allow manual input
                                                  }
                                                },
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
                          //purchase update
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
                                    return; // Stop further execution
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

  ///purchase item add in list.
  void showSalesDialog(
    BuildContext context,
    PurchaseController controller,
    PurchaseUpdateProvider provider,
  ) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);

    final unitProvider = Provider.of<UnitProvider>(context, listen: false);

    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    final controller = Provider.of<PurchaseController>(context, listen: false);
    controller.dialogtotalController();

    final TextEditingController itemController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // ✅ Pop the loading dialog
    Navigator.of(context).pop();

    // Define local state variables
    String? selectedCategoryId;
    String? selectedSubCategoryId;

    List<String> unitIdsList = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
              backgroundColor: Colors.grey.shade400,
              child: Container(
                height: 300, //550
                // width: Constraints.maxWidth,
                decoration: BoxDecoration(
                  color: const Color(0xffe7edf4),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    ///header, add item & service , and close icon
                    Container(
                      height: 30,
                      color: const Color(0xff278d46),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                              width:
                                  30), // Placeholder for left spacing (can be removed or adjusted)

                          // Centered text and icon
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
                          const SizedBox(
                            height: 3,
                          ),

                          // Category and Subcategory Row

                          const SizedBox(
                            height: 5,
                          ),

                          const Column(children: [
                            /// Category and Subcategory Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /////===> category

                                SizedBox(width: 10),
                              ],
                            ),

                            SizedBox(height: 5),
                          ]),

                          ///item drop down
                          ItemCustomDropDownTextField(
                            controller: itemController,
                            //label: "Select Item",
                            onItemSelected: (selectedItem) async {
                              // This will print the id and name when item is selected
                              debugPrint(
                                  "=======> Selected Item: ${selectedItem.name} (ID: ${selectedItem.id})");

                              setState(() {
                                // Save selected item name and id in controller
                                controller.seletedItemName = selectedItem.name;
                                controller.selcetedItemId =
                                    selectedItem.id.toString();

                                // Fetch stock quantity
                                if (controller.selcetedItemId != null) {
                                  fetchStockQuantity.fetchStockQuantity(
                                      controller.selcetedItemId!);
                                }
                              });

                              // Ensure unitProvider is loaded
                              if (unitProvider.units.isEmpty) {
                                await unitProvider
                                    .fetchUnits(); // Ensure units are fetched
                              }

                              // Clear previous units
                              unitIdsList.clear();

                              debugPrint(
                                  "Selected item unitId: ${selectedItem.unitId}");
                              debugPrint(
                                  "Selected item secondaryUnitId: ${selectedItem.secondaryUnitId}");

                              // Base unit
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
                                  controller.selectedUnit = unit.name;

                                  // Create final unit string like: "24_Pces_1"
                                  String finalUnitString =
                                      "${unit.id}_${unit.name}"; //"${unit.id}_${unit.name}_1";
                                  controller.selectedUnitIdWithNameFunction(
                                      finalUnitString);
                                }
                              }

                              // Secondary unit
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

                              if (unitIdsList.isEmpty) {
                                debugPrint(
                                    "No valid units found for this item.");
                              } else {
                                debugPrint("Units Available: $unitIdsList");
                              }
                            },
                          ),

                          ///stock
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //qty
                              Column(
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: AddSalesFormfield(
                                      labelText: "Qty",
                                      label: "",
                                      controller: controller.qtyController,
                                      keyboardType: TextInputType.number,
                                      //xyz
                                    ),
                                  ),
                                ],
                              ),

                              //unit <<<<====
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: CustomDropdownTwo(
                                      labelText: "Unit",
                                      hint: '',
                                      items:
                                          unitIdsList, // should be list of symbols like ["KG", "Bag", "PKT"]
                                      width: 150,
                                      height: 30,
                                      selectedItem: unitIdsList.isNotEmpty
                                          ? unitIdsList.first
                                          : null,
                                      onChanged: (selectedUnit) {
                                        debugPrint(
                                            "Selected Unit: $selectedUnit");

                                        controller.selectedUnit = selectedUnit;

                                        // FIX: Match by symbol
                                        final selectedUnitObj =
                                            unitProvider.units.firstWhere(
                                          (unit) => unit.symbol == selectedUnit,
                                          orElse: () => Unit(
                                              id: 0,
                                              name: "Unknown Unit",
                                              symbol: "",
                                              status: 0),
                                        );

                                        controller
                                            .selectedUnitIdWithNameFunction(
                                          "${selectedUnitObj.id}_${selectedUnitObj.symbol}",
                                        );

                                        debugPrint(
                                            "🆔 Selected Unit ID: ${selectedUnitObj.id}_${selectedUnitObj.symbol}");
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),

                          ///price
                          AddSalesFormfield(
                            labelText: "Price",
                            label: "",
                            controller: controller.mrpController,
                            keyboardType: TextInputType.number,
                            // onChanged: (value) {
                            //   controller.subtotalItemDiolog;

                            // },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Consumer<PurchaseController>(
                      builder: (context, controller, _) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Subtotal:",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(top: 7.0),
                              child: Text(
                                controller.subtotalItemDiolog
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
                        ///added & new
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () async {
                                debugPrint("🟢 Add Item button tapped");
                                debugPrint(
                                    "🔹 Selected Unit: ${controller.selectedUnit}");
                                debugPrint(
                                    "🔹 Selected Unit: ${controller.selectedUnit}");
                                debugPrint(
                                    "🔹 Full Selected Unit Info: ${controller.selectedUnitIdWithName}");

                                debugPrint("Add Item");
                                debugPrint("selectedItem ============|>");

                                //debugPrint(selectedItem);

                                debugPrint(
                                  'Selected Unit: ${controller.selectedUnit ?? "None"}',
                                );

                                if (controller.qtyController.text.isEmpty ||
                                    controller.mrpController.text.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                      'Please enter the qty & price',
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                } else {
                                  setState(() {
                                    controller.isCash
                                        ? controller.addCashItem()
                                        : controller.addCreditItem();

                                    controller.addAmount();

                                    Navigator.pop(context);
                                  });
                                }

                                setState(() {
                                  Provider.of<PurchaseController>(context,
                                          listen: false)
                                      .notifyListeners();
                                });

                                ////clear item name
                                setState(() {
                                  controller.seletedItemName = null;

                                  // ✅ Clear selected category & subcategory
                                  selectedCategoryId = null;
                                  selectedSubCategoryId = null;

                                  // ✅ (Optional) Clear subcategories
                                  Provider.of<ItemCategoryProvider>(context,
                                          listen: false)
                                      .subCategories = [];
                                });

                                // ✅ Clear stock info
                                Provider.of<AddItemProvider>(context,
                                        listen: false)
                                    .clearPurchaseStockData();

                                controller.mrpController.clear();
                                controller.qtyController.clear();
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

                        const SizedBox(
                          width: 4,
                        ),

                        /// add item
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () async {
                                debugPrint("🟢 Add Item button tapped");
                                debugPrint(
                                    "🔹 Selected Unit: ${controller.selectedUnit}");
                                debugPrint(
                                    "🔹 Selected Unit: ${controller.selectedUnit}");
                                debugPrint(
                                    "🔹 Full Selected Unit Info: ${controller.selectedUnitIdWithName}");

                                debugPrint("Add Item");
                                debugPrint("selectedItem ============|>");

                                //debugPrint(selectedItem);

                                debugPrint(
                                  'Selected Unit: ${controller.selectedUnit ?? "None"}',
                                );

                                if (controller.qtyController.text.isEmpty ||
                                    controller.mrpController.text.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text('Please enter the qty & price'),
                                    backgroundColor: Colors.red,
                                  ));
                                } else {
                                  // ✅ Add new PurchaseUpdateModel to provider list
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

                                  provider
                                      .notifyListeners(); // ✅ Notify UI of changes

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
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ));
        });
      },
    );
  }
}

///===>purchase ItemModel , to add data in model.

// 

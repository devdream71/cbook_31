import 'dart:convert';

import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/close_button_icon.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/customer_create/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/purchase_return/controller/purchase_return_controller.dart';
import 'package:cbook_dt/feature/purchase_return/layer/bottom_portion_purchase_return.dart';
import 'package:cbook_dt/feature/purchase_return/purchase_return_item_details.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../common/give_information_dialog.dart';
import '../../sales/widget/add_sales_formfield.dart';
import 'package:http/http.dart' as http;
part '../layer/purchase_return_field_portion.dart';

class PurchaseReturnView extends StatefulWidget {
  const PurchaseReturnView({super.key});

  @override
  State<PurchaseReturnView> createState() => _PurchaseReturnViewState();
}

class _PurchaseReturnViewState extends State<PurchaseReturnView> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseReturnController>();
    return const _Layout();
  }
}

class _Layout extends StatefulWidget {
  const _Layout();

  @override
  State<_Layout> createState() => _LayoutState();
}

class _LayoutState extends State<_Layout> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  TextEditingController customerNameController = TextEditingController();

  final TextEditingController itemController = TextEditingController();

  TextEditingController billController = TextEditingController();

  String? localSelectedUnit;
  bool isItemSelected = false;

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  String? selectedItem;
  Customer? selectedCustomerObject;

  int? selectedSubCategoryId;

  String? selectedCustomer;
  String? selectedCustomerId;

  String? selectedItemNameInvoice;

  List<String> unitIdsList = [];

  List<double> amount = [];

  bool showNoteField = false;

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    Future.microtask(() =>
        Provider.of<ItemCategoryProvider>(context, listen: false)
            .fetchCategories());

    Provider.of<AddItemProvider>(context, listen: false).fetchItems();

    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());

    Provider.of<PurchaseReturnController>(context, listen: false).clearAll();

    Future.microtask(() async => await fetchAndSetBillNumber());

  }

  // Updated fetchAndSetBillNumber with more debugging:
  Future<void> fetchAndSetBillNumber() async {
    debugPrint('fetchAndSetBillNumber called');

    final url = Uri.parse(
      'https://commercebook.site/api/v1/app/setting/bill/number?voucher_type=purchase&type=purchase-return&code=PURR&bill_number=100&with_nick_name=1',
    );

    debugPrint('API URL: $url');

    try {
      debugPrint('Making API call...');
      final response = await http.get(url);
      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Parsed data: $data');

        if (data['success'] == true && data['data'] != null) {
          String billFromApi = data['data'].toString(); // Ensure it's a string
          debugPrint('Bill from API: $billFromApi');

          //String newBill = _incrementBillNumber(billFromApi);

          String newBill = billFromApi;

          debugPrint('New bill after increment: $newBill');

          // Update the controller and trigger UI rebuild
          if (mounted) {
            setState(() {
              billController.text = newBill;
              debugPrint('Bill controller updated to: ${billController.text}');
            });
          }
        } else {
          debugPrint('API success false or data null');
          // Handle API error
          if (mounted) {
            setState(() {
              billController.text = "PURR-100"; // Default fallback
              debugPrint('Set fallback bill: ${billController.text}');
            });
          }
        }
      } else {
        debugPrint('Failed to fetch bill number: ${response.statusCode}');
        // Set fallback bill number
        if (mounted) {
          setState(() {
            billController.text = "PURR-100";
            debugPrint(
                'Set fallback bill due to status code: ${billController.text}');
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching bill number: $e');
      // Set fallback bill number
      if (mounted) {
        setState(() {
          billController.text = "PURR-100";
          debugPrint('Set fallback bill due to exception: ${billController.text}');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.watch<PurchaseReturnController>();

    final unitProvider = Provider.of<UnitProvider>(context, listen: false);
    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    List<InvoiceItem> invoiceItems = controller.itemsCashReuturn.map((item) {
      return InvoiceItem(
        itemName: item.itemName ?? "",
        unit: item.unit ?? "Pc",
        //unit: "N/A", // You might need to update this logic
        quantity: int.tryParse(item.quantity ?? "0") ?? 0,
        amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
            (double.tryParse(item.mrp ?? "0") ?? 0.0),
      );
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
        statusBarIconBrightness: Brightness.light, // for Android
        statusBarBrightness: Brightness.dark, // for iOS
      ),
      child: Container(
        color: AppColors.primaryColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: colorScheme.surface,
                ),
              ),
              centerTitle: true,
              title: Text(
                "Purchase Return Invoice",
                style: GoogleFonts.lato(
                  color: Colors.yellow,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      //////=====>=====>updateCash==========<<<<<<<
                                      controller.updateCash();
                                    },
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child:

                                            //PaymentToggle(isCash: true, onToggle: ,)

                                            Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              controller.isCash
                                                  ? "Cash"
                                                  : "Credit",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
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
                                  vPad2,
                                  const Text(
                                    "Bill To",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  vPad5,
                                  const Text(
                                    "Cash",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 58,
                                        width: 190,
                                        // Adjusted height for cursor visibility
                                        child: controller.isCash
                                            ? TextField(
                                                readOnly: true,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      child: ReusableForm(
                                                        nameController:
                                                            nameController,
                                                        phoneController:
                                                            phoneController,
                                                        emailController:
                                                            emailController,
                                                        addressController:
                                                            addressController,
                                                        primaryColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onCancel: _onCancel,
                                                        onSubmit: () {
                                                          setState(() {
                                                            controller
                                                                .updatedCustomerInfomation(
                                                              nameFrom:
                                                                  nameController
                                                                      .text,
                                                              phoneFrom:
                                                                  phoneController
                                                                      .text,
                                                              emailFrom:
                                                                  emailController
                                                                      .text,
                                                              addressFrom:
                                                                  addressController
                                                                      .text,
                                                            );
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },

                                                controller: controller
                                                    .controller, // Managing text field content
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                                decoration: InputDecoration(
                                                  // filled: true,
                                                  fillColor: Colors.white,
                                                  border: UnderlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                    borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                    borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                    borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 12,
                                                    horizontal: 2,
                                                  ),
                                                ),
                                                cursorHeight:
                                                    12, // Adjusted cursor height
                                                cursorWidth:
                                                    2, // Adjusted cursor width for visibility
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ///show text field search ====>
                                                  AddSalesFormfieldTwo(
                                                    controller: controller
                                                        .customerNameController,
                                                    customerorSaleslist:
                                                        "Showing Customer list",
                                                    customerOrSupplierButtonLavel:
                                                        "Add customer",
                                                    color: Colors.grey,
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const CustomerCreate()));
                                                    },
                                                    //label: "Customer",
                                                  ),

                                                  /// show bottom payable or recivedable.
                                                  Consumer<CustomerProvider>(
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
                                                            if (customerProvider
                                                                        .selectedCustomer !=
                                                                    null &&
                                                                customerProvider
                                                                        .selectedCustomer!
                                                                        .id !=
                                                                    -1)
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    "${customerProvider.selectedCustomer!.type == 'customer' ? 'Receivable' : 'Payable'}: ",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: customerProvider.selectedCustomer!.type ==
                                                                              'customer'
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .red,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            2.0),
                                                                    child: Text(
                                                                      "৳ ${customerProvider.selectedCustomer!.due.toStringAsFixed(2)}",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black,
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
                                      )
                                    ],
                                  ),
                                  vPad5,
                                  nameController.value.text == ""
                                      ? const SizedBox.shrink()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Name: ${controller.customerName}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10)),
                                            Text("Phone: ${controller.phone}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10)),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                            hPad10,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Bill No Field
                                  // SizedBox(
                                  //   height: 30,
                                  //   width: 127,
                                  //   child: AddSalesFormfield(
                                  //     controller: controller.billNoController,
                                  //     labelText: "Bill No",
                                  //   ),
                                  // ),


                                  SizedBox(
                                      height: 30,
                                      width: 130,
                                      child: AddSalesFormfield(
                                        labelText: "Bill No",
                                        controller: billController,
                                        readOnly:
                                            true, // Prevent manual editing
                                      ),
                                    ),

                                  SizedBox(
                                    height: 25,
                                    width: 127,
                                    child: InkWell(
                                      onTap: () => controller.pickDate(
                                          context), // Trigger the date picker
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          suffixIconConstraints:
                                              const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ), // Adjust constraints to align icon closely
                                          hintText: "Bill Date",
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 10,
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400,
                                                width: 0.5),
                                          ),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.green),
                                          ),
                                        ),
                                        child: Text(
                                          controller.formattedDate.isNotEmpty
                                              ? controller.formattedDate
                                              : "Select Date", // Default text when no date is selected
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  ///bill person
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Consumer<PaymentVoucherProvider>(
                                      builder: (context, provider, child) {
                                        return SizedBox(
                                          height: 30,
                                          width: double.infinity,
                                          child: provider.isLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : CustomDropdownTwo(
                                                  hint: '',
                                                  items:
                                                      provider.billPersonNames,
                                                  width: double.infinity,
                                                  height: 30,
                                                  labelText: 'Bill Person',
                                                  selectedItem:
                                                      selectedBillPerson,
                                                  onChanged: (value) {
                                                    debugPrint(
                                                        '=== Bill Person Selected: $value ===');
                                                    setState(() {
                                                      selectedBillPerson =
                                                          value;
                                                      selectedBillPersonData =
                                                          provider.billPersons
                                                              .firstWhere(
                                                        (person) =>
                                                            person.name ==
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
                            )
                          ],
                        ),

                        vPad10,

                        /// Item Dropdown
                        SizedBox(
                          height: 52,
                          width: 200,
                          child: Consumer<AddItemProvider>(
                            builder: (context, itemProvider, child) {
                              if (itemProvider.isLoading) {
                                return const Center(child: SizedBox());
                              }

                              if (itemProvider.items.isEmpty) {
                                return const Center(
                                  child: Text('No items available.',
                                      style: TextStyle(color: Colors.black)),
                                );
                              }

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Selected an item",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: CustomDropdownTwo(
                                      hint: '', //hint: 'Choose an item',
                                      items: itemProvider.items
                                          .map((item) => item.name)
                                          .toList(),
                                      width: double.infinity,
                                      height: 30,
                                      selectedItem: controller.seletedItemName,
                                      onChanged: (selectedItemName) async {
                                        setState(() {
                                          controller.seletedItemName =
                                              selectedItemName;
                                          itemProvider.items.forEach((e) {
                                            if (selectedItemName == e.name) {
                                              controller.selcetedItemId =
                                                  e.id.toString();
                                            }
                                          });
                                        });

                                        if (controller.selcetedItemId != null) {
                                          await itemProvider
                                              .fetchPurchaseHistory(
                                                  controller.selcetedItemId);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// Purchase History (Only show after item selection)
                        Consumer<AddItemProvider>(
                          builder: (context, itemProvider, child) {
                            if (controller.seletedItemName == null) {
                              return const Center(
                                  child: Text("Please select an item"));
                            }

                            if (itemProvider.isHistoryLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (itemProvider.purchaseHistory.isEmpty) {
                              return const Center(
                                  child: Text(
                                "No Purchase History Available",
                                style: TextStyle(color: Colors.black),
                              ));
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PurchaseReturnDetailsPage(
                                              purchaseHistory:
                                                  itemProvider.purchaseHistory,
                                              itemName:
                                                  controller.seletedItemName!,
                                              // Pass data
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Rounded corners
                                        ),
                                      ),
                                      child: const Text(
                                        "Purchase Return",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                )
                              ],
                            );
                          },
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        vPad20,

                        //////cash item list
                        controller.isCash
                            ? Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      controller.itemsCashReuturn.isEmpty
                                          ? const SizedBox.shrink()
                                          : Column(
                                              children: List.generate(
                                                  controller.itemsCashReuturn
                                                      .length, (index) {
                                                final item = controller
                                                    .itemsCashReuturn[index];
                                                debugPrint(
                                                    "cash item list ===> $item");
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: DecoratedBox(
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.1),
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            2),
                                                                  ),
                                                                ],
                                                                color: const Color(
                                                                    0xffe1e5f8),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  ///item index number.
                                                                  SizedBox(
                                                                    width: 20,
                                                                    child: Text(
                                                                      '${index + 1}.',
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),

                                                                  ///item, qty, unit, total price.
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      ///item name
                                                                      Text(
                                                                        item.itemName!,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),

                                                                      //item mrp, qty , unit, total price

                                                                      Text(
                                                                        "৳ ${item.mrp!} x ${item.quantity!} ${controller.extractUnitName(item.unit ?? '')} = ${(int.tryParse(item.quantity!) ?? 0) * (double.tryParse(item.mrp!) ?? 0)}",
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ],
                                                                  ),

                                                                  ///remove button
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                                      hPad2,
                                                      InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                dialogContext) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    "Remove Item"),
                                                                content:
                                                                    const Text(
                                                                  "Are you sure you want to remove this item?",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          dialogContext); // Close the dialog
                                                                    },
                                                                    child: const Text(
                                                                        "Cancel"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      controller
                                                                          .removeCashItem(
                                                                              index); // Perform the removal action
                                                                      Navigator.pop(
                                                                          dialogContext); // Close the dialog
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            colorScheme.primary),
                                                                    child:
                                                                        const Text(
                                                                      "Remove",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                          child: const Icon(
                                                              Icons.remove,
                                                              color:
                                                                  Colors.green,
                                                              size: 18),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),
                                      controller.itemsCashReuturn.isEmpty
                                          ? const SizedBox()
                                          : vPad10,
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),

                        ////===> credit item list ///
                        controller.isCash == false
                            ? Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      controller.itemsCreditReturn.isEmpty
                                          ? const SizedBox.shrink()
                                          : Column(
                                              children: List.generate(
                                                  controller.itemsCreditReturn
                                                      .length, (index) {
                                                final item = controller
                                                    .itemsCreditReturn[index];
                                                debugPrint(
                                                    "item list cash=====>>> $item");
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: DecoratedBox(
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xffe1e5f8),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  ///item index number.
                                                                  SizedBox(
                                                                    width: 20,
                                                                    child: Text(
                                                                      '${index + 1}.',
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),

                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        // "${item.itemName!} ${item.category!}",
                                                                        item.itemName!,

                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),

                                                                      ///mrp, unit , qty, price

                                                                      Text(
                                                                        "৳ ${item.mrp!} x ${item.quantity!} pc  = ${(int.tryParse(item.quantity!) ?? 0) * (double.tryParse(item.mrp!) ?? 0)}",
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                                      hPad2,
                                                      InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                  dialogContext) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      "Remove Item"),
                                                                  content:
                                                                      const Text(
                                                                    "Are you sure you want to remove this item?",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            dialogContext); // Close the dialog
                                                                      },
                                                                      child: const Text(
                                                                          "Cancel"),
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        controller
                                                                            .removeCreditItem(index); // Perform the removal action
                                                                        Navigator.pop(
                                                                            dialogContext); // Close the dialog
                                                                      },
                                                                      style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              colorScheme.primary),
                                                                      child:
                                                                          const Text(
                                                                        "Remove",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child:
                                                              const CloseButtonIconNew())
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),
                                      controller.itemsCreditReturn.isEmpty
                                          ? const SizedBox()
                                          : vPad10,
                                      controller.itemsCreditReturn.isNotEmpty
                                          ? Container(
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
                                                      "Products",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                    InkWell(
                                                      onTap: () {},
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),

                        const SizedBox(
                          height: 2,
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
                                              color: Colors.grey.shade400,
                                              width: 1),
                                          bottom: BorderSide(
                                              color: Colors.grey.shade400,
                                              width: 1),
                                          left: BorderSide(
                                              color: Colors.grey.shade400,
                                              width: 1),
                                          right: BorderSide(
                                              color: Colors.grey.shade400,
                                              width: 1)),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Center(
                                      child: TextField(
                                        controller: controller
                                            .purchaseReturnNoteController,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                        onChanged: (value) {
                                          controller
                                              .purchaseReturnNoteController
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

                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: FieldPortion(),
                        ),

                        BottomPortionPurchaseReturn(
                          invoiceItems: invoiceItems,
                          saleType: controller.isCash ? "Cash" : "Credit",
                          customerId: controller.isCash
                              ? "cash"
                              : selectedCustomerId ?? "cash",
                        )

                        //bottom button portion
                      ],
                    ),
                  ),
                ),

                //BottomPortion(saleType: controller.isCash ? "Cash" : "Credit",),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

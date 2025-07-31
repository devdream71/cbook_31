import 'dart:convert';

import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/item_dropdown_custom.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/invoice/invoice.dart';
import 'package:cbook_dt/feature/invoice/invoice_a5.dart';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/purchase/purchase_setting.dart';
import 'package:cbook_dt/feature/sales/sales_view.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/custom_box.dart';
import 'package:cbook_dt/feature/suppliers/suppliers_create.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../common/give_information_dialog.dart';
import '../sales/widget/add_sales_formfield.dart';
import 'controller/purchase_controller.dart';
import 'package:http/http.dart' as http;
part 'layer/field_portion.dart';

class PurchaseView extends StatefulWidget {
  const PurchaseView({
    super.key,
  });

  @override
  PurchaseViewState createState() => PurchaseViewState();
}

class PurchaseViewState extends State<PurchaseView> {
  // TextEditingController for managing the text field content

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseController>();
    return const Layout();
  }
}

class Layout extends StatefulWidget {
  const Layout();

  @override
  State<Layout> createState() => LayoutState();
}

class LayoutState extends State<Layout> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController billController = TextEditingController();

  void _onCancel() {
    Navigator.pop(context);
  }

  String? selectedCustomer;
  int? selectedCategoryId;
  int? selectedSubCategoryId;

  Customer? selectedCustomerObject;

  String? selectedCustomerId;
  String? selectedCustomerDue;

  String? selectedItem;

  String? selectedItemNameInvoice;

  List<String> unitIdsList = [];

  List<double> amount = [];

  bool showNoteField = false;

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;


  @override
  void initState() {
    super.initState();

    // Initialize with loading text
  billController.text = "Loading...";
  print('Bill controller initialized with: ${billController.text}');


    Future.microtask(() async {
      ///fetch customer.
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr();

      ///fetch category.
      Provider.of<ItemCategoryProvider>(context, listen: false)
          .fetchCategories();

      ///fetch item.
      Provider.of<AddItemProvider>(context, listen: false).fetchItems();

      ///fetch stock quantity.
      Provider.of<AddItemProvider>(context, listen: false)
          .fetchPurchaseStockQuantity(
              "1"); // Pass a default itemId or handle it later

      ///fetch customer.
      Future.microtask(() =>
          Provider.of<CustomerProvider>(context, listen: false)
              .fetchCustomsr());

      ///fetch bill person.
      Future.microtask(() =>
          Provider.of<PaymentVoucherProvider>(context, listen: false)
              .fetchBillPersons());

      // await fetchAndSetBillNumber();

       print('About to fetch bill number...');
    await fetchAndSetBillNumber();
    print('Bill number fetch completed. Current value: ${billController.text}');

    });
  }


  // Updated fetchAndSetBillNumber with more debugging:
Future<void> fetchAndSetBillNumber() async {
  debugPrint('fetchAndSetBillNumber called');
  
  final url = Uri.parse(
    'https://commercebook.site/api/v1/app/setting/bill/number?voucher_type=purchase&type=purchase&code=PUR&bill_number=100&with_nick_name=1',
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
            billController.text = "PUR-102"; // Default fallback
            debugPrint('Set fallback bill: ${billController.text}');
          });
        }
      }
    } else {
      debugPrint('Failed to fetch bill number: ${response.statusCode}');
      // Set fallback bill number
      if (mounted) {
        setState(() {
          billController.text = "PUR-102";
          debugPrint('Set fallback bill due to status code: ${billController.text}');
        });
      }
    }
  } catch (e) {
    debugPrint('Error fetching bill number: $e');
    // Set fallback bill number
    if (mounted) {
      setState(() {
        billController.text = "PUR-102";
        debugPrint('Set fallback bill due to exception: ${billController.text}');
      });
    }
  }
}

// Your increment function looks correct, but here's a slightly improved version:
// String _incrementBillNumber(String bill) {
//   try {
//     print('_incrementBillNumber called with: $bill');
    
//     // Handle format like "PUR-101"
//     final parts = bill.trim().split('-');
//     print('Split parts: $parts');
    
//     if (parts.length == 2) {
//       final prefix = parts[0].trim(); // "PUR"
//       final numberPart = parts[1].trim();
//       final currentNumber = int.tryParse(numberPart) ?? 100;
//       final nextNumber = currentNumber + 1;
//       final result = '$prefix-$nextNumber';
      
//       print('Successfully incremented: $bill -> $result');
//       return result;
//     }
    
//     // Fallback: if format is unexpected, try to find and increment any number
//     print('Trying fallback regex method...');
//     final regex = RegExp(r'(\D*)(\d+)(.*)');
//     final match = regex.firstMatch(bill);
//     if (match != null) {
//       final prefix = match.group(1) ?? '';
//       final currentNumber = int.tryParse(match.group(2) ?? '100') ?? 100;
//       final suffix = match.group(3) ?? '';
//       final nextNumber = currentNumber + 1;
//       final result = '$prefix$nextNumber$suffix';
      
//       print('Fallback incremented: $bill -> $result');
//       return result;
//     }
//   } catch (e) {
//     print('Error in _incrementBillNumber: $e');
//   }
  
//   // Ultimate fallback
//   print('Using ultimate fallback: PUR-102');
//   return 'PUR-102';
// }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final controller = context.watch<PurchaseController>();
    final categoryProvider = Provider.of<ItemCategoryProvider>(context);

    //String? selectedItemNameInvoice;
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
            backgroundColor: AppColors.sfWhite,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              leading: InkWell(
                onTap: () {
                  Provider.of<CustomerProvider>(context, listen: false)
                      .clearSelectedCustomer();
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: colorScheme.surface,
                ),
              ),
              centerTitle: true,
              title: Text(
                "Purchase Invoice",
                style: GoogleFonts.lato(
                  color: Colors.yellow,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PurchaseSetting()));
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ))
              ],
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                    /// cash or credit
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            controller.updateCash();
                                          },
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    //context.watch<PurchaseController>().isCash ? "Cash" : "Credit",
                                                    controller.isCash
                                                        ? "Cash"
                                                        : "Credit",
                                                    style: GoogleFonts.lato(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                        const SizedBox(
                                          width: 8,
                                        ),
                                      ],
                                    ),
                                    vPad2,

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
                                          color: Colors.black, fontSize: 12),
                                    ),

                                    ///=> supplier cash and supplier or customer list in api ,
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 58,
                                          width: 180,
                                          // Adjusted height for cursor visibility
                                          child: controller.isCash
                                              ? InkWell(
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
                                                  child: const Text(
                                                    "Cash",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                )

                                              //: SizedBox.shrink(),

                                              : Column(
                                                  children: [
                                                    AddSalesFormfieldTwo(
                                                        controller: controller
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
                                                                  builder:
                                                                      (context) =>
                                                                          const SuppliersCreate()));
                                                        }),
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
                                                                            FontWeight.bold,
                                                                        color: customerProvider.selectedCustomer!.type ==
                                                                                'customer'
                                                                            ? Colors.green
                                                                            : Colors.red,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              2.0),
                                                                      child:
                                                                          Text(
                                                                        "৳ ${customerProvider.selectedCustomer!.due.toStringAsFixed(2)}",
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
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

                                        hPad3, // Space between TextField and Icon
                                      ],
                                    ),
                                    vPad5,

                                    /// need //// name controlller in cash
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
                                                      fontSize: 12)),
                                              Text("Phone: ${controller.phone}",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                  ],
                                ),
                              ),

                              ///bill no, bill date, bill person
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Bill No Field,, it should be auto. fill.
                                     
                                   

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

                                    ///bill date
                                    SizedBox(
                                      height: 30,
                                      width: 130,
                                      child: InkWell(
                                        onTap: () => controller.pickDate(
                                            context), // Trigger the date picker
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            isDense: true,
                                            suffixIcon: Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            suffixIconConstraints:
                                                const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ), // Adjust constraints to align icon closely
                                            hintText: "Bill Date",
                                            hintStyle: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 9,
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 0.5),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400),
                                            ),
                                          ),
                                          child: Text(
                                            controller.formattedDate.isNotEmpty
                                                ? controller.formattedDate
                                                : "Select Date", // Default text when no date is selected
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
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
                                            width: 130,
                                            child: provider.isLoading
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator())
                                                : CustomDropdownTwo(
                                                    hint: '',
                                                    items: provider
                                                        .billPersonNames,
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

                          const SizedBox(height: 5),

                          //vPad10,
                          controller.isCash
                              ? controller.itemsCash.isEmpty
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {});

                                        showSalesDialog(
                                          context,
                                          controller,
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
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
                                                "Add item & service",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {});
                                                  showSalesDialog(
                                                      context, controller);

                                                  setState(() {});
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
                                        setState(() {});

                                        showSalesDialog(
                                          context,
                                          controller,
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
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
                                                "Add item & service",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {});
                                                  showSalesDialog(
                                                      context, controller);

                                                  setState(() {});
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

                          vPad20,

                          ///==>cash
                          controller.isCash
                              ? SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      context
                                              .watch<PurchaseController>()
                                              .itemsCash
                                              .isEmpty
                                          ? const SizedBox.shrink()
                                          : InkWell(
                                              onTap: () {
                                                setState(() {
                                                  Provider.of<PurchaseController>(
                                                          context,
                                                          listen: false)
                                                      //.notifyListeners()
                                                      ;

                                                  setState(() {
                                                    controller.purchaseItem;
                                                  });
                                                });
                                              },
                                              child: Column(
                                                children: List.generate(
                                                    context
                                                        .watch<
                                                            PurchaseController>()
                                                        .itemsCash
                                                        .length, (index) {
                                                  final item = context
                                                      .watch<
                                                          PurchaseController>()
                                                      .itemsCash[index];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 3),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: () {
                                                              //setState(() {});

                                                              // showCashItemDetailsDialog(
                                                              //     context, item);

                                                              setState(() {
                                                                showCashItemDetailsDialog(
                                                                    context,
                                                                    item);

                                                                // setState(() {});
                                                              });

                                                              //setState(() {});
                                                            },
                                                            child: DecoratedBox(
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: const Color(
                                                                            0xfff4f6ff), //0xfff4f6ff
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          2),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center, // <--- Center vertically
                                                                          children: [
                                                                            Text(
                                                                              "${index + 1}. ",
                                                                              style: const TextStyle(
                                                                                overflow: TextOverflow.ellipsis,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Expanded(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    item.itemName!,
                                                                                    style: const TextStyle(
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 14,
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    //"৳ ${item.mrp!} x ${item.quantity!} ${item.unit} =  ${item.total} ",
                                                                                    "৳ ${item.mrp!} x ${item.quantity!} ${item.unit} = ৳ ${(double.parse(item.mrp!) * int.parse(item.quantity!)).toStringAsFixed(2)}",
                                                                                    style: const TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),

                                                                      ///close
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            controller.purchaseItem;
                                                                          });
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext dialogContext) {
                                                                              return AlertDialog(
                                                                                title: const Text("Remove Item"),
                                                                                content: const Text(
                                                                                  "Are you sure you want to remove this item?",
                                                                                  style: TextStyle(color: Colors.black),
                                                                                ),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(dialogContext); // Close the dialog
                                                                                    },
                                                                                    child: const Text("Cancel"),
                                                                                  ),
                                                                                  ElevatedButton(
                                                                                    onPressed: () {
                                                                                      controller.removeCashItem(index);
                                                                                      // Perform the removal action
                                                                                      Navigator.pop(dialogContext);
                                                                                      // Close the dialog
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
                                                                                    child: const Text(
                                                                                      "Remove",
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                          setState(
                                                                              () {
                                                                            controller.purchaseItem;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              20,
                                                                          height:
                                                                              20,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(color: Colors.grey.shade500, width: 1),
                                                                            borderRadius:
                                                                                BorderRadius.circular(30),
                                                                          ),
                                                                          child: const Icon(
                                                                              Icons.remove,
                                                                              color: Colors.green,
                                                                              size: 18),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )),
                                                          ),
                                                        ),
                                                        hPad2,
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),

                                      controller.itemsCash.isEmpty
                                          ? const SizedBox()
                                          : vPad10,

                                      ///if item not empry
                                      controller.itemsCash.isNotEmpty
                                          ? InkWell(
                                              onTap: () {
                                                showSalesDialog(
                                                    context, controller);
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
                                                      offset:
                                                          const Offset(0, 3),
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
                                                        "Add item & service",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {});

                                                          showSalesDialog(
                                                            context,
                                                            controller,
                                                          );
                                                          setState(() {
                                                            controller
                                                                .purchaseItem;
                                                          });

                                                          setState(() {});
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
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),

                          ////credit ====>
                          controller.isCash == false
                              ? Expanded(
                                  child: SingleChildScrollView(
                                    child: InkWell(
                                      onTap: () {
                                        controller.purchaseItem;
                                        setState(() {
                                          controller.purchaseItem;
                                        });
                                      },

                                      ///list show in credit item.
                                      child: Column(
                                        children: [
                                          controller.itemsCredit.isEmpty
                                              ? const SizedBox.shrink()
                                              : Column(
                                                  children: List.generate(
                                                      controller.itemsCredit
                                                          .length, (index) {
                                                    final item = controller
                                                        .itemsCredit[index];
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 3),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  showCashItemDetailsDialog(
                                                                      context,
                                                                      item);
                                                                });
                                                              },
                                                              child:
                                                                  DecoratedBox(
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xfff4f6ff),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          3),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center, // <--- Center vertically
                                                                          children: [
                                                                            Text(
                                                                              "${index + 1}. ",
                                                                              style: const TextStyle(
                                                                                overflow: TextOverflow.ellipsis,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Expanded(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    item.itemName!,
                                                                                    style: const TextStyle(
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 14,
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    "৳ ${item.mrp!} x ${item.quantity!} ${item.unit} = ৳ ${(double.parse(item.mrp!) * int.parse(item.quantity!)).toStringAsFixed(2)} ", //${item.total}
                                                                                    style: const TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext dialogContext) {
                                                                              return AlertDialog(
                                                                                title: const Text("Remove Item"),
                                                                                content: const Text(
                                                                                  "Are you sure you want to remove this item?",
                                                                                  style: TextStyle(color: Colors.black),
                                                                                ),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(dialogContext); // Close the dialog
                                                                                    },
                                                                                    child: const Text("Cancel"),
                                                                                  ),
                                                                                  ElevatedButton(
                                                                                    onPressed: () {
                                                                                      controller.removeCreditItem(index); // Perform the removal action

                                                                                      Navigator.pop(dialogContext);
                                                                                      // Close the dialog
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
                                                                                    child: const Text(
                                                                                      "Remove",
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child:
                                                                            const CircleAvatar(
                                                                          radius:
                                                                              12,
                                                                          backgroundColor:
                                                                              Colors.grey,
                                                                          child:
                                                                              Icon(
                                                                            Icons.close,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          hPad2,
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ),
                                          controller.itemsCredit.isEmpty
                                              ? const SizedBox()
                                              : vPad10,

                                          ///item not empty credit.
                                          controller.itemsCredit.isNotEmpty
                                              ? InkWell(
                                                  onTap: () {
                                                    showSalesDialog(
                                                        context, controller);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          colorScheme.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text(
                                                            "Add item & service",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {});
                                                              showSalesDialog(
                                                                  context,
                                                                  controller);
                                                              setState(() {});
                                                            },
                                                            child: const Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),

                          const Spacer(),
                          //FieldPortion(),

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
                                          controller: controller.noteController,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
                                          onChanged: (value) {
                                            controller.noteController.text =
                                                value;
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

                          ////Note

                          /// ===========>  amount , discount, total amount ====>
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:

                                //FieldPortion(),

                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                  // 1st Row: Amount //cash purchase
                                  controller.isCash && controller.isAmount
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Amount",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black)),
                                              hPad5,
                                              SizedBox(
                                                height: 30,
                                                width: 153,
                                                child: AddSalesFormfield(
                                                  controller:
                                                      TextEditingController(
                                                          text: controller
                                                              .addAmount2()),
                                                  decoration: InputDecoration(
                                                    hintText: "",
                                                    hintStyle: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade400),
                                                    // filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),

                                  // 2nd Row: Discount ///cash discount
                                  controller.isCash && controller.isDisocunt
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Discount",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black)),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                height: 30,
                                                width: 75,
                                                child: AddSalesFormfield(
                                                  labelText: "৳",
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller: controller
                                                      .discountController,
                                                  onChanged: (value) {
                                                    TextEditingController(
                                                        text: controller
                                                            .totalAmount);
                                                    controller
                                                        .discountController
                                                        .text = value;
                                                    controller
                                                        .updateDiscountcash(
                                                            value);
                                                  },
                                                ),
                                              ),
                                              hPad2,
                                              SizedBox(
                                                height: 30,
                                                width: 75,
                                                child: AddSalesFormfield(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  labelText: "%",
                                                  controller: controller
                                                      .discountAmountController,
                                                  onChanged: (value) {
                                                    controller
                                                        .updateDiscountPercentageCash(
                                                            value);
                                                    ;
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText: "%",
                                                    hintStyle: TextStyle(
                                                        color: Colors
                                                            .grey.shade400,
                                                        fontSize: 12),
                                                    // filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),

                                  // 3rd Row: Amount >>>>>>>> ======== its need next time
                                  controller.isCash && controller.isDisocunt
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Amount",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black)),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                height: 30,
                                                width: 150,
                                                child: AddSalesFormfield(
                                                  onChanged: (value) {
                                                    Provider.of(context)<
                                                        PurchaseController>();
                                                  },
                                                  controller:
                                                      TextEditingController(
                                                          text: controller
                                                              .totalAmount),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),

                                  //cash payment
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
                                                          controller
                                                                  .isReceived =
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
                                                const Text("Payment",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black)),
                                                const SizedBox(width: 5),
                                                SizedBox(
                                                  height: 30,
                                                  width: 150,
                                                  child: SizedBox(
                                                    height: 25,
                                                    width: 150,
                                                    child: AddSalesFormfield(
                                                      readOnly: true,
                                                      onChanged: (value) {
                                                        Provider.of(context)<
                                                            PurchaseController>();
                                                      },
                                                      controller:
                                                          TextEditingController(
                                                              text: controller
                                                                  .totalAmount),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      : const SizedBox.shrink(),

                                  //credit =============>
                                  // 1st Row: Amount ////====> credit =====>

                                  controller.isCash == false &&
                                          controller.isAmountCredit
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Amount",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black)),
                                              hPad5,
                                              SizedBox(
                                                height: 30,
                                                width: 153,
                                                child: AddSalesFormfield(
                                                  controller:
                                                      TextEditingController(
                                                          text: controller
                                                              .addAmount()),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),

                                  // 2nd Row: Discount
                                  controller.isCash == false &&
                                          controller.isDiscountCredit
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Discount",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black)),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                height: 30,
                                                width: 75,
                                                child: AddSalesFormfield(
                                                  labelText: "৳",
                                                  controller: controller
                                                      .discountController,
                                                  onChanged: (value) {
                                                    TextEditingController(
                                                        text: controller
                                                            .totalAmount2);
                                                    controller
                                                        .discountController
                                                        .text = value;
                                                    controller
                                                        .updateDiscountCredit(
                                                            value);
                                                  },
                                                ),
                                              ),
                                              hPad2,

                                              ///
                                              SizedBox(
                                                height: 30,
                                                width: 75,
                                                child: AddSalesFormfield(
                                                  onChanged: (value) {
                                                    controller
                                                        .updateDiscountPercentageCredit(
                                                            value);
                                                  },
                                                  controller: controller
                                                      .discountAmountController,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),

                                  // 3rd Row: Amount
                                  controller.isCash == false &&
                                          controller.isDiscountCredit
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Amount",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black)),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                height: 30,
                                                width: 150,
                                                child: AddSalesFormfield(
                                                  onChanged: (value) {
                                                    Provider.of(context)<
                                                        PurchaseController>();
                                                  },
                                                  controller:
                                                      //controller.amountCreditController2,
                                                      TextEditingController(
                                                          text: controller
                                                              .totalAmount2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),

                                  /////====>credit payment
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
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
                                                    controller: controller
                                                        .receivedAmountController,

                                                    readOnly: controller
                                                        .isOnlineMoneyChecked, // ✅ Read-only when checked

                                                    keyboardType:
                                                        TextInputType.number,
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
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ]),
                          ),

                          //bottom button portion
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //const BottomPortion(),
                  ///////=====>view A4, view A5, save and view , save.

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        hPad5,

                        ///=====>view A4
                        InkWell(
                          onTap: () {
                            if (controller.purchaseItem.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 1),
                                  content: Text("No Item added"),
                                ),
                              );
                            } else {
                              debugPrint(
                                  "return item length ${controller.purchaseItem.length}");
                              List<InvoiceItem> invoiceItems =
                                  (controller.isCash
                                          ? controller.itemsCash
                                          : controller.itemsCredit)
                                      .map((item) {
                                return InvoiceItem(
                                  itemName: item.itemName ?? "",
                                  unit: item.unit ?? "PC",
                                  quantity:
                                      int.tryParse(item.quantity ?? "0") ?? 0,
                                  amount: (int.tryParse(item.quantity ?? "0") ??
                                          0) *
                                      (double.tryParse(item.mrp ?? "0") ?? 0.0),
                                  discount: double.tryParse(
                                          controller.discountController.text) ??
                                      0.0,
                                );
                              }).toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InvoiceScreen(items: invoiceItems),
                                ),
                              );
                            }
                          },
                          child: const CustomBox(
                            color: Colors.white,
                            textColor: Colors.black,
                            text: "View A4",
                          ),
                        ),

                        hPad5,
                        // InkWell(
                        //   onTap: () {
                        //     //===>View A5 navigation.

                        //     if (controller.purchaseItem.isEmpty) {
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(
                        //           backgroundColor: Colors.red,
                        //           duration: Duration(seconds: 1),
                        //           content: Text("No Item added"),
                        //         ),
                        //       );
                        //     } else {
                        //       List<InvoiceItem> invoiceItems =
                        //           (controller.isCash
                        //                   ? controller.itemsCash
                        //                   : controller.itemsCredit)
                        //               .map((item) {
                        //         return InvoiceItem(
                        //           itemName: item.itemName ?? "",
                        //           unit: item.unit ?? "PC",
                        //           quantity:
                        //               int.tryParse(item.quantity ?? "0") ?? 0,
                        //           amount: (int.tryParse(item.quantity ?? "0") ??
                        //                   0) *
                        //               (double.tryParse(item.mrp ?? "0") ?? 0.0),
                        //           discount: double.tryParse(
                        //                   controller.discountController.text) ??
                        //               0.0,
                        //         );
                        //       }).toList();

                        //       debugPrint("item name   ");

                        //       Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) =>
                        //                   InvoiceA5(items: invoiceItems)));
                        //     }
                        //   },
                        //   child: const CustomBox(
                        //     color: Colors.white,
                        //     textColor: Colors.black,
                        //     text: "View A5",
                        //   ),
                        // ),
                        hPad5,
                        // InkWell(
                        //   onTap: () {
                        //     //Navigator.push(context, MaterialPageRoute(builder: (context)=>const InvoiceScreen()));
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       const SnackBar(
                        //         backgroundColor: Colors.red,
                        //         duration: Duration(seconds: 1),
                        //         content: Text("N0 fuction called"),
                        //       ),
                        //     );
                        //   },
                        //   child: const CustomBox(
                        //     color: Colors.white,
                        //     textColor: Colors.black,
                        //     text: "Save & View",
                        //   ),
                        // ),
                        hPad5,
                        InkWell(
                          onTap: () async {
                            var date = controller.formattedDate;

                            String amount = controller.isCash
                                ? controller.addAmount2()
                                : controller.addAmount();

                            String discount =
                                controller.discountController.text;
                            debugPrint("discount  =====> $discount");

                            String total = controller.isCash
                                ? controller.totalAmount
                                : controller.totalAmount2;

                            String? payment =
                                controller.receivedAmountController.text;

                            debugPrint("amount =========>>>>====> $amount");

                            debugPrint(
                                "selectedBillPersonData!.id =========>>>>====> $selectedBillPersonData!.id");

                            debugPrint(
                                "note  =========>>>>====> ${controller.noteController.text}");

                            if (controller.purchaseItem.isEmpty ||
                                billController.text.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  'No Item Added or no bill number.',
                                ),
                                backgroundColor: Colors.red,
                              ));
                            } else {
                              bool isSuccess = await controller.storePurchase(
                                context,
                                date: date,
                                amount: amount,
                                customerId: controller.isCash
                                    ? "cash"
                                    : Provider.of<CustomerProvider>(context,
                                                listen: false)
                                            .selectedCustomer
                                            ?.id
                                            .toString() ??
                                        "cash",
                                saleType: controller.isCash ? "cash" : "credit",
                                discount: discount,
                                note: controller.noteController.text,
                                billNo: billController.text,
                                total: total,
                                paymnetAmount: payment,
                                billPersonId: selectedBillPersonData!.id,
                              );

                              if (isSuccess) {
                                // Clear all controllers and purchase items

                                controller.clearPurchaseForm();

                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 1),
                                    content:
                                        Text("Purchase Create Successfully."),
                                  ),
                                );

                                Navigator.pushReplacement(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeView()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 1),
                                    content: Text("Not uloaded"),
                                  ),
                                );
                              }
                            }

                            debugPrint("customer it $selectedCustomerId");
                          },
                          child: CustomBox(
                            color: AppColors.primaryColor,
                            textColor: Colors.white,
                            text: "Save",
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///purchase item add in list.
  void showSalesDialog(
      BuildContext context, PurchaseController controller) async {
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

    // ✅ Fetch categories
    // if (categoryProvider.categories.isEmpty) {
    //   await categoryProvider.fetchCategories();
    // }

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

                                ////====>category working.
                                // Column(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   crossAxisAlignment:
                                //       CrossAxisAlignment.start,
                                //   children: [
                                //     const Text(
                                //       "Category",
                                //       style: TextStyle(
                                //           color: Colors.black, fontSize: 14),
                                //     ),
                                //     SizedBox(
                                //       height: 30,
                                //       width: 150,
                                //       child: CustomDropdownTwo(
                                //         hint: '', //Category
                                //         items: categoryProvider.categories
                                //             .map((category) => category.name)
                                //             .toList(),
                                //         width: double.infinity,
                                //         height: 30,
                                //         onChanged: (value) async {
                                //           final selectedCategory =
                                //               categoryProvider.categories
                                //                   .firstWhere((cat) =>
                                //                       cat.name == value);
                                //           setState(() {
                                //             selectedCategoryId =
                                //                 selectedCategory.id
                                //                     .toString();
                                //             selectedSubCategoryId = null;
                                //           });

                                //           debugPrint(
                                //               "selected category id $selectedCategoryId");

                                //           await categoryProvider
                                //               .fetchSubCategories(
                                //                   selectedCategory.id);
                                //           setState(() {});
                                //         },
                                //         selectedItem:
                                //             selectedCategoryId != null
                                //                 ? categoryProvider.categories
                                //                     .firstWhere(
                                //                       (cat) =>
                                //                           cat.id.toString() ==
                                //                           selectedCategoryId,
                                //                       orElse: () =>
                                //                           categoryProvider
                                //                               .categories
                                //                               .first,
                                //                     )
                                //                     .name
                                //                 : null,
                                //       ),
                                //     ),
                                //   ],
                                // ),

                                SizedBox(width: 10),

                                /////===>sub category working.
                                // Column(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   crossAxisAlignment:
                                //       CrossAxisAlignment.start,
                                //   children: [
                                //     categoryProvider.isSubCategoryLoading
                                //         ? const SizedBox()
                                //         : categoryProvider
                                //                 .subCategories.isNotEmpty
                                //             ? Column(
                                //                 mainAxisAlignment:
                                //                     MainAxisAlignment.start,
                                //                 crossAxisAlignment:
                                //                     CrossAxisAlignment.start,
                                //                 children: [
                                //                   const Text(
                                //                     "Sub category", //Sub category
                                //                     style: TextStyle(
                                //                         color: Colors.black,
                                //                         fontSize: 14),
                                //                   ),
                                //                   CustomDropdownTwo(
                                //                     hint:
                                //                         '', //Sel Sub Category
                                //                     items: categoryProvider
                                //                         .subCategories
                                //                         .map((subCategory) =>
                                //                             subCategory.name)
                                //                         .toList(),
                                //                     width: 150,
                                //                     height: 30,
                                //                     onChanged: (value) {
                                //                       final selectedSubCategory =
                                //                           categoryProvider
                                //                               .subCategories
                                //                               .firstWhere(
                                //                                   (subCat) =>
                                //                                       subCat
                                //                                           .name ==
                                //                                       value);
                                //                       setState(() {
                                //                         selectedSubCategoryId =
                                //                             selectedSubCategory
                                //                                 .id
                                //                                 .toString();
                                //                       });

                                //                       debugPrint(
                                //                           "selected sub category id $selectedSubCategoryId");
                                //                     },
                                //                     selectedItem:
                                //                         selectedSubCategoryId !=
                                //                                 null
                                //                             ? categoryProvider
                                //                                 .subCategories
                                //                                 .firstWhere(
                                //                                   (sub) =>
                                //                                       sub.id
                                //                                           .toString() ==
                                //                                       selectedSubCategoryId,
                                //                                   orElse: () =>
                                //                                       categoryProvider
                                //                                           .subCategories
                                //                                           .first,
                                //                                 )
                                //                                 .name
                                //                             : null,
                                //                   ),
                                //                 ],
                                //               )
                                //             : const Align(
                                //                 alignment: Alignment.topLeft,
                                //                 child: Text(
                                //                   "", // "No subcategories available"

                                //                   style: TextStyle(
                                //                       color: Colors.black,
                                //                       fontSize: 12),
                                //                 ),
                                //               ),
                                //   ],
                                // ),
                              ],
                            ),

                            SizedBox(height: 5),
                          ]),

                          ///new item working for base and secondary unit.
                          ItemCustomDropDownTextField(
                            controller: itemController,
                            onItemSelected: (selectedItem) async {
                              debugPrint(
                                  "Selected Item: ${selectedItem.name} (ID: ${selectedItem.id})");

                              unitIdsList.clear();

                              // ✅ Set purchase price first
                              controller.purchasePrice =
                                  selectedItem.purchasePrice is int
                                      ? (selectedItem.purchasePrice as int)
                                          .toDouble()
                                      : (selectedItem.purchasePrice ?? 0.0);

                              // ✅ Set unit quantity (default to 1 if null)
                              controller.unitQty = selectedItem.unitQty ?? 1;

                              // ✅ Set the price initially to purchase price
                              controller.mrpController.text =
                                  controller.purchasePrice.toStringAsFixed(2);

                              setState(() {
                                controller.seletedItemName = selectedItem.name;
                                controller.selcetedItemId =
                                    selectedItem.id.toString();

                                // fetch stock quantity
                                if (controller.selcetedItemId != null) {
                                  fetchStockQuantity.fetchStockQuantity(
                                      controller.selcetedItemId!);
                                }
                              });

                              // Ensure unitProvider is loaded
                              if (unitProvider.units.isEmpty) {
                                await unitProvider.fetchUnits();
                              }

                              /// ⛔️ Clear units
                              unitIdsList.clear();

                              // ===> Primary unit
                              if (selectedItem.unitId != null) {
                                final unit = unitProvider.units.firstWhere(
                                  (unit) =>
                                      unit.id.toString() ==
                                      selectedItem.unitId.toString(),
                                  orElse: () => Unit(
                                      id: 0,
                                      name: 'Unknown',
                                      symbol: '',
                                      status: 0),
                                );
                                if (unit.id != 0) {
                                  unitIdsList.add(unit.name);
                                  controller.primaryUnitName = unit.name;
                                  controller.selectedUnit = unit.name;

                                  controller.selectedUnitIdWithNameFunction(
                                      "${unit.id}_${unit.name}");
                                }
                              }

                              // ===> Secondary unit
                              if (selectedItem.secondaryUnitId != null) {
                                final secondaryUnit =
                                    unitProvider.units.firstWhere(
                                  (unit) =>
                                      unit.id.toString() ==
                                      selectedItem.secondaryUnitId.toString(),
                                  orElse: () => Unit(
                                      id: 0,
                                      name: 'Unknown',
                                      symbol: '',
                                      status: 0),
                                );
                                if (secondaryUnit.id != 0) {
                                  unitIdsList.add(secondaryUnit.name);
                                  controller.secondaryUnitName =
                                      secondaryUnit.name;
                                }
                              }

                              debugPrint("Units Available: $unitIdsList");
                              debugPrint(
                                  "purchase price ===> ${controller.purchasePrice}");
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

                              /// new updated code working, for base and secondary unit.
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 150,
                                    child: CustomDropdownTwo(
                                      labelText: "Unit",
                                      hint: '',
                                      items: unitIdsList,
                                      width: 150,
                                      height: 30,
                                      selectedItem: unitIdsList.isNotEmpty
                                          ? unitIdsList.first
                                          : null,
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

                                        // ✅ Price update logic
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
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          ///price
                          AddSalesFormfield(
                            labelText: "Price",
                            label: "",
                            controller: controller.mrpController,

                            ///.!purchase price
                            keyboardType: TextInputType.number,
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
                            const Text("Subtotal: ",
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
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Align(
                        //     alignment: Alignment.bottomRight,
                        //     child: InkWell(
                        //       onTap: () async {
                        //         debugPrint("🟢 Add Item button tapped");
                        //         debugPrint(
                        //             "🔹 Selected Unit: ${controller.selectedUnit}");
                        //         debugPrint(
                        //             "🔹 Selected Unit: ${controller.selectedUnit}");
                        //         debugPrint(
                        //             "🔹 Full Selected Unit Info: ${controller.selectedUnitIdWithName}");

                        //         debugPrint("Add Item");
                        //         debugPrint("selectedItem ============|>");

                        //         debugPrint(selectedItem);

                        //         debugPrint(
                        //           'Selected Unit: ${controller.selectedUnit ?? "None"}',
                        //         );

                        //         // controller.isCash
                        //         //     ? controller.addCashItem()
                        //         //     : controller.addCreditItem();
                        //         // controller.addAmount();

                        //         if (controller.qtyController.text.isEmpty ||
                        //             controller.mrpController.text.isEmpty) {
                        //           ScaffoldMessenger.of(context)
                        //               .showSnackBar(const SnackBar(
                        //             content: Text(
                        //               'Please enter the qty & price',
                        //             ),
                        //             backgroundColor: Colors.red,
                        //           ));
                        //         } else {
                        //           setState(() {
                        //             controller.isCash
                        //                 ? controller.addCashItem()
                        //                 : controller.addCreditItem();

                        //             controller.addAmount();

                        //             Navigator.pop(context);
                        //           });
                        //         }

                        //         setState(() {
                        //           Provider.of<PurchaseController>(context,
                        //                   listen: false)
                        //               .notifyListeners();
                        //         });

                        //         ////clear item n ame
                        //         setState(() {
                        //           controller.seletedItemName = null;

                        //           // ✅ Clear selected category & subcategory
                        //           selectedCategoryId = null;
                        //           selectedSubCategoryId = null;

                        //           // ✅ (Optional) Clear subcategories
                        //           Provider.of<ItemCategoryProvider>(context,
                        //                   listen: false)
                        //               .subCategories = [];
                        //         });

                        //         // ✅ Clear stock info
                        //         Provider.of<AddItemProvider>(context,
                        //                 listen: false)
                        //             .clearPurchaseStockData();

                        //         controller.mrpController.clear();
                        //         controller.qtyController.clear();
                        //       },
                        //       child: SizedBox(
                        //         width: 90,
                        //         child: DecoratedBox(
                        //           decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(5),
                        //             color: colorScheme.primary,
                        //           ),
                        //           child: const Padding(
                        //             padding: EdgeInsets.symmetric(
                        //                 horizontal: 6.0, vertical: 2),
                        //             child: Center(
                        //               child: Text(
                        //                 "Add & new",
                        //                 style: TextStyle(
                        //                     color: Colors.white, fontSize: 14),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),

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

                                debugPrint(selectedItem);

                                debugPrint(
                                  'Selected Unit: ${controller.selectedUnit ?? "None"}',
                                );

                                // controller.isCash
                                //     ? controller.addCashItem()
                                //     : controller.addCreditItem();
                                // controller.addAmount();

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

                                ////clear item n ame
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

  ///purchase item edit.  Purchase item edit <<<======
  Future<void> showCashItemDetailsDialog(
    BuildContext context,
    ItemModel selectedItem,
  ) async {
    // String? selectedTaxName;
    // String? selectedTaxId;

    final priceController = TextEditingController(text: "${selectedItem.mrp}");
    final qtyController =
        TextEditingController(text: "${selectedItem.quantity}");

    // final totalController =
    //     TextEditingController(text: "${selectedItem.total}");

    final addItemProvider =
        Provider.of<AddItemProvider>(context, listen: false);

    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);

    final unitProvider = Provider.of<UnitProvider>(context, listen: false);

    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    final controller = Provider.of<PurchaseController>(context, listen: false);

    TextEditingController totalController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          void updateTotal() {
            final price = double.tryParse(priceController.text) ?? 0.0;
            final qty = double.tryParse(qtyController.text) ?? 0.0;
            final total = price * qty;
            totalController.text = total.toStringAsFixed(2);
          }

          final price = double.tryParse(priceController.text) ?? 0.0;
          final qty = double.tryParse(qtyController.text) ?? 0.0;
          final purchaseTotal = price * qty;
          totalController.text = purchaseTotal.toStringAsFixed(2);

          return AlertDialog(
            title: const Text("Item List Edit"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔽 Item Dropdown

                  Row(
                    children: [
                      //item ===
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Item",
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(
                            height: 30,
                            width: 135,
                            child: Consumer<AddItemProvider>(
                              builder: (context, itemProvider, child) {
                                if (itemProvider.isLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (itemProvider.items.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No items available.',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: CustomDropdownTwo(
                                    hint: '', // Choose an item
                                    items: itemProvider.items
                                        .map((item) => item.name)
                                        .toList(),
                                    width: 135,
                                    height: 30,

                                    selectedItem: selectedItem.itemName,
                                    onChanged: (selectedItemName) async {
                                      setState(() {
                                        controller.seletedItemName =
                                            selectedItemName; // Update controller's selectedItemName
                                        itemProvider.items.forEach((e) {
                                          if (selectedItemName == e.name) {
                                            controller.selcetedItemId =
                                                e.id.toString();
                                          }
                                        });

                                        // Fetch stock quantity based on selected item
                                        if (controller.selcetedItemId != null) {
                                          fetchStockQuantity.fetchStockQuantity(
                                              controller.selcetedItemId!);
                                        }
                                      });

                                      // Find the selected item
                                      final selected =
                                          itemProvider.items.firstWhere(
                                        (item) => item.name == selectedItemName,
                                        orElse: () => itemProvider.items.first,
                                      );

                                      // Ensure unitProvider is loaded
                                      if (unitProvider.units.isEmpty) {
                                        await unitProvider
                                            .fetchUnits(); // Ensure units are fetched
                                      }

                                      // Update unit dropdown list based on selected item
                                      unitIdsList.clear();

                                      // Debugging: Print unitId and secondaryUnitId for comparison
                                      debugPrint(
                                          "Selected item unitId: ${selected.unitId}");
                                      debugPrint(
                                          "Selected item secondaryUnitId: ${selected.secondaryUnitId}");

                                      // Update the unitIdsList population logic to handle null values properly

                                      // Clear previous units
                                      unitIdsList.clear();

                                      // Base unit
                                      if (selected.unitId != null &&
                                          selected.unitId != '') {
                                        final unit =
                                            unitProvider.units.firstWhere(
                                          (unit) =>
                                              unit.id.toString() ==
                                              selected.unitId.toString(),
                                          orElse: () => Unit(
                                              id: 0,
                                              name: 'Unknown Unit',
                                              symbol: '',
                                              status: 0),
                                        );
                                        if (unit.id != 0) {
                                          unitIdsList.add(unit
                                              .name); // ✅ Use full name (e.g., Pces)
                                          controller.selectedUnit = unit.name;

                                          // Create the final unit string for the selected unit
                                          String finalUnitString =
                                              "${unit.id}_${unit.name}"; // Default to qty=1 //_1 //"${unit.id}_${unit.name}_1";
                                          controller
                                              .selectedUnitIdWithNameFunction(
                                                  finalUnitString);
                                        }
                                      }

                                      // Secondary unit
                                      if (selected.secondaryUnitId != null &&
                                          selected.secondaryUnitId != '') {
                                        final secondaryUnit =
                                            unitProvider.units.firstWhere(
                                          (unit) =>
                                              unit.id.toString() ==
                                              selected.secondaryUnitId
                                                  .toString(),
                                          orElse: () => Unit(
                                              id: 0,
                                              name: 'Unknown Unit',
                                              symbol: '',
                                              status: 0),
                                        );
                                        if (secondaryUnit.id != 0) {
                                          unitIdsList.add(secondaryUnit
                                              .name); // ✅ Use full name
                                        }
                                      }

                                      if (unitIdsList.isEmpty) {
                                        debugPrint(
                                            "No valid units found for this item.");
                                      } else {
                                        debugPrint(
                                            "Units Available: $unitIdsList"); // Check both units are added
                                      }

                                      // ✅ Now trigger UI update
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      ////===UNit
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Unit:",
                              style: TextStyle(color: Colors.black)),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: SizedBox(
                              width: 135,
                              child: CustomDropdownTwo(
                                hint: '',
                                items:
                                    unitIdsList, // Holds unit names like ["Pces", "Packet"]
                                width: 135,
                                height: 30,
                                selectedItem: selectedItem.unit,
                                onChanged: (selectedUnit) {
                                  debugPrint("Selected Unit: $selectedUnit");

                                  // Update the selected unit in controller
                                  controller.selectedUnit = selectedUnit;

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
                                  int qty = 1; // Default qty

                                  // Search through fetchStockQuantity items to find unit ID and qty
                                  for (var item in fetchStockQuantity.items) {
                                    if (item.id.toString() ==
                                        controller.selcetedItemId) {
                                      String unitId =
                                          selectedUnitObj.id.toString();
                                      String unitName = selectedUnit;

                                      // Check if selected unit is the primary or secondary unit and set the correct quantity
                                      if (unitId ==
                                          item.secondaryUnitId.toString()) {
                                        qty = item.secondaryUnitQty ??
                                            item.unitQty ??
                                            1; // Use secondaryUnitQty, fallback to unitQty or default to 1
                                      } else if (unitId ==
                                          item.unitId.toString()) {
                                        qty = item.unitQty ??
                                            1; // Use unitQty or fallback to 1
                                      }

                                      // Build the final unit string in the required format (e.g., 24_Pces_1)
                                      finalUnitString =
                                          "${unitId}_${unitName}_$qty";
                                      controller.selectedUnitIdWithNameFunction(
                                          finalUnitString);
                                      break;
                                    }
                                  }

                                  // Fallback if no valid unit string was found
                                  if (finalUnitString.isEmpty) {
                                    finalUnitString =
                                        "${selectedUnitObj.id}_${selectedUnit}"; // Default to 1 if no match //"${selectedUnitObj.id}_${selectedUnit}_1";
                                    controller.selectedUnitIdWithNameFunction(
                                        finalUnitString);
                                  }

                                  // Debug print to show final unit ID selected
                                  debugPrint(
                                      "🆔 Final Unit ID: $finalUnitString");

                                  // Notify listeners to update the UI
                                  controller.notifyListeners();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  //stock
                  Consumer<AddItemProvider>(
                    builder: (context, stockProvider, child) {
                      //controller.mrpController.text = stockProvider.stockData!.price.toString();
                      if (stockProvider.stockData != null) {
                        controller.mrpController.text =
                            stockProvider.stockData!.price.toString();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "   Stock Available:  ${stockProvider.stockData!.unitStocks} ৳ ${stockProvider.stockData!.price} ",
                              //"   Stock Available: ${stockProvider.stockData!.stocks} (${stockProvider.stockData!.unitStocks}) ৳ ${stockProvider.stockData!.price} ",

                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "   ", // Updated message for empty stock
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  //price //qty
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ///price
                      Expanded(
                        child: SizedBox(
                          // width: 100,
                          child: AddSalesFormfield(
                            label: "Price",
                            controller: priceController,
                            onChanged: (value) {
                              selectedItem.mrp = value;

                              // Optionally recalculate total
                              final price = double.tryParse(value) ?? 0.0;
                              //final qty = double.tryParse(selectedItem.quantity) ?? 0.0;

                              selectedItem.mrp = value;
                              updateTotal(); // 🔁 Calculate and update total
                              setState(() {});

                              addItemProvider.notifyListeners();

                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),

                      ///qty
                      Expanded(
                        child: SizedBox(
                          //width: 100,
                          child: AddSalesFormfield(
                            label: 'QTY',
                            controller: qtyController,
                            onChanged: (value) {
                              selectedItem.quantity = value;
                              updateTotal(); // 🔁 Calculate and update total
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  //trotal
                  AddSalesFormfield(
                    label: "Total",
                    controller: totalController,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  final updatedPrice =
                      double.tryParse(priceController.text) ?? 0.0;
                  final updatedQty = double.tryParse(qtyController.text) ?? 0.0;

                  final updatedTotal = ((updatedPrice * updatedQty));

                  final updatedItem = ItemModel(
                    category: selectedItem.category,
                    subCategory: selectedItem.subCategory,
                    itemName: selectedItem.itemName,
                    itemCode: selectedItem.itemCode,
                    mrp: priceController.text,
                    quantity: qtyController.text,
                    price: priceController.text,
                    unit: selectedItem.unit,
                    total: updatedTotal.toStringAsFixed(2),
                  );

                  setState(() {
                    final index = controller.itemsCash.indexOf(selectedItem);

                    if (index != -1) {
                      controller.itemsCash[index] = updatedItem;
                    }

                    debugPrint(
                        '===========>> item list: [${controller.itemsCash.map((e) => e.toString()).join(', ')}]');

                    // for (var item in controller.itemsCash) {
                    //   debugPrint("Item: ${item.toString()}");
                    // }
                  });

                  //addItemProvider.notifyListeners();

                  Navigator.pop(context);
                },
                child: const Text("Update"),
              )
            ],
          );
        });
      },
    );
  }
}

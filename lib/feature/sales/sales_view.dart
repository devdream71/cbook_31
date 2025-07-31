import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/item_dropdown_custom.dart';
import 'package:cbook_dt/feature/customer_create/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/settings/ui/bill_invoice_create_form.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../common/give_information_dialog.dart';
import '../../common/input_field.dart';
import '../../utils/custom_padding.dart';
import 'controller/sales_controller.dart';
import 'widget/add_sales_formfield.dart';
import 'layer/bttom_portion.dart';
import 'package:http/http.dart' as http;
part 'layer/field_portion.dart';
part 'layer/give_information.dart';

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  SalesViewState createState() => SalesViewState();
}

class SalesViewState extends State<SalesView> {
  // TextEditingController for managing the text field content

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalesController(),
      builder: (context, child) => const _Layout(),
    );
  }
}

class _Layout extends StatefulWidget {
  const _Layout();

  @override
  State<_Layout> createState() => _LayoutState();
}

class _LayoutState extends State<_Layout> {

  TextEditingController customerNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController billController = TextEditingController();

  String? selectedItem;

  Customer? selectedCustomerObject;

  int? selectedSubCategoryId;

  String? selectedCustomer;
  String? selectedCustomerId;

  String? selectedItemNameInvoice;

  List<String> unitIdsList = [];

  List<double> amount = [];

  bool showNoteField = false;

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  late TextEditingController customerController;



  @override
  void initState()   {
    super.initState();
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    Future.microtask(() =>
        Provider.of<ItemCategoryProvider>(context, listen: false)
            .fetchCategories());

    Provider.of<AddItemProvider>(context, listen: false).fetchItems();

    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons()
            );

      Future.microtask(() async { 

         await fetchAndSetBillNumber(); 


      });         

    customerController = TextEditingController();
  }


   Future<void> fetchAndSetBillNumber() async {
  debugPrint('fetchAndSetBillNumber called');
  
  final url = Uri.parse(
    'https://commercebook.site/api/v1/app/setting/bill/number?voucher_type=purchase&type=sales&code=SAL&bill_number=100&with_nick_name=1',
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
            billController.text = "SAL-100"; // Default fallback
            debugPrint('Set fallback bill: ${billController.text}');
          });
        }
      }
    } else {
      debugPrint('Failed to fetch bill number: ${response.statusCode}');
      // Set fallback bill number
      if (mounted) {
        setState(() {
          billController.text = "SAL-100";
          debugPrint('Set fallback bill due to status code: ${billController.text}');
        });
      }
    }
  } catch (e) {
    debugPrint('Error fetching bill number: $e');
    // Set fallback bill number
    if (mounted) {
      setState(() {
        billController.text = "SAL-100";
        debugPrint('Set fallback bill due to exception: ${billController.text}');
      });
    }
  }
}




  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.watch<SalesController>();

    // ✅ Define invoiceItems before using it in BottomPortion
    List<InvoiceItem> invoiceItems = controller.itemsCash.map((item) {
      return InvoiceItem(
        itemName: item.itemName ?? "",
        unit: "N/A", // You might need to update this logic
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
           resizeToAvoidBottomInset: true, //keybord hold up the content.
            backgroundColor: AppColors.sfWhite,

            ///app bar
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
                "Bill/ Invoice",
                style: GoogleFonts.lato(
                  color: Colors
                      .yellow, //style: TextStyle(color: Colors.yellow, fontSize: 16)
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
                              builder: (context) =>
                                  const BillInvoiceCreateForm()));
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ///   ====> cash / credit button
                                            InkWell(
                                              onTap: () {
                                                controller.updateCash(context);

                                                Provider.of<CustomerProvider>(
                                                        context,
                                                        listen: false)
                                                    .clearSelectedCustomer();
                                              },
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
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

                                            ///bill to text
                                            const Text(
                                              "Bill To",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    ///!.customer text
                                    const Text(
                                      "Customer",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 13),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 58,
                                          width: 180,
                                          // Adjusted height for cursor visibility

                                          ///!.cash name, phone, email, address. diolog.
                                          ///!. credit customer name dropdown.
                                          child: controller.isCash
                                              ?

                                              ///cash, cash sale customer name, phone, email, address
                                              InkWell(
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
                                                      color: Colors.blue,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ))
                                              :

                                              ///cutomer name show ---- credit.
                                              Column(
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
                                                                builder:
                                                                    (context) =>
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
                                      ],
                                    ),
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
                                              Text("Email: ${controller.email}",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                              Text(
                                                  "Address: ${controller.address}",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),

                              ///bill no, bill person, date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ///bill no,
                                    // SizedBox(
                                    //   height: 30,
                                    //   width: 130,
                                    //   child: AddSalesFormfield(
                                    //     controller: controller.billController,
                                    //     labelText: "Bill NO",
                                    //     // Match cursor height to text size
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
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.green),
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

                                    //bill person
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

                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          vPad10,

                          ///cash item list.
                          ///! add item and service section, and item show
                          controller.isCash
                              ? controller.itemsCash.isEmpty
                                  ? InkWell(
                                      onTap: () {
                                        //setState(() {});
                                        showSalesDialog(context, controller);
                                        //setState(() {});
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
                                                  // setState(() {});
                                                  showSalesDialog(
                                                      context, controller);
                                                  //setState(() {});
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
                              :

                              ///credit item list.
                              controller.itemsCredit.isEmpty
                                  ? InkWell(
                                      onTap: () {
                                        //setState(() {});
                                        showSalesDialog(context, controller);
                                        //setState(() {});
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
                                                  // setState(() {});
                                                  showSalesDialog(
                                                      context, controller);
                                                  // setState(() {});
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

                          /// cash product =====
                          controller.isCash
                              ? Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        controller.itemsCash.isEmpty
                                            ? const SizedBox.shrink()
                                            : Column(
                                                children: List.generate(
                                                    controller.itemsCash.length,
                                                    (index) {
                                                  final item = controller
                                                      .itemsCash[index];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 3),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                            ///cash item list edit.
                                                            onTap: () {
                                                              //setState(() {});

                                                              showCashItemDetailsDialog(
                                                                  context,
                                                                  item);

                                                              //showSalesDialog(context, controller);
                                                              //setState(() {});
                                                            },
                                                            child:
                                                                //cash item
                                                                //cash => list show, index, itam name, unit, qty, and total price
                                                                SizedBox(
                                                              height: 50,
                                                              child:
                                                                  DecoratedBox(
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: const Color(
                                                                            0xfff4f6ff), //f4f6ff

                                                                        ///f4f6ff, dddefa
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          2,
                                                                      vertical:
                                                                          2),
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center, // <--- Center vertically
                                                                      children: [
                                                                        /// Left Side: Index + Item Info
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center, // <--- Center vertically
                                                                            children: [
                                                                              ///index number
                                                                              Text(
                                                                                "${index + 1}.",
                                                                                style: const TextStyle(
                                                                                  //overflow: TextOverflow.ellipsis,
                                                                                  color: Colors.black,
                                                                                  //fontWeight: FontWeight.w200,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 5),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      height: 4,
                                                                                    ),

                                                                                    ///item name
                                                                                    Text(
                                                                                      item.itemName!,
                                                                                      style: const TextStyle(
                                                                                        //overflow: TextOverflow.ellipsis,
                                                                                        color: Colors.black,
                                                                                        //fontWeight: FontWeight.w600,
                                                                                        fontSize: 13,
                                                                                      ),
                                                                                    ),

                                                                                    ///cash mrp, qty, unit, total price.
                                                                                    Text(
                                                                                      "৳ ${item.mrp!} x ${item.quantity!} ${item.unit} = ${item.total}",
                                                                                      style: const TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 12,
                                                                                        //fontWeight: FontWeight.w600,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),

                                                                        /// Right Side: Close Button
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext dialogContext) {
                                                                                return AlertDialog(
                                                                                  title: const Text("Remove Item"),
                                                                                  content: const Text(
                                                                                    "Are you sure you want to remove this item?",
                                                                                    style: TextStyle(color: Colors.black),
                                                                                  ),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(dialogContext);
                                                                                      },
                                                                                      child: const Text("Cancel"),
                                                                                    ),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        controller.removeCashItem(index);
                                                                                        Navigator.pop(dialogContext);
                                                                                      },
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        backgroundColor: colorScheme.primary,
                                                                                      ),
                                                                                      child: const Text(
                                                                                        "Remove",
                                                                                        style: TextStyle(color: Colors.white),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                            setState(() {});
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                20,
                                                                            height:
                                                                                20,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.grey.shade300, width: 1),
                                                                              borderRadius: BorderRadius.circular(30),
                                                                            ),
                                                                            child: const Icon(Icons.close,
                                                                                color: Colors.green,
                                                                                size: 14),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),

                                        ///cash item empty then empty.
                                        controller.itemsCash.isEmpty
                                            ? const SizedBox()
                                            : vPad10,

                                        ///
                                        controller.itemsCash.isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  //setState(() {});
                                                  showSalesDialog(
                                                      context, controller);
                                                  //setState(() {});
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
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
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            //setState(() {});
                                                            showSalesDialog(
                                                                context,
                                                                controller);
                                                            //setState(() {});
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
                                  ),
                                )
                              : const SizedBox.shrink(),

                          //// credit ====>
                          controller.isCash == false
                              ? Expanded(
                                  child: SingleChildScrollView(
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
                                                        .symmetric(vertical: 3),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: () {
                                                              //setState(() {});
                                                              showSalesDialog(
                                                                  context,
                                                                  controller);
                                                              //setState(() {});
                                                            },
                                                            child: SizedBox(
                                                              height: 50,
                                                              child:
                                                                  DecoratedBox(
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: const Color(
                                                                            0xfff4f6ff), //f4f6ff

                                                                        ///f4f6ff, dddefa
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          2,
                                                                      vertical:
                                                                          2),
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center, // <--- Center vertically
                                                                      children: [
                                                                        /// Left Side: Index + Item Info
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center, // <--- Center vertically
                                                                            children: [
                                                                              ///index
                                                                              Text(
                                                                                "${index + 1}. ",
                                                                                style: const TextStyle(
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  color: Colors.black,
                                                                                  //fontWeight: FontWeight.w200,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 5),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    ///credit item name
                                                                                    Text(
                                                                                      item.itemName!,
                                                                                      style: const TextStyle(
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        color: Colors.black,
                                                                                        //fontWeight: FontWeight.w200,
                                                                                        fontSize: 13,
                                                                                      ),
                                                                                    ),

                                                                                    ///creadit mrp, quantity, unit, total amount.
                                                                                    Text(
                                                                                      "৳ ${item.mrp!} x ${item.quantity!} ${item.unit} = ${item.total}",
                                                                                      style: const TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 12,
                                                                                        //fontWeight: FontWeight.w200,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),

                                                                        /// credit item remove, Right Side: Close Button
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext dialogContext) {
                                                                                return AlertDialog(
                                                                                  title: const Text("Remove Item"),
                                                                                  content: const Text(
                                                                                    "Are you sure you want to remove this item?",
                                                                                    style: TextStyle(color: Colors.black),
                                                                                  ),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(dialogContext);
                                                                                      },
                                                                                      child: const Text("Cancel"),
                                                                                    ),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        //controller.removeCashItem(index);
                                                                                        controller.removeCreditItem(index);
                                                                                        Navigator.pop(dialogContext);
                                                                                      },
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        backgroundColor: colorScheme.primary,
                                                                                      ),
                                                                                      child: const Text(
                                                                                        "Remove",
                                                                                        style: TextStyle(color: Colors.white),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                            setState(() {});
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                20,
                                                                            height:
                                                                                20,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.grey.shade300, width: 1),
                                                                              borderRadius: BorderRadius.circular(30),
                                                                            ),
                                                                            child: const Icon(Icons.close,
                                                                                color: Colors.green,
                                                                                size: 14),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                         
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),

                                        ///item credit
                                        controller.itemsCredit.isEmpty
                                            ? const SizedBox()
                                            : vPad10,

                                        //item credit. Add items & service
                                        controller.itemsCredit.isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  //setState(() {});
                                                  showSalesDialog(
                                                      context, controller);
                                                  //setState(() {});
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
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
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text(
                                                          "Add items & service",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            //setState(() {});
                                                            showSalesDialog(
                                                                context,
                                                                controller);
                                                            //setState(() {});
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
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),

                          ///note ====>
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
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      height: 40,
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
                                          controller:
                                              controller.saleNoteController,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
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

                          ///bottom button portion
                          ///amount, discount, tax vat, adjust total, received
                          const FieldPortion(),
                        ],
                      ),
                    ),
                  ),
                  vPad20,

                  ///bottom portion
                  ///new view, view a4, view a5, save and view.
                  BottomPortion(
                    invoiceItems: invoiceItems,
                    saleType: controller.isCash ? "Cash" : "Credit",
                    customerId: controller.isCash
                        ? "Cash"
                        : selectedCustomerId ?? "Cash",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///===>>>sales item picked.
  ////show sales diolog.
  void showSalesDialog(BuildContext context, SalesController controller) async {

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

                        ///Item search dropdown === working.

                        // Updated Item selection dropdown
                        ItemCustomDropDownTextField(
                          controller: itemController,
                          onItemSelected: (selectedItem) async {
                            debugPrint(
                                "Selected Item: ${selectedItem.name} (ID: ${selectedItem.id})");

                            unitIdsList.clear();

                            // ✅ Set purchase price first
                            controller.salePrice = selectedItem.salesPrice
                                    is int
                                ? (selectedItem.salesPrice as int).toDouble()
                                : (selectedItem.salesPrice ?? 0.0);

                            // ✅ Set unit quantity (default to 1 if null)
                            controller.unitQty = selectedItem.unitQty ?? 1;

                            // ✅ Set the price initially to purchase price
                            controller.mrpController.text =
                                controller.salePrice.toStringAsFixed(2);

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

                                // 🔥 SOLUTION 1: Set with default quantity "1" initially
                                controller.selectedUnitIdWithNameFunction(
                                    "${unit.id}_${unit.name}_1");
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
                                "purchase price ===> ${controller.salePrice}");
                          },
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

                        ///Qty and Unit.
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

                                            // 🔥 SOLUTION 2: Directly update selectedUnitIdWithName with quantity
                                            if (controller
                                                .selectedUnit!.isNotEmpty) {
                                              final selectedUnitObj =
                                                  unitProvider.units.firstWhere(
                                                (unit) =>
                                                    unit.name ==
                                                    controller.selectedUnit,
                                                orElse: () => Unit(
                                                    id: 0,
                                                    name: "Unknown",
                                                    symbol: "",
                                                    status: 0),
                                              );

                                              final qtyText = controller
                                                  .qtyController.text
                                                  .trim();
                                              final qty = qtyText.isNotEmpty
                                                  ? qtyText
                                                  : "1";

                                              controller
                                                  .selectedUnitIdWithNameFunction(
                                                      "${selectedUnitObj.id}_${selectedUnitObj.name}_$qty");

                                              debugPrint(
                                                  "✅ Updated unit_id after qty change: ${controller.selectedUnitIdWithName}");
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              /// Unit Dropdown
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 150,
                                    child:

                                        
                                        CustomDropdownTwo(
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

                                        final qtyText = controller
                                            .qtyController.text
                                            .trim();
                                        final qty =
                                            qtyText.isNotEmpty ? qtyText : "1";

                                        controller.selectedUnitIdWithNameFunction(
                                            "${selectedUnitObj.id}_${selectedUnitObj.name}_$qty");

                                        debugPrint(
                                            "🆔 Unit ID: ${selectedUnitObj.id}_${selectedUnitObj.name}");

                                        // ✅ Price update logic
                                        if (selectedUnit ==
                                            controller.secondaryUnitName) {
                                          double newPrice =
                                              controller.salePrice /
                                                  controller.unitQty;
                                          controller.mrpController.text =
                                              newPrice.toStringAsFixed(2);
                                        } else if (selectedUnit ==
                                            controller.primaryUnitName) {
                                          controller.mrpController.text =
                                              controller.salePrice
                                                  .toStringAsFixed(2);
                                        }

                                        setState(() {
                                          controller.hasCustomPrice = true;
                                          controller.calculateSubtotal();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Container(
                          child: AddSalesFormfield(
                            label: "", // price
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

                              debugPrint(
                                  "selectedItem ======= $selectedItem =====|>");

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

                              setState(() {
                                showSalesDialog(context, controller);
                              });

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

                              debugPrint(
                                  "selectedItem ======= $selectedItem =====|>");

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
                                  print(
                                      'cash or credit =====>${controller.isCash}');

                                  controller.isCash
                                      ? controller.addCashItem()
                                      : controller.addCreditItem();

                                  controller.isCash
                                      ? controller.addAmount2()
                                      : controller.addAmount();

                                  //controller.addAmount();
                                });

                                controller.clearFields();

                                Navigator.pop(context);
                              }

                              Provider.of<SalesController>(context,
                                      listen: false)
                                  .notifyListeners();

                              setState(() {
                                controller.seletedItemName = null;

                                Provider.of<AddItemProvider>(context,
                                        listen: false)
                                    .clearPurchaseStockDatasale();

                                controller.mrpController.clear();
                                controller.qtyController.clear();
                              });

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

  ////item edit list ===>
  Future<void> showCashItemDetailsDialog(
    BuildContext context,
    ItemModel selectedItem,
  ) async {
    String? selectedTaxName;
    String? selectedTaxId;

    final priceController = TextEditingController(text: "${selectedItem.mrp}");
    final qtyController =
        TextEditingController(text: "${selectedItem.quantity}");
    final discountController =
        TextEditingController(text: "${selectedItem.discountAmount}");
    final vatController =
        TextEditingController(text: "${selectedItem.vatAmount}");
    final totalController =
        TextEditingController(text: "${selectedItem.total}");

    final addItemProvider =
        Provider.of<AddItemProvider>(context, listen: false);

    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);
    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    final taxProvider = Provider.of<TaxProvider>(context, listen: false);

    final controller = Provider.of<SalesController>(context, listen: false);

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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

          void updateTotalDiscount() {
            final price = double.tryParse(priceController.text) ?? 0.0;
            final qty = double.tryParse(qtyController.text) ?? 0.0;

            final discount = double.tryParse(discountController.text) ?? 0.0;

            final totalAfterDiscount = (price * qty) - discount;
            totalController.text = totalAfterDiscount.toStringAsFixed(2);
          }

          final price = double.tryParse(priceController.text) ?? 0.0;
          final qty = double.tryParse(qtyController.text) ?? 0.0;
          final purchaseTotal = price * qty;
          totalController.text = purchaseTotal.toStringAsFixed(2);

          final double screenWidth = MediaQuery.of(context).size.width;

          return Dialog(
            backgroundColor: Colors.transparent,

            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            //title: const Text("Item List Edit"),
            child: Container(
              height: 400,
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // 🔽 Item Dropdown , and unit drop down

                        Row(
                          children: [
                            // === Item Column ===
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Item",
                                      style: TextStyle(color: Colors.black)),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    height: 30,
                                    child: Consumer<AddItemProvider>(
                                      builder: (context, itemProvider, child) {
                                        if (itemProvider.isLoading) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }

                                        if (itemProvider.items.isEmpty) {
                                          return const Center(
                                            child: Text(
                                              'No items available.',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          );
                                        }

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2.0),
                                          child: CustomDropdownTwo(
                                            width: double.infinity,
                                            hint: '',
                                            items: itemProvider.items
                                                .map((item) => item.name)
                                                .toList(),
                                            height: 30,
                                            selectedItem: selectedItem.itemName,
                                            onChanged:
                                                (selectedItemName) async {
                                              setState(() {
                                                controller.seletedItemName =
                                                    selectedItemName;
                                                itemProvider.items.forEach((e) {
                                                  if (selectedItemName ==
                                                      e.name) {
                                                    controller.selcetedItemId =
                                                        e.id.toString();
                                                  }
                                                });

                                                if (controller.selcetedItemId !=
                                                    null) {
                                                  fetchStockQuantity
                                                      .fetchStockQuantity(
                                                          controller
                                                              .selcetedItemId!);
                                                }
                                              });

                                              final selected =
                                                  itemProvider.items.firstWhere(
                                                (item) =>
                                                    item.name ==
                                                    selectedItemName,
                                                orElse: () =>
                                                    itemProvider.items.first,
                                              );

                                              if (unitProvider.units.isEmpty) {
                                                await unitProvider.fetchUnits();
                                              }

                                              unitIdsList.clear();

                                              if (selected.unitId != null &&
                                                  selected.unitId != '') {
                                                final unit = unitProvider.units
                                                    .firstWhere(
                                                  (unit) =>
                                                      unit.id.toString() ==
                                                      selected.unitId
                                                          .toString(),
                                                  orElse: () => Unit(
                                                      id: 0,
                                                      name: 'Unknown Unit',
                                                      symbol: '',
                                                      status: 0),
                                                );
                                                if (unit.id != 0) {
                                                  unitIdsList.add(unit.name);
                                                  controller.selectedUnit =
                                                      unit.name;

                                                  String finalUnitString =
                                                      "${unit.id}_${unit.name}_1";
                                                  controller
                                                      .selectedUnitIdWithNameFunction(
                                                          finalUnitString);
                                                }
                                              }

                                              if (selected.secondaryUnitId !=
                                                      null &&
                                                  selected.secondaryUnitId !=
                                                      '') {
                                                final secondaryUnit =
                                                    unitProvider.units
                                                        .firstWhere(
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
                                                  unitIdsList
                                                      .add(secondaryUnit.name);
                                                }
                                              }

                                              if (unitIdsList.isEmpty) {
                                                debugPrint(
                                                    "No valid units found for this item.");
                                              } else {
                                                debugPrint(
                                                    "Units Available: $unitIdsList");
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            // === Unit Column ===
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Unit",
                                      style: TextStyle(color: Colors.black)),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    height: 30,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: CustomDropdownTwo(
                                        width: double.infinity,
                                        hint: '',
                                        items: unitIdsList,
                                        height: 30,
                                        selectedItem: selectedItem.unit,
                                        onChanged: (selectedUnit) {
                                          print("Selected Unit: $selectedUnit");

                                          controller.selectedUnit =
                                              selectedUnit;

                                          final selectedUnitObj =
                                              unitProvider.units.firstWhere(
                                            (unit) => unit.name == selectedUnit,
                                            orElse: () => Unit(
                                                id: 0,
                                                name: "Unknown Unit",
                                                symbol: "",
                                                status: 0),
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
                                                  "${unitId}_${unitName}";
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

                                          debugPrint(
                                              "🆔 Final Unit ID: $finalUnitString");
                                          controller.notifyListeners();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        ///stock available
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

                        ///price
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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

                            //qty
                            Expanded(
                              child: SizedBox(
                                //width: 100,
                                child: AddSalesFormfield(
                                  label: 'QTY',
                                  controller: qtyController,
                                  onChanged: (value) {
                                    selectedItem.quantity = value;
                                    updateTotal();
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        ///discount, discount amount
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: SizedBox(
                                      child: AddSalesFormfield(
                                        label: "Discount (%)",
                                        controller:
                                            controller.discountPercentance,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          controller.lastChanged = 'percent';
                                          controller.calculateSubtotal();

                                          selectedItem.discountPercentance =
                                              value;
                                          updateTotalDiscount(); // Calculate and update total
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: SizedBox(
                                child: AddSalesFormfield(
                                    label: "Discount AMT",
                                    controller: discountController),
                              ),
                            ),
                          ],
                        ),

                        ///tax, tax amount
                        Row(
                          children: [
                            Expanded(
                              child: Consumer<TaxProvider>(
                                builder: (context, taxProvider, child) {
                                  if (taxProvider.isLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (taxProvider.taxList.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No tax',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }
                                  return SizedBox(
                                    //width: 135,
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "VAT/TAX (%)",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                        ),
                                        CustomDropdownTwo(
                                          hint: 'VAT/TAX',
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

                                              final nameOnly =
                                                  newValue?.split(" - ").first;

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

                                              // controller.setTaxPercent(selectedTaxPercent ?? 0.0); // 👈 Call controller
                                              controller.taxPercent = controller
                                                      .selectedTaxPercent ??
                                                  0.0;

                                              controller.updateTaxPaecentId(
                                                  '${selectedTaxId}_${controller.selectedTaxPercent}');

                                              print(
                                                  'tax_percent: "${controller.taxPercentValue}"');

                                              //controller.calculateSubtotal();

                                              debugPrint(
                                                  "Selected Tax ID: $selectedTaxId");
                                              debugPrint(
                                                  "Selected Tax Percent: ${controller.selectedTaxPercent}");
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: SizedBox(
                                child: AddSalesFormfield(
                                    label: "VAT/TAX AMT",
                                    controller: vatController),
                              ),
                            ),
                          ],
                        ),

                        AddSalesFormfield(
                          label: "Total",
                          controller: totalController,
                        ),
                      ],
                    ),
                  ),

                  /////====> add item
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: () async {
                          debugPrint("Update Item");

                          debugPrint(
                              "selectedItem ======= $selectedItem =====|>");

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
                              print(
                                  'cash or credit =====>${controller.isCash}');

                              controller.isCash
                                  ? controller.addCashItem()
                                  : controller.addCreditItem();

                              controller.isCash
                                  ? controller.addAmount2()
                                  : controller.addAmount();

                              //controller.addAmount();
                            });

                            controller.clearFields();

                            Navigator.pop(context);
                          }

                          Provider.of<SalesController>(context, listen: false)
                              .notifyListeners();

                          setState(() {
                            controller.seletedItemName = null;

                            Provider.of<AddItemProvider>(context, listen: false)
                                .clearPurchaseStockDatasale();

                            controller.mrpController.clear();
                            controller.qtyController.clear();
                          });

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
                                    "Update",
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
            ),
          );
        });
      },
    );
  }
}

class ItemModel {
  String? category;
  String? subCategory;
  String? itemName;
  String? itemCode;
  String? mrp;
  String? quantity;
  String? total;
  String? price;
  String? unit;
  dynamic discountAmount;
  dynamic discountPercentance;
  dynamic vatAmount;
  dynamic vatPerentace;
  dynamic description;

  ItemModel(
      {this.category,
      this.subCategory,
      this.itemName,
      this.itemCode,
      this.mrp,
      this.quantity,
      this.total,
      this.price,
      this.unit,
      this.discountAmount,
      this.discountPercentance,
      this.vatAmount,
      this.vatPerentace,
      this.description});
}

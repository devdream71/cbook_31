import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/cash_credit_switch_button.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/item/model/items_show_model.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/payment_out/model/bill_person_list_model.dart';
import 'package:cbook_dt/feature/payment_out/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/provider/update_provider.dart';
import 'package:cbook_dt/feature/sales/update_sale_item_view.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/settings/ui/bill_invoice_create_form.dart';
import 'package:cbook_dt/feature/suppliers/suppliers_create.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///====>Sales update Screen
class SalesUpdateScreen extends StatefulWidget {
  final int salesId;
  final String? transactionMethod; // Add this
  final String? customerName;

  const SalesUpdateScreen({
    Key? key,
    required this.salesId,
    this.transactionMethod,
    this.customerName,
  }) : super(key: key);

  @override
  State<SalesUpdateScreen> createState() => _SalesUpdateScreenState();
}

class _SalesUpdateScreenState extends State<SalesUpdateScreen> {
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
      final controller = Provider.of<SalesController>(context, listen: false);

      // Set initial cash/credit state based on transaction method
      if (widget.transactionMethod == "cash") {
        controller.isCash = true;
      } else if (widget.transactionMethod == "customer") {
        controller.isCash = false;
      }

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
    });
  }

  String formatNumber(dynamic value) {
    if (value == null) return "0";

    // Convert to double safely
    double? numValue;
    if (value is String) {
      numValue = double.tryParse(value);
    } else if (value is num) {
      numValue = value.toDouble();
    }

    if (numValue == null) return "0";

    // If whole number (e.g. 15.0 → 15)
    if (numValue % 1 == 0) {
      return numValue.toInt().toString();
    }

    return numValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('customer name ${widget.customerName}');
    final controller = context.watch<SalesController>();
    final updateController = context.watch<SaleUpdateProvider>();
    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: true);
    final colorScheme = Theme.of(context).colorScheme;
    final saleProvider = Provider.of<SaleUpdateProvider>(context);

    debugPrint("purchase id ${widget.salesId}");

    return ChangeNotifierProvider(
      create: (_) => SaleUpdateProvider()..fetchSaleData(widget.salesId),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          //centerTitle: true,
          title: const Text(
            "Update Sale",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          ),

          actions: [
            CashCreditToggle(
              initialCash: widget.transactionMethod ==
                  "cash", // Set based on transaction method
              onChanged: (isCash) {
                print("Selected: ${isCash ? "Cash" : "Credit"}");
                controller.updateCash(context);
              },
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BillInvoiceCreateForm()));
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ))
          ],
        ),
        body: SingleChildScrollView(
          child: Consumer<SaleUpdateProvider>(
            builder: (context, provider, child) {
              debugPrint("======================");
              return provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              color: Color(0xffdddefa),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 4.0),
                                child: Row(
                                  children: [
                                    /// Bill No
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Bill/Invoice No",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            provider.billNumberController.text,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                            overflow: TextOverflow
                                                .ellipsis, // ✅ Prevent overflow
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// Vertical Divider
                                    Container(
                                      width: 1,
                                      height:
                                          40, // you can tweak this to match the height of content
                                      color: Colors.black,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),

                                    /// Bill Date
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Date",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  controller.pickDate(context);
                                                },
                                                child: Icon(
                                                  Icons.calendar_today,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              )
                                            ],
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                controller.pickDate(context),
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                isDense: true,
                                                //suffixIcon: ,
                                                suffixIconConstraints:
                                                    const BoxConstraints(
                                                  minWidth: 16,
                                                  minHeight: 16,
                                                ),
                                                hintText: "Bill Date",
                                                hintStyle: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 9,
                                                ),
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.transparent,
                                                      width: 0),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.transparent),
                                                ),
                                              ),
                                              child: Text(
                                                controller.formattedDate
                                                        .isNotEmpty
                                                    ? controller.formattedDate
                                                    : "Select Date",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
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
                            ),
                          ),

                          // Main Form Section
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Bill To and Form Fields Row
                                Row(
                                  children: [
                                    // Bill To Section
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Customer/Supplier Section
                                          Row(
                                            children: [
                                              SizedBox(
                                                  child: provider.hasCustomer
                                                      ? const Column(
                                                          children: [
                                                            SizedBox.shrink()
                                                          ],
                                                        )
                                                      : InkWell(
                                                          onTap: () {},
                                                          child: const SizedBox
                                                              .shrink())),
                                              hPad3,
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                              
                                if (controller.isCash == false)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (widget.customerName != null &&
                                            widget.customerName != "N/A")
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            
                                          ),
                                        Consumer<CustomerProvider>(
                                          builder: (context, customerProvider,
                                              child) {
                                            // Find the customer object that matches the customer name
                                            Customer? preSelectedCustomer;
                                            if (widget.customerName != null &&
                                                widget.customerName != "N/A" &&
                                                customerProvider
                                                        .customerResponse
                                                        ?.data !=
                                                    null) {
                                              try {
                                                preSelectedCustomer =
                                                    customerProvider
                                                        .customerResponse!.data!
                                                        .firstWhere(
                                                  (customer) =>
                                                      customer.name ==
                                                      widget.customerName,
                                                );
                                              } catch (e) {
                                                // Customer not found, preSelectedCustomer remains null
                                                preSelectedCustomer = null;
                                              }
                                            }

                                            return AddSalesFormfieldTwo(
                                                controller:
                                                    controller.codeController,
                                                customerorSaleslist:
                                                    "Showing customer list",
                                                customerOrSupplierButtonLavel:
                                                    "Add new customer",
                                                selectedCustomer:
                                                    preSelectedCustomer,
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const SuppliersCreate()));
                                                });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.saleUpdateList.length,
                                  itemBuilder: (context, index) {
                                    final detail =
                                        provider.saleUpdateList[index];

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
                                              itemMap: provider.itemMap,
                                              unitMap: provider.unitMap,
                                              itemList: provider.itemList,
                                              itemDiscoumtAmount:
                                                  provider.itemDiscountAmount,
                                              itemDiscountPercentance: provider
                                                  .itemDiscountPercentance,
                                              itemtaxAmount:
                                                  provider.itemTaxVatAmount,
                                              itemtaxPercentance: provider
                                                  .itemTaxVatPercentance,
                                            ),
                                          ),
                                        );
                                        if (context.mounted) {
                                          provider.notifyListeners();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Item Info
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${provider.itemMap[int.tryParse(detail.itemId) ?? 0] ?? "Unknown"}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "${formatNumber(detail.qty)} ${provider.unitMap[int.tryParse(detail.unitId.split("_")[0]) ?? 0] ?? "Unknown"}",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12),
                                                                ),

//

                                                                const SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  "x ${formatNumber(detail.price)}",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ],
                                                            ),
                                                            // Text(
                                                            //   "Discount: ${formatNumber(detail.salesUpdateDiscountPercentace)} % "
                                                            //   "(${formatNumber(detail.salesUpdateDiscountAmount)}) , ",
                                                            //   style: const TextStyle(
                                                            //       color: Colors
                                                            //           .black,
                                                            //       fontSize: 12),
                                                            // ),
                                                            // Text(
                                                            //   "Tax: ${formatNumber(detail.salesUpdateVATTAXPercentance)} % "
                                                            //   "(${formatNumber(detail.salesUpdateVATTAXAmount)})",
                                                            //   style: const TextStyle(
                                                            //       color: Colors
                                                            //           .black,
                                                            //       fontSize: 12),
                                                            // ),

                                                            // Show discount only if percentage or amount is not zero
                                                            if ((detail.salesUpdateDiscountPercentace !=
                                                                        null &&
                                                                    double.tryParse(detail
                                                                            .salesUpdateDiscountPercentace
                                                                            .toString()) !=
                                                                        0) ||
                                                                (detail.salesUpdateDiscountAmount !=
                                                                        null &&
                                                                    double.tryParse(detail
                                                                            .salesUpdateDiscountAmount
                                                                            .toString()) !=
                                                                        0))
                                                              Text(
                                                                "Discount: ${formatNumber(detail.salesUpdateDiscountPercentace)} % "
                                                                "(${formatNumber(detail.salesUpdateDiscountAmount)}) , ",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12),
                                                              ),

// Show tax only if percentage or amount is not zero
                                                            if ((detail.salesUpdateVATTAXPercentance !=
                                                                        null &&
                                                                    double.tryParse(detail
                                                                            .salesUpdateVATTAXPercentance
                                                                            .toString()) !=
                                                                        0) ||
                                                                (detail.salesUpdateVATTAXAmount !=
                                                                        null &&
                                                                    double.tryParse(detail
                                                                            .salesUpdateVATTAXAmount
                                                                            .toString()) !=
                                                                        0))
                                                              Text(
                                                                "Tax: ${formatNumber(detail.salesUpdateVATTAXPercentance)} % "
                                                                "(${formatNumber(detail.salesUpdateVATTAXAmount)})",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Subtotal
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          const Text(
                                                            "Subtotal",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.purple,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            formatNumber(detail
                                                                .subTotal),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.purple,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
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

                          // Bottom Section with Totals and Actions
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                // Add Item Button
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: _buildAddItemButton(context,
                                      controller, provider, colorScheme),
                                ),
                                const SizedBox(height: 8),

                                // Note Section
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .45,
                                      child: _buildNoteSection(controller)),
                                ),
                                const SizedBox(height: 3),

                                // Subtotal
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: _buildSubtotalSection(provider),
                                ),
                                const SizedBox(height: 5),

                                // Discount Section
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: _buildDiscountSection(
                                      updateController, saleProvider),
                                ),
                                const SizedBox(height: 4),

                                // Tax Section
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: _buildTaxSection(saleProvider),
                                ),
                                const SizedBox(height: 8),

                                // Gross Total
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: _buildGrossTotalSection(provider),
                                ),
                                const SizedBox(height: 4),

                                // Cash Received Section
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: _buildCashReceivedSection(controller),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Update Button
                          SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              onPressed: () async {
                                updateController.updateSale(context);
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
                          const SizedBox(height: 50)
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  // Enhanced version with dynamic button text:
  Widget _buildAddItemButton(BuildContext context, SalesController controller,
      SaleUpdateProvider provider, ColorScheme colorScheme) {
    // ✅ Check if items exist to show appropriate text
    bool hasItems = controller.isCash
        ? controller.itemsCash.isNotEmpty
        : controller.itemsCredit.isNotEmpty;

    // ✅ Also check provider's sale update list for existing items
    bool hasExistingItems = provider.saleUpdateList.isNotEmpty;

    String buttonText =
        (hasItems || hasExistingItems) ? "Add Another Item" : "Add Item";

    return InkWell(
      onTap: () {
        showSalesDialog(context, controller, provider);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primaryColor,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                buttonText,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build Note Section
  Widget _buildNoteSection(SalesController controller) {
    return Row(
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
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Container(
                height: 38,
                width: MediaQuery.of(context).size.width * .40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Center(
                  child: TextField(
                    controller: controller.saleUpdateNoteController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    onChanged: (value) {
                      controller.saleUpdateNoteController.text = value;
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
    );
  }

  // Helper method to build Subtotal Section
  Widget _buildSubtotalSection(SaleUpdateProvider provider) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 250,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            SizedBox(
              width: 200,
              child: AddSalesFormfield(
                labelText: 'Subtotal',
                readOnly: true,
                controller: TextEditingController(text: provider.getSubTotal()),
                keyboardType: TextInputType.number,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build Discount Section
  Widget _buildDiscountSection(
      SaleUpdateProvider updateController, SaleUpdateProvider saleProvider) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          // Discount Percentage
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 95,
                  child: AddSalesFormfield(
                    labelText: 'DIS (%)',
                    controller: updateController.updateDiscountPercentance,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      updateController.updateDiscountPercent(value);
                      saleProvider.grossTotalController.text =
                          saleProvider.calculateFinalGrossTotalWithTax();
                      debugPrint(
                          "Discount Percent Changed: ${updateController.updateDiscountPercentance.text}");
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Discount Amount
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: SizedBox(
                  width: 95,
                  child: AddSalesFormfield(
                    labelText: "DIS AMT",
                    controller: updateController.updateDiscountAmount,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      updateController.updateDiscountAmountUpdate2(value);
                      saleProvider.grossTotalController.text =
                          saleProvider.calculateFinalGrossTotalWithTax();
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
        ]),
      ),
    );
  }

  // Helper method to build Tax Section
  Widget _buildTaxSection(SaleUpdateProvider saleProvider) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      // VAT Dropdown
      Consumer2<TaxProvider, SaleUpdateProvider>(
        builder: (context, taxProvider, saleProvider, _) {
          if (taxProvider.isLoading) {
            return const SizedBox();
          }


          if (taxProvider.taxList.isEmpty) {
            return CustomDropdownTwo(
                height: 38,
                hint: taxProvider.taxList.isEmpty ? "None" : "Select VAT/TAX",
                items: taxProvider.taxList.isEmpty
                    ? ["None"] // Show only "None"
                    : taxProvider.taxList
                        .map((tax) => "${tax.name} - ${tax.percent}")
                        .toList(),
                width: 95,
                selectedItem: selectedTaxName,
                onChanged: (newValue) {});

            
          }

          return Padding(
            padding: const EdgeInsets.only(left: 17.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdownTwo(
                  labelText: 'VAT/TAX',
                  items: taxProvider.taxList
                      .map((tax) => "${tax.name} - (${tax.percent})")
                      .toList(),
                  width: 95,
                  height: 38,
                  selectedItem: selectedTaxName,
                  onChanged: (newValue) {
                    setState(() {
                      selectedTaxName = newValue;

                      final nameOnly = newValue?.split(" - ")?.first;
                      final selected = taxProvider.taxList.firstWhere(
                        (tax) => tax.name == nameOnly,
                        orElse: () => taxProvider.taxList.first,
                      );

                      selectedTaxId = selected.id.toString();
                      final selectedPercent =
                          double.tryParse(selected.percent) ?? 0.0;

                      // Update provider values
                      saleProvider.selectedTaxPercent = selectedPercent;
                      saleProvider.taxPercent = selectedPercent;

                      saleProvider.updateTaxPaecentId(
                          '${selectedTaxId}_${selectedPercent}');

                      // Update Gross Total
                      saleProvider.grossTotalController.text =
                          saleProvider.calculateFinalGrossTotalWithTax();

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
      const SizedBox(width: 8),

      // TAX AMOUNT FIELD (ReadOnly)
      Consumer<SaleUpdateProvider>(
        builder: (context, controller, _) {
          return SizedBox(
            width: 95,
            child: AddSalesFormfield(
              labelText: 'TAX AMT',
              controller: TextEditingController(
                text: controller.taxAmount.toStringAsFixed(2),
              ),
              readOnly: true,
              keyboardType: TextInputType.number,
            ),
          );
        },
      ),
    ]);
  }

  // Helper method to build Gross Total Section
  Widget _buildGrossTotalSection(SaleUpdateProvider provider) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 250,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            Consumer<SaleUpdateProvider>(
              builder: (context, controller, _) {
                return SizedBox(
                  width: 200,
                  child: AddSalesFormfield(
                    labelText: 'Gross Total',
                    // controller: controller.grossTotalController,
                    controller:
                        TextEditingController(text: provider.getSubTotal()),
                    readOnly: true,
                    keyboardType: TextInputType.number,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build Cash Received Section
  Widget _buildCashReceivedSection(SalesController controller) {
    return controller.isReciptType && controller.isCash
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                      height: 25,
                      child: Checkbox(
                        value: controller.isReceived,
                        onChanged: (bool? value) {
                          if (controller.isCash) {
                            if (value == true) {
                              controller.isReceived = true;
                              controller.notifyListeners();
                            }
                          } else {
                            controller.isReceived = value ?? false;
                            controller.notifyListeners();
                          }
                        },
                      )),
                  const Text("",
                      style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 38,
                    width: 200,
                    child: Consumer<SaleUpdateProvider>(
                      builder: (context, controller, _) {
                        return SizedBox(
                          width: 160,
                          child: AddSalesFormfield(
                            labelText: "Received",
                            controller: controller.grossTotalController,
                            readOnly: true,
                            keyboardType: TextInputType.number,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          )
        : const SizedBox.shrink();
  }

  ///new sales dialog
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

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Fetch required data
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

    String? selectedItemName;
    ItemsModel? selectedItemData;
    int? selectedItemId;

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
              height: 420,
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  // Dialog Title and Close Button
                  Container(
                    height: 30,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 5),
                            Text(
                              "Add Item to edit sales",
                              style: TextStyle(
                                  color: AppColors.primaryColor,
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

                  // Dialog Content
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, right: 10.0, top: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                       

                        ////new sales item dropdown.
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Consumer<AddItemProvider>(
                            builder: (context, itemProvider, child) {
                              return SizedBox(
                                height: 38,
                                width: double.infinity,
                                child: itemProvider.isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : CustomDropdownTwo(
                                        enableSearch: true,
                                        hint: 'Select Item',
                                        items: itemProvider.items
                                            .map((item) => item.name)
                                            .toList(), // List<String>
                                        width: double.infinity,
                                        height: 30,
                                        selectedItem:
                                            selectedItemName, // Global/state variable
                                        onChanged: (value) async {
                                          debugPrint(
                                              '=== Item Selected: $value ===');

                                          // Find selected item from provider
                                          final selectedItem =
                                              itemProvider.items.firstWhere(
                                            (item) => item.name == value,
                                          );

                                          setState(() {
                                            selectedItemName = value;
                                            selectedItemData = selectedItem;
                                            selectedItemId = selectedItem.id;
                                          });

                                          // ✅ Clear previous units
                                          unitIdsList.clear();
                                          localSelectedUnit =
                                              null; // ✅ Reset local unit selection

                                          // ✅ Set sales price first
                                          controller.salePrice = selectedItem
                                                  .salesPrice is int
                                              ? (selectedItem.salesPrice as int)
                                                  .toDouble()
                                              : (selectedItem.salesPrice ??
                                                  0.0);

                                          // ✅ Set unit quantity (default to 1 if null)
                                          controller.unitQty =
                                              selectedItem.unitQty ?? 1;

                                          // ✅ Set price initially to sales price
                                          controller.mrpController.text =
                                              controller.salePrice
                                                  .toStringAsFixed(2);

                                          controller.seletedItemName =
                                              selectedItem.name;
                                          controller.selcetedItemId =
                                              selectedItem.id.toString();

                                          // fetch stock quantity
                                          if (controller.selcetedItemId !=
                                              null) {
                                            fetchStockQuantity
                                                .fetchStockQuantity(
                                                    controller.selcetedItemId!);
                                          }

                                          // Ensure unitProvider is loaded
                                          if (unitProvider.units.isEmpty) {
                                            await unitProvider.fetchUnits();
                                          }

                                          // ===> Primary unit
                                          if (selectedItem.unitId != null) {
                                            final unit =
                                                unitProvider.units.firstWhere(
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
                                              localSelectedUnit = unit
                                                  .name; // ✅ Set local selection

                                              // Set with default quantity "1"
                                              controller
                                                  .selectedUnitIdWithNameFunction(
                                                      "${unit.id}_${unit.name}_1");
                                            }
                                          }

                                          // ===> Secondary unit
                                          if (selectedItem.secondaryUnitId !=
                                              null) {
                                            final secondaryUnit =
                                                unitProvider.units.firstWhere(
                                              (unit) =>
                                                  unit.id.toString() ==
                                                  selectedItem.secondaryUnitId
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

                                          // ✅ Force UI update after setting units
                                          setState(() {
                                            // This triggers the UI rebuild with updated unitIdsList and localSelectedUnit
                                          });

                                          debugPrint(
                                              "Units Available: $unitIdsList");
                                          debugPrint(
                                              "Selected Unit: $localSelectedUnit");
                                          debugPrint(
                                              "sales price ===> ${controller.salePrice}");
                                        },
                                      ),
                              );
                            },
                          ),
                        ),

                        // Stock Available Display
                        Consumer<AddItemProvider>(
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

                        // Quantity and Unit Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Qty Field
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  AddSalesFormfield(
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
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Unit Dropdown
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 38,
                                    child: CustomDropdownTwo(
                                      key: ValueKey(
                                          '${unitIdsList.length}_${localSelectedUnit}_$isItemSelected'),
                                      hint: !isItemSelected
                                          ? ''
                                          : unitIdsList.isEmpty
                                              ? 'No units available'
                                              : 'Select unit',
                                      items: unitIdsList,
                                      width: double.infinity,
                                      height: 38,
                                      labelText: 'Unit',
                                      selectedItem: localSelectedUnit,
                                      onChanged: (selectedUnit) {
                                        debugPrint(
                                            "Selected Unit: $selectedUnit");

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

                                        debugPrint(
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

                        // Price Field
                        AddSalesFormfield(
                          label: "",
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

                        // Discount Percentage and Amount Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Discount Percentage (%)
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

                            const SizedBox(width: 8),

                            // Discount Amount
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

                        // VAT/TAX Dropdown Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // VAT/TAX Dropdown
                            Expanded(
                              flex: 1,
                              child: Consumer<TaxProvider>(
                                builder: (context, taxProvider, child) {
                                  if (taxProvider.isLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (taxProvider.taxList.isEmpty) {
                                    return Column(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        CustomDropdownTwo(
                                            height: 38,
                                            width: double.infinity,
                                            hint: taxProvider.taxList.isEmpty
                                                ? "None"
                                                : "Select VAT/TAX",
                                            items: taxProvider.taxList.isEmpty
                                                ? ["None"] // Show only "None"
                                                : taxProvider.taxList
                                                    .map((tax) =>
                                                        "${tax.name} - ${tax.percent}")
                                                    .toList(),
                                            selectedItem: selectedTaxName,
                                            onChanged: (newValue) {}),
                                      ],
                                    );
                                  }

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        height: 38,
                                        child: CustomDropdownTwo(
                                          labelText: 'Vat/Tax',
                                          hint: '',
                                          items: taxProvider.taxList
                                              .map((tax) =>
                                                  "${tax.name} - (${tax.percent})")
                                              .toList(),
                                          width: double.infinity,
                                          height: 38,
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

                                              controller.taxPercent = controller
                                                      .selectedTaxPercent ??
                                                  0.0;

                                              controller.selectedTaxId =
                                                  selected.id.toString();
                                              controller.selectedTaxPercent =
                                                  double.tryParse(
                                                      selected.percent);

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

                            // VAT/TAX Amount (Read-only field)
                            Expanded(
                              flex: 1,
                              child: AddSalesFormfield(
                                readOnly: true,
                                label: "",
                                labelText: "Amount",
                                controller: TextEditingController(
                                  text: controller.taxAmount.toStringAsFixed(2),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // Subtotal with Tax
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

                  // Dialog Action Buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 4),

                      // Add Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () async {
                              debugPrint("Add Item");

                              // controller.isCash
                              //     ? updateProvider.addCashItemSaleUpdate(
                              //         controller.selcetedItemId,
                              //         controller.mrpController.text,
                              //         controller.selectedUnitIdWithName,
                              //         controller.qtyController.text,
                              //         controller.discountAmount.text,
                              //         controller.discountPercentance.text,
                              //         controller.taxPercentValue,
                              //         controller.taxAmount.toString(),
                              //         '',
                              //       )
                              //     :

                              //     controller.addCreditItem();

                              // ✅ Updated logic for both cash and credit
                              if (controller.isCash) {
                                // Add to cash sale
                                updateProvider.addCashItemSaleUpdate(
                                  controller.selcetedItemId,
                                  controller.mrpController.text,
                                  controller.selectedUnitIdWithName,
                                  controller.qtyController.text,
                                  controller.discountAmount.text,
                                  controller.discountPercentance.text,
                                  controller.taxPercentValue,
                                  controller.taxAmount.toString(),
                                  '',
                                );
                                debugPrint("✅ Cash item added");
                              } else {
                                // ✅ Add to credit sale using the new method
                                updateProvider.addCreditItemSaleUpdate(
                                  controller.selcetedItemId,
                                  controller.mrpController.text,
                                  controller.selectedUnitIdWithName,
                                  controller.qtyController.text,
                                  controller.discountAmount.text,
                                  controller.discountPercentance.text,
                                  controller.taxPercentValue,
                                  controller.taxAmount.toString(),
                                  '',
                                );
                                debugPrint("✅ Credit item added");

                                // Also call controller's method if it exists
                                controller.addCreditItem();
                              }

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
}

// ItemModel class (if not already defined elsewhere)
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


import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/customer_create/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/item/model/items_show_model.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/settings/ui/bill_invoice_create_form.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  int? selectedCategoryId;
  int? selectedSubCategoryId;

  final String baseUrl = "https://commercebook.site/";

  //String? selectedItem;
  // ItemsModel selectedItem;
  ItemsModel? selectedItem;
  int? selectedItemIndex;

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<ItemCategoryProvider>(context, listen: false)
            .fetchCategories());

    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    Future.microtask(() async {
      await Provider.of<AddItemProvider>(context, listen: false).fetchItems();
      final items = Provider.of<AddItemProvider>(context, listen: false).items;

      // Initialize quantities based on fetched items
      setState(() {
        quantities = List.generate(items.length, (index) => 0);
      });
    });
  }

  ///quantities
  List<int> quantities = List.generate(0, (index) => 0);

  ///total amount
  double get totalAmount {
    double total = 0;
    final items = Provider.of<AddItemProvider>(context, listen: false).items;
    for (int i = 0; i < quantities.length; i++) {
      total += quantities[i] * items[i].salesPrice;
    }
    return total;
  }

  ///item count
  int get totalItems {
    return quantities.where((qty) => qty > 0).length;
  }

  final DateTime _selectedDate = DateTime.now();

  String get formattedDate => DateTimeHelper.formatDate(_selectedDate);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final categoryProvider = Provider.of<ItemCategoryProvider>(context);

    final controller = context.watch<SalesController>();

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: InkWell(
            onTap: () {
              final customerProvider =
                  Provider.of<CustomerProvider>(context, listen: false);

              // Clear selected customer
              customerProvider.clearSelectedCustomer();

              // Clear customer list
              customerProvider.clearCustomerList();

              // Clear customer name from TextField
              controller.customerNameController.clear();

              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: colorScheme.surface,
            ),
          ),
          actions: [
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
          title: Column(
            children: [
              const Text(
                'Bulk Sales/ Invoice',
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sal/423',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  //Text('', style: TextStyle(fontSize: 24, color: Colors.white),)
                ],
              ),
            ],
          )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///cash and credit , if creadit then show customer list.
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2),
                child: InkWell(
                  onTap: () {
                    controller.updateCash(context);
                        
                    Provider.of<CustomerProvider>(context, listen: false)
                        .clearSelectedCustomer();
                        
                    final customerProvider = Provider.of<CustomerProvider>(
                        context,
                        listen: false);
                        
                    // Clear selected customer
                    customerProvider.clearSelectedCustomer();
                        
                    // Clear customer list
                    customerProvider.clearCustomerList();
                        
                    // Clear customer name from TextField
                    controller.customerNameController.clear();
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.isCash ? "Cash" : "Credit",
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
              ),
          
              const SizedBox(
                width: 6,
              ),
          
              //customer list.
              controller.isCash
                  ? const SizedBox(
                      height: 53,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: SizedBox(
                        width: 320,
                        height: 53,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///show text field search ====>
                            AddSalesFormfieldTwo(
                              controller: controller.customerNameController,
                              customerorSaleslist: "Showing Customer list",
                              customerOrSupplierButtonLavel: "Add customer",
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
                              builder: (context, customerProvider, child) {
                                final customerList =
                                    customerProvider.customerResponse?.data ??
                                        [];
          
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // If the customer list is empty, show a SizedBox
                                    if (customerList.isEmpty)
                                      const SizedBox(
                                          height:
                                              2), // Adjust height as needed
          
                                    // Otherwise, show the dropdown with customers
                                    if (customerList.isNotEmpty)
          
                                      // Check if the selected customer is valid
                                      if (customerProvider.selectedCustomer !=
                                              null &&
                                          customerProvider
                                                  .selectedCustomer!.id !=
                                              -1)
                                        Row(
                                          children: [
                                            Text(
                                              "${customerProvider.selectedCustomer!.type == 'customer' ? 'Receivable' : 'Payable'}: ",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: customerProvider
                                                            .selectedCustomer!
                                                            .type ==
                                                        'customer'
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2.0),
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
                    ),
            ],
          ),

          /// Category and Subcategory Section - Full Width, Equal Size, No Padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                // CATEGORY Dropdown
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Category",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      categoryProvider.isLoading
                          ? const SizedBox()
                          : CustomDropdownTwo(
                              items: categoryProvider.categories
                                  .map((category) => category.name)
                                  .toList(),
                              hint: '',
                              width: double.infinity,
                              height: 30,
                              onChanged: (value) {
                                final selectedCategory = categoryProvider
                                    .categories
                                    .firstWhere((cat) => cat.name == value);

                                setState(() {
                                  selectedCategoryId = selectedCategory.id;
                                  selectedSubCategoryId = null;
                                });

                                categoryProvider
                                    .fetchSubCategories(selectedCategory.id);

                                Provider.of<AddItemProvider>(context,
                                        listen: false)
                                    .filterItems(selectedCategoryId, null);
                              },
                            ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                // SUBCATEGORY Dropdown
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      categoryProvider.isSubCategoryLoading
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : categoryProvider.subCategories.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Sub Category",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    CustomDropdownTwo(
                                      items: categoryProvider.subCategories
                                          .map(
                                              (subCategory) => subCategory.name)
                                          .toList(),
                                      hint: '',
                                      width: double.infinity,
                                      height: 30,
                                      onChanged: (value) {
                                        final selectedSubCategory =
                                            categoryProvider
                                                .subCategories
                                                .firstWhere((subCat) =>
                                                    subCat.name == value);

                                        setState(() {
                                          selectedSubCategoryId =
                                              selectedSubCategory.id;
                                        });
                                        debugPrint(
                                            "Selected SubCategory: $selectedSubCategoryId");
                                        Provider.of<AddItemProvider>(context,
                                                listen: false)
                                            .filterItems(selectedCategoryId,
                                                selectedSubCategoryId);
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          ///all item show here
          Consumer<AddItemProvider>(
            builder: (context, itemProvider, child) {
              if (itemProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (itemProvider.filteredItems.isEmpty) {
                return const Center(
                  child: Text(
                    'No items available.',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                  itemCount: itemProvider.filteredItems.length,
                  itemBuilder: (context, index) {
                    ItemsModel item = itemProvider.filteredItems[index];

                    return InkWell(
                      onTap: () {
                        // showSalesDialog(context, controller,
                        //     selectedItem: item);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 1),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.only(left: 4, right: 2),
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ///image
                              InkWell(
                                onTap: () {
                                  showSalesDialog(context, controller,
                                      selectedItem: item);
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Image.network(
                                    "$baseUrl${item.image}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/image/cbook_logo.png",
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              ///product name
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedItem =
                                          item; // ✅ Save the entire item
                                      selectedItemIndex = index;
                                    });

                                    showSalesDialog(
                                      context,
                                      controller,
                                      selectedItem: item,
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          'pp: ${item.purchasePrice}   sp: ${item.salesPrice}   Stock: ${item.openingStock}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          )),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              /// add item qty and remove item qty.
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(
                                    //       color: Colors.green, width: 1),
                                    //   borderRadius: BorderRadius.circular(
                                    //       30), // Makes the pill shape
                                    // ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (quantities[index] > 0) {
                                                quantities[index]--;
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade500,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Icon(Icons.remove,
                                                color: Colors.green, size: 18),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(
                                            '${quantities[index]}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              quantities[index]++;
                                            });
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              //color: Colors.grey,
                                              border: Border.all(
                                                  color: Colors.grey.shade500,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              //shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.green, size: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.add_shopping_cart,
                  color: Colors.white, size: 24),
              //total item
              Text('Item: $totalItems',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              //total amount
              Text('Amount: $totalAmount',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Row(
                children: [
                  //item view pop up
                  GestureDetector(
                    onTap: () {
                      final items =
                          Provider.of<AddItemProvider>(context, listen: false)
                              .items;

                      showBulkSalesDialog(
                        context,
                        controller,
                        items: items,
                        quantities: quantities,
                      );
                    },
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.receipt, color: Colors.white, size: 24),
                    ),
                  ),

                  const SizedBox(width: 8),

                  //invoice view
                  GestureDetector(
                    onTap: () {},
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(Icons.description,
                          color: Colors.white, size: 24),
                    ),
                  ),

                  const SizedBox(width: 8),

                  //item save.
                  GestureDetector(
                    onTap: () {},
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.save, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  ///bulk sales diolog , items
  void showBulkSalesDialog(
    BuildContext context,
    SalesController controller, {
    required List<ItemsModel> items,
    required List<int> quantities,
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Filter items where qty > 0
            final filteredItems = items
                .asMap()
                .entries
                .where((entry) => quantities[entry.key] > 0)
                .toList();

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(6.0),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Item Details',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    if (filteredItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No item selected',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index].value;
                          final itemIndex = filteredItems[index].key;
                          final qty = quantities[itemIndex];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text('${index + 1}. ',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14)),
                                    const SizedBox(width: 3),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                          "${item.salesPrice} x $qty Pc = ${item.salesPrice * qty}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          quantities[itemIndex] = 0;
                                        });
                                      },
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade500,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.green, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showSalesDialog(BuildContext context, SalesController controller,
      {required ItemsModel selectedItem}) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);

    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    final taxProvider = Provider.of<TaxProvider>(context, listen: false);

    final controller = Provider.of<SalesController>(context, listen: false);

    await fetchStockQuantity.fetchStockQuantity(selectedItem.id.toString());

    // ✅ Fetch stock for the pre-selected item
    await fetchStockQuantity.fetchStockQuantity(selectedItem.id.toString());

    final TextEditingController itemController =
        TextEditingController(text: selectedItem.name);

    String? selectedTaxName;
    String? selectedTaxId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // ✅ Fetch categories
    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.fetchCategories();
    }

    if (taxProvider.taxList.isEmpty) {
      await taxProvider.fetchTaxes();
    }

    // Fetch units if not loaded
    if (unitProvider.units.isEmpty) {
      await unitProvider.fetchUnits();
    }

    //Provider.of<AddItemProvider>(context, listen: false).clearStockData();

    // ✅ Fetch stock for the pre-selected item
    await Provider.of<AddItemProvider>(context, listen: false)
        .fetchStockQuantity(selectedItem.id.toString());

    await fetchStockQuantity.fetchStockQuantity(selectedItem.id.toString());

    /// ✅ Prefill qtyController with item quantity (default to 1 if not found)

    controller.clearFields();

    // ✅ Pop the loading dialog
    Navigator.of(context).pop();

    // Define local state variables
    // String? selectedCategoryId;
    // String? selectedSubCategoryId;

    @override
    void dispose() {
      itemController.dispose();
      super.dispose();
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            // ✅ Use StatefulBuilder to update UI

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final controller =
                  Provider.of<SalesController>(context, listen: false);

              controller.addListener(() {
                setState(() {});
              });
            });

            bool isLoading =
                categoryProvider.isLoading || fetchStockQuantity.isLoading;

           

            //int initialQty = 1;

            // if (selectedItem.unitQty != null && selectedItem.unitQty != 0) {
            //   initialQty = selectedItem.unitQty!;
            // } else if (selectedItem.secondaryUnitQty != null &&
            //     selectedItem.secondaryUnitQty != 0) {
            //   initialQty = selectedItem.secondaryUnitQty!;
            // }

            //controller.qtyController.text = initialQty.toString();

            List<String> unitIdsList = [];

            final unit = unitProvider.units.firstWhere(
              (unit) => unit.id.toString() == selectedItem.unitId.toString(),
              orElse: () =>
                  Unit(id: 0, name: 'Unknown Unit', symbol: '', status: 0),
            );

            if (unit.id != 0) {
              unitIdsList.add(unit.name);
              controller.selectedUnit = unit.name;

              String finalUnitString = "${unit.id}_${unit.name}_1";
              controller.selectedUnitIdWithNameFunction(finalUnitString);
            }

            if (selectedItem.secondaryUnitId != null &&
                selectedItem.secondaryUnitId != '') {
              final secondaryUnit = unitProvider.units.firstWhere(
                (unit) =>
                    unit.id.toString() ==
                    selectedItem.secondaryUnitId.toString(),
                orElse: () =>
                    Unit(id: 0, name: 'Unknown Unit', symbol: '', status: 0),
              );
              if (secondaryUnit.id != 0) {
                unitIdsList.add(secondaryUnit.name);
              }
            }

            if (unitIdsList.isEmpty) {
              debugPrint("No valid units found for this item.");
            } else {
              debugPrint("Units Available: $unitIdsList");
            }

            return Dialog(
              backgroundColor: Colors.grey.shade400,
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  height: 340,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xffe7edf4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
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
                                Icon(
                                  Icons.add_box,
                                  color: Colors.white,
                                ),
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
                            left: 10.0, right: 10.0, top: 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 8,
                            ),

                            ///new item search <<<<<<==========
                            ///

                            //item
                            AddSalesFormfield(
                              height: 30,
                              label: "", //price
                              labelText: "Item",
                              controller: itemController,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              onChanged: (value) {},
                            ),

                            ///item working, with dropdown
                            // Container(
                            //   //color: Colors.red,
                            //   child: ItemCustomDropDownTextField(
                            //     controller: itemController,
                            //     //label: "Select Item",
                            //     onItemSelected: (selectedItem) async {
                            //       // This will print the id and name when item is selected
                            //       debugPrint(
                            //           "=======> Selected Item: ${selectedItem.name} (ID: ${selectedItem.id})");

                            //       setState(() {
                            //         // Save selected item name and id in controller
                            //         controller.seletedItemName =
                            //             selectedItem.name;
                            //         controller.selcetedItemId =
                            //             selectedItem.id.toString();

                            //         // Fetch stock quantity
                            //         if (controller.selcetedItemId != null) {
                            //           fetchStockQuantity.fetchStockQuantity(
                            //               controller.selcetedItemId!);
                            //         }
                            //       });

                            //       // Ensure unitProvider is loaded
                            //       if (unitProvider.units.isEmpty) {
                            //         await unitProvider
                            //             .fetchUnits(); // Ensure units are fetched
                            //       }

                            //       // Clear previous units
                            //       unitIdsList.clear();

                            //       print(
                            //           "Selected item unitId: ${selectedItem.unitId}");
                            //       print(
                            //           "Selected item secondaryUnitId: ${selectedItem.secondaryUnitId}");

                            //       // Base unit
                            //       if (selectedItem.unitId != null &&
                            //           selectedItem.unitId != '') {
                            //         final unit = unitProvider.units.firstWhere(
                            //           (unit) =>
                            //               unit.id.toString() ==
                            //               selectedItem.unitId.toString(),
                            //           orElse: () => Unit(
                            //               id: 0,
                            //               name: 'Unknown Unit',
                            //               symbol: '',
                            //               status: 0),
                            //         );
                            //         if (unit.id != 0) {
                            //           unitIdsList.add(unit.name);
                            //           controller.selectedUnit = unit.name;

                            //           // Create final unit string like: "24_Pces_1"
                            //           String finalUnitString =
                            //               "${unit.id}_${unit.name}_1";
                            //           controller.selectedUnitIdWithNameFunction(
                            //               finalUnitString);
                            //         }
                            //       }

                            //       // Secondary unit
                            //       if (selectedItem.secondaryUnitId != null &&
                            //           selectedItem.secondaryUnitId != '') {
                            //         final secondaryUnit =
                            //             unitProvider.units.firstWhere(
                            //           (unit) =>
                            //               unit.id.toString() ==
                            //               selectedItem.secondaryUnitId
                            //                   .toString(),
                            //           orElse: () => Unit(
                            //               id: 0,
                            //               name: 'Unknown Unit',
                            //               symbol: '',
                            //               status: 0),
                            //         );
                            //         if (secondaryUnit.id != 0) {
                            //           unitIdsList.add(secondaryUnit.name);
                            //         }
                            //       }

                            //       if (unitIdsList.isEmpty) {
                            //         print(
                            //             "No valid units found for this item.");
                            //       } else {
                            //         print("Units Available: $unitIdsList");
                            //       }
                            //     },
                            //   ),
                            // ),

                            ///update stock code , for custome price input
                            SizedBox(
                              //color: Colors.blue,
                              child: Consumer<AddItemProvider>(
                                builder: (context, stockProvider, child) {
                                  final stock = stockProvider.stockData;

                                  if (stock != null &&
                                      !controller.hasCustomPrice) {
                                    controller.mrpController.text =
                                        stock.price.toString();
                                  }

                                  return stock != null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "   Stock Available: ${stock.unitStocks} ৳ ${stock.price}",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(); // Show nothing if stock is null
                                },
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            ///qty , unit
                            SizedBox(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      //qty
                                      SizedBox(
                                        width: 150,
                                        child: AddSalesFormfield(
                                          //label: "", //Qty
                                          labelText: "Item Qty",
                                                                  
                                          controller:
                                              controller.qtyController,
                                          keyboardType:
                                              TextInputType.number,
                                          onChanged: (value) {
                                            setState(() {
                                              
                                              controller
                                                  .calculateSubtotal();
                                            });
                                                                  
                                            ///<<<===
                                            //controller.calculateSubtotal();
                                          },
                                        ),
                                      ),
                            
                                      /// Qty Field (✅ Pre-filled here)
                                    ],
                                  ),
                            
                                  ///===>>>unit
                                  // Column(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.start,
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   children: [
                                  //     ///unit dropdown
                                  //     SizedBox(
                                  //       height: 30,
                                  //       width: 150,
                                  //       child: CustomDropdownTwo(
                                  //         //hint: '',
                                  //         items:
                                  //             unitIdsList, // Holds unit names like ["Pces", "Packet"]
                                  //         width: double.infinity,
                                  //         height: 30,
                                  //         //labelText: 'Vat/Tax',
                                  //         labelText: 'Unit',
                                  //         selectedItem:
                                  //             controller.selectedUnit,
                                  //         onChanged: (selectedUnit) {
                                  //           print(
                                  //               "Selected Unit: $selectedUnit");
                            
                                  //           // Update the selected unit in controller
                                  //           controller.selectedUnit =
                                  //               selectedUnit;
                            
                                  //           final selectedUnitObj =
                                  //               unitProvider.units.firstWhere(
                                  //             (unit) =>
                                  //                 unit.name == selectedUnit,
                                  //             orElse: () => Unit(
                                  //               id: 0,
                                  //               name: "Unknown Unit",
                                  //               symbol: "",
                                  //               status: 0,
                                  //             ),
                                  //           );
                            
                                  //           //String finalUnitStringID = '';
                            
                                  //           String finalUnitString = '';
                                  //           int qty = 1; // Default qty
                            
                                  //           // Search through fetchStockQuantity items to find unit ID and qty
                                  //           for (var item
                                  //               in fetchStockQuantity.items) {
                                  //             if (item.id.toString() ==
                                  //                 controller.selcetedItemId) {
                                  //               String unitId =
                                  //                   selectedUnitObj.id
                                  //                       .toString();
                                  //               String unitName =
                                  //                   selectedUnit;
                            
                                  //               // Check if selected unit is the primary or secondary unit and set the correct quantity
                                  //               if (unitId ==
                                  //                   item.secondaryUnitId
                                  //                       .toString()) {
                                  //                 qty = item
                                  //                         .secondaryUnitQty ??
                                  //                     item.unitQty ??
                                  //                     1; // Use secondaryUnitQty, fallback to unitQty or default to 1
                                  //               } else if (unitId ==
                                  //                   item.unitId.toString()) {
                                  //                 qty = item.unitQty ??
                                  //                     1; // Use unitQty or fallback to 1
                                  //               }
                            
                                  //               // Build the final unit string in the required format (e.g., 24_Pces_1)
                                  //               finalUnitString =
                                  //                   "${unitId}_${unitName}_$qty";
                                  //               controller
                                  //                   .selectedUnitIdWithNameFunction(
                                  //                       finalUnitString);
                                  //               break;
                                  //             }
                                  //           }
                            
                                  //           // Fallback if no valid unit string was found
                                  //           if (finalUnitString.isEmpty) {
                                  //             finalUnitString =
                                  //                 "${selectedUnitObj.id}_${selectedUnit}_1"; // Default to 1 if no match
                                  //             controller
                                  //                 .selectedUnitIdWithNameFunction(
                                  //                     finalUnitString);
                                  //           }
                            
                                  //           // Debug print to show final unit ID selected
                                  //           print(
                                  //               "🆔 Final Unit ID: $finalUnitString");
                            
                                  //           // Notify listeners to update the UI
                                  //           controller.notifyListeners();
                                  //         },
                                  //       ),
                                  //     ),
                                  //   ],
                                  // )
                            
                                  ///===>>>Unit dropdown
                                  ///
                            
                                  ///===>>>Unit dropdown
                                  ///===>>>Unit dropdown
                            
                                  /// Unit dropdown
                                  /// Unit Dropdown
                                  SizedBox(
                                    height: 30,
                                    width: 150,
                                    child: CustomDropdownTwo(
                                      items: unitIdsList,
                                      width: double.infinity,
                                      height: 30,
                                      labelText: 'Unit',
                                      selectedItem: controller.selectedUnit,
                                      onChanged: (selectedUnit) {
                                        debugPrint("Selected Unit: $selectedUnit");
                            
                                        controller.selectedUnit =
                                            selectedUnit;
                            
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
                            
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),
                            //purchase price
                            AddSalesFormfield(
                              height: 30,
                              //label: "", //price
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

                            const SizedBox(
                              height: 6,
                            ),

                            ////discount percentan ande amount
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        //discount %
                                        child: SizedBox(
                                          width: 150,
                                          child: AddSalesFormfield(
                                            labelText: "Discount (%)",
                                            //label: " ", //Discount (%)
                                            controller: controller
                                                .discountPercentance,
                                            keyboardType:
                                                TextInputType.number,
                                            onChanged: (value) {
                                              setState(() {
                                                controller.lastChanged =
                                                    'percent';
                                                controller
                                                    .calculateSubtotal();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        //discount amount
                                        child: SizedBox(
                                          width: 150,
                                          child: AddSalesFormfield(
                                            //label: "", //Amount
                                            labelText: "Amount",
                                            controller:
                                                controller.discountAmount,
                                            keyboardType:
                                                TextInputType.number,
                                            onChanged: (value) {
                                              setState(() {
                                                controller.lastChanged =
                                                    'amount';
                            
                                                controller
                                                    .calculateSubtotal();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),

                            const SizedBox(
                              height: 6,
                            ),

                            // ✅ VAT/TAX Dropdown Row
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dropdown
                                Expanded(
                                  child: Consumer<TaxProvider>(
                                    builder: (context, taxProvider, child) {
                                      if (taxProvider.isLoading) {
                                        return const Center(
                                            child:
                                                CircularProgressIndicator());
                                      }
                            
                                      if (taxProvider.taxList.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            'No tax options available.',
                                            style: TextStyle(
                                                color: Colors.black),
                                          ),
                                        );
                                      }
                                      return SizedBox(
                                        width: 150,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //vat, tax %
                                            SizedBox(
                                              height: 30,
                                              child: CustomDropdownTwo(
                                                labelText: 'Vat/Tax',
                                                //hint: '',
                                                items: taxProvider.taxList
                                                    .map((tax) =>
                                                        "${tax.name} - (${tax.percent})")
                                                    .toList(),
                                                width: 150,
                                                height: 30,
                                                selectedItem: selectedTaxName,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedTaxName =
                                                        newValue;
                            
                                                    final nameOnly = newValue
                                                        ?.split(" - ")
                                                        .first;
                            
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
                            
                                                    controller
                                                            .selectedTaxPercent =
                                                        double.tryParse(
                                                            selected.percent);
                            
                                                    // controller.setTaxPercent(selectedTaxPercent ?? 0.0); // 👈 Call controller
                                                    controller
                                                        .taxPercent = controller
                                                            .selectedTaxPercent ??
                                                        0.0;
                            
                                                    controller.updateTaxPaecentId(
                                                        '${selectedTaxId}_${controller.selectedTaxPercent}');
                            
                                                    debugPrint(
                                                        'tax_percent: "${controller.taxPercentValue}"');
                            
                                                    //controller.calculateSubtotal();
                            
                                                    debugPrint(
                                                        "Selected Tax ID: $selectedTaxId");
                                                    debugPrint(
                                                        "Selected Tax Percent: ${controller.selectedTaxPercent}");
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            
                                const SizedBox(width: 8),
                            
                                //vat, tax amount
                                SizedBox(
                                  width: 150,
                                  child: AddSalesFormfield(
                                    readOnly: true,
                                    //label: "", //amount
                                    labelText: "Amount",
                                    controller: TextEditingController(
                                      text: controller.taxAmount
                                          .toStringAsFixed(
                                              2), // 👈 show calculated tax
                                    ),
                                    keyboardType: TextInputType.number,
                                    //readOnly: true, // 👈 prevent manual editing
                                  ),
                                ),
                              ],
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
                                        controller.subtotalWithTax.toStringAsFixed(2),
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
                      
                      ///add
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            );
          });
        });
  }
}

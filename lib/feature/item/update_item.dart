import 'dart:io';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/add_unit.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/item/multiprice_two.dart';
import 'package:cbook_dt/feature/item/multipul_price.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/item_save_provider.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/update_item_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateItem extends StatefulWidget {
  final int itemId;
  const UpdateItem({super.key, required this.itemId});

  @override
  State<UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<UpdateItem> {

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _existingImage;

  ///pick image
  void _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  int? selectedCategoryId;
  int? selectedSubCategoryId;

  String selectedStatus = "1";

  @override
  void initState() {
    super.initState();

    // ✅ fetch unit
    Provider.of<AddItemProvider>(context, listen: false).fetchUnits();

    // ✅ Continue your other data fetch
    Provider.of<ItemUpdateProvider>(context, listen: false)
        .fetchItemDetails(widget.itemId)
        .then((_) => setState(() {}));

    _loadSettings();

    Future.microtask(() {
      final controller = Provider.of<SalesController>(context, listen: false);
      controller.clearUnitSelection();

      controller.salesControllerAS();

      controller.clearSalesFields();

      // this will trigger notifyListeners
    });

    // Fetch categories
    Future.microtask(() =>
        Provider.of<ItemCategoryProvider>(context, listen: false)
            .fetchCategories());

    // Fetch item details and update UI
    final itemProvider =
        Provider.of<ItemUpdateProvider>(context, listen: false);
    itemProvider.fetchItemDetails(widget.itemId).then((_) {
      setState(() {}); // Rebuild the widget once the data is fetched
    });

    // Add listeners to update UI when text changes
    itemProvider.nameController.addListener(() {
      setState(() {});
    });
    itemProvider.priceController.addListener(() {
      setState(() {});
    });
    itemProvider.stockController.addListener(() {
      setState(() {});
    });
    itemProvider.valueController.addListener(() {
      setState(() {});
    });
    itemProvider.purchasePriceController.addListener(() {
      setState(() {});
    });

    itemProvider.unitIdController.addListener(() {
      setState(() {});
    });

    itemProvider.unitIdSecondController.addListener(() {
      setState(() {});
    });

    itemProvider.unitQtyController.addListener(() {
      setState(() {});
    });
  }

  bool _isPriceLevelEnabled = false; // From Settings
  bool _isDefaultPriceChecked = false; // For Checkbox

  bool _isCategoryEnabled = false;

  bool _isSwitchedCategoryPrice =
      false; // Enable/Disable Price Category Switch from Settings
  bool _isPriceCategory = false; // For Checkbox

  bool _isPriceQTYPriceEnable = false;

  bool _isQTYPriceChecked = false;

  bool _isStatusEnabled = false;

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPriceLevelEnabled = prefs.getBool('isSwitchedPrice') ?? false;
      _isCategoryEnabled = prefs.getBool('isSwitchedCategory') ?? false;
      _isSwitchedCategoryPrice =
          prefs.getBool('isSwitchedCategoryPrice') ?? false;
      _isPriceQTYPriceEnable = prefs.getBool('isSwitchedQtyPrice') ?? false;
      _isStatusEnabled = prefs.getBool('isStatus') ?? false;
    });
  }

  // List to store TextEditingController for each row
  List<Map<String, TextEditingController>> _textControllers = [];

  void _addRow() {
    setState(() {
      // Add a new map for qty and price controllers to the list
      _textControllers.add({
        'qty': TextEditingController(),
        'price': TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<ItemCategoryProvider>(context);
    final itemProvider = Provider.of<ItemUpdateProvider>(context);
    final controller = Provider.of<SalesController>(context);

    if (itemProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (itemProvider.item != null) {
      _existingImage = itemProvider.item!.image;
    }

    debugPrint("Name: ${itemProvider.nameController.text}");
    debugPrint("Price: ${itemProvider.priceController.text}");
    debugPrint("Stock: ${itemProvider.stockController.text}");
    debugPrint("Value: ${itemProvider.valueController.text}");
    debugPrint("Purchase Price: ${itemProvider.valueController.text}");

    debugPrint("unit id Price: ${itemProvider.unitIdController.text}");
    debugPrint(
        "unit 2nd id Price: ${itemProvider.unitIdSecondController.text}");
    debugPrint("unit qty Price: ${itemProvider.unitQtyController.text}");
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          //centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: const Text(
            "Update Item",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ////image showing here.
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.green[100],
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _imageFile != null
                                  ? FileImage(File(_imageFile!.path))
                                  : (_existingImage != null &&
                                              _existingImage!.isNotEmpty
                                          ? NetworkImage(
                                              "https://commercebook.site/$_existingImage")
                                          : const AssetImage(
                                              'assets/image/image_color.png'))
                                      as ImageProvider,
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _showImageSourceActionSheet(context),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    ///name
                    AddSalesFormfield(
                      height: 40,
                      labelText: 'Name',
                      controller: itemProvider.nameController,
                    ),

                    const SizedBox(height: 10),

                    ////api unit show and if unit selcted then replace api unit.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer2<AddItemProvider, SalesController>(
                          builder: (context, unitProvider, controller, _) {
                            final unitId = itemProvider.unitIdController.text;
                            final secondaryUnitId =
                                itemProvider.unitIdSecondController.text;
                            final unitQty = itemProvider.unitQtyController.text;

                            final mainUnitName =
                                unitProvider.getUnitSymbol(unitId);
                            final secondaryUnitName =
                                unitProvider.getUnitSymbol(secondaryUnitId);

                            // If user selected custom units, show only selected
                            if (controller.selectedUnit != null &&
                                controller.selectedUnit!.isNotEmpty) {
                              return Text(
                                controller.selectedUnit2 != null &&
                                        controller.selectedUnit2!.isNotEmpty &&
                                        controller.selectedUnit !=
                                            controller.selectedUnit2
                                    ? '1 ${controller.selectedUnit} = ${controller.conversionRate} ${controller.selectedUnit2}'
                                    : '${controller.selectedUnit}',
                                style: GoogleFonts.notoSansPhagsPa(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              );
                            }

                            // Otherwise show API data
                            return Text(
                              secondaryUnitId.isNotEmpty
                                  ? '$unitQty $mainUnitName $secondaryUnitName'
                                  : '$unitQty $mainUnitName',
                              style: GoogleFonts.notoSansPhagsPa(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),

                        /// Additional secondary unit conversion details
                        Column(
                          children: [
                            // If user selected both base and secondary unit
                            if (controller.selectedUnit2 != null &&
                                controller.selectedUnit2!.isNotEmpty &&
                                controller.selectedUnit2 !=
                                    controller.selectedUnit) ...[
                              const SizedBox(height: 5),
                            ]
                            // If only base unit is selected
                            else if (controller.selectedUnit != null &&
                                controller.selectedUnit!.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              // Text(
                              //   controller.selectedUnit!,
                              //   style: const TextStyle(
                              //       fontSize: 12, color: Colors.black),
                              // ),
                            ]
                          ],
                        ),

                        /// Button to open unit selector
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (BuildContext context) {
                                  return DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.45,
                                    minChildSize: 0.35,
                                    maxChildSize: 0.85,
                                    builder: (context, scrollController) {
                                      return Container(
                                        padding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: 16,
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                        ),
                                        child: SingleChildScrollView(
                                          controller: scrollController,
                                          child: SelectUnitBottomSheet(
                                            selectedUnit:
                                                controller.selectedUnit,
                                            selectedUnit2:
                                                controller.selectedUnit2,
                                            conversionRateController: controller
                                                .conversionRateController,
                                            onUnit1Changed: (value) {
                                              controller.updateUnit1(value);
                                            },
                                            onUnit2Changed: (value) {
                                              controller.updateUnit2(value);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: const Text("Selected Unit"),
                          ),
                        ),
                      ],
                    ),

                    vPad5,

                    ///category.
                    Row(
                      children: [
                        // Category Dropdown
                        Expanded(
                          child: categoryProvider.isLoading
                              ? const Center(
                                  child: SizedBox(
                                    width:
                                        24, // Set a fixed size for the progress indicator
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : CustomDropdownTwo(
                                  items: categoryProvider.categories
                                      .map((category) => category.name)
                                      .toList(),
                                  hint: 'Select Category',
                                  width: double.infinity,
                                  height: 40, // Adjust height if needed
                                  onChanged: (value) {
                                    final selectedCategory = categoryProvider
                                        .categories
                                        .firstWhere((cat) => cat.name == value);

                                    setState(() {
                                      selectedCategoryId = selectedCategory.id;
                                      selectedSubCategoryId =
                                          null; // Reset subcategory
                                    });

                                    // Fetch subcategories for selected category
                                    categoryProvider.fetchSubCategories(
                                        selectedCategory.id);
                                  },
                                ),
                        ),

                        const SizedBox(width: 10), // Spacing between dropdowns

                        // Subcategory Dropdown
                        Expanded(
                          child: categoryProvider.isSubCategoryLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : categoryProvider.subCategories.isNotEmpty
                                  ? CustomDropdownTwo(
                                      items: categoryProvider.subCategories
                                          .map(
                                              (subCategory) => subCategory.name)
                                          .toList(),
                                      hint: 'Select Sub Category',
                                      width: double.infinity,
                                      height: 40, // Adjust height if needed
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
                                            "Selected Sub Category ID: ${selectedSubCategory.id}");
                                      },
                                    )
                                  : const Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "No subcategories available",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                    ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    ///price , and value

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            height: 40,
                            labelText: 'Price',
                            controller: itemProvider.priceController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AddSalesFormfield(
                            height: 40,
                            labelText: 'Value',
                            controller: itemProvider.valueController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ///stock and purchase price.
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                            height: 40,
                            labelText: 'Stock',
                            controller: itemProvider.stockController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AddSalesFormfield(
                            height: 40,
                            labelText: 'Purchase Price',
                            controller: itemProvider.purchasePriceController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ///sales price and mrp price.
                    Row(
                      children: [
                        Expanded(
                          child: AddSalesFormfield(
                              height: 40,
                              labelText: 'Sale Price',
                              controller: itemProvider.salePriceController),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AddSalesFormfield(
                              height: 40,
                              labelText: 'MRP Price',
                              controller: itemProvider.mrpPriceController),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    //////===========>Price level , if its enable from settings then show it.
                    const SizedBox(
                      height: 10,
                    ),

                    ///====> price level

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Price Level",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isPriceLevelEnabled) // If Price Level is Enabled from Settings
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isDefaultPriceChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isDefaultPriceChecked = value ?? false;
                                      });
                                    },
                                  ),
                                  const Text(
                                    "Default Price",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              if (_isDefaultPriceChecked)
                                const Padding(
                                  padding: EdgeInsets.only(left: 50.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5),
                                      SupplierCustomerPriceTwoPage(), // your price fields
                                    ],
                                  ),
                                )
                            ],
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),

                    ///===> price category
                    if (_isSwitchedCategoryPrice) // Check if enabled from Settings
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _isPriceCategory,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isPriceCategory = value!;
                                  });
                                },
                              ),
                              const Text(
                                "Price Category",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          if (_isPriceCategory) // Show price fields only if checkbox ticked
                            const Padding(
                              padding: EdgeInsets.only(left: 50.0),
                              child: SupplierCustomerPricePage(),
                            ),
                        ],
                      )
                    else
                      const SizedBox
                          .shrink(), // If switch is disabled, show nothing

                    /////qty price
                    ///
                    if (_isPriceQTYPriceEnable) ...[
                      Row(
                        children: [
                          Checkbox(
                            value: _isQTYPriceChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isQTYPriceChecked = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "QTY price",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ],
                      ),
                      if (_isQTYPriceChecked)
                        Padding(
                          padding: const EdgeInsets.only(left: 50.0, top: 4),
                          child: Column(
                            children: [
                              const Text(
                                "Auto Qty & Price (Only Default Price allow)",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 13),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white),
                                onPressed: _addRow,
                                child: const Text("Add"),
                              ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _textControllers.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      // Quantity TextField

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0, right: 5),
                                        child: Text(
                                          "${index + 1}.",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),

                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Qty",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: AddSalesFormfield(
                                              controller: _textControllers[
                                                      index][
                                                  'qty']!, // _textControllers[index]['price']

                                              keyboardType:
                                                  TextInputType.number,

                                              onChanged: (qtyValue) {
                                                final provider =
                                                    Provider.of<ItemProvider>(
                                                        context,
                                                        listen: false);
                                                final priceValue =
                                                    _textControllers[index]
                                                                ['price']
                                                            ?.text ??
                                                        '';
                                                provider.updateQtyPrice(
                                                  index,
                                                  qty: qtyValue,
                                                  price: priceValue,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Padding(
                                        padding:
                                            EdgeInsets.only(top: 18.0, left: 8),
                                        child: Text(
                                          ">=",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),

                                      const SizedBox(width: 10),
                                      // Price TextField
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Price",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14)),
                                          SizedBox(
                                            width: 100,
                                            child: AddSalesFormfield(
                                              controller:
                                                  _textControllers[index]
                                                      ['price']!,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (priceValue) {
                                                final provider =
                                                    Provider.of<ItemProvider>(
                                                        context,
                                                        listen: false);
                                                final qtyValue =
                                                    _textControllers[index]
                                                                ['qty']
                                                            ?.text ??
                                                        '';
                                                provider.updateQtyPrice(
                                                  index,
                                                  qty: qtyValue,
                                                  price: priceValue,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _textControllers.removeAt(index);
                                            });
                                          },
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                    ],

                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {
                  final itemProvider =
                      Provider.of<ItemUpdateProvider>(context, listen: false);
                  itemProvider.updateItem(widget.itemId, context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Update Item",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }

  ///action sheet gallery, camera
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

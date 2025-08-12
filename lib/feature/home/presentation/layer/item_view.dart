import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/feature_not_available.dart';
import 'package:cbook_dt/feature/Received/received_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/expense_list.dart';
import 'package:cbook_dt/feature/account/ui/income/income_list.dart';
import 'package:cbook_dt/feature/item/add_item.dart';
import 'package:cbook_dt/feature/item/item_details.dart';
import 'package:cbook_dt/feature/item/model/items_show.dart';
import 'package:cbook_dt/feature/item/update_item.dart';
import 'package:cbook_dt/feature/payment_out/payment_out_list.dart';
import 'package:cbook_dt/feature/purchase/purchase_list_api.dart';
import 'package:cbook_dt/feature/purchase_return/purchase_return_list.dart';
import 'package:cbook_dt/feature/sales/sales_list.dart';
import 'package:cbook_dt/feature/sales_bulk/sales_bulk.dart';
import 'package:cbook_dt/feature/sales_return/sales_return_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../item/provider/items_show_provider.dart';
import 'package:http/http.dart' as http;

class ItemView extends StatefulWidget {
  const ItemView({super.key});

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  int itemCount = 0;

  @override
  void initState() {
    super.initState();

    _initData();
  }

  void _initData() async {
    final provider = context.read<AddItemProvider>();

    await provider.fetchItems();

    setState(() {
      itemCount = provider.items.length;
    });

    if (!mounted) return; // Widget might have been disposed

    for (var item in provider.items) {
      await provider.fetchStockQuantity(item.id.toString());
    }

    if (!mounted) return;

    await provider.fetchUnits();
  }

  // Map<int, String> unitMap = {}; // Store unitId -> unitName
  Map<int, String> unitMap = {};

  final String base_url = "https://commercebook.site/";

  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorTheme.primary,
        centerTitle: true,
        title: Row(
          children: [
            // If searching: Show search field (left side)
            if (isSearching)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          cursorColor: Colors.white,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1),
                            ),
                            //filled: true,
                            fillColor: Colors.green,

                            hintText: '',
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          isSearching = false;
                          searchController.clear();
                        });
                      },
                    ),
                  ],
                ),
              )
            else
              // If not searching: Show search icon + Party text + Add icon
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center: Party title
                    const Center(
                      child: Text(
                        'Item/Product',
                        style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Left: Search icon
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isSearching = true;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.search,
                                color: Colors.green, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Always visible: Add icon
            IconButton(
              icon: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: Colors.green)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItem(),
                  ),
                );
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FocusableActionDetector(
              autofocus: true,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) => _buildBottomSheetContent(context),
                  );
                },
                child: Container(
                  width: 50, // Make sure width and height are equal
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xffdddefa),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left (Customer)
                  Row(
                    children: [
                      const Icon(Icons.handshake, color: Colors.blue),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Item",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12)),
                          Text(itemCount.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),

                  // Vertical Divider
                  SizedBox(
                    height: 35,
                    width: 35,
                    child: Image.asset('assets/image/product.png'),
                  ),

                  // Right (Supplier)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Right (Stock Value - Now Dynamic)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("Stock Value",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12)),
                                  Consumer<AddItemProvider>(
                                    builder: (context, provider, child) {
                                      return Text(
                                        provider.getFormattedTotals(),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Text("10,01,55,320",
                          //     style:
                          //         TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AddItemProvider>(
                builder: (context, itemProvider, child) {
                  if (itemProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemProvider.items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items available.',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero, // No padding
                          itemCount: itemProvider.items.length,

                          separatorBuilder: (context, index) => const SizedBox(
                            height: 1,
                          ),

                          // 1px space
                          itemBuilder: (context, index) {
                            ItemsModel item = itemProvider.items[index];
                            debugPrint("Item from provider: ${item.name}");
                            debugPrint("Item from provider: ${item.id}");

                            final itemCount = itemProvider.items.length;

                            final itemId = item.id;

                            final unitName = itemProvider
                                .getUnitSymbol(item.unitId?.toString());

                            final secondaryUnitName =
                                item.secondaryUnitId != null &&
                                        item.secondaryUnitId != 0
                                    ? itemProvider.getUnitSymbol(
                                        item.secondaryUnitId?.toString())
                                    : null;

                            return InkWell(
                              onLongPress: () {
                                editDeleteDiolog(context, itemId.toString());
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailsView(
                                        itemId: item.id, item: item),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        2), // 🔥 Rounded corner radius here
                                  ),
                                  shadowColor: const Color(0xff396be8),
                                  elevation: 1, // Optional: add shadow
                                  margin: EdgeInsets.zero, // No margin
                                  child: ListTile(
                                    minVerticalPadding: 0,
                                    visualDensity: const VisualDensity(
                                        vertical: 0, horizontal: 0),
                                    //contentPadding: EdgeInsets.zero,

                                    contentPadding: const EdgeInsets.only(
                                        left: 4, right: 4),
                                    title: Row(
                                      children: [
                                        /// Product image
                                        SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Image.network(
                                            "$base_url${item.image}",
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                "assets/image/no_pictures.png",
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 6),

                                        /// item name , box, mrp, sales price, purchase price.
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              /// Item details
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        263, // Adjust based on layout space
                                                    height:
                                                        18, // To restrict vertical overflow
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Text(
                                                        item.name,
                                                        style: GoogleFonts
                                                            .notoSansPhagsPa(
                                                          fontSize: 13,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Text(
                                                  //   secondaryUnitName != null
                                                  //       ? '1 $unitName ${item.unitQty} $secondaryUnitName'
                                                  //       : unitName,
                                                  //   overflow:
                                                  //       TextOverflow.ellipsis,
                                                  //   style: GoogleFonts
                                                  //       .notoSansPhagsPa(
                                                  //     fontSize: 12,
                                                  //     color: Colors.blue,
                                                  //   ),
                                                  // ),
                                                  item.openingStock == null
                                                      ? Text(
                                                          'Stock: 0 $unitName',
                                                          style: GoogleFonts
                                                              .notoSansPhagsPa(
                                                            fontSize: 11,
                                                            color: Colors.black,
                                                          ),
                                                        )
                                                      : Text(
                                                          "Stock: ${item.openingStock} $unitName",
                                                          style: GoogleFonts
                                                              .notoSansPhagsPa(
                                                            fontSize: 11,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                ],
                                              ),

                                              /// Prices
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 2.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    FittedBox(
                                                      child: item.salesPrice ==
                                                              null
                                                          ? Text(
                                                              'S.Price N/A',
                                                              style: GoogleFonts
                                                                  .notoSansPhagsPa(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            )
                                                          : Text(
                                                              "S. Price: ${item.salesPrice}",
                                                              style: GoogleFonts
                                                                  .notoSansPhagsPa(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                    ),
                                                    item.purchasePrice == null
                                                        ? Text(
                                                            'Purchase N/A',
                                                            style: GoogleFonts
                                                                .notoSansPhagsPa(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          )
                                                        : Text(
                                                            "Purchase: ${item.purchasePrice}",
                                                            style: GoogleFonts
                                                                .notoSansPhagsPa(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////delete and edit alart diolog
  Future<dynamic> editDeleteDiolog(BuildContext context, String itemId) {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16), // Adjust side padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            width: double.infinity, // Full width
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Height as per content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Action',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          border: Border.all(
                              color: Colors.grey,
                              width: 1), // Border color and width
                          borderRadius: BorderRadius.circular(
                              50), // Corner radius, adjust as needed
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.primary, // Use your color
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    //Navigate to Edit Page

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateItem(itemId: int.parse(itemId)),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Edit',
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
                // const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteDialog(context, itemId);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Delete',
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /////delete diolog
  void _showDeleteDialog(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Item',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Item?',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // final provider =
              //     Provider.of<CustomerProvider>(context, listen: false);
              // bool isDeleted =
              //     await provider.deleteCustomer(int.parse(customerId));

              // if (isDeleted) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Text(
              //         'Item deleted successfully!',
              //         style: TextStyle(color: colorScheme.primary),
              //       ),
              //     ),
              //   );
              //   Navigator.of(context).pop(); // Close dialog
              //   await provider.fetchCustomsr(); // Refresh list
              // } else {
              //   Navigator.of(context).pop(); // Close dialog
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text(
              //         'Failed to delete Item',
              //         style: TextStyle(color: Colors.red),
              //       ),
              //     ),
              //   );
              // }

              final provider =
                  Provider.of<AddItemProvider>(context, listen: false);
              bool isDeleted = await provider
                  .deleteItem(int.parse(itemId)); // itemId as string

              Navigator.of(context).pop(); // Always close the dialog

              if (isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete Item'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  ///Feature Not Available
  void showFeatureNotAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Not Available'),
        content: const Text(
          'This feature is not available right now.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  ////bottom item modal shet
  Widget _buildBottomSheetContent(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title for Sales Transaction
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //     context, MaterialPageRoute(builder: (_) => SalesScreen()));

                    _buildBottomSheetContent(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0), // Only vertical padding
                        child: Text(
                          "Sales Transaction",
                          style: GoogleFonts.notoSansPhagsPa(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.yellow,
                            )),
                      ),
                    ],
                  ),
                ),

                // Icons with text in a Wrap for Sales Transaction
                Wrap(
                  spacing: 10,
                  runSpacing: 20,
                  children: [
                    //// Sales/Bill/\nInvoice
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SalesScreen()));

                          // showFeatureNotAvailableDialog(context);
                        },
                        child: _buildIconWithLabel(Icons.shopping_cart_checkout,
                            "Sales/Bill/\nInvoice", context)),

                    //// bulk sales
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ItemListPage()));

                          // showFeatureNotAvailableDialog(context);
                        },
                        child: _buildIconWithLabel(
                            Icons.apps, "Bulk sales/\nInvoice", context)),

                    //// Estimate/\nQuotation
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.view_timeline, "Estimate/\nQuotation", context),
                    ),

                    //// Challan
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  const FeatureNotAvailableDialog());
                        },
                        child:
                            _buildIconWithLabel(Icons.tab, "Challan", context)),

                    //// Receipt In
                    InkWell(
                        onTap: () {
                          // showDialog(
                          //     context: context,
                          //     builder: (context) =>
                          //         const FeatureNotAvailableDialog());

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ReceivedList()));
                        },
                        child: _buildIconWithLabel(
                            Icons.receipt, "Receipt In", context)),

                    ////Sales\nReturn
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const SalesReturnScreen())); //SalesReturnView
                        //showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(
                          Icons.redo, "Sales\nReturn", context),
                    ),

                    ////Delivery
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  const FeatureNotAvailableDialog());
                        },
                        child: _buildIconWithLabel(
                            Icons.delivery_dining, "Delivery", context)),
                  ],
                ),

                // Purchase Transaction Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Purchase Transaction",
                    style: GoogleFonts.notoSansPhagsPa(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Wrap(
                  runSpacing: 20,
                  spacing: 10,
                  children: [
                    ////Purchase
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PurchaseListApi()));

                        //showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(
                          Icons.add_shopping_cart_rounded, "Purchase", context),
                    ),

                    ////  Purchase/\nOrder
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.work_history, "Purchase/\nOrder", context),
                    ),

                    //// Payment\nOut
                    InkWell(
                        onTap: () {
                          // showDialog(
                          //     context: context,
                          //     builder: (context) =>
                          //         const FeatureNotAvailableDialog());

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PaymentOutList()));
                        },
                        child: _buildIconWithLabel(
                            Icons.tab, "Payment\nOut", context)),

                    ///// Purchase\nReturn
                    InkWell(
                      onTap: () {},
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PurchaseReturnList()));

                          //showFeatureNotAvailableDialog(context);
                        },
                        child: _buildIconWithLabel(
                            Icons.redo_rounded, "Purchase\nReturn", context),
                      ),
                    ),
                  ],
                ),

                // Account Transaction Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0), // Only vertical padding
                  child: Text(
                    "Account Transaction",
                    style: GoogleFonts.notoSansPhagsPa(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),

                Wrap(
                  runSpacing: 20,
                  spacing: 10,
                  children: [
                    ////Purchase
                    InkWell(
                      onTap: () {
                        // showDialog(
                        //     context: context,
                        //     builder: (context) =>
                        //         const FeatureNotAvailableDialog());

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Expanse()));
                      },
                      child: _buildIconWithLabel(
                          Icons.card_travel, "Expense", context),
                    ),

                    ////  Purchase/\nOrder
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.work_history, "Contacts", context),
                    ),

                    //// Payment\nOut
                    InkWell(
                        onTap: () {
                          // showDialog(
                          //     context: context,
                          //     builder: (context) =>
                          //         const FeatureNotAvailableDialog());

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Income()));
                        },
                        child:
                            _buildIconWithLabel(Icons.tab, "Income", context)),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////icon with label
  Widget _buildIconWithLabel(
      IconData icon, String label, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primaryColor,
            ),
          ),
        ), // Icon size and color
        const SizedBox(height: 4), // Space between icon and text
        Text(
          label,
          style:
              GoogleFonts.notoSansPhagsPa(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

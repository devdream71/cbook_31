import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/item_details_pop_up_two.dart';
import 'package:cbook_dt/feature/item/model/items_show_model.dart';
import 'package:cbook_dt/feature/item/model/new_update_item_details_model.dart';
import 'package:cbook_dt/feature/item/update_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ItemDetailsView extends StatefulWidget {
  final int itemId;
  final ItemsModel item;

  const ItemDetailsView({super.key, required this.itemId, required this.item});

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  bool isLoading = true;
  ItemDetail? itemDetails;
  String errorMessage = "";
  final String baseUrl = "https://commercebook.site/";

  String? selectedDropdownValue;

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() {
          errorMessage = "No authentication token found";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://commercebook.site/api/v1/item/show/${widget.itemId}'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Item Details API Response: $data");

        final itemDetailResponse = NewItemDetailResponse.fromJson(data);
        if (itemDetailResponse.success) {
          setState(() {
            itemDetails = itemDetailResponse.data.itemName;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Failed to fetch item details";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              "Error: ${response.statusCode} - ${response.reasonPhrase}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  // Add filtering method
  List<PurchaseDetail> getFilteredPurchaseDetails() {
    if (selectedDropdownValue == null || 
        selectedDropdownValue == "All" || 
        itemDetails?.purchaseDetails == null) {
      return itemDetails?.purchaseDetails ?? [];
    }
    
    // Convert dropdown value to match API transaction types
    String filterType;
    switch (selectedDropdownValue!) {
      case "Purchase":
        filterType = "purchase";
        break;
      case "Sales":
        filterType = "sales";
        break;
      case "Purchase Return":
        filterType = "purchase_return";
        break;
      case "Sales Return":
        filterType = "sales_return";
        break;
      case "Opening":
        filterType = "opening";
        break;
      default:
        return itemDetails?.purchaseDetails ?? [];
    }
    
    return itemDetails!.purchaseDetails
        .where((detail) => detail.type.toLowerCase() == filterType)
        .toList();
  }

  String _formatTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
        return 'Purchase';
      case 'purchase_return':
        return 'Purchase Return';
      case 'sales':
        return 'Sales';
      case 'sales_return':
        return 'Sales Return';
      case 'opening':
        return 'Opening';
      default:
        return type; // Return original if not found
    }
  }

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 13);
  TextStyle ts2 = const TextStyle(
      color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use API data if available, otherwise fall back to passed item data
    final item = widget.item;
    final itemName = itemDetails?.name ?? item.name;
    final purchasePrice =
        itemDetails?.purchasePrice ?? item.purchasePrice?.toString() ?? '0';
    final salesPrice =
        itemDetails?.salesPrice ?? item.salesPrice?.toString() ?? '0';
    final mrpspricesPrice =
        itemDetails?.mrpPrice ?? item.mrp?.toString() ?? '0';
    final image = itemDetails?.image ?? item.image;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: Column(
          children: [
            Text(
              itemName,
              style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateItem(itemId: widget.itemId),
                    ));
              },
              icon: const Icon(Icons.edit_document))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = "";
                          });
                          fetchItemDetails();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0.0, right: 0, top: 0),
                        child: SizedBox(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      height: 90,
                                      width: 120,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          "$baseUrl${image ?? ''}",
                                          height: 110,
                                          width: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                                "assets/image/no_pictures.png",
                                                fit: BoxFit.fill);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0.0, vertical: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 0.0),
                                        child: Column(
                                          children: [
                                            const ItemDetailsPopUpTwo(
                                              leftTest: "Default Price",
                                              rightText: "",
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ItemDetailsPopUpTwo(
                                              leftTest: "Purchase Price",
                                              rightText: purchasePrice,
                                            ),
                                            ItemDetailsPopUpTwo(
                                              leftTest: "Sales Price",
                                              rightText: salesPrice,
                                            ),
                                            ItemDetailsPopUpTwo(
                                              leftTest: "MRP Price",
                                              rightText: mrpspricesPrice,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Row(
                            children: [],
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Transactions History",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: SizedBox(
                                    height: 30,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 0),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                        ),
                                      ),
                                      value: selectedDropdownValue,
                                      hint: const Text("All"),
                                      menuMaxHeight: 200,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedDropdownValue = newValue;
                                        });
                                        // Debug print to verify filtering is working
                                        debugPrint("Filter changed to: $newValue");
                                        debugPrint("Filtered items: ${getFilteredPurchaseDetails().length}");
                                      },
                                      items: [
                                        "All",
                                        "Purchase",
                                        "Sales",
                                        "P. Return",
                                        "S.  Return",
                                        'Opening'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0, vertical: 0),
                                            child: Text(value,
                                                style:
                                                    GoogleFonts.notoSansPhagsPa(
                                                        fontSize: 12,
                                                        color: Colors.black)),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Use the filtered list here instead of the original purchaseDetails
                          Builder(
                            builder: (context) {
                              final filteredDetails = getFilteredPurchaseDetails();
                              
                              if (filteredDetails.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                                  child: Center(
                                    child: Text(
                                      "No transactions found for selected filter.",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                );
                              }
                              
                              return Column(
                                children: filteredDetails.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  PurchaseDetail purchase = entry.value;
                                  Color bgColor = index % 2 == 0
                                      ? Colors.blueGrey.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1);

                                  return Container(
                                    color: bgColor,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 1, horizontal: 1),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 130,
                                              child: Text(
                                                itemDetails!.openingDate,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _formatTransactionType(
                                                  purchase.type),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                            Text(
                                              purchase.billNumber,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 40,
                                          width: 2,
                                          color: const Color(0xff278d46),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (purchase.transaction != null &&
                                                purchase.transaction != 'N/A')
                                              Text(
                                                "${purchase.transaction}",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            if (purchase.transaction != 'cash' &&
                                                purchase.proprietorName != null &&
                                                purchase.proprietorName != 'N/A')
                                              Text(
                                                purchase.proprietorName,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Bill Qty: ${purchase.qty}",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              "Price: ${itemDetails!.openingPrice}",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              "Amount: ${purchase.subTotal}",
                                              style: const TextStyle(
                                                  color: Color(0xff5156be),
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
    );
  }
}


 
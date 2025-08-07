import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/close_button_icon.dart';
import 'package:cbook_dt/common/item_details_pop_up.dart';
import 'package:cbook_dt/common/item_details_pop_up_two.dart';
import 'package:cbook_dt/feature/item/model/items_show.dart';
import 'package:cbook_dt/feature/item/update_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ItemDetailsView extends StatefulWidget {
  final int itemId;
  final ItemsModel item;

  const ItemDetailsView({super.key, required this.itemId, required this.item});

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {

  bool isLoading = true;
  Map<String, dynamic>? itemDetails;
  //List<dynamic> purchaseDetails = [];
  final String baseUrl = "https://commercebook.site/";

  DateTime selectedStartDate = DateTime.now();
  // Default to current date
  DateTime selectedEndDate = DateTime.now();
  // Default to current date
  String? selectedDropdownValue;

  
  ///selected date.
  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  } 

  @override
  void initState() {
    super.initState();
    //fetchItemDetails();
  }

  // Future<void> fetchItemDetails() async {
  //   final String apiUrl =
  //       "https://commercebook.site/api/v1/item/show/${widget.itemId}";

  //   try {
  //     final response = await http.get(Uri.parse(apiUrl));

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       setState(() {
  //         itemDetails = data['data']['item_name'];
  //         purchaseDetails = itemDetails?['pruchase_details'] ?? [];
  //         isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Failed to load item details")),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   }
  // }

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 13);
  TextStyle ts2 = const TextStyle(
      color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // final itemName = itemDetails?['name'] as String? ?? '';
    // final purchasePrice = itemDetails?['purchase_price']?.toString() ?? 'N/A';
    // final salesPrice = itemDetails?['sales_price']?.toString() ?? 'N/A';
    // final mrpspricesPrice = itemDetails?['mrps_price']?.toString() ?? 'N/A';

    final item = widget.item;
    final itemName = item.name;
    final purchasePrice = item.purchasePrice?.toString() ?? '0';
    final salesPrice = item.salesPrice?.toString() ?? '0';
    final mrpspricesPrice = item.mrp?.toString() ?? '0';
    final image = item.image;
    final purchaseDetails = item.purchaseDetails ?? [];

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        //centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: Column(
          children: [
            Text(
              itemName,
              style: const TextStyle(
                  color: Colors.white,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
              child: SizedBox(
                //color: Colors.grey.shade300,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///===>>>Image , text, and 5 icon
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(4)),
                            height: 90,
                            width: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "$baseUrl${image ?? ''}",
                                height: 110,
                                width: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
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

                    const SizedBox(
                      width: 6,
                    ),

                    ///item name, vat/tex, exclusive, inclusive
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Column(
                                children: [
                                  const ItemDetailsPopUpTwo(
                                    leftTest: "Vat/Tax 15%",
                                    rightText: 'Exclusive',
                                    last: "Inclusive",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ItemDetailsPopUpTwo(
                                    leftTest: "Pur Price",
                                    rightText: purchasePrice,
                                    last: purchasePrice,
                                  ),
                                  ItemDetailsPopUpTwo(
                                    leftTest: "Sales. Price",
                                    rightText: salesPrice,
                                    last: salesPrice,
                                  ),
                                  const ItemDetailsPopUpTwo(
                                    leftTest: "Discount",
                                    rightText: '5%',
                                    last: " ",
                                  ),
                                  ItemDetailsPopUpTwo(
                                    leftTest: "MRP",
                                    rightText: mrpspricesPrice,
                                    last: mrpspricesPrice,
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
            //const SizedBox(height: 10),

            //// info and dropdown filter.,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                //color: Colors.white
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    ///info button
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        iconSize: 20, // match icon size
                        padding: EdgeInsets
                            .zero, // remove inner padding :contentReference[oaicite:1]{index=1}
                        constraints:
                            const BoxConstraints(), // override default 48×48 minimum :contentReference[oaicite:2]{index=2}
                        visualDensity: VisualDensity
                            .compact, // further tighten around the icon :contentReference[oaicite:3]{index=3}
                        onPressed: () {
                          showItemDetailsDialog(context);
                        },
                        icon: Icon(
                          Icons.info,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Dropdown
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: SizedBox(
                        height: 30,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                                  const BorderSide(color: Colors.transparent),
                            ),
                          ),
                          value: selectedDropdownValue,
                          hint: const Text("All"),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDropdownValue = newValue;
                            });
                          },
                          items: [
                            "All",
                            "Purchase",
                            "Sale",
                            "P. Return",
                            "S. Return"
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(value,
                                    style: GoogleFonts.notoSansPhagsPa(
                                        fontSize: 12, color: Colors.black)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text(
                    "Purchase History",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                purchaseDetails.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Center(
                          child: Text(
                            "No Bill Transection found.",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                    : Column(
                        children: purchaseDetails.asMap().entries.map((entry) {
                          int index = entry.key;
                          var purchase = entry.value;
                          Color bgColor = index % 2 == 0
                              ? Colors.blueGrey.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1);

                          return Container(
                            color: bgColor,
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      purchase.purchaseDate,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      purchase.type,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),

                                //divider
                                Container(
                                  height: 30,
                                  width: 2,
                                  color: Colors.green.shade200,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Qty: ${purchase.qty}",
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                    Text(
                                      "Price: ${purchase.price}",
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showItemDetailsDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 270,
            decoration: BoxDecoration(
              color: const Color(0xffe7edf4),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  color: colorScheme.primary,
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
                            "Item Information",
                            style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      // Cancel icon on the right

                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: CloseButtonIconNew(
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Code/SKU/HSN",
                        rightText: ' ',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Model No",
                        rightText: ' ',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Barcode",
                        rightText: ' ',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Unit",
                        rightText: '1 box = 10',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Category",
                        rightText: 'Light',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Sub Category",
                        rightText: 'Gadget',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Brand",
                        rightText: 'Vision',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Opening Date",
                        rightText: '01/01/2025',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "current Stock Qty",
                        rightText: '2.5 Box',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Secondary Stock Qty",
                        rightText: '25 Pc',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Current Unit Value",
                        rightText: '155',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';
import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:flutter/material.dart';

class CustomDropdownFour extends StatefulWidget {
  final List<Customer> items;
  final String hint;
  final Function(Customer) onChanged;
  final double width;
  final double height;
  final Customer? selectedItem;
  final String addCustomerOrSupplier;
  final void Function()? onTap;

  const CustomDropdownFour({
    super.key,
    required this.items,
    required this.hint,
    required this.onChanged,
    required this.width,
    required this.height,
    this.selectedItem,
    required this.addCustomerOrSupplier,
    required this.onTap,
  });

  @override
  CustomDropdownFourState createState() => CustomDropdownFourState();
}

class CustomDropdownFourState extends State<CustomDropdownFour> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool isDropdownOpen = false;
  Customer? selectedItem;

  late List<Customer> filteredItems;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    selectedItem =
        widget.selectedItem ?? widget.items.first; // Set default selected item
    filteredItems = List.from(widget.items);
    searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      setState(() {
        filteredItems = widget.items
            .where((item) => item.name
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  void _toggleDropdown() {
    if (isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      isDropdownOpen = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_searchFocusNode.canRequestFocus) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      }
    });
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      isDropdownOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    double maxWidth = MediaQuery.of(context).size.width * 0.8 - 18;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeDropdown,
              behavior: HitTestBehavior.opaque,
              child: Container(),
            ),
          ),
          Positioned(
            width: widget.width == double.infinity ? maxWidth : widget.width,
            left: offset.dx,
            top: offset.dy + size.height,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height),
              child: Material(
                elevation: 4.0,
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Showing saved customer",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            InkWell(
                              onTap: widget.onTap,
                              child: Text(
                                widget.addCustomerOrSupplier,
                                style: const TextStyle(
                                    color: Colors.blue, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            controller: searchController,
                            focusNode: _searchFocusNode,
                            cursorHeight: 18,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: "Search customer",
                              hintStyle: TextStyle(fontSize: 14),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              suffixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: filteredItems.isNotEmpty
                            ? ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                children: filteredItems.map((customer) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedItem = customer;
                                      });
                                      widget.onChanged(customer);
                                      _removeDropdown();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  //if (customer.type == 'customer')
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(top: 2),
                                                    child: Icon(
                                                      Icons.circle,
                                                      color: customer.type ==
                                                              'customer'
                                                          ? Colors.green
                                                          : Colors
                                                              .red, // Green for customers, red for suppliers
                                                      size: 6,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    width: 5,
                                                  ),

                                                  Text(
                                                    customer.name,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Text(
                                            "৳ ${customer.due.toStringAsFixed(2)}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    customer.type == 'customer'
                                                        ? Colors.green
                                                        : Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                child: Text(
                                  "No customer found",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _removeDropdown();
    searchController.removeListener(_onSearchTextChanged);
    _debounce?.cancel();
    searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width * 0.8 - 5;
    final displayValue = selectedItem?.name.isNotEmpty == true
        ? selectedItem?.name
        : widget.hint;
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: widget.width == double.infinity ? maxWidth : widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayValue ?? '',
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                isDropdownOpen
                    ? Icons.arrow_drop_up
                    : Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

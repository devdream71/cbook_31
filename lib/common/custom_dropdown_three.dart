import 'dart:async';
import 'package:flutter/material.dart';

class CustomDropdownThree extends StatefulWidget {
  final List<String> items;
  // final List<Customer> items; 
  final String hint;
  final Function(String) onChanged;
  final double width;
  final double height;
  final String? selectedItem;
  final String? value;
  final String addCustomerOrSupplier;
  final void Function()? onTap;

  const CustomDropdownThree({
    Key? key,
    required this.items,
    required this.hint,
    required this.onChanged,
    required this.width,
    required this.height,
    this.selectedItem,
    this.value,
    required this.addCustomerOrSupplier,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomDropdownThreeState createState() => _CustomDropdownThreeState();
}

class _CustomDropdownThreeState extends State<CustomDropdownThree> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool isDropdownOpen = false;
  String? selectedItem;

   

  late List<String> filteredItems;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounce;
  
  

  @override
  void initState() {
    super.initState();
    selectedItem = widget.selectedItem ?? widget.hint;
    filteredItems = List.from(widget.items);
    searchController.addListener(_onSearchTextChanged);
  }

  @override
  void didUpdateWidget(covariant CustomDropdownThree oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != null && widget.value != selectedItem) {
      setState(() {
        selectedItem = widget.value;
      });
    }

    if (oldWidget.items != widget.items) {
      filteredItems = List.from(widget.items);
    }
  }

  void _onSearchTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      setState(() {
        filteredItems = widget.items
            .where((item) => item
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  void _onSearchTextChangedTwo() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      setState(() {
        filteredItems = widget.items
            .where((item) => item
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
                              onTap: 
                              widget.onTap,
                              // () 
                              // {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           const CustomerCreate(),
                              //     ),
                              //   );
                              //   _removeDropdown();
                              // },
                              child: Text(
                                widget.addCustomerOrSupplier,
                                style:
                                    const TextStyle(color: Colors.blue, fontSize: 12),
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
                                children: filteredItems.map((item) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedItem = item;
                                      });
                                      widget.onChanged(item);
                                      _removeDropdown();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16),
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
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
    final displayValue =
        selectedItem?.isNotEmpty == true ? selectedItem : widget.hint;
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
                isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

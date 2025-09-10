import 'package:cbook_dt/feature/item/add_item.dart';
import 'package:cbook_dt/feature/item/model/items_show_model.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ItemCustomDropDownTextField extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final Color? color;
  final ItemsModel? initialItem;

  final void Function()? onTap;

  final void Function(ItemsModel selectedItem)? onItemSelected;

  const ItemCustomDropDownTextField({
    super.key,
    this.label,
    required this.controller,
    this.color,
    this.onTap,
    this.onItemSelected,
    this.initialItem,
  });

  @override
  State<ItemCustomDropDownTextField> createState() =>
      _ItemCustomDropDownTextFieldState();
}

class _ItemCustomDropDownTextFieldState
    extends State<ItemCustomDropDownTextField> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<ItemsModel> _filteredItems = [];

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        final provider = Provider.of<AddItemProvider>(context, listen: false);
        _filteredItems = provider.items;
        _showOverlay(context);
      } else {
        _removeOverlay();
      }
    });

    if (widget.initialItem != null) {
      widget.controller.text = widget.initialItem!.name;
    }

    // final fetchStockQuantity =
    //     Provider.of<AddItemProvider>(context, listen: false);

    Provider.of<AddItemProvider>(context, listen: false).clearStockData();
  }

  void _showOverlay(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          color: Colors.white,
          child: Consumer<AddItemProvider>(
            builder: (context, provider, _) {
              if (_filteredItems.isEmpty) return const SizedBox.shrink();
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 4.0, left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Showing item list",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddItem()),
                              );
                            },
                            child: const Text(
                              "Add new Item",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: widget.color,
                      height: 1,
                      thickness: 1,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return GestureDetector(
                            onTap: () {
                              widget.controller.text = item.name;
                              _removeOverlay();
                              FocusScope.of(context).unfocus();

                              // Print selected item id and name
                              debugPrint(
                                  "Selected Item Id: ${item.id}, Name: ${item.name}");

                              // Call the callback if provided
                              if (widget.onItemSelected != null) {
                                widget.onItemSelected!(item);
                              }
                            },
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 6,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            //price
                                            _infoChip(
                                                "pp", "${item.purchasePrice}"),
                                            //sales
                                            _infoChip(
                                                "sp", "${item.salesPrice}"),

                                            _infoChip(
                                              "stock",
                                              '  ${provider.getUnitSymbol(item.unitId?.toString())}'
                                                  '${provider.getUnitSymbol(item.secondaryUnitId?.toString()) != "N/A" ? " (${item.unitQty} ${provider.getUnitSymbol(item.secondaryUnitId?.toString())})" : ""}',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onChanged(String value, AddItemProvider provider) {
    if (value.isEmpty) {
      _filteredItems = [];
      _removeOverlay();
      return;
    }

    _filteredItems = provider.items
        .where((item) => item.name.toLowerCase().contains(value.toLowerCase()))
        .toList();

    if (_filteredItems.isNotEmpty) {
      if (_overlayEntry == null) {
        _showOverlay(context);
      } else {
        _overlayEntry!.markNeedsBuild();
      }
    } else {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddItemProvider>(
      builder: (context, itemProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Text(widget.label!,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            SizedBox(
              height: 35,
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: (value) => _onChanged(value, itemProvider),
                onTap: () {
                  // Select all text when tapping
                  widget.controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: widget.controller.text.length,
                  );
                },
                cursorHeight: 14,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  labelText: "Item",
                  labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  floatingLabelStyle:
                      const TextStyle(color: Colors.green, fontSize: 12),
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ),

             
          ],
        );
      },
    );
  }
}

// Helper widget:
Widget _infoChip(String label, String value) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle()),
            TextSpan(text: value),
          ],
        ),
      ),
    ],
  );
}

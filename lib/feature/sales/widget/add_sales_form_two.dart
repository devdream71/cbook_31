import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// customer list dropdown with overlay and search

class AddSalesFormfieldTwo extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final String? customerorSaleslist;
  final String? customerOrSupplierButtonLavel;
  final void Function()? onTap;
  final Color? color;
  final bool isForReceivedVoucher;

  //xyz
  final String? label2;
  final TextEditingController? controllerText;

  const AddSalesFormfieldTwo({
    super.key,
    this.label,
    required this.controller,
    this.customerorSaleslist,
    this.customerOrSupplierButtonLavel,
    this.onTap,
    this.label2,
    this.controllerText,
    this.color,
    this.isForReceivedVoucher = false,
  });

  @override
  State<AddSalesFormfieldTwo> createState() => _AddSalesFormfieldTwoState();
}

class _AddSalesFormfieldTwoState extends State<AddSalesFormfieldTwo> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        final provider = Provider.of<CustomerProvider>(context, listen: false);
        _filteredCustomers = provider.customerResponse?.data ?? [];
        _showOverlay(context);
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - offset.dx;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: availableWidth,
        child: Material(
          color: colorScheme.surface,
          elevation: 4,
          child: Consumer<CustomerProvider>(
            builder: (context, provider, _) {
              if (_filteredCustomers.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                constraints: const BoxConstraints(
                  maxHeight: 400, // increased height for longer list
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.customerorSaleslist ?? "",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                          if (widget.customerOrSupplierButtonLavel != null)
                            InkWell(
                              onTap: widget.onTap,
                              child: Text(
                                widget.customerOrSupplierButtonLavel!,
                                style: const TextStyle(
                                    color: Colors.blue, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Divider(color: widget.color ?? Colors.grey),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];

                          return Material(
                            color: colorScheme.surface,
                            child: InkWell(
                              onTap: () {
                                widget.controller.text = customer.name;
                                // provider.setSelectedCustomer(customer);
                                if (widget.isForReceivedVoucher) {
                                  provider.setSelectedCustomerRecived(
                                      customer); // ✅ RECEIVED
                                } else {
                                  provider.setSelectedCustomer(
                                      customer); // ✅ PAYMENT
                                }

                               // selectedCustomerId = customer.id.toString();


                                // 👇 Print selected customer ID
                                debugPrint(
                                    "Selected Customer ID: ${customer.id}");
                                _removeOverlay();
                                FocusScope.of(context).unfocus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: customer.type == 'customer'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        customer.name,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      customer.due.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
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

  void _onChanged(String value, CustomerProvider provider) {
    if (value.isEmpty) {
      _filteredCustomers = [];
      _removeOverlay();
      return;
    }

    _filteredCustomers = provider.customerResponse?.data
            ?.where((customer) =>
                customer.name.toLowerCase().contains(value.toLowerCase()))
            .toList() ??
        [];

    if (_filteredCustomers.isNotEmpty) {
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
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Text(widget.label!,
                  style: const TextStyle(color: Colors.black, fontSize: 10)),
            const SizedBox(height: 5),
            SizedBox(
              height: 35,
              child: TextFormField(
                cursorHeight: 18,
                
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: (value) => _onChanged(value, customerProvider),
                style: const TextStyle(color: Colors.black, fontSize: 14),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  labelText: "Customer",
                  labelStyle: const TextStyle(fontSize: 14),
                  floatingLabelStyle:
                      const TextStyle(fontSize: 14, color: Colors.green),
                  hintText: "",
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

import 'package:cbook_dt/feature/customer_create/model/customer_list_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// customer list dropdown with overlay and search

/// Customer list dropdown with overlay and search - Similar to CustomDropdownTwo
class AddSalesFormfieldTwo extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final String? customerorSaleslist;
  final String? customerOrSupplierButtonLavel;
  final void Function()? onTap;
  final Color? color;
  final bool isForReceivedVoucher;
  final bool enableSearch;
  final double width;
  final double height;
  final Customer? selectedCustomer; // Add selected customer parameter

  // Additional parameters
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
    this.enableSearch = true, // Default to true for search capability
    this.width = double.infinity,
    this.height = 35,
    this.selectedCustomer,
  });

  @override
  State<AddSalesFormfieldTwo> createState() => _AddSalesFormfieldTwoState();
}

// Enhanced AddSalesFormfieldTwo with better state management

class _AddSalesFormfieldTwoState extends State<AddSalesFormfieldTwo> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isDropdownOpen = false;
  final FocusNode _focusNode = FocusNode();
  List<Customer> _filteredCustomers = [];
  Customer? selectedCustomer;

  @override
  void initState() {
    super.initState();
    selectedCustomer = widget.selectedCustomer;

    // Set initial text if customer is selected
    if (selectedCustomer != null) {
      widget.controller.text = selectedCustomer!.name;
    }

    // ✅ Add listener to detect external changes to the controller
    widget.controller.addListener(_onControllerChanged);
  }

  // ✅ Handle external controller changes
  void _onControllerChanged() {
    // If controller is externally cleared but we have a selected customer, restore it
    if (widget.controller.text.isEmpty && selectedCustomer != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && selectedCustomer != null) {
          widget.controller.text = selectedCustomer!.name;
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant AddSalesFormfieldTwo oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update selected customer if changed
    if (widget.selectedCustomer != oldWidget.selectedCustomer) {
      setState(() {
        selectedCustomer = widget.selectedCustomer;
        if (selectedCustomer != null) {
          widget.controller.text = selectedCustomer!.name;
        } else {
          widget.controller.text = '';
        }
      });
    }
  }

  @override
  void dispose() {
    _removeDropdown();
    _focusNode.dispose();
    widget.controller.removeListener(_onControllerChanged); // ✅ Remove listener
    super.dispose();
  }

  // ✅ Rest of your existing methods remain the same...
  void _onSearchChanged(String value, CustomerProvider provider) {
    // Don't filter if we're just restoring the selected customer name
    if (selectedCustomer != null && value == selectedCustomer!.name) {
      return;
    }

    setState(() {
      if (value.isEmpty) {
        _filteredCustomers = provider.customerResponse?.data ?? [];
      } else {
        _filteredCustomers = provider.customerResponse?.data
                .where((customer) =>
                    customer.name.toLowerCase().contains(value.toLowerCase()))
                .toList() ??
            [];
      }
    });

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  // ✅ Improved customer selection handling
  void _selectCustomer(Customer customer, CustomerProvider provider) {
    setState(() {
      selectedCustomer = customer;
      widget.controller.text = customer.name;
    });

    // Set selected customer in provider
    if (widget.isForReceivedVoucher) {
      provider.setSelectedCustomerRecived(customer);
    } else {
      provider.setSelectedCustomer(customer);
    }

    debugPrint("✅ Selected Customer: ${customer.name} (ID: ${customer.id})");
    _removeDropdown();
    FocusScope.of(context).unfocus();
  }

  // Your existing methods (toggleDropdown, showDropdown, removeDropdown, createOverlayEntry)
  void _toggleDropdown(CustomerProvider provider) {
    if (provider.customerResponse?.data?.isEmpty ?? true) return;

    if (isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown(provider);
    }
  }

  void _showDropdown(CustomerProvider provider) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _filteredCustomers = provider.customerResponse?.data ?? [];
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() => isDropdownOpen = true);
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => isDropdownOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeDropdown,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Consumer<CustomerProvider>(
                      builder: (context, provider, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.customerorSaleslist ??
                                        "Customer list",
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  if (widget.customerOrSupplierButtonLavel !=
                                      null)
                                    InkWell(
                                      onTap: () {
                                        _removeDropdown();
                                        widget.onTap?.call();
                                      },
                                      child: Text(
                                        widget.customerOrSupplierButtonLavel!,
                                        style: const TextStyle(
                                            color: Colors.blue, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Divider(
                                color: widget.color ?? Colors.grey, height: 1),
                            Flexible(
                              child: _filteredCustomers.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No customers found',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: _filteredCustomers.length,
                                      itemBuilder: (context, index) {
                                        final customer =
                                            _filteredCustomers[index];
                                        final isSelected =
                                            selectedCustomer?.id == customer.id;

                                        return Material(
                                          color: isSelected
                                              ? Colors.grey.shade200
                                              : Colors.white,
                                          child: InkWell(
                                            onTap: () => _selectCustomer(
                                                customer, provider),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: customer.type ==
                                                              'customer'
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    "৳ ${customer.due.toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, _) {
        // ✅ Check if we should restore selected customer from provider
        if (selectedCustomer == null && !widget.isForReceivedVoucher) {
          selectedCustomer = customerProvider.selectedCustomer;
          if (selectedCustomer != null && widget.controller.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                widget.controller.text = selectedCustomer!.name;
              }
            });
          }
        }

        final hasValue = selectedCustomer != null;
        final isEnabled =
            customerProvider.customerResponse?.data?.isNotEmpty ?? false;
        final verticalPadding = (widget.height - 20) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: const TextStyle(color: Colors.black, fontSize: 10),
              ),
              const SizedBox(height: 5),
            ],

            CompositedTransformTarget(
              link: _layerLink,
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: widget.enableSearch
                    ? _buildSearchField(
                        customerProvider, isEnabled, verticalPadding)
                    : _buildDropdownField(
                        customerProvider, isEnabled, verticalPadding, hasValue),
              ),
            ),

            // ✅ Enhanced due amount display with better null checking
            if (selectedCustomer != null && selectedCustomer!.id != -1) ...[
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    "${selectedCustomer!.type == 'customer' ? 'Receivable' : 'Payable'}: ",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: selectedCustomer!.type == 'customer'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  Text(
                    "${selectedCustomer!.due.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      if (selectedCustomer != null) {
                        _showCustomerDetailsDialog(context, selectedCustomer!);
                      }
                    },
                    child: const Text(
                      'View',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  )
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSearchField(
      CustomerProvider provider, bool isEnabled, double verticalPadding) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      onTap: () {
        if (isEnabled) {
          _focusNode.requestFocus();
          if (!isDropdownOpen) {
            _showDropdown(provider);
          }
        }
      },
      onChanged: (value) {
        if (!isDropdownOpen) {
          _showDropdown(provider);
        }
        _onSearchChanged(value, provider);
      },
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        isDense: true,
        fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
        labelText: "Customer",
        labelStyle: TextStyle(
          fontSize: 14,
          color: isEnabled ? Colors.grey : Colors.grey.shade400,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 14,
          color: isEnabled ? Colors.green : Colors.grey.shade400,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isEnabled ? Colors.green : Colors.grey.shade300,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: verticalPadding,
        ),
        suffixIcon: Icon(
          isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildDropdownField(CustomerProvider provider, bool isEnabled,
      double verticalPadding, bool hasValue) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              _focusNode.requestFocus();
              _toggleDropdown(provider);
            }
          : null,
      child: InputDecorator(
        isFocused: isDropdownOpen || _focusNode.hasFocus,
        isEmpty: !hasValue,
        decoration: InputDecoration(
          filled: true,
          isDense: true,
          fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
          labelText: "Customer",
          labelStyle: TextStyle(
            fontSize: 14,
            color: isEnabled ? Colors.grey : Colors.grey.shade400,
          ),
          floatingLabelStyle: TextStyle(
            fontSize: 14,
            color: isEnabled ? Colors.green : Colors.grey.shade400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isEnabled ? Colors.green : Colors.grey.shade300,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: verticalPadding,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hasValue ? selectedCustomer!.name : 'Select Customer',
                style: TextStyle(
                  fontSize: 14,
                  color: hasValue
                      ? (isEnabled ? Colors.black : Colors.grey.shade500)
                      : Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Alternative compact dialog design:
  void _showCustomerDetailsDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(6), // 👈 set your desired radius
          ),
          title: const Text(
            'Customer Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Customer Type Indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: customer.type == 'customer'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: customer.type == 'customer'
                          ? Colors.green
                          : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    customer.type == 'customer' ? 'Customer' : 'Supplier',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: customer.type == 'customer'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Information Table
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    _buildTableRow(customer.name),
                    _buildTableRow(customer.proprietorName ?? 'N/A'),
                    _buildTableRow(customer.phone ?? 'N/A'),
                    _buildTableRow(customer.address ?? 'N/A'),
                    _buildTableRow(
                      '${customer.type == 'customer' ? 'Receivable:' : 'Payable:'} ৳ ${customer.due.toStringAsFixed(2)}',
                      valueColor: customer.type == 'customer'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

// Helper method for table rows:
  TableRow _buildTableRow(String value, {Color? valueColor}) {
    return TableRow(
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 6),
        //   child: Text(
        //     label,
        //     style: const TextStyle(
        //       fontSize: 12,
        //       color: Colors.grey,
        //       fontWeight: FontWeight.w500,
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

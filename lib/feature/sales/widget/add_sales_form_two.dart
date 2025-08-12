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

  void _onSearchChanged(String value, CustomerProvider provider) {
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
            // Backdrop to close dropdown
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeDropdown,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            // Dropdown content
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
                            // Header with title and add button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.customerorSaleslist ?? "Customer list",
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  if (widget.customerOrSupplierButtonLavel != null)
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
                            Divider(color: widget.color ?? Colors.grey, height: 1),
                            
                            // Customer list
                            Flexible(
                              child: _filteredCustomers.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No customers found',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: _filteredCustomers.length,
                                      itemBuilder: (context, index) {
                                        final customer = _filteredCustomers[index];
                                        final isSelected = selectedCustomer?.id == customer.id;

                                        return Material(
                                          color: isSelected ? Colors.grey.shade200 : Colors.white,
                                          child: InkWell(
                                            onTap: () {
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

                                              debugPrint("Selected Customer ID: ${customer.id}");
                                              _removeDropdown();
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
  void dispose() {
    _removeDropdown();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, _) {
        final hasValue = selectedCustomer != null;
        final isEnabled = customerProvider.customerResponse?.data?.isNotEmpty ?? false;
        final verticalPadding = (widget.height - 20) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: const TextStyle(color: Colors.black, fontSize: 10),
              ),
              const SizedBox(height: 5),
            ],
            
            // Main dropdown field
            CompositedTransformTarget(
              link: _layerLink,
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: widget.enableSearch
                    ? _buildSearchField(customerProvider, isEnabled, verticalPadding)
                    : _buildDropdownField(customerProvider, isEnabled, verticalPadding, hasValue),
              ),
            ),

            // Due amount display (similar to original)
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
                    "৳ ${selectedCustomer!.due.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSearchField(CustomerProvider provider, bool isEnabled, double verticalPadding) {
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

  Widget _buildDropdownField(CustomerProvider provider, bool isEnabled, double verticalPadding, bool hasValue) {
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
}






// class AddSalesFormfieldTwo extends StatefulWidget {
//   final String? label;
//   final TextEditingController controller;
//   final String? customerorSaleslist;
//   final String? customerOrSupplierButtonLavel;
//   final void Function()? onTap;
//   final Color? color;
//   final bool isForReceivedVoucher;

//   //xyz
//   final String? label2;
//   final TextEditingController? controllerText;

//   const AddSalesFormfieldTwo({
//     super.key,
//     this.label,
//     required this.controller,
//     this.customerorSaleslist,
//     this.customerOrSupplierButtonLavel,
//     this.onTap,
//     this.label2,
//     this.controllerText,
//     this.color,
//     this.isForReceivedVoucher = false,
//   });

//   @override
//   State<AddSalesFormfieldTwo> createState() => _AddSalesFormfieldTwoState();
// }

// class _AddSalesFormfieldTwoState extends State<AddSalesFormfieldTwo> {
//   final FocusNode _focusNode = FocusNode();
//   OverlayEntry? _overlayEntry;
//   List<Customer> _filteredCustomers = [];

//   @override
//   void initState() {
//     super.initState();

//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus) {
//         final provider = Provider.of<CustomerProvider>(context, listen: false);
//         _filteredCustomers = provider.customerResponse?.data ?? [];
//         _showOverlay(context);
//       } else {
//         _removeOverlay();
//       }
//     });
//   }

//   void _showOverlay(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     final renderBox = context.findRenderObject() as RenderBox;
//     final size = renderBox.size;
//     final offset = renderBox.localToGlobal(Offset.zero);

//     final screenWidth = MediaQuery.of(context).size.width;
//     final availableWidth = screenWidth - offset.dx;

//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         left: offset.dx,
//         top: offset.dy + size.height,
//         width: availableWidth,
//         child: Material(
//           color: colorScheme.surface,
//           elevation: 4,
//           child: Consumer<CustomerProvider>(
//             builder: (context, provider, _) {
//               if (_filteredCustomers.isEmpty) {
//                 return const SizedBox.shrink();
//               }
//               return Container(
//                 decoration: BoxDecoration(
//                   color: colorScheme.surface,
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 constraints: const BoxConstraints(
//                   maxHeight: 400, // increased height for longer list
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 6),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             widget.customerorSaleslist ?? "",
//                             style: const TextStyle(
//                                 color: Colors.black, fontSize: 12),
//                           ),
//                           if (widget.customerOrSupplierButtonLavel != null)
//                             InkWell(
//                               onTap: widget.onTap,
//                               child: Text(
//                                 widget.customerOrSupplierButtonLavel!,
//                                 style: const TextStyle(
//                                     color: Colors.blue, fontSize: 12),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     Divider(color: widget.color ?? Colors.grey),
//                     Expanded(
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         padding: EdgeInsets.zero,
//                         itemCount: _filteredCustomers.length,
//                         itemBuilder: (context, index) {
//                           final customer = _filteredCustomers[index];

//                           return Material(
//                             color: colorScheme.surface,
//                             child: InkWell(
//                               onTap: () {
//                                 widget.controller.text = customer.name;
//                                 // provider.setSelectedCustomer(customer);
//                                 if (widget.isForReceivedVoucher) {
//                                   provider.setSelectedCustomerRecived(
//                                       customer); // ✅ RECEIVED
//                                 } else {
//                                   provider.setSelectedCustomer(
//                                       customer); // ✅ PAYMENT
//                                 }

//                                // selectedCustomerId = customer.id.toString();


//                                 // 👇 Print selected customer ID
//                                 debugPrint(
//                                     "Selected Customer ID: ${customer.id}");
//                                 _removeOverlay();
//                                 FocusScope.of(context).unfocus();
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 8),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       width: 8,
//                                       height: 8,
//                                       margin: const EdgeInsets.only(right: 10),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: customer.type == 'customer'
//                                             ? Colors.green
//                                             : Colors.red,
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Text(
//                                         customer.name,
//                                         style: const TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 14,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                     Text(
//                                       customer.due.toString(),
//                                       style: const TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//   }

//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   void _onChanged(String value, CustomerProvider provider) {
//     if (value.isEmpty) {
//       _filteredCustomers = [];
//       _removeOverlay();
//       return;
//     }

//     _filteredCustomers = provider.customerResponse?.data
//             .where((customer) =>
//                 customer.name.toLowerCase().contains(value.toLowerCase()))
//             .toList() ??
//         [];

//     if (_filteredCustomers.isNotEmpty) {
//       if (_overlayEntry == null) {
//         _showOverlay(context);
//       } else {
//         _overlayEntry!.markNeedsBuild();
//       }
//     } else {
//       _removeOverlay();
//     }
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _removeOverlay();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CustomerProvider>(
//       builder: (context, customerProvider, _) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (widget.label != null)
//               Text(widget.label!,
//                   style: const TextStyle(color: Colors.black, fontSize: 10)),
//             const SizedBox(height: 5),
//             SizedBox(
//               height: 35,
//               child: TextFormField(
//                 cursorHeight: 18,
                
//                 controller: widget.controller,
//                 focusNode: _focusNode,
//                 onChanged: (value) => _onChanged(value, customerProvider),
//                 style: const TextStyle(color: Colors.black, fontSize: 14),
//                 decoration: InputDecoration(
//                   fillColor: Colors.white,
//                   labelText: "Customer",
//                   labelStyle: const TextStyle(fontSize: 14),
//                   floatingLabelStyle:
//                       const TextStyle(fontSize: 14, color: Colors.green),
//                   hintText: "",
//                   filled: true,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                     borderSide:
//                         BorderSide(color: Colors.grey.shade400, width: 1),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                     borderSide:
//                         BorderSide(color: Colors.grey.shade400, width: 1),
//                   ),
//                   focusedBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.green),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         );
//       },
//     );
//   }
// }

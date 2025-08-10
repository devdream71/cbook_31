import 'package:flutter/material.dart';

class CustomDropdownTwo extends StatefulWidget {
  final List<String> items;
  final String? hint;
  final String? labelText;
  final Function(String) onChanged;
  final double width;
  final double height;
  final String? selectedItem;
  final String? value;
  final bool enableSearch; // New parameter to enable/disable search

  const CustomDropdownTwo({
    super.key,
    required this.items,
    this.hint,
    this.labelText,
    required this.onChanged,
    required this.width,
    required this.height,
    this.selectedItem,
    this.value,
    this.enableSearch = false, // Default to false for backward compatibility
  });

  @override
  State<CustomDropdownTwo> createState() => _CustomDropdownTwoState();
}

class _CustomDropdownTwoState extends State<CustomDropdownTwo> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isDropdownOpen = false;
  String? selectedItem;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    selectedItem = widget.selectedItem ?? widget.value;
    _filteredItems = widget.items;
    
    if (widget.enableSearch) {
      _searchController.text = selectedItem ?? '';
    }
  }

  @override
  void didUpdateWidget(covariant CustomDropdownTwo oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update filtered items when widget items change
    if (widget.items != oldWidget.items) {
      _filteredItems = widget.items;
    }

    // Only update if value actually changed
    if (widget.selectedItem != oldWidget.selectedItem &&
        widget.selectedItem != selectedItem) {
      setState(() {
        selectedItem = widget.selectedItem;
        if (widget.enableSearch) {
          _searchController.text = selectedItem ?? '';
        }
      });
    }

    if (widget.value != oldWidget.value &&
        widget.value != selectedItem &&
        widget.value != null) {
      setState(() {
        selectedItem = widget.value;
        if (widget.enableSearch) {
          _searchController.text = selectedItem ?? '';
        }
      });
    }

    if (widget.items != oldWidget.items &&
        selectedItem != null &&
        !widget.items.contains(selectedItem)) {
      setState(() {
        selectedItem = null;
        if (widget.enableSearch) {
          _searchController.text = '';
        }
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _toggleDropdown() {
    // Don't allow dropdown to open if no items available
    if (widget.items.isEmpty) return;

    if (isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _filteredItems = widget.items; // Reset filtered items
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
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search field (only show if enableSearch is true)
                        if (widget.enableSearch) ...[
                          // Container(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: TextField(
                          //     controller: _searchController,
                          //     onChanged: _onSearchChanged,
                          //     decoration: InputDecoration(
                          //       hintText: 'Search items...',
                          //       hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                          //       prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                          //       contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(4),
                          //         borderSide: BorderSide(color: Colors.grey.shade300),
                          //       ),
                          //       focusedBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(4),
                          //         borderSide: const BorderSide(color: Colors.green),
                          //       ),
                          //       isDense: true,
                          //     ),
                          //     style: const TextStyle(fontSize: 12),
                          //   ),
                          // ),
                          // Divider(height: 1, color: Colors.grey.shade300),
                        ],
                        
                        // Items list
                        Flexible(
                          child: _filteredItems.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No items found',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: _filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredItems[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        item,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      tileColor: selectedItem == item
                                          ? Colors.grey.shade200
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          selectedItem = item;
                                          if (widget.enableSearch) {
                                            _searchController.text = item;
                                          }
                                        });
                                        widget.onChanged(item);
                                        _removeDropdown();
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedItem != null && selectedItem!.isNotEmpty;
    final verticalPadding = (widget.height - 20) / 2;
    final isEnabled = widget.items.isNotEmpty;

    // For search-enabled dropdown, use TextField
    if (widget.enableSearch) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: TextFormField(
            controller: _searchController,
            focusNode: _focusNode,
            onTap: () {
              if (isEnabled) {
                _focusNode.requestFocus();
                if (!isDropdownOpen) {
                  _showDropdown();
                }
              }
            },
            onChanged: (value) {
              if (!isDropdownOpen) {
                _showDropdown();
              }
              _onSearchChanged(value);
            },
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              filled: true,
              isDense: true,
              fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
              labelText: widget.labelText,
              hintText: widget.hint,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isEnabled ? Colors.grey : Colors.grey.shade400,
              ),
              hintStyle: TextStyle(
                fontSize: 12,
                color: isEnabled ? Colors.grey : Colors.grey.shade400,
              ),
              floatingLabelStyle: TextStyle(
                fontSize: 12,
                color: isEnabled ? Colors.green : Colors.grey.shade400,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(
                  color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
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
                horizontal: 10,
                vertical: verticalPadding,
              ),
              suffixIcon: Icon(
                isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      );
    }

    // Original dropdown without search
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                _focusNode.requestFocus();
                _toggleDropdown();
              }
            : null,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: InputDecorator(
            isFocused: isDropdownOpen || _focusNode.hasFocus,
            isEmpty: !hasValue,
            decoration: InputDecoration(
              filled: true,
              isDense: true,
              fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
              labelText: widget.labelText,
              labelStyle: TextStyle(
                  fontSize: 12,
                  color: isEnabled ? Colors.grey : Colors.grey.shade400),
              floatingLabelStyle: TextStyle(
                  fontSize: 12,
                  color: isEnabled ? Colors.green : Colors.grey.shade400),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(
                    color:
                        isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
                    width: 1),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(
                    color:
                        isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
                    width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isEnabled ? Colors.green : Colors.grey.shade300),
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 10, vertical: verticalPadding),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hasValue ? selectedItem! : widget.hint ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: hasValue
                          ? (isEnabled ? Colors.black : Colors.grey.shade500)
                          : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color:
                      isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class CustomDropdownTwo extends StatefulWidget {
//   final List<String> items;
//   final String? hint;
//   final String? labelText;
//   final Function(String) onChanged;
//   final double width;
//   final double height;
//   final String? selectedItem;
//   final String? value;

  

//   const CustomDropdownTwo({
//     super.key,
//     required this.items,
//     this.hint,
//     this.labelText,
//     required this.onChanged,
//     required this.width,
//     required this.height,
//     this.selectedItem,
//     this.value,
//   });

//   @override
//   State<CustomDropdownTwo> createState() => _CustomDropdownTwoState();
// }

// class _CustomDropdownTwoState extends State<CustomDropdownTwo> {
//   final LayerLink _layerLink = LayerLink();
//   OverlayEntry? _overlayEntry;
//   bool isDropdownOpen = false;
//   String? selectedItem;
//   final FocusNode _focusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     selectedItem = widget.selectedItem ?? widget.value;
//   }

//   @override
//   void didUpdateWidget(covariant CustomDropdownTwo oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     // Only update if value actually changed
//     if (widget.selectedItem != oldWidget.selectedItem &&
//         widget.selectedItem != selectedItem) {
//       setState(() {
//         selectedItem = widget.selectedItem;
//       });
//     }

//     if (widget.value != oldWidget.value &&
//         widget.value != selectedItem &&
//         widget.value != null) {
//       setState(() {
//         selectedItem = widget.value;
//       });
//     }

//     if (widget.items != oldWidget.items &&
//         selectedItem != null &&
//         !widget.items.contains(selectedItem)) {
//       setState(() {
//         selectedItem = null;
//       });
//     }
//   }

//   void _toggleDropdown() {
//     // Don't allow dropdown to open if no items available
//     if (widget.items.isEmpty) return;

//     if (isDropdownOpen) {
//       _removeDropdown();
//     } else {
//       _showDropdown();
//     }
//   }

//   void _showDropdown() {
//     final overlay = Overlay.of(context);
//     if (overlay == null) return;

//     _overlayEntry = _createOverlayEntry();
//     overlay.insert(_overlayEntry!);
//     setState(() => isDropdownOpen = true);
//   }

//   void _removeDropdown() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     setState(() => isDropdownOpen = false);
//   }

//   OverlayEntry _createOverlayEntry() {
//     RenderBox renderBox = context.findRenderObject() as RenderBox;
//     Offset offset = renderBox.localToGlobal(Offset.zero);
//     Size size = renderBox.size;

//     return OverlayEntry(
//       builder: (context) {
//         return Stack(
//           children: [
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: _removeDropdown,
//                 behavior: HitTestBehavior.translucent,
//                 child: const SizedBox.expand(),
//               ),
//             ),
//             Positioned(
//               left: offset.dx,
//               top: offset.dy,
//               width: size.width,
//               child: CompositedTransformFollower(
//                 link: _layerLink,
//                 showWhenUnlinked: false,
//                 offset: Offset(0, size.height),
//                 child: Material(
//                   elevation: 4,
//                   borderRadius: BorderRadius.circular(4),
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(maxHeight: 200),
//                     child: ListView(
//                       shrinkWrap: true,
//                       padding: EdgeInsets.zero,
//                       children: widget.items.map((item) {
//                         return ListTile(
//                           dense: true,
//                           title:
//                               Text(item, style: const TextStyle(fontSize: 13)),
//                           tileColor: selectedItem == item
//                               ? Colors.grey.shade200
//                               : null,
//                           onTap: () {
//                             setState(() => selectedItem = item);
//                             widget.onChanged(item);
//                             _removeDropdown();
//                           },
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _removeDropdown();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hasValue = selectedItem != null && selectedItem!.isNotEmpty;
//     final verticalPadding = (widget.height - 20) / 2;
//     final isEnabled = widget.items.isNotEmpty;

//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: GestureDetector(
//         onTap: isEnabled
//             ? () {
//                 _focusNode.requestFocus();
//                 _toggleDropdown();
//               }
//             : null,
//         child: SizedBox(
//           width: widget.width,
//           height: widget.height,
//           child: InputDecorator(
//             isFocused: isDropdownOpen || _focusNode.hasFocus,
//             isEmpty: !hasValue,
//             decoration: InputDecoration(
//               filled: true,
//               isDense: true,
//               fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
//               labelText: widget.labelText,
//               labelStyle: TextStyle(
//                   fontSize: 12,
//                   color: isEnabled ? Colors.grey : Colors.grey.shade400),
//               floatingLabelStyle: TextStyle(
//                   fontSize: 12,
//                   color: isEnabled ? Colors.green : Colors.grey.shade400),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(3),
//                 borderSide: BorderSide(
//                     color:
//                         isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
//                     width: 1),
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(3),
//                 borderSide: BorderSide(
//                     color:
//                         isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
//                     width: 1),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                     color: isEnabled ? Colors.green : Colors.grey.shade300),
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                   horizontal: 10, vertical: verticalPadding),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     hasValue ? selectedItem! : widget.hint ?? '',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: hasValue
//                           ? (isEnabled ? Colors.black : Colors.grey.shade500)
//                           : Colors.grey.shade600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 Icon(
//                   isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
//                   color:
//                       isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CashCreditToggle extends StatefulWidget {
  final bool initialCash;
  final ValueChanged<bool> onChanged;

  const CashCreditToggle({
    super.key,
    required this.initialCash,
    required this.onChanged,
  });

  @override
  State<CashCreditToggle> createState() => _CashCreditToggleState();
}

class _CashCreditToggleState extends State<CashCreditToggle> {
  late bool isCash;

  @override
  void initState() {
    super.initState();
    isCash = widget.initialCash;
  }

  void toggle(bool value) {
    // Only update if the value is different from current state
    if (isCash != value) {
      setState(() {
        isCash = value;
      });
      widget.onChanged(isCash);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Row(
        children: [
          // Cash half
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => toggle(true), // Set to Cash
              child: Container(
                decoration: BoxDecoration(
                  color: isCash ? Colors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Cash",
                  style: TextStyle(
                      color: isCash ? Colors.black : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ),
            ),
          ),
          // Credit half
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => toggle(false), // Set to Credit
              child: Container(
                decoration: BoxDecoration(
                  color: !isCash ? Colors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Credit",
                  style: TextStyle(
                      color: !isCash ? Colors.black : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


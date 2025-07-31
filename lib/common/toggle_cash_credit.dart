import 'package:flutter/material.dart';

class PaymentToggle extends StatefulWidget {
  final bool isCash;
  final Function(bool) onToggle;

  const PaymentToggle({super.key, required this.isCash, required this.onToggle});

  @override
  PaymentToggleState createState() => PaymentToggleState();
}

class PaymentToggleState extends State<PaymentToggle> {
  late bool isCash;

  @override
  void initState() {
    super.initState();
    isCash = widget.isCash;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 140,
      decoration: BoxDecoration(
        color: Colors.grey[300], // Background color
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Credit Button
          GestureDetector(
            onTap: () {
              setState(() {
                isCash = false;
              });
              widget.onToggle(isCash);
            },
            child: Container(
              width: 65,
              height: 35,
              decoration: BoxDecoration(
                color: isCash ? Colors.transparent : Colors.green,
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Text(
                "Credit",
                style: TextStyle(
                  color: isCash ? Colors.grey : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Cash Button
          GestureDetector(
            onTap: () {
              setState(() {
                isCash = true;
              });
              widget.onToggle(isCash);
            },
            child: Container(
              width: 65,
              height: 35,
              decoration: BoxDecoration(
                color: isCash ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Text(
                "Cash",
                style: TextStyle(
                  color: isCash ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ItemDetailsPopUpTwo extends StatelessWidget {
  final String leftTest;
  final String rightText;
  final String last;
  final FontWeight? fontWeight;
  const ItemDetailsPopUpTwo(
      {super.key,
      required this.leftTest,
      required this.rightText,
      this.fontWeight,
      required this.last});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              //color: Colors.blue,
              child: SizedBox(
                width: 108,
                child: Text(leftTest,
                    style: TextStyle(
                        fontWeight: fontWeight,
                        color: Colors.black,
                        fontSize: 12)),
              ),
            ),
            SizedBox(
              //color: Colors.green,
              child: SizedBox(
                width: 70,
                child: Text(" $rightText",
                    style: TextStyle(
                        fontWeight: fontWeight,
                        color: Colors.black,
                        fontSize: 12)),
              ),
            ),
            SizedBox(
              //color: Colors.red,
              child: SizedBox(
                width: 70,
                child: Text(" $last",
                    style: TextStyle(
                        fontWeight: fontWeight,
                        color: Colors.black,
                        fontSize: 12)),
              ),
            ),
            const SizedBox(height: 3),
          ]),
    );
  }
}

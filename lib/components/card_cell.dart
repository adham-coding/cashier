import 'package:cashier/constants/sizes.dart';
import 'package:cashier/utils/fucntions.dart';
import 'package:flutter/material.dart';

class CardCell extends StatelessWidget {
  final String text;
  final Color color;
  final bool isNumber;
  final bool isEllipsis;
  final double fontSize;

  const CardCell({
    super.key,
    required this.text,
    required this.color,
    this.isNumber = false,
    this.isEllipsis = true,
    this.fontSize = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        color: color,
        shape: softRect,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.1),
            child: Text(
              isNumber == false ? text : humanizedNumber(text),
              textAlign: TextAlign.center,
              style: TextStyle(
                overflow: isEllipsis == true ? TextOverflow.ellipsis : null,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

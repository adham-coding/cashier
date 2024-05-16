import 'package:cashier/components/card_cell.dart';
import 'package:cashier/constants/colors.dart';
import 'package:flutter/material.dart';

class Balance extends StatelessWidget {
  final int outgoing, income;

  const Balance({super.key, required this.outgoing, required this.income});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <CardCell>[
        CardCell(text: outgoing.toString(), color: yellowColor, isNumber: true),
        CardCell(text: income.toString(), color: greenColor, isNumber: true),
        CardCell(
          isNumber: true,
          color: redColor,
          text: (outgoing - income).toString(),
        ),
      ],
    );
  }
}

import 'package:cashier/components/card_cell.dart';
import 'package:cashier/components/card_wrapper.dart';
import 'package:cashier/components/balance.dart';
import 'package:cashier/constants/colors.dart';
import 'package:cashier/model/history.dart';
import 'package:cashier/utils/fucntions.dart';
import 'package:flutter/material.dart';

class CardHistory extends StatelessWidget {
  final History history;
  final ElevatedButton button;

  const CardHistory({super.key, required this.history, required this.button});

  @override
  Widget build(BuildContext context) {
    return CardWrapper(button: button, children: [
      Row(children: [
        CardCell(text: humanizedDate(history.timestamp!), color: blueColor)
      ]),
      Balance(outgoing: history.outgoing!, income: history.income!),
      Row(children: [
        CardCell(
          text: history.comment!,
          color: greyColor,
          isEllipsis: false,
        )
      ]),
    ]);
  }
}

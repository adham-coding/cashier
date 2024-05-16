import 'package:cashier/components/card_cell.dart';
import 'package:cashier/components/card_wrapper.dart';
import 'package:cashier/constants/colors.dart';
import 'package:cashier/constants/sizes.dart';
import 'package:cashier/model/person.dart';
import 'package:flutter/material.dart';

class CardPerson extends StatelessWidget {
  final Person person;
  final String currency;
  final ElevatedButton button;

  const CardPerson({
    super.key,
    required this.person,
    required this.currency,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    return CardWrapper(button: button, children: [
      Padding(
        padding: const EdgeInsets.only(right: 3.5),
        child: SizedBox(
          height: buttonSize + 6.0,
          child: Row(
            children: [
              CardCell(
                text: person.name!,
                color: greyColor,
                isEllipsis: false,
                fontSize: 16.0,
              ),
              CardCell(
                isNumber: true,
                color: redColor,
                fontSize: 16.0,
                text: (person.balance?[currency]["outgoing"] -
                        person.balance?[currency]["income"])
                    .toString(),
              ),
            ],
          ),
        ),
      )
    ]);
  }
}

import 'package:cashier/assets/currencies.dart';
import 'package:cashier/constants/colors.dart';
import 'package:cashier/constants/sizes.dart';
import 'package:cashier/model/cashier_db.dart';
import 'package:cashier/model/config.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';

class CurrencyDropdown extends StatefulWidget {
  final CashierDB db;
  final TextEditingController controller;
  final Function stateRefresher;

  const CurrencyDropdown({
    super.key,
    required this.db,
    required this.stateRefresher,
    required this.controller,
  });

  @override
  State<CurrencyDropdown> createState() => _CurrencyDropdownState();
}

class _CurrencyDropdownState extends State<CurrencyDropdown> {
  Future<void> _changeCurrency(String currency) async {
    Map<String, dynamic> config = {
      CashierDB.configId: 1,
      CashierDB.configCurrency: currency,
    };

    widget.db.editConfig(Config.fromJSON(config));
    widget.controller.text = currency;
    widget.stateRefresher();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shape: softRect,
      color: greyColor,
      child: SizedBox(
        height: 36.0,
        child: DropdownButton<String>(
          autofocus: false,
          iconSize: 0,
          elevation: 3,
          value: widget.controller.text,
          dropdownColor: greyColor,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          style: const TextStyle(
            fontFamily: "FontMain",
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
          underline: Container(height: 0),
          onChanged: (String? value) {
            _changeCurrency(value!);
          },
          items: currencies.map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Flag.fromString(
                      value.substring(0, 2),
                      height: 20.0,
                      width: 44.0,
                    ),
                    Text(value),
                  ],
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

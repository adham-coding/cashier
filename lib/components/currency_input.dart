import 'package:cashier/assets/currencies.dart';
import 'package:cashier/constants/colors.dart';
import 'package:cashier/constants/sizes.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class CurrencyInput extends StatefulWidget {
  final TextEditingController controller;

  const CurrencyInput({super.key, required this.controller});

  @override
  State<CurrencyInput> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shape: softRect,
      color: greyColor,
      child: Container(
        padding: const EdgeInsets.only(right: 13.0),
        height: 53.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DropdownButton<String>(
                iconSize: 0,
                elevation: 3,
                value: widget.controller.text,
                dropdownColor: greyColor,
                padding: const EdgeInsets.only(left: 10.0, top: 3.0),
                style: const TextStyle(
                  fontFamily: "FontMain",
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
                underline: Container(height: 0),
                onChanged: (String? value) {
                  setState(() => widget.controller.text = value!);
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
            const Icon(UniconsLine.usd_square, color: fgColor),
          ],
        ),
      ),
    );
  }
}

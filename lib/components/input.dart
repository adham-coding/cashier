import 'package:cashier/constants/colors.dart';
import 'package:cashier/constants/sizes.dart';
import 'package:cashier/utils/fucntions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Input extends StatefulWidget {
  final Color color;
  final String placeholder;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool readOnly;
  final EdgeInsets contentPadding;

  const Input({
    super.key,
    required this.color,
    required this.placeholder,
    required this.icon,
    required this.controller,
    this.inputType = TextInputType.text,
    this.readOnly = false,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 13.0,
    ),
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => widget.controller.text = getDate(pickedDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        elevation: 3,
        shape: softRect,
        child: TextField(
          style: const TextStyle(fontFamily: "FontMain", color: fgColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.color,
            hintText: widget.placeholder,
            hintStyle: const TextStyle(color: Color.fromARGB(100, 44, 52, 94)),
            contentPadding: widget.contentPadding,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(13.0),
            ),
            suffixIcon: Icon(widget.icon),
            suffixIconColor: fgColor,
          ),
          keyboardType: widget.inputType,
          controller: widget.controller,
          readOnly: widget.readOnly,
          maxLines: widget.inputType == TextInputType.multiline ? null : 1,
          onTap: widget.inputType == TextInputType.datetime ? _pickDate : () {},
          onChanged: widget.inputType == TextInputType.number
              ? (value) => widget.controller.text = humanizedNumber(value)
              : (value) {},
          inputFormatters: <TextInputFormatter>[
            widget.inputType == TextInputType.number
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.singleLineFormatter
          ],
        ),
      ),
    );
  }
}

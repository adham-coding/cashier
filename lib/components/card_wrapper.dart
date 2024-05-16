import 'package:cashier/constants/sizes.dart';
import 'package:flutter/material.dart';

class CardWrapper extends StatelessWidget {
  final ElevatedButton button;
  final List<Widget> children;

  const CardWrapper({
    super.key,
    required this.button,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: softRect,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(1.5, 3.0, 5.0, 3.0),
        child: Row(
          children: <Widget>[
            Expanded(child: Column(children: children)),
            SizedBox(
                width: buttonSize,
                height: buttonSize + 6.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: button,
                ))
          ],
        ),
      ),
    );
  }
}

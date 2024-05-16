import 'package:cashier/constants/colors.dart';
import 'package:flutter/material.dart';

class Desk extends StatelessWidget {
  final List<Widget> children;
  final double height;
  final double width;

  const Desk({
    super.key,
    required this.children,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          color: blueColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 6.0,
              color: fgColor,
              offset: Offset(0.0, -1.0),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}

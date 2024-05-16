import 'package:cashier/constants/colors.dart';
import 'package:cashier/constants/sizes.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomAppBar(height: bottomBarHeight, color: fgColor);
  }
}

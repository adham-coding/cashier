import 'package:cashier/constants/colors.dart';
import 'package:cashier/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CashierApp());
}

class CashierApp extends StatelessWidget {
  const CashierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cashier",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: redColor),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: "FontMain",
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
          ),
          bodyMedium: TextStyle(fontFamily: "FontMain", color: fgColor),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

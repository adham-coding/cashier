import 'dart:convert';

import 'package:cashier/model/cashier_db.dart';

class Person {
  int? id;
  String? name;
  String? phone;
  Map? balance;

  Person({
    this.id,
    required this.name,
    required this.phone,
    required this.balance,
  });

  Map<String, dynamic> toJSON() {
    return {
      CashierDB.personId: id,
      CashierDB.personName: name,
      CashierDB.personPhone: phone,
      CashierDB.personBalance: jsonEncode(balance),
    };
  }

  Person.fromJSON(Map<String, dynamic> person) {
    id = person["id"];
    name = person["name"];
    phone = person["phone"];
    balance = jsonDecode(person["balance"]);
  }
}

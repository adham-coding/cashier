import 'package:cashier/model/cashier_db.dart';

class Config {
  int? id;
  String? currency;

  Config({this.id, required this.currency});

  Map<String, dynamic> toJSON() {
    return {CashierDB.configId: id, CashierDB.configCurrency: currency};
  }

  Config.fromJSON(Map<String, dynamic> config) {
    id = config["id"];
    currency = config["currency"];
  }
}

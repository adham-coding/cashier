import 'package:cashier/model/cashier_db.dart';

class History {
  int? id;
  int? personId;
  int? outgoing;
  int? income;
  int? timestamp;
  String? currency;
  String? comment;

  History({
    this.id,
    required this.personId,
    required this.outgoing,
    required this.income,
    required this.timestamp,
    required this.currency,
    required this.comment,
  });

  Map<String, dynamic> toJSON() {
    return {
      CashierDB.historyId: id,
      CashierDB.personHistoryId: personId,
      CashierDB.historyOutgoing: outgoing,
      CashierDB.historyIncome: income,
      CashierDB.historyTimestamp: timestamp,
      CashierDB.historyCurrency: currency,
      CashierDB.historyComment: comment,
    };
  }

  History.fromJSON(Map<String, dynamic> history) {
    id = history["id"];
    personId = history["personId"];
    outgoing = history["outgoing"];
    income = history["income"];
    timestamp = history["timestamp"];
    currency = history["currency"];
    comment = history["comment"];
  }
}

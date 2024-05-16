import 'package:cashier/components/bottom_bar.dart';
import 'package:cashier/components/desk.dart';
import 'package:cashier/components/input.dart';
import 'package:cashier/components/currency_input.dart';
import 'package:cashier/constants/colors.dart';
import 'package:cashier/constants/sizes.dart';
import 'package:cashier/model/cashier_db.dart';
import 'package:cashier/model/history.dart';
import 'package:cashier/model/person.dart';
import 'package:cashier/utils/fucntions.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

// ignore: must_be_immutable
class AddHistoryScreen extends StatelessWidget {
  final CashierDB db;
  final Person person;
  final Function showMessage;
  final TextEditingController currencyController;
  final TextEditingController _outgoingController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: today(),
  );

  AddHistoryScreen({
    super.key,
    required this.db,
    required this.person,
    required this.showMessage,
    required this.currencyController,
  }) {
    initialCurrency = currencyController.text;
  }

  String initialCurrency = "";

  Future<void> _addHistory() async {
    int outgoing = toInt(_outgoingController.text);
    int income = toInt(_incomeController.text);
    String date = _dateController.text;
    String currency = currencyController.text;
    String comment = _commentController.text;

    Map<String, dynamic> history = {
      CashierDB.personHistoryId: person.id,
      CashierDB.historyOutgoing: outgoing,
      CashierDB.historyIncome: income,
      CashierDB.historyTimestamp: toTimestamp(date),
      CashierDB.historyCurrency: currency,
      CashierDB.historyComment: comment,
    };

    await db.createHistory(History.fromJSON(history));

    if (person.balance!.containsKey(currency)) {
      person.balance?[currency]["outgoing"] =
          person.balance?[currency]["outgoing"] + outgoing;
      person.balance?[currency]["income"] =
          person.balance?[currency]["income"] + income;
    } else {
      person.balance?[currency] = {"outgoing": outgoing, "income": income};
    }

    await db.editPerson(person);

    showMessage(message: "History successfully created");
  }

  @override
  Widget build(BuildContext context) {
    double dHeight = MediaQuery.of(context).size.height;
    double dWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: fgColor,
          foregroundColor: bgColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  person.name!,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(UniconsLine.angle_left_b, size: 32),
            onPressed: () {
              currencyController.text = initialCurrency;

              Navigator.of(context).pop();
            },
          ),
        ),
        bottomNavigationBar: const BottomBar(),
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: FloatingActionButton(
            elevation: 3,
            tooltip: "Confirm",
            backgroundColor: greenColor,
            foregroundColor: fgColor,
            onPressed: () {
              if (_outgoingController.text == "") {
                _outgoingController.text = "0";
              }
              if (_incomeController.text == "") {
                _incomeController.text = "0";
              }

              _addHistory();

              Navigator.of(context).pop();
            },
            child: const Icon(UniconsLine.check, size: 28),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: SizedBox(
          width: dWidth,
          height: dHeight,
          child: Stack(
            children: <Widget>[
              Desk(
                height: normalDeskHeight,
                width: dWidth,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Card(
                      elevation: 3,
                      shape: softRect,
                      child: const Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Icon(UniconsLine.bill, color: fgColor, size: 44),
                      ),
                    ),
                  ),
                ],
              ),
              ListView(
                padding: normalDeskPadding,
                children: <Widget>[
                  Input(
                    controller: _outgoingController,
                    color: yellowColor,
                    placeholder: "Outging",
                    icon: UniconsLine.money_insert,
                    inputType: TextInputType.number,
                  ),
                  Input(
                    controller: _incomeController,
                    color: greenColor,
                    placeholder: "Income",
                    icon: UniconsLine.money_withdraw,
                    inputType: TextInputType.number,
                  ),
                  Input(
                    controller: _dateController,
                    color: greyColor,
                    placeholder: "Date",
                    icon: UniconsLine.calendar_alt,
                    inputType: TextInputType.datetime,
                    readOnly: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: CurrencyInput(controller: currencyController),
                  ),
                  Input(
                    controller: _commentController,
                    color: greyColor,
                    placeholder: "Comment",
                    icon: UniconsLine.comment_alt_lines,
                    inputType: TextInputType.multiline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class EditHistoryScreen extends StatelessWidget {
  final CashierDB db;
  final Person person;
  final History history;
  final Function showMessage;
  final TextEditingController currencyController;
  final TextEditingController _outgoingController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  EditHistoryScreen({
    super.key,
    required this.db,
    required this.person,
    required this.history,
    required this.showMessage,
    required this.currencyController,
  }) {
    _outgoingController.text = humanizedNumber(history.outgoing.toString());
    _incomeController.text = humanizedNumber(history.income.toString());
    _dateController.text = getDate(toDate(history.timestamp));
    _commentController.text = history.comment!;
  }

  Future<void> _editHistory() async {
    String currency = currencyController.text;
    String comment = _commentController.text;
    int outgoing = toInt(_outgoingController.text);
    int income = toInt(_incomeController.text);
    int outgoingDelta = outgoing - history.outgoing!;
    int incomeDelta = income - history.income!;
    Map currBalance = person.balance?[history.currency];

    if (currency == history.currency) {
      currBalance["outgoing"] = currBalance["outgoing"] + outgoingDelta;
      currBalance["income"] = currBalance["income"] + incomeDelta;
    } else {
      currBalance["outgoing"] = currBalance["outgoing"] - history.outgoing;
      currBalance["income"] = currBalance["income"] - history.income;

      if (person.balance!.containsKey(currency)) {
        Map otherBalance = person.balance?[currency];

        otherBalance["outgoing"] = otherBalance["outgoing"] + outgoing;
        otherBalance["income"] = otherBalance["income"] + income;
      } else {
        person.balance?[currency] = {"outgoing": outgoing, "income": income};
      }
    }

    history.outgoing = outgoing;
    history.income = income;
    history.currency = currency;
    history.comment = comment;
    history.timestamp = toTimestamp(_dateController.text);

    await db.editHistory(history);
    await db.editPerson(person);

    showMessage(message: "History successfully changed");
  }

  Future<void> _deleteHistory() async {
    Map currBalance = person.balance?[history.currency];

    currBalance["outgoing"] = currBalance["outgoing"] - history.outgoing;
    currBalance["income"] = currBalance["income"] - history.income;

    await db.deleteHistory(history.id!);
    await db.editPerson(person);

    showMessage(message: "History successfully deleted");
  }

  Future<void> _deleteDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 3,
          title: const Text("History is deleting!"),
          content: const Text("Are you sure?"),
          actionsAlignment: MainAxisAlignment.spaceAround,
          titleTextStyle: TextStyle(
            fontFamily: "FontMain",
            fontWeight: FontWeight.w600,
            fontSize: 22.0,
            color: Colors.red[900],
          ),
          contentTextStyle: const TextStyle(
            fontFamily: "FontMain",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                backgroundColor: redColor,
                textStyle: const TextStyle(
                  fontFamily: "FontMain",
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text("Delete"),
              onPressed: () {
                _deleteHistory();

                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                backgroundColor: blueColor,
                foregroundColor: fgColor,
                textStyle: const TextStyle(
                  fontFamily: "FontMain",
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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
              currencyController.text = history.currency!;

              Navigator.of(context).pop();
            },
          ),
        ),
        bottomNavigationBar: const BottomBar(),
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: SizedBox(
            width: dWidth / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton(
                  elevation: 3,
                  tooltip: "Delete History",
                  heroTag: "delete",
                  backgroundColor: redColor,
                  foregroundColor: fgColor,
                  onPressed: () => _deleteDialog(context),
                  child: const Icon(UniconsLine.trash_alt, size: 28),
                ),
                FloatingActionButton(
                  elevation: 3,
                  tooltip: "Confirm",
                  heroTag: "confirm",
                  backgroundColor: greenColor,
                  foregroundColor: fgColor,
                  onPressed: () {
                    if (_outgoingController.text == "") {
                      _outgoingController.text = "0";
                    }
                    if (_incomeController.text == "") {
                      _incomeController.text = "0";
                    }

                    _editHistory();

                    Navigator.of(context).pop();
                  },
                  child: const Icon(UniconsLine.check, size: 28),
                ),
              ],
            ),
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

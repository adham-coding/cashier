import 'package:cashier/components/bottom_bar.dart';
import 'package:cashier/components/desk.dart';
import 'package:cashier/components/input.dart';
import 'package:cashier/components/currency_dropdown.dart';
import 'package:cashier/components/balance.dart';
import 'package:cashier/components/card_history.dart';
import 'package:cashier/constants/colors.dart';
import 'package:cashier/constants/sizes.dart';
import 'package:cashier/model/cashier_db.dart';
import 'package:cashier/model/history.dart';
import 'package:cashier/model/person.dart';
import 'package:cashier/screens/add_history_screen.dart';
import 'package:cashier/screens/edit_history_screen.dart';
import 'package:cashier/screens/edit_person_screen.dart';
import 'package:cashier/utils/fucntions.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class HistoryScreen extends StatefulWidget {
  final CashierDB db;
  final Person person;
  final Function showMessage;
  final TextEditingController currencyController;

  const HistoryScreen({
    super.key,
    required this.db,
    required this.person,
    required this.showMessage,
    required this.currencyController,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Map<String, int> filtered = {"outgoing": 0, "income": 0};

  Future<List<History>> _getHistory() async {
    if (_startDateController.text.isEmpty && _endDateController.text.isEmpty) {
      List<History> histories = await widget.db.getHistories(
        widget.person.id!,
        widget.currencyController.text,
      );

      filtered = {"outgoing": 0, "income": 0};

      return histories;
    } else {
      String startDate = _startDateController.text.isEmpty
          ? "2000-01-01"
          : _startDateController.text;

      String endDate = _endDateController.text.isEmpty
          ? "2100-01-01"
          : _endDateController.text;

      List<History> histories = await widget.db.filterHistories(
        widget.person.id!,
        widget.currencyController.text,
        toTimestamp(startDate),
        toTimestamp(endDate),
      );

      filtered = histories.fold(
        {"outgoing": 0, "income": 0},
        (total, History history) {
          return {
            "outgoing": total["outgoing"]! + history.outgoing!,
            "income": total["income"]! + history.income!,
          };
        },
      );

      return histories;
    }
  }

  void _stateRefresher() => setState(() {});

  Future<void> _filterDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 3,
          title: const Text("Date Filter"),
          actionsAlignment: MainAxisAlignment.spaceAround,
          titleTextStyle: const TextStyle(
            fontFamily: "FontMain",
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Input>[
              Input(
                color: greyColor,
                placeholder: "Start",
                icon: UniconsLine.calendar_alt,
                controller: _startDateController,
                inputType: TextInputType.datetime,
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 16.0,
                ),
              ),
              Input(
                  color: greyColor,
                  placeholder: "End",
                  icon: UniconsLine.calendar_alt,
                  controller: _endDateController,
                  inputType: TextInputType.datetime,
                  readOnly: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  )),
            ],
          ),
          contentTextStyle: const TextStyle(
            fontFamily: "FontMain",
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                shape: softRect,
                backgroundColor: redColor,
                textStyle: const TextStyle(
                  fontFamily: "FontMain",
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text("Clear"),
              onPressed: () {
                _startDateController.text = "";
                _endDateController.text = "";
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                shape: softRect,
                backgroundColor: greenColor,
                foregroundColor: fgColor,
                textStyle: const TextStyle(
                  fontFamily: "FontMain",
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text("Filter"),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CurrencyDropdown(
                db: widget.db,
                controller: widget.currencyController,
                stateRefresher: _stateRefresher,
              ),
              Expanded(
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          widget.person.name!,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: "Edit Person",
                      icon: const Icon(UniconsLine.user, size: 28),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return EditPersonScreen(
                              db: widget.db,
                              person: widget.person,
                              showMessage: widget.showMessage,
                            );
                          }),
                        ).then((value) => setState(() {}));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          leading: IconButton(
            tooltip: "Back",
            icon: const Icon(UniconsLine.angle_left_b, size: 32),
            onPressed: () => Navigator.of(context).pop(),
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
                  tooltip: "Filter History",
                  heroTag: "filter",
                  backgroundColor: blueColor,
                  foregroundColor: fgColor,
                  onPressed: () {
                    _filterDialog(context).then((value) => setState(() {}));
                  },
                  child: const Icon(UniconsLine.filter, size: 28),
                ),
                FloatingActionButton(
                  elevation: 3,
                  tooltip: "Add History",
                  heroTag: "addHistory",
                  backgroundColor: greenColor,
                  foregroundColor: fgColor,
                  child: const Icon(UniconsLine.plus, size: 28),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return AddHistoryScreen(
                          db: widget.db,
                          person: widget.person,
                          showMessage: widget.showMessage,
                          currencyController: widget.currencyController,
                        );
                      }),
                    ).then((value) => setState(() {}));
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: SizedBox(
          width: dWidth,
          height: dHeight,
          child: FutureBuilder(
            future: _getHistory(),
            initialData: const <History>[],
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              String currency = widget.currencyController.text;

              if (snapshot.connectionState == ConnectionState.waiting ||
                  currency == "") {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation(fgColor),
                  ),
                );
              }

              List<dynamic>? futureHistory = snapshot.data;

              if (futureHistory == null ||
                  futureHistory.isEmpty ||
                  !widget.person.balance!.containsKey(currency)) {
                return const Center(child: Text("No History found"));
              }

              return Stack(
                children: <Widget>[
                  ListView.builder(
                    itemCount: futureHistory.length,
                    itemBuilder: (BuildContext context, int i) {
                      return CardHistory(
                        history: futureHistory[i],
                        button: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            padding: EdgeInsets.zero,
                            backgroundColor: yellowColor,
                            foregroundColor: fgColor,
                            shape: softRect,
                          ),
                          child: const Icon(UniconsLine.pen),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return EditHistoryScreen(
                                    db: widget.db,
                                    person: widget.person,
                                    history: futureHistory[i],
                                    showMessage: widget.showMessage,
                                    currencyController:
                                        widget.currencyController,
                                  );
                                },
                              ),
                            ).then((value) => setState(() {}));
                          },
                        ),
                      );
                    },
                    padding: const EdgeInsets.fromLTRB(
                      listPaddingX,
                      listPaddingY + normalDeskHeight,
                      listPaddingX,
                      listPaddingY,
                    ),
                  ),
                  Desk(
                    height: normalDeskHeight,
                    width: dWidth,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 3,
                          shape: softRect,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    for (String text in <String>[
                                      "Outgoing",
                                      "Income",
                                      "Remain",
                                    ])
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            text,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                                _startDateController.text.isNotEmpty ||
                                        _endDateController.text.isNotEmpty
                                    ? Opacity(
                                        opacity: 0.5,
                                        child: Balance(
                                          outgoing:
                                              widget.person.balance?[currency]
                                                      ["outgoing"] -
                                                  filtered["outgoing"]!,
                                          income:
                                              widget.person.balance?[currency]
                                                      ["income"] -
                                                  filtered["income"]!,
                                        ),
                                      )
                                    : Container(),
                                _startDateController.text.isNotEmpty ||
                                        _endDateController.text.isNotEmpty
                                    ? Balance(
                                        outgoing: filtered["outgoing"]!,
                                        income: filtered["income"]!,
                                      )
                                    : Container(),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green[200],
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100.0),
                                    ),
                                  ),
                                  child: Balance(
                                    outgoing: widget.person.balance?[currency]
                                        ["outgoing"],
                                    income: widget.person.balance?[currency]
                                        ["income"],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

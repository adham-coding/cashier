import 'package:cashier/components/bottom_bar.dart';
import 'package:cashier/components/currency_dropdown.dart';
import 'package:cashier/components/balance.dart';
import 'package:cashier/components/desk.dart';
import 'package:cashier/components/card_person.dart';
import 'package:cashier/constants/colors.dart';
import 'package:cashier/constants/sizes.dart';
import 'package:cashier/model/cashier_db.dart';
import 'package:cashier/model/config.dart';
import 'package:cashier/model/person.dart';
import 'package:cashier/screens/add_person_screen.dart';
import 'package:cashier/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CashierDB db = CashierDB.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _getConfig();
  }

  Map<String, int> balance = {"outgoing": 0, "income": 0};
  String searchQuery = "";

  void _showMessage({String? message, String? type}) {
    Color? color = Colors.green[700];

    switch (type) {
      case "warning":
        color = Colors.amber[800];
        break;
      case "danger":
        color = Colors.red[700];
        break;
    }

    final snackBar = SnackBar(
      elevation: 3,
      showCloseIcon: true,
      content: Text(message!),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: softRect,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _getConfig() async {
    Config config = await db.getConfig();

    _currencyController.text = config.currency!;

    _stateRefresher();
  }

  Future<List<Person>> _getPersons() async {
    String currency = _currencyController.text;
    List<Person> persons;

    if (searchQuery.isEmpty) {
      persons = await db.getPersons(currency);

      balance = persons.fold(
        {"outgoing": 0, "income": 0},
        (total, Person person) {
          return {
            "outgoing": total["outgoing"]! +
                person.balance?[currency]["outgoing"] as int,
            "income":
                total["income"]! + person.balance?[currency]["income"] as int,
          };
        },
      );
    } else {
      persons = await db.searchPersons(searchQuery, currency);
    }

    return persons;
  }

  void _stateRefresher() => setState(() {});

  @override
  Widget build(BuildContext context) {
    double dWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: fgColor,
          foregroundColor: bgColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text("Cashier", style: TextStyle(fontSize: 18.0)),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currencyController.text != ""
                        ? CurrencyDropdown(
                            db: db,
                            controller: _currencyController,
                            stateRefresher: _stateRefresher,
                          )
                        : const Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation(bgColor),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 36.0,
                      width: 175.0,
                      child: Material(
                        elevation: 3,
                        shape: softRect,
                        child: TextField(
                          autofocus: false,
                          style: const TextStyle(
                            fontFamily: "FontMain",
                            color: fgColor,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: greyColor,
                            hintText: "Search",
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(100, 44, 52, 94),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 0.0,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            suffixIcon: const Icon(UniconsLine.search),
                            suffixIconColor: fgColor,
                          ),
                          controller: _searchController,
                          onChanged: (name) {
                            setState(() => searchQuery = name);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: const BottomBar(),
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: FloatingActionButton(
            elevation: 3,
            backgroundColor: greenColor,
            foregroundColor: fgColor,
            tooltip: "Add Person",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return AddPersonScreen(
                    db: db,
                    showMessage: _showMessage,
                    currencyController: _currencyController,
                  );
                }),
              ).then((value) => setState(() {}));
            },
            child: const Icon(UniconsLine.user_plus, size: 28),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: FutureBuilder(
          future: _getPersons(),
          initialData: const <Person>[],
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            String currency = _currencyController.text;

            if (snapshot.connectionState == ConnectionState.waiting ||
                currency == "") {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation(fgColor),
                ),
              );
            }

            List<dynamic>? futurePersons = snapshot.data;

            if (futurePersons == null || futurePersons.isEmpty) {
              return const Center(child: Text("No Person found"));
            }

            return Stack(
              children: <Widget>[
                ListView.builder(
                  itemCount: futurePersons.length,
                  itemBuilder: (BuildContext context, int i) {
                    if (!futurePersons[i].balance.containsKey(currency)) {
                      return null;
                    }

                    return CardPerson(
                      person: futurePersons[i],
                      currency: currency,
                      button: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          padding: EdgeInsets.zero,
                          backgroundColor: yellowColor,
                          foregroundColor: fgColor,
                          shape: softRect,
                        ),
                        child: const Icon(UniconsLine.user),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return HistoryScreen(
                                  db: db,
                                  person: futurePersons[i],
                                  showMessage: _showMessage,
                                  currencyController: _currencyController,
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
                    listPaddingY + smallDeskHeight,
                    listPaddingX,
                    listPaddingY,
                  ),
                ),
                Desk(
                  height: smallDeskHeight,
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
                              Balance(
                                outgoing: balance["outgoing"]!,
                                income: balance["income"]!,
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
    );
  }
}

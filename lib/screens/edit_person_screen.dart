import 'package:cashier/components/bottom_bar.dart';
import 'package:cashier/components/desk.dart';
import 'package:cashier/components/input.dart';
import 'package:cashier/constants/colors.dart';
import 'package:cashier/constants/sizes.dart';
import 'package:cashier/model/cashier_db.dart';
import 'package:cashier/model/person.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditPersonScreen extends StatelessWidget {
  final CashierDB db;
  final Person person;
  final Function showMessage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  EditPersonScreen({
    super.key,
    required this.db,
    required this.person,
    required this.showMessage,
  }) {
    _nameController.text = person.name!;
    _phoneController.text = person.phone!;
  }

  Future<void> _editPerson() async {
    person.name = _nameController.text;
    person.phone = _phoneController.text;

    await db.editPerson(person);

    showMessage(message: "Person successfully changed");
  }

  Future<void> _deletePerson() async {
    await db.deletePerson(person.id!);

    showMessage(message: "Person successfully deleted");
  }

  Future<void> _deleteDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 3,
          title: const Text("Person is deleting!"),
          actionsAlignment: MainAxisAlignment.spaceAround,
          titleTextStyle: TextStyle(
            fontFamily: "FontMain",
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
            color: Colors.red[900],
          ),
          content: const Text("Are you sure?"),
          contentTextStyle: const TextStyle(
            fontFamily: "FontMain",
            fontSize: 18.0,
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
                _deletePerson();

                Navigator.of(context)
                  ..pop()
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
                  tooltip: "Delete Person",
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
                    if (_nameController.text == "") {
                      showMessage(
                        message: "Person name can't be empty!",
                        type: "danger",
                      );

                      return;
                    } else if (_nameController.text == person.name &&
                        _phoneController.text == person.phone) {
                      return Navigator.of(context).pop();
                    }

                    _editPerson();

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
                        child: Icon(UniconsLine.user, color: fgColor, size: 44),
                      ),
                    ),
                  ),
                ],
              ),
              ListView(
                padding: normalDeskPadding,
                children: <Widget>[
                  Input(
                    controller: _nameController,
                    color: greyColor,
                    placeholder: "Name",
                    icon: UniconsLine.user_square,
                  ),
                  Input(
                    controller: _phoneController,
                    color: blueColor,
                    placeholder: "Phone",
                    icon: UniconsLine.phone,
                    inputType: TextInputType.phone,
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

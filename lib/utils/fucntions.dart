import 'package:intl/intl.dart';

String humanizedNumber(String value) {
  return value.replaceAll(RegExp(r"\B(?=(\d{3})+(?!\d))"), " ");
}

int toInt(String value) => int.parse(value.replaceAll(" ", ""));

int toTimestamp(String date) => DateTime.parse(date).millisecondsSinceEpoch;

DateTime toDate(timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp);
}

String getDate(DateTime datetime) => datetime.toString().split(" ")[0];

String today() => getDate(DateTime.now());

String humanizedDate(int timestamp) {
  return DateFormat("d - MMMM, yyyy").format(toDate(timestamp));
}

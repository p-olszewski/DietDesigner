import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateProvider with ChangeNotifier {
  DateTime _date = DateTime.now();

  DateTime get date => _date;
  String get dateFormattedWithDots => DateFormat('dd.MM.yyyy').format(date);
  String get dateFormattedWithWords => DateFormat('EEEE, dd MMM').format(date);

  void setDate(DateTime date) {
    _date = date;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateProvider with ChangeNotifier {
  DateTime _date = DateTime.now();

  DateTime get date => _date;
  String get formattedDate => DateFormat('dd.MM.yyyy').format(date);

  void setDate(DateTime date) {
    _date = date;
    notifyListeners();
  }

  String getCurrentDate() => DateFormat('dd.MM.yyyy').format(DateTime.now());
}

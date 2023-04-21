import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateProvider with ChangeNotifier {
  String _date = '';

  String get date => _date;

  void setDate(DateTime date) {
    final String formattedDate = DateFormat('dd.MM.yyyy').format(date);
    _date = formattedDate;
    notifyListeners();
  }

  String getCurrentDate() => DateFormat('dd.MM.yyyy').format(DateTime.now());
}

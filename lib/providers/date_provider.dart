import 'package:flutter/material.dart';

class DateProvider with ChangeNotifier {
  String _date = '';

  String get date => _date;

  void setDate(String date) {
    _date = date;
    notifyListeners();
  }
}

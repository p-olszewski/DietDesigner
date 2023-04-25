import 'package:diet_designer/models/user.dart';
import 'package:flutter/material.dart';

class UserDataProvider with ChangeNotifier {
  late User _user;
  User get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}

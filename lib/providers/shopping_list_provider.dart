import 'package:flutter/material.dart';

class ShoppingListProvider with ChangeNotifier {
  String _listId = '';
  String _listTitle = '';

  String get listId => _listId;
  String get listTitle => _listTitle;

  void setListId(String listId) {
    _listId = listId;
    notifyListeners();
  }

  void setListTitle(String listTitle) {
    _listTitle = listTitle;
    notifyListeners();
  }
}

import 'package:diet_designer/services/firestore_service.dart';
import 'package:flutter/material.dart';

class ShoppingListProvider with ChangeNotifier {
  String _listId = '';
  String _listTitle = '';
  int _itemsCounter = 0;

  String get listId => _listId;
  String get listTitle => _listTitle;
  int get itemsCounter => _itemsCounter;

  void setListId(String listId) {
    _listId = listId;
    notifyListeners();
  }

  void setListTitle(String listTitle) {
    _listTitle = listTitle;
    notifyListeners();
  }

  void countItems(String listId) async {
    _itemsCounter = await countAndUpdateItemsCounter(listId);
    notifyListeners();
  }
}

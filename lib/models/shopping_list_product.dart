import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListProduct {
  String name;
  bool bought;
  FieldValue? timestamp;
  double order;

  ShoppingListProduct({required this.name, this.bought = false, this.timestamp, this.order = 0});

  ShoppingListProduct.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        bought = json['bought'],
        timestamp = json['timestamp'],
        order = json['order'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'bought': bought,
        'timestamp': FieldValue.serverTimestamp(),
        'order': order,
      };
}

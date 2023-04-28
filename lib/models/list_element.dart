import 'package:cloud_firestore/cloud_firestore.dart';

class ListElement {
  String name;
  bool bought;
  FieldValue? timestamp;
  double order;

  ListElement({required this.name, this.bought = false, this.timestamp, this.order = 0});

  ListElement.fromJson(Map<String, dynamic> json)
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

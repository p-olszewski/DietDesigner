import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:diet_designer/models/user.dart' as user_model;

final FirebaseFirestore _database = FirebaseFirestore.instance;
final String? _uid = FirebaseAuth.instance.currentUser?.uid;

Future<bool> checkUserHasCalculatedData() async {
  final userSnapshot = await _database.doc('users/$_uid').get();
  if (userSnapshot.data() == null || userSnapshot.data()!['hasCalculatedData'] != true) {
    Fluttertoast.showToast(msg: "You have no calculated data, go to calculator!");
    return false;
  } else {
    return true;
  }
}

// TODO: add bmr calculation
bool updateUserData(user_model.User user) {
  try {
    // update only non-null fields and set hasCalculatedData flag to true
    final Map<String, dynamic> data = user.toJson()..removeWhere((key, value) => value == null);
    data['hasCalculatedData'] = true;
    _database.doc('users/$_uid').update(data);
    return true;
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    return false;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> signIn(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      Fluttertoast.showToast(msg: 'This email address is not registered.');
    } else if (e.code == 'wrong-password') {
      Fluttertoast.showToast(msg: 'Wrong password.');
    }
    return false;
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    return false;
  }
}

Future<bool> signUp(String email, String password, String repeatedPassword) async {
  if (password != repeatedPassword) {
    Fluttertoast.showToast(msg: 'The passwords do not match.');
    return false;
  }
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      Fluttertoast.showToast(msg: 'The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      Fluttertoast.showToast(msg: 'The account already exists for that email.');
    }
    return false;
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    return false;
  }
}

Future<bool> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    return true;
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    return false;
  }
}

Future<bool> checkUserCalculatedCalories() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();

  if (userSnapshot.data() == null ||
      userSnapshot.data()!['calories'] == null ||
      userSnapshot.data()!['protein'] == null ||
      userSnapshot.data()!['carbs'] == null ||
      userSnapshot.data()!['fat'] == null ||
      userSnapshot.data()!['goal'] == null) {
    Fluttertoast.showToast(msg: "No data, go to calculator");
    return false;
  } else {
    return true;
  }
}

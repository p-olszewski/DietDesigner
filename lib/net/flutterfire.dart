import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> signIn(String email, String password) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return true;
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    return false;
  }
}

Future<bool> signUp(String email, String password) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
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

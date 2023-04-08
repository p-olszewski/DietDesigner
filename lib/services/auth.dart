import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<bool> signIn(String email, String password) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
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
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
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
    await _auth.signOut();
    return true;
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    return false;
  }
}

String? getUserId() {
  return _auth.currentUser?.uid;
}

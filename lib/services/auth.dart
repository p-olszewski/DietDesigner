import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<bool> signIn(String email, String password) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      PopupMessenger.error('This email address is not registered.');
    } else if (e.code == 'wrong-password') {
      PopupMessenger.error('Wrong password.');
    }
    return false;
  } catch (e) {
    PopupMessenger.error(e.toString());
    return false;
  }
}

Future<bool> signUp(String email, String password, String repeatedPassword) async {
  if (password != repeatedPassword) {
    PopupMessenger.error('The passwords do not match.');
    return false;
  }
  try {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      PopupMessenger.error('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      PopupMessenger.error('The account already exists for that email.');
    }
    return false;
  } catch (e) {
    PopupMessenger.error(e.toString());
    return false;
  }
}

Future<bool> signOut() async {
  try {
    await _auth.signOut();
    return true;
  } catch (e) {
    PopupMessenger.error(e.toString());
    return false;
  }
}

String? getUserId() {
  return _auth.currentUser?.uid;
}

import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider {
  final FirebaseAuth _firebaseAuth;
  AuthProvider(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  String? get uid => _firebaseAuth.currentUser?.uid;

  Future<bool> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
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

  Future<bool> signUp(
      String email, String password, String repeatedPassword) async {
    if (password != repeatedPassword) {
      PopupMessenger.error('The passwords do not match.');
      return false;
    }
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final bool isAddedCorrectly =
          await addUserDocument(userCredential.user!.uid, email);
      return isAddedCorrectly;
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
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      PopupMessenger.error(e.toString());
      return false;
    }
  }
}

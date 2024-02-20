import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthRouter {
  /// Returns a stream that listens to authentication state changes
  Stream<User?> authMonitor() {
    return FirebaseAuth.instance.authStateChanges();
  }

  bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Returns the users UID
  String getUserUID() {
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  ///Generates login credentials using email and password. If an error occurs the
  ///callback function is invoked.
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print(e);
      return null;
    }
  }

  void logout(BuildContext context) {
    // FirebaseAuth.instance.signOut();
    // Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(
    //       builder: (ctxt) => LandingPage()
    //     ),
    //         (route) => false);
  }

  /// Changes the user's password
  void changePassword(String password) async {
    await FirebaseAuth.instance.currentUser?.updatePassword(password);
  }

  /// Changes the user's email.
  void changeEmail(String email) async {
    await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:theraportal/Pages/LandingPage.dart';

class AuthRouter {
  // Returns a stream that listens to authentication state changes
  static Stream<User?> authMonitor() {
    return FirebaseAuth.instance.authStateChanges();
  }

  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  // Returns the users UID
  static String getUserUID() {
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  //Generates login credentials using email and password. If an error occurs the
  //callback function is invoked.
  static Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Object> registerUser(
      String emailAddress, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  static Future<void> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  static Future<bool> isVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  static void logoutAndNavigateHome(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (ctxt) => LandingPage()), (route) => false);
  }

  //Changes the user's password
  static void changePassword(String password) async {
    await FirebaseAuth.instance.currentUser?.updatePassword(password);
  }

  //Changes the user's email.
  static void changeEmail(String email) async {
    await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:theraportal/Pages/ApplicationPage.dart';
import 'package:theraportal/Pages/LandingPage.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Directionality(textDirection: TextDirection.ltr, child: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   future: Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform,
    //   ),
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // AuthRouter.logout();
        if (snapshot.hasError) {
          // Error occurred during initialization
          return Scaffold(
            body: Center(
              child: Text('Error initializing Firebase: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          //Firebase initialization is in progress
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          //Firebase initialized successfully
          //Check if the user is authenticated
          if (snapshot.hasData && snapshot.data!.emailVerified) {
            return MaterialApp(
              title: "TheraPortal",
              debugShowCheckedModeBanner: false,
              theme: themeStyle,
              home: ApplicationPage(),
            );
          } else {
            return MaterialApp(
              title: "TheraPortal",
              debugShowCheckedModeBanner: false,
              theme: themeStyle,
              home: LandingPage(),
            );
          }
        }
      },
    );
  }
}

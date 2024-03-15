import 'package:flutter/material.dart';
import 'package:theraportal/Pages/CommunicationPage.dart';
import 'package:theraportal/Pages/ExerciseTest.dart';
import 'package:theraportal/Pages/HomePage.dart';
import 'package:theraportal/Pages/LandingPage.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Error occurred during initialization
          return Scaffold(
            body: Center(
              child: Text('Error initializing Firebase: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Firebase initialized successfully
          // Check if the user is authenticated
          if (AuthRouter().isLoggedIn()) {
            return MaterialApp(
              title: "TheraPortal",
              debugShowCheckedModeBanner: false,
              theme: themeStyle,
              home: HomePage(),
            );
          } else {
            return MaterialApp(
              title: "TheraPortal",
              debugShowCheckedModeBanner: false,
              theme: themeStyle,
              home: LandingPage(),
            );
          }
        } else {
          // Firebase initialization is in progress
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

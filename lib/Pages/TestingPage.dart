import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Utilities/GoogleDriveRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      largeScreen: LargeScreen(),
    );
  }
}

class LargeScreen extends StatefulWidget {
  const LargeScreen({super.key});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  Uint8List? exerciseMedia; // Set an initial value
  GoogleDriveRouter router = GoogleDriveRouter();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Settings Page"),
          // ElevatedButton(
          // onPressed: () => AuthRouter.logout(), child: Text("logout")),
          ElevatedButton(
              onPressed: () {
                GoogleDriveRouter().listFiles();
              },
              child: Text("test function")),
        ],
      ),
    );
  }
}

class TestingPage extends StatelessWidget {
  static const Key pageKey = Key("Testing Page");

  const TestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
    );
  }
}

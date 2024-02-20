import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:theraportal/Utilities/GoogleDriveRouter.dart';
import '../Widgets/Widgets.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(),
    );
  }
}

class LargeScreen extends StatefulWidget {
  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  Uint8List? exerciseMedia; // Set an initial value
  GoogleDriveRouter router = GoogleDriveRouter();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return const Center(child: Text("PIZZA"));
  }
}

class TestingPage extends StatelessWidget {
  static const Key pageKey = Key("Testing Page");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}

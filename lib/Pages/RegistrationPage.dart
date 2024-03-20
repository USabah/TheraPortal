import 'package:flutter/material.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final Map<String, dynamic> userMap;
  const Body({super.key, required this.userMap});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(userMap: userMap),
    );
  }
}

class LargeScreen extends StatelessWidget {
  final Map<String, dynamic> userMap;
  const LargeScreen({super.key, required this.userMap});

  @override
  Widget build(BuildContext context) {
    return const Text("Registration Page");
  }
}

class RegistrationPage extends StatelessWidget {
  static const Key pageKey = Key("Registration Page");

  final Map<String, dynamic> userMap;

  const RegistrationPage({
    Key? key,
    required this.userMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Body(userMap: userMap),
    );
  }
}
